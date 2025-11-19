"""
Database operations tools for AI agents.

Provides database query execution, record manipulation, and schema inspection
for various database systems (SQLite, PostgreSQL, MySQL, MongoDB, Redis).

Note: Requires optional database dependencies. Install with:
    pip install openai-tools[database]
"""

from typing import Any, Dict, List, Optional, Union


def execute_query(
    connection_string: str,
    query: str,
    parameters: Optional[Dict[str, Any]] = None,
    fetch: bool = True,
) -> Union[List[Dict[str, Any]], int]:
    """
    Execute a SQL query against a database.
    
    Args:
        connection_string: Database connection string (e.g., sqlite:///path/to/db.db, postgresql://user:pass@host/db)
        query: SQL query to execute
        parameters: Optional dictionary of parameters for parameterized queries
        fetch: Whether to fetch and return results (default: True)
        
    Returns:
        List of result rows as dictionaries if fetch=True, otherwise row count
        
    Raises:
        ImportError: If database driver is not installed
        Exception: If query execution fails
    """
    try:
        from sqlalchemy import create_engine, text
    except ImportError:
        raise ImportError(
            "SQLAlchemy is required for database operations. "
            "Install with: pip install openai-tools[database]"
        )
    
    engine = create_engine(connection_string)
    
    with engine.connect() as connection:
        result = connection.execute(text(query), parameters or {})
        
        if fetch:
            # Fetch results
            rows = result.fetchall()
            columns = result.keys()
            return [dict(zip(columns, row)) for row in rows]
        else:
            # Return row count for non-SELECT queries
            connection.commit()
            return result.rowcount


def insert_record(
    connection_string: str,
    table: str,
    record: Dict[str, Any],
) -> str:
    """
    Insert a record into a database table.
    
    Args:
        connection_string: Database connection string
        table: Name of the table to insert into
        record: Dictionary of column names to values
        
    Returns:
        Success message with the number of rows inserted
        
    Raises:
        ImportError: If database driver is not installed
        Exception: If insert fails
    """
    try:
        from sqlalchemy import create_engine, text
    except ImportError:
        raise ImportError(
            "SQLAlchemy is required for database operations. "
            "Install with: pip install openai-tools[database]"
        )
    
    engine = create_engine(connection_string)
    
    columns = ", ".join(record.keys())
    placeholders = ", ".join([f":{key}" for key in record.keys()])
    query = f"INSERT INTO {table} ({columns}) VALUES ({placeholders})"
    
    with engine.connect() as connection:
        result = connection.execute(text(query), record)
        connection.commit()
        return f"Inserted {result.rowcount} record(s) into {table}"


def update_record(
    connection_string: str,
    table: str,
    updates: Dict[str, Any],
    condition: str,
    parameters: Optional[Dict[str, Any]] = None,
) -> str:
    """
    Update records in a database table.
    
    Args:
        connection_string: Database connection string
        table: Name of the table to update
        updates: Dictionary of column names to new values
        condition: WHERE clause condition (without WHERE keyword)
        parameters: Optional parameters for the WHERE clause
        
    Returns:
        Success message with the number of rows updated
        
    Raises:
        ImportError: If database driver is not installed
        Exception: If update fails
    """
    try:
        from sqlalchemy import create_engine, text
    except ImportError:
        raise ImportError(
            "SQLAlchemy is required for database operations. "
            "Install with: pip install openai-tools[database]"
        )
    
    engine = create_engine(connection_string)
    
    set_clause = ", ".join([f"{key} = :update_{key}" for key in updates.keys()])
    query = f"UPDATE {table} SET {set_clause} WHERE {condition}"
    
    # Combine parameters
    all_params = {f"update_{k}": v for k, v in updates.items()}
    if parameters:
        all_params.update(parameters)
    
    with engine.connect() as connection:
        result = connection.execute(text(query), all_params)
        connection.commit()
        return f"Updated {result.rowcount} record(s) in {table}"


def delete_record(
    connection_string: str,
    table: str,
    condition: str,
    parameters: Optional[Dict[str, Any]] = None,
) -> str:
    """
    Delete records from a database table.
    
    Args:
        connection_string: Database connection string
        table: Name of the table to delete from
        condition: WHERE clause condition (without WHERE keyword)
        parameters: Optional parameters for the WHERE clause
        
    Returns:
        Success message with the number of rows deleted
        
    Raises:
        ImportError: If database driver is not installed
        Exception: If delete fails
    """
    try:
        from sqlalchemy import create_engine, text
    except ImportError:
        raise ImportError(
            "SQLAlchemy is required for database operations. "
            "Install with: pip install openai-tools[database]"
        )
    
    engine = create_engine(connection_string)
    
    query = f"DELETE FROM {table} WHERE {condition}"
    
    with engine.connect() as connection:
        result = connection.execute(text(query), parameters or {})
        connection.commit()
        return f"Deleted {result.rowcount} record(s) from {table}"


def list_tables(connection_string: str) -> List[str]:
    """
    List all tables in a database.
    
    Args:
        connection_string: Database connection string
        
    Returns:
        List of table names
        
    Raises:
        ImportError: If database driver is not installed
        Exception: If listing tables fails
    """
    try:
        from sqlalchemy import create_engine, inspect
    except ImportError:
        raise ImportError(
            "SQLAlchemy is required for database operations. "
            "Install with: pip install openai-tools[database]"
        )
    
    engine = create_engine(connection_string)
    inspector = inspect(engine)
    return inspector.get_table_names()


def get_table_schema(connection_string: str, table: str) -> List[Dict[str, Any]]:
    """
    Get the schema (column definitions) of a table.
    
    Args:
        connection_string: Database connection string
        table: Name of the table
        
    Returns:
        List of dictionaries containing column information
        
    Raises:
        ImportError: If database driver is not installed
        Exception: If getting schema fails
    """
    try:
        from sqlalchemy import create_engine, inspect
    except ImportError:
        raise ImportError(
            "SQLAlchemy is required for database operations. "
            "Install with: pip install openai-tools[database]"
        )
    
    engine = create_engine(connection_string)
    inspector = inspect(engine)
    columns = inspector.get_columns(table)
    
    return [
        {
            "name": col["name"],
            "type": str(col["type"]),
            "nullable": col.get("nullable", True),
            "default": col.get("default"),
            "primary_key": col.get("primary_key", False),
        }
        for col in columns
    ]


# MongoDB operations (optional)
def mongodb_find(
    connection_string: str,
    database: str,
    collection: str,
    query: Dict[str, Any],
    limit: int = 100,
) -> List[Dict[str, Any]]:
    """
    Find documents in a MongoDB collection.
    
    Args:
        connection_string: MongoDB connection string
        database: Database name
        collection: Collection name
        query: Query filter as a dictionary
        limit: Maximum number of documents to return (default: 100)
        
    Returns:
        List of matching documents
        
    Raises:
        ImportError: If pymongo is not installed
    """
    try:
        from pymongo import MongoClient
    except ImportError:
        raise ImportError(
            "PyMongo is required for MongoDB operations. "
            "Install with: pip install openai-tools[database]"
        )
    
    client = MongoClient(connection_string)
    db = client[database]
    coll = db[collection]
    
    results = list(coll.find(query).limit(limit))
    
    # Convert ObjectId to string for JSON serialization
    for doc in results:
        if "_id" in doc:
            doc["_id"] = str(doc["_id"])
    
    return results


def mongodb_insert(
    connection_string: str,
    database: str,
    collection: str,
    document: Dict[str, Any],
) -> str:
    """
    Insert a document into a MongoDB collection.
    
    Args:
        connection_string: MongoDB connection string
        database: Database name
        collection: Collection name
        document: Document to insert as a dictionary
        
    Returns:
        Success message with inserted document ID
        
    Raises:
        ImportError: If pymongo is not installed
    """
    try:
        from pymongo import MongoClient
    except ImportError:
        raise ImportError(
            "PyMongo is required for MongoDB operations. "
            "Install with: pip install openai-tools[database]"
        )
    
    client = MongoClient(connection_string)
    db = client[database]
    coll = db[collection]
    
    result = coll.insert_one(document)
    return f"Inserted document with ID: {result.inserted_id}"


__all__ = [
    "execute_query",
    "insert_record",
    "update_record",
    "delete_record",
    "list_tables",
    "get_table_schema",
    "mongodb_find",
    "mongodb_insert",
]
