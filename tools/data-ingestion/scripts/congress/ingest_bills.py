#!/usr/bin/env python3
"""
Ingest bills data from Congress.gov API.

This script fetches bills for a specified Congress and stores them in a
PostgreSQL database with progress reporting.
"""

import argparse
import json
import logging
import os
import sys
from datetime import datetime
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from lib.congress_client import CongressClient
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
    
    # Bills table
    bills_sql = """
    CREATE TABLE IF NOT EXISTS congress_bills (
        bill_id VARCHAR(255) PRIMARY KEY,
        congress INTEGER,
        bill_type VARCHAR(50),
        bill_number INTEGER,
        title TEXT,
        origin_chamber VARCHAR(50),
        origin_chamber_code VARCHAR(10),
        update_date TIMESTAMP,
        update_date_including_text TIMESTAMP,
        introduced_date DATE,
        policy_area TEXT,
        latest_action_text TEXT,
        latest_action_date DATE,
        sponsor_bioguide_id VARCHAR(50),
        sponsor_name TEXT,
        sponsor_party VARCHAR(50),
        sponsor_state VARCHAR(2),
        url TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    CREATE INDEX IF NOT EXISTS idx_bills_congress ON congress_bills(congress);
    CREATE INDEX IF NOT EXISTS idx_bills_type ON congress_bills(bill_type);
    CREATE INDEX IF NOT EXISTS idx_bills_introduced ON congress_bills(introduced_date);
    CREATE INDEX IF NOT EXISTS idx_bills_sponsor ON congress_bills(sponsor_bioguide_id);
    """
    
    # Bill actions table
    actions_sql = """
    CREATE TABLE IF NOT EXISTS congress_bill_actions (
        id SERIAL PRIMARY KEY,
        bill_id VARCHAR(255) REFERENCES congress_bills(bill_id),
        action_date DATE,
        action_code VARCHAR(50),
        action_type VARCHAR(100),
        text TEXT,
        source_system VARCHAR(100),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    CREATE INDEX IF NOT EXISTS idx_bill_actions_bill ON congress_bill_actions(bill_id);
    CREATE INDEX IF NOT EXISTS idx_bill_actions_date ON congress_bill_actions(action_date);
    """
    
    # Bill cosponsors table
    cosponsors_sql = """
    CREATE TABLE IF NOT EXISTS congress_bill_cosponsors (
        id SERIAL PRIMARY KEY,
        bill_id VARCHAR(255) REFERENCES congress_bills(bill_id),
        bioguide_id VARCHAR(50),
        name TEXT,
        party VARCHAR(50),
        state VARCHAR(2),
        district INTEGER,
        sponsored_date DATE,
        is_original_cosponsor BOOLEAN,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    CREATE INDEX IF NOT EXISTS idx_bill_cosponsors_bill ON congress_bill_cosponsors(bill_id);
    CREATE INDEX IF NOT EXISTS idx_bill_cosponsors_member ON congress_bill_cosponsors(bioguide_id);
    """
    
    db_manager.execute_query(bills_sql)
    db_manager.execute_query(actions_sql)
    db_manager.execute_query(cosponsors_sql)
    logger.info("Database tables created/verified")


def ingest_bills(
    client: CongressClient,
    db_manager: DatabaseManager,
    congress: int,
    bill_type: str = None,
    progress: ProgressReporter = None,
) -> int:
    """
    Ingest bills for a congress.

    Args:
        client: Congress API client
        db_manager: Database manager
        congress: Congress number
        bill_type: Optional bill type filter
        progress: Progress reporter

    Returns:
        Number of bills ingested
    """
    logger.info(f"Fetching bills for Congress {congress}")
    if bill_type:
        logger.info(f"  Bill type: {bill_type}")
    
    bills = client.list_bills(congress=congress, bill_type=bill_type)
    
    logger.info(f"Found {len(bills)} bills")
    
    if not bills:
        return 0
    
    # Prepare data for bulk insert
    values = []
    
    with progress.track(len(bills), "Processing bills") as p:
        for bill in bills:
            try:
                # Get detailed bill information
                bill_data = bill
                
                # Extract sponsor info
                sponsor = bill_data.get("sponsors", [{}])[0] if bill_data.get("sponsors") else {}
                
                # Extract latest action
                latest_action = bill_data.get("latestAction", {})
                latest_action_date = latest_action.get("actionDate")
                if latest_action_date:
                    latest_action_date = datetime.strptime(latest_action_date, "%Y-%m-%d").date()
                
                # Extract dates
                update_date = bill_data.get("updateDate")
                if update_date:
                    update_date = datetime.fromisoformat(update_date.replace("Z", "+00:00"))
                
                update_date_text = bill_data.get("updateDateIncludingText")
                if update_date_text:
                    update_date_text = datetime.fromisoformat(update_date_text.replace("Z", "+00:00"))
                
                introduced_date = bill_data.get("introducedDate")
                if introduced_date:
                    introduced_date = datetime.strptime(introduced_date, "%Y-%m-%d").date()
                
                # Create bill ID
                bill_id = f"{congress}-{bill_data.get('type')}-{bill_data.get('number')}"
                
                values.append((
                    bill_id,
                    bill_data.get("congress"),
                    bill_data.get("type"),
                    bill_data.get("number"),
                    bill_data.get("title"),
                    bill_data.get("originChamber"),
                    bill_data.get("originChamberCode"),
                    update_date,
                    update_date_text,
                    introduced_date,
                    bill_data.get("policyArea", {}).get("name"),
                    latest_action.get("text"),
                    latest_action_date,
                    sponsor.get("bioguideId"),
                    sponsor.get("fullName"),
                    sponsor.get("party"),
                    sponsor.get("state"),
                    bill_data.get("url"),
                ))
                
                p.record_success()
                
            except Exception as e:
                logger.error(f"Error processing bill: {e}")
                p.record_failure()
                progress.record_error(f"Bill {bill.get('number')}: {str(e)}")
    
    # Bulk upsert
    columns = [
        "bill_id", "congress", "bill_type", "bill_number", "title",
        "origin_chamber", "origin_chamber_code", "update_date",
        "update_date_including_text", "introduced_date", "policy_area",
        "latest_action_text", "latest_action_date", "sponsor_bioguide_id",
        "sponsor_name", "sponsor_party", "sponsor_state", "url"
    ]
    
    count = db_manager.upsert(
        table="congress_bills",
        columns=columns,
        values=values,
        conflict_columns=["bill_id"],
    )
    
    logger.info(f"Ingested {count} bills")
    return count


def ingest_bill_details(
    client: CongressClient,
    db_manager: DatabaseManager,
    congress: int,
    progress: ProgressReporter = None,
    fetch_actions: bool = True,
    fetch_cosponsors: bool = True,
) -> dict:
    """
    Ingest detailed bill information including actions and cosponsors.

    Args:
        client: Congress API client
        db_manager: Database manager
        congress: Congress number
        progress: Progress reporter
        fetch_actions: Whether to fetch bill actions
        fetch_cosponsors: Whether to fetch cosponsors

    Returns:
        Dictionary with counts
    """
    # Get bills that need detail ingestion
    query = """
    SELECT bill_id, bill_type, bill_number 
    FROM congress_bills 
    WHERE congress = %s
    ORDER BY introduced_date DESC
    LIMIT 100
    """
    
    bills = db_manager.execute_query(query, (congress,), fetch=True)
    
    if not bills:
        logger.info("No bills need detail ingestion")
        return {"actions": 0, "cosponsors": 0}
    
    logger.info(f"Fetching details for {len(bills)} bills")
    
    actions_count = 0
    cosponsors_count = 0
    
    with progress.track(len(bills), "Fetching bill details") as p:
        for bill in bills:
            bill_id = bill["bill_id"]
            bill_type = bill["bill_type"]
            bill_number = bill["bill_number"]
            
            try:
                # Fetch actions
                if fetch_actions:
                    actions = client.get_bill_actions(congress, bill_type, bill_number)
                    
                    if actions:
                        action_values = []
                        for action in actions:
                            action_date = action.get("actionDate")
                            if action_date:
                                action_date = datetime.strptime(action_date, "%Y-%m-%d").date()
                            
                            action_values.append((
                                bill_id,
                                action_date,
                                action.get("actionCode"),
                                action.get("type"),
                                action.get("text"),
                                action.get("sourceSystem", {}).get("name"),
                            ))
                        
                        if action_values:
                            columns = ["bill_id", "action_date", "action_code", "action_type", "text", "source_system"]
                            actions_count += db_manager.bulk_insert(
                                table="congress_bill_actions",
                                columns=columns,
                                values=action_values,
                                on_conflict="DO NOTHING",
                            )
                
                # Fetch cosponsors
                if fetch_cosponsors:
                    cosponsors = client.get_bill_cosponsors(congress, bill_type, bill_number)
                    
                    if cosponsors:
                        cosponsor_values = []
                        for cosponsor in cosponsors:
                            sponsored_date = cosponsor.get("sponsorshipDate")
                            if sponsored_date:
                                sponsored_date = datetime.strptime(sponsored_date, "%Y-%m-%d").date()
                            
                            cosponsor_values.append((
                                bill_id,
                                cosponsor.get("bioguideId"),
                                cosponsor.get("fullName"),
                                cosponsor.get("party"),
                                cosponsor.get("state"),
                                cosponsor.get("district"),
                                sponsored_date,
                                cosponsor.get("isOriginalCosponsor"),
                            ))
                        
                        if cosponsor_values:
                            columns = ["bill_id", "bioguide_id", "name", "party", "state", "district", "sponsored_date", "is_original_cosponsor"]
                            cosponsors_count += db_manager.bulk_insert(
                                table="congress_bill_cosponsors",
                                columns=columns,
                                values=cosponsor_values,
                                on_conflict="DO NOTHING",
                            )
                
                p.record_success()
                
            except Exception as e:
                logger.error(f"Error processing bill {bill_id}: {e}")
                p.record_failure()
                progress.record_error(f"Bill {bill_id}: {str(e)}")
    
    logger.info(f"Ingested {actions_count} actions and {cosponsors_count} cosponsors")
    return {"actions": actions_count, "cosponsors": cosponsors_count}


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Ingest bills data from Congress.gov API"
    )
    parser.add_argument(
        "--congress",
        type=int,
        required=True,
        help="Congress number (e.g., 118)",
    )
    parser.add_argument(
        "--bill-type",
        choices=["hr", "s", "hjres", "sjres", "hconres", "sconres", "hres", "sres"],
        help="Bill type filter",
    )
    parser.add_argument(
        "--skip-details",
        action="store_true",
        help="Skip fetching bill details (actions, cosponsors)",
    )
    parser.add_argument(
        "--api-key",
        default=os.getenv("CONGRESS_API_KEY"),
        help="Congress API key (or set CONGRESS_API_KEY env var)",
    )
    parser.add_argument(
        "--database-url",
        default=os.getenv("DATABASE_URL"),
        help="PostgreSQL database URL (or set DATABASE_URL env var)",
    )
    
    args = parser.parse_args()
    
    if not args.api_key:
        logger.error("API key required. Set CONGRESS_API_KEY env var or use --api-key")
        sys.exit(1)
    
    if not args.database_url:
        logger.error("Database URL required. Set DATABASE_URL env var or use --database-url")
        sys.exit(1)
    
    # Initialize clients
    client = CongressClient(args.api_key)
    db_manager = DatabaseManager(args.database_url)
    progress = ProgressReporter(verbose=True)
    
    try:
        # Create tables
        create_tables(db_manager)
        
        # Ingest bills
        logger.info("Starting bill ingestion...")
        bill_count = ingest_bills(
            client, db_manager, args.congress, args.bill_type, progress
        )
        
        # Ingest details
        if not args.skip_details:
            logger.info("Starting detail ingestion...")
            details = ingest_bill_details(client, db_manager, args.congress, progress)
        else:
            details = {"actions": 0, "cosponsors": 0}
            logger.info("Skipping detail ingestion")
        
        # Print summary
        progress.print_summary()
        
        logger.info("Ingestion complete!")
        logger.info(f"  Bills: {bill_count}")
        logger.info(f"  Actions: {details['actions']}")
        logger.info(f"  Cosponsors: {details['cosponsors']}")
        
    except Exception as e:
        logger.error(f"Ingestion failed: {e}", exc_info=True)
        sys.exit(1)
    finally:
        db_manager.close()


if __name__ == "__main__":
    main()
