"""
Database management utilities for data ingestion.

Provides PostgreSQL connection management and common database operations.
"""

import logging
from contextlib import contextmanager
from typing import Any, Dict, List, Optional, Generator
from datetime import datetime

import psycopg2
from psycopg2.extras import RealDictCursor, execute_values
from psycopg2.pool import ThreadedConnectionPool
from sqlalchemy import create_engine, MetaData, Table, inspect
from sqlalchemy.orm import sessionmaker
from pydantic_settings import BaseSettings

logger = logging.getLogger(__name__)


class DatabaseConfig(BaseSettings):
    """Database configuration from environment variables."""

    database_url: str = "postgresql://localhost:5432/opendiscourse"
    pool_size: int = 5
    max_overflow: int = 10
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


class DatabaseManager:
    """Manage database connections and operations."""

    def __init__(self, database_url: Optional[str] = None):
        """
        Initialize database manager.

        Args:
            database_url: PostgreSQL connection URL
        """
        config = DatabaseConfig()
        self.database_url = database_url or config.database_url
        
        # Setup SQLAlchemy engine
        self.engine = create_engine(
            self.database_url,
            pool_size=config.pool_size,
            max_overflow=config.max_overflow,
            echo=False,
        )
        
        # Setup session maker
        self.SessionLocal = sessionmaker(
            autocommit=False,
            autoflush=False,
            bind=self.engine,
        )
        
        # Setup connection pool for psycopg2
        self._init_connection_pool()
        
        logger.info(f"Database manager initialized: {self._mask_url(self.database_url)}")

    def _mask_url(self, url: str) -> str:
        """Mask password in database URL for logging."""
        if "@" in url:
            prefix, suffix = url.split("@", 1)
            if ":" in prefix:
                prefix_parts = prefix.split(":")
                prefix_parts[-1] = "****"
                prefix = ":".join(prefix_parts)
            return f"{prefix}@{suffix}"
        return url

    def _init_connection_pool(self):
        """Initialize psycopg2 connection pool."""
        try:
            self.pool = ThreadedConnectionPool(
                minconn=1,
                maxconn=10,
                dsn=self.database_url,
            )
            logger.info("Connection pool initialized")
        except Exception as e:
            logger.error(f"Failed to initialize connection pool: {e}")
            raise

    @contextmanager
    def get_connection(self) -> Generator[psycopg2.extensions.connection, None, None]:
        """
        Get database connection from pool.

        Yields:
            Database connection
        """
        conn = self.pool.getconn()
        try:
            yield conn
        finally:
            self.pool.putconn(conn)

    @contextmanager
    def get_cursor(self, dict_cursor: bool = True) -> Generator:
        """
        Get database cursor.

        Args:
            dict_cursor: Whether to use RealDictCursor

        Yields:
            Database cursor
        """
        with self.get_connection() as conn:
            cursor_factory = RealDictCursor if dict_cursor else None
            cursor = conn.cursor(cursor_factory=cursor_factory)
            try:
                yield cursor
                conn.commit()
            except Exception as e:
                conn.rollback()
                logger.error(f"Database error: {e}")
                raise
            finally:
                cursor.close()

    @contextmanager
    def get_session(self):
        """
        Get SQLAlchemy session.

        Yields:
            SQLAlchemy session
        """
        session = self.SessionLocal()
        try:
            yield session
            session.commit()
        except Exception as e:
            session.rollback()
            logger.error(f"Database session error: {e}")
            raise
        finally:
            session.close()

    def execute_query(
        self,
        query: str,
        params: Optional[tuple] = None,
        fetch: bool = False,
    ) -> Optional[List[Dict[str, Any]]]:
        """
        Execute SQL query.

        Args:
            query: SQL query
            params: Query parameters
            fetch: Whether to fetch results

        Returns:
            Query results if fetch=True, else None
        """
        with self.get_cursor() as cursor:
            cursor.execute(query, params)
            if fetch:
                return cursor.fetchall()
        return None

    def bulk_insert(
        self,
        table: str,
        columns: List[str],
        values: List[tuple],
        on_conflict: Optional[str] = None,
    ) -> int:
        """
        Bulk insert records into table.

        Args:
            table: Table name
            columns: Column names
            values: List of value tuples
            on_conflict: ON CONFLICT clause (e.g., "DO NOTHING")

        Returns:
            Number of rows inserted
        """
        if not values:
            return 0

        columns_str = ", ".join(columns)
        conflict_clause = f" ON CONFLICT {on_conflict}" if on_conflict else ""
        
        query = f"""
            INSERT INTO {table} ({columns_str})
            VALUES %s
            {conflict_clause}
        """

        with self.get_cursor(dict_cursor=False) as cursor:
            execute_values(cursor, query, values)
            return cursor.rowcount

    def upsert(
        self,
        table: str,
        columns: List[str],
        values: List[tuple],
        conflict_columns: List[str],
        update_columns: Optional[List[str]] = None,
    ) -> int:
        """
        Upsert (insert or update) records.

        Args:
            table: Table name
            columns: Column names
            values: List of value tuples
            conflict_columns: Columns to check for conflicts
            update_columns: Columns to update on conflict (defaults to all except conflict columns)

        Returns:
            Number of rows affected
        """
        if not values:
            return 0

        if update_columns is None:
            update_columns = [col for col in columns if col not in conflict_columns]

        columns_str = ", ".join(columns)
        conflict_str = ", ".join(conflict_columns)
        update_str = ", ".join([f"{col} = EXCLUDED.{col}" for col in update_columns])

        query = f"""
            INSERT INTO {table} ({columns_str})
            VALUES %s
            ON CONFLICT ({conflict_str})
            DO UPDATE SET {update_str}
        """

        with self.get_cursor(dict_cursor=False) as cursor:
            execute_values(cursor, query, values)
            return cursor.rowcount

    def table_exists(self, table_name: str, schema: str = "public") -> bool:
        """
        Check if table exists.

        Args:
            table_name: Table name
            schema: Schema name

        Returns:
            True if table exists
        """
        query = """
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_schema = %s 
                AND table_name = %s
            )
        """
        result = self.execute_query(query, (schema, table_name), fetch=True)
        return result[0]["exists"] if result else False

    def create_table_from_sql(self, sql: str):
        """
        Create table from SQL statement.

        Args:
            sql: CREATE TABLE SQL statement
        """
        self.execute_query(sql)
        logger.info("Table created successfully")

    def get_table_info(self, table_name: str) -> Dict[str, Any]:
        """
        Get table information.

        Args:
            table_name: Table name

        Returns:
            Table information dictionary
        """
        inspector = inspect(self.engine)
        
        if not inspector.has_table(table_name):
            raise ValueError(f"Table {table_name} does not exist")
        
        columns = inspector.get_columns(table_name)
        pk_constraint = inspector.get_pk_constraint(table_name)
        indexes = inspector.get_indexes(table_name)
        
        return {
            "columns": columns,
            "primary_key": pk_constraint,
            "indexes": indexes,
        }

    def count_records(self, table: str, where: Optional[str] = None) -> int:
        """
        Count records in table.

        Args:
            table: Table name
            where: Optional WHERE clause

        Returns:
            Number of records
        """
        query = f"SELECT COUNT(*) as count FROM {table}"
        if where:
            query += f" WHERE {where}"
        
        result = self.execute_query(query, fetch=True)
        return result[0]["count"] if result else 0

    def close(self):
        """Close all database connections."""
        if hasattr(self, "pool"):
            self.pool.closeall()
            logger.info("Connection pool closed")
        
        if hasattr(self, "engine"):
            self.engine.dispose()
            logger.info("SQLAlchemy engine disposed")
