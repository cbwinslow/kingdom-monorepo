#!/usr/bin/env python3
"""
Ingest Congressional Record (CREC) data from GovInfo.gov API.

This script fetches Congressional Record packages and granules for a specified
date range and stores them in a PostgreSQL database with progress reporting.
"""

import argparse
import json
import logging
import os
import sys
from datetime import datetime, timedelta
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from lib.govinfo_client import GovInfoClient
from lib.database import DatabaseManager
from lib.progress import ProgressReporter
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)


def create_tables(db_manager: DatabaseManager):
    """Create database tables if they don't exist."""
    
    # Congressional Record packages table
    packages_sql = """
    CREATE TABLE IF NOT EXISTS govinfo_crec_packages (
        package_id VARCHAR(255) PRIMARY KEY,
        title TEXT,
        date_issued DATE,
        last_modified TIMESTAMP,
        package_link TEXT,
        granules_link TEXT,
        congress INTEGER,
        session INTEGER,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    CREATE INDEX IF NOT EXISTS idx_crec_packages_date_issued 
        ON govinfo_crec_packages(date_issued);
    CREATE INDEX IF NOT EXISTS idx_crec_packages_congress 
        ON govinfo_crec_packages(congress);
    """
    
    # Congressional Record granules table
    granules_sql = """
    CREATE TABLE IF NOT EXISTS govinfo_crec_granules (
        granule_id VARCHAR(255) PRIMARY KEY,
        package_id VARCHAR(255) REFERENCES govinfo_crec_packages(package_id),
        title TEXT,
        granule_class VARCHAR(100),
        granule_date DATE,
        pdf_link TEXT,
        htm_link TEXT,
        xml_link TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    CREATE INDEX IF NOT EXISTS idx_crec_granules_package 
        ON govinfo_crec_granules(package_id);
    CREATE INDEX IF NOT EXISTS idx_crec_granules_class 
        ON govinfo_crec_granules(granule_class);
    CREATE INDEX IF NOT EXISTS idx_crec_granules_date 
        ON govinfo_crec_granules(granule_date);
    """
    
    db_manager.execute_query(packages_sql)
    db_manager.execute_query(granules_sql)
    logger.info("Database tables created/verified")


def ingest_packages(
    client: GovInfoClient,
    db_manager: DatabaseManager,
    start_date: str,
    end_date: str,
    progress: ProgressReporter,
) -> int:
    """
    Ingest Congressional Record packages.

    Args:
        client: GovInfo API client
        db_manager: Database manager
        start_date: Start date (YYYY-MM-DD)
        end_date: End date (YYYY-MM-DD)
        progress: Progress reporter

    Returns:
        Number of packages ingested
    """
    logger.info(f"Fetching Congressional Record packages from {start_date} to {end_date}")
    
    # Convert dates to ISO format for API
    start_iso = f"{start_date}T00:00:00Z"
    end_iso = f"{end_date}T23:59:59Z"
    
    packages = client.get_congressional_record(start_iso, end_iso)
    
    logger.info(f"Found {len(packages)} packages")
    
    if not packages:
        return 0
    
    # Prepare data for bulk insert
    values = []
    for pkg in packages:
        package_id = pkg.get("packageId")
        
        # Parse date issued
        date_issued = pkg.get("dateIssued")
        if date_issued:
            date_issued = datetime.fromisoformat(date_issued.replace("Z", "+00:00")).date()
        
        # Parse last modified
        last_modified = pkg.get("lastModified")
        if last_modified:
            last_modified = datetime.fromisoformat(last_modified.replace("Z", "+00:00"))
        
        values.append((
            package_id,
            pkg.get("title"),
            date_issued,
            last_modified,
            pkg.get("packageLink"),
            pkg.get("granulesLink"),
            pkg.get("congress"),
            pkg.get("session"),
        ))
        
        progress.record_success()
    
    # Bulk upsert
    columns = [
        "package_id", "title", "date_issued", "last_modified",
        "package_link", "granules_link", "congress", "session"
    ]
    
    count = db_manager.upsert(
        table="govinfo_crec_packages",
        columns=columns,
        values=values,
        conflict_columns=["package_id"],
    )
    
    logger.info(f"Ingested {count} packages")
    return count


def ingest_granules(
    client: GovInfoClient,
    db_manager: DatabaseManager,
    progress: ProgressReporter,
) -> int:
    """
    Ingest granules for all packages that don't have granules yet.

    Args:
        client: GovInfo API client
        db_manager: Database manager
        progress: Progress reporter

    Returns:
        Number of granules ingested
    """
    # Get packages that need granule ingestion
    query = """
    SELECT package_id 
    FROM govinfo_crec_packages 
    WHERE package_id NOT IN (
        SELECT DISTINCT package_id 
        FROM govinfo_crec_granules 
        WHERE package_id IS NOT NULL
    )
    ORDER BY date_issued DESC
    LIMIT 100
    """
    
    packages = db_manager.execute_query(query, fetch=True)
    
    if not packages:
        logger.info("No packages need granule ingestion")
        return 0
    
    logger.info(f"Fetching granules for {len(packages)} packages")
    
    total_granules = 0
    
    with progress.track(len(packages), "Fetching granules") as p:
        for pkg in packages:
            package_id = pkg["package_id"]
            
            try:
                granules = client.get_package_granules(package_id)
                
                if not granules:
                    p.record_skip()
                    continue
                
                # Prepare granule data
                values = []
                for granule in granules:
                    granule_id = granule.get("granuleId")
                    
                    # Get granule summary for download links
                    try:
                        summary = client.get_granule_summary(package_id, granule_id)
                        download = summary.get("download", {})
                    except Exception as e:
                        logger.warning(f"Failed to get granule summary for {granule_id}: {e}")
                        download = {}
                    
                    # Parse date
                    granule_date = granule.get("granuleDate")
                    if granule_date:
                        granule_date = datetime.fromisoformat(granule_date.replace("Z", "+00:00")).date()
                    
                    values.append((
                        granule_id,
                        package_id,
                        granule.get("title"),
                        granule.get("granuleClass"),
                        granule_date,
                        download.get("pdfLink"),
                        download.get("htmLink"),
                        download.get("xmlLink"),
                    ))
                
                # Bulk upsert
                if values:
                    columns = [
                        "granule_id", "package_id", "title", "granule_class",
                        "granule_date", "pdf_link", "htm_link", "xml_link"
                    ]
                    
                    count = db_manager.upsert(
                        table="govinfo_crec_granules",
                        columns=columns,
                        values=values,
                        conflict_columns=["granule_id"],
                    )
                    
                    total_granules += count
                
                p.record_success()
                
            except Exception as e:
                logger.error(f"Error processing package {package_id}: {e}")
                p.record_failure()
                progress.record_error(f"Package {package_id}: {str(e)}")
    
    logger.info(f"Ingested {total_granules} granules")
    return total_granules


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Ingest Congressional Record data from GovInfo.gov"
    )
    parser.add_argument(
        "--start-date",
        required=True,
        help="Start date (YYYY-MM-DD)",
    )
    parser.add_argument(
        "--end-date",
        help="End date (YYYY-MM-DD), defaults to start date",
    )
    parser.add_argument(
        "--skip-granules",
        action="store_true",
        help="Skip granule ingestion",
    )
    parser.add_argument(
        "--api-key",
        default=os.getenv("GOVINFO_API_KEY"),
        help="GovInfo API key (or set GOVINFO_API_KEY env var)",
    )
    parser.add_argument(
        "--database-url",
        default=os.getenv("DATABASE_URL"),
        help="PostgreSQL database URL (or set DATABASE_URL env var)",
    )
    
    args = parser.parse_args()
    
    if not args.api_key:
        logger.error("API key required. Set GOVINFO_API_KEY env var or use --api-key")
        sys.exit(1)
    
    if not args.database_url:
        logger.error("Database URL required. Set DATABASE_URL env var or use --database-url")
        sys.exit(1)
    
    # Default end date to start date
    end_date = args.end_date or args.start_date
    
    # Initialize clients
    client = GovInfoClient(args.api_key)
    db_manager = DatabaseManager(args.database_url)
    progress = ProgressReporter(verbose=True)
    
    try:
        # Create tables
        create_tables(db_manager)
        
        # Ingest packages
        logger.info("Starting package ingestion...")
        with progress.track(1, "Ingesting packages") as p:
            package_count = ingest_packages(
                client, db_manager, args.start_date, end_date, p
            )
        
        # Ingest granules
        if not args.skip_granules:
            logger.info("Starting granule ingestion...")
            granule_count = ingest_granules(client, db_manager, progress)
        else:
            granule_count = 0
            logger.info("Skipping granule ingestion")
        
        # Print summary
        progress.print_summary()
        
        logger.info("Ingestion complete!")
        logger.info(f"  Packages: {package_count}")
        logger.info(f"  Granules: {granule_count}")
        
    except Exception as e:
        logger.error(f"Ingestion failed: {e}", exc_info=True)
        sys.exit(1)
    finally:
        db_manager.close()


if __name__ == "__main__":
    main()
