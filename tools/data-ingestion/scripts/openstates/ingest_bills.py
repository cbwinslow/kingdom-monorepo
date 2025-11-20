#!/usr/bin/env python3
"""
Ingest bills data from OpenStates.org API.

This script fetches state bills for a specified jurisdiction and session,
storing them in a PostgreSQL database with progress reporting.
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

from lib.openstates_client import OpenStatesClient
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
    CREATE TABLE IF NOT EXISTS openstates_bills (
        id VARCHAR(255) PRIMARY KEY,
        identifier VARCHAR(100),
        title TEXT,
        classification VARCHAR(50),
        subject TEXT[],
        jurisdiction_id VARCHAR(255),
        jurisdiction_name VARCHAR(100),
        session VARCHAR(100),
        from_organization_id VARCHAR(255),
        from_organization_name VARCHAR(255),
        from_organization_classification VARCHAR(50),
        first_action_date DATE,
        latest_action_date DATE,
        latest_action_description TEXT,
        created_at_source TIMESTAMP,
        updated_at_source TIMESTAMP,
        openstates_url TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    CREATE INDEX IF NOT EXISTS idx_os_bills_jurisdiction ON openstates_bills(jurisdiction_id);
    CREATE INDEX IF NOT EXISTS idx_os_bills_session ON openstates_bills(session);
    CREATE INDEX IF NOT EXISTS idx_os_bills_identifier ON openstates_bills(identifier);
    CREATE INDEX IF NOT EXISTS idx_os_bills_latest_action ON openstates_bills(latest_action_date);
    """
    
    # Bill sponsors table
    sponsors_sql = """
    CREATE TABLE IF NOT EXISTS openstates_bill_sponsors (
        id SERIAL PRIMARY KEY,
        bill_id VARCHAR(255) REFERENCES openstates_bills(id),
        person_id VARCHAR(255),
        person_name TEXT,
        classification VARCHAR(50),
        primary_sponsor BOOLEAN,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    CREATE INDEX IF NOT EXISTS idx_os_bill_sponsors_bill ON openstates_bill_sponsors(bill_id);
    CREATE INDEX IF NOT EXISTS idx_os_bill_sponsors_person ON openstates_bill_sponsors(person_id);
    """
    
    # Bill actions table
    actions_sql = """
    CREATE TABLE IF NOT EXISTS openstates_bill_actions (
        id SERIAL PRIMARY KEY,
        bill_id VARCHAR(255) REFERENCES openstates_bills(id),
        organization_id VARCHAR(255),
        organization_name VARCHAR(255),
        description TEXT,
        action_date DATE,
        classification TEXT[],
        order_number INTEGER,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    CREATE INDEX IF NOT EXISTS idx_os_bill_actions_bill ON openstates_bill_actions(bill_id);
    CREATE INDEX IF NOT EXISTS idx_os_bill_actions_date ON openstates_bill_actions(action_date);
    """
    
    # Bill votes table
    votes_sql = """
    CREATE TABLE IF NOT EXISTS openstates_bill_votes (
        id VARCHAR(255) PRIMARY KEY,
        bill_id VARCHAR(255) REFERENCES openstates_bills(id),
        motion_text TEXT,
        motion_classification TEXT[],
        start_date TIMESTAMP,
        result VARCHAR(50),
        organization_id VARCHAR(255),
        organization_name VARCHAR(255),
        yes_count INTEGER,
        no_count INTEGER,
        other_count INTEGER,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    CREATE INDEX IF NOT EXISTS idx_os_bill_votes_bill ON openstates_bill_votes(bill_id);
    CREATE INDEX IF NOT EXISTS idx_os_bill_votes_date ON openstates_bill_votes(start_date);
    """
    
    db_manager.execute_query(bills_sql)
    db_manager.execute_query(sponsors_sql)
    db_manager.execute_query(actions_sql)
    db_manager.execute_query(votes_sql)
    logger.info("Database tables created/verified")


def ingest_bills(
    client: OpenStatesClient,
    db_manager: DatabaseManager,
    jurisdiction: str,
    session: str = None,
    chamber: str = None,
    updated_since: str = None,
    progress: ProgressReporter = None,
) -> int:
    """
    Ingest bills for a jurisdiction.

    Args:
        client: OpenStates API client
        db_manager: Database manager
        jurisdiction: Jurisdiction abbreviation (e.g., ca)
        session: Optional session filter
        chamber: Optional chamber filter (upper, lower)
        updated_since: Optional filter for bills updated since date
        progress: Progress reporter

    Returns:
        Number of bills ingested
    """
    logger.info(f"Fetching bills for {jurisdiction}")
    if session:
        logger.info(f"  Session: {session}")
    if chamber:
        logger.info(f"  Chamber: {chamber}")
    if updated_since:
        logger.info(f"  Updated since: {updated_since}")
    
    bills = client.search_bills(
        jurisdiction=jurisdiction,
        session=session,
        chamber=chamber,
        updated_since=updated_since,
    )
    
    logger.info(f"Found {len(bills)} bills")
    
    if not bills:
        return 0
    
    # Prepare data for bulk insert
    values = []
    sponsor_values = []
    action_values = []
    vote_values = []
    
    with progress.track(len(bills), "Processing bills") as p:
        for bill in bills:
            try:
                bill_id = bill.get("id")
                
                # Parse dates
                first_action_date = bill.get("first_action_date")
                if first_action_date:
                    first_action_date = datetime.strptime(first_action_date, "%Y-%m-%d").date()
                
                latest_action_date = bill.get("latest_action_date")
                if latest_action_date:
                    latest_action_date = datetime.strptime(latest_action_date, "%Y-%m-%d").date()
                
                created_at = bill.get("created_at")
                if created_at:
                    created_at = datetime.fromisoformat(created_at.replace("Z", "+00:00"))
                
                updated_at = bill.get("updated_at")
                if updated_at:
                    updated_at = datetime.fromisoformat(updated_at.replace("Z", "+00:00"))
                
                # Extract organization info
                from_org = bill.get("from_organization", {})
                
                # Extract jurisdiction info
                jurisdiction_data = bill.get("jurisdiction", {})
                
                values.append((
                    bill_id,
                    bill.get("identifier"),
                    bill.get("title"),
                    bill.get("classification"),
                    bill.get("subject", []),
                    jurisdiction_data.get("id"),
                    jurisdiction_data.get("name"),
                    bill.get("session"),
                    from_org.get("id"),
                    from_org.get("name"),
                    from_org.get("classification"),
                    first_action_date,
                    latest_action_date,
                    bill.get("latest_action_description"),
                    created_at,
                    updated_at,
                    bill.get("openstates_url"),
                ))
                
                # Extract sponsors
                for sponsor in bill.get("sponsorships", []):
                    person = sponsor.get("person", {})
                    sponsor_values.append((
                        bill_id,
                        person.get("id"),
                        person.get("name"),
                        sponsor.get("classification"),
                        sponsor.get("primary"),
                    ))
                
                # Extract actions
                for i, action in enumerate(bill.get("actions", [])):
                    action_date = action.get("date")
                    if action_date:
                        action_date = datetime.strptime(action_date, "%Y-%m-%d").date()
                    
                    action_org = action.get("organization", {})
                    action_values.append((
                        bill_id,
                        action_org.get("id"),
                        action_org.get("name"),
                        action.get("description"),
                        action_date,
                        action.get("classification", []),
                        i,
                    ))
                
                # Extract votes
                for vote in bill.get("votes", []):
                    vote_date = vote.get("start_date")
                    if vote_date:
                        vote_date = datetime.fromisoformat(vote_date.replace("Z", "+00:00"))
                    
                    vote_org = vote.get("organization", {})
                    vote_counts = vote.get("counts", [])
                    
                    yes_count = next((c["count"] for c in vote_counts if c["option"] == "yes"), 0)
                    no_count = next((c["count"] for c in vote_counts if c["option"] == "no"), 0)
                    other_count = sum(c["count"] for c in vote_counts if c["option"] not in ["yes", "no"])
                    
                    vote_values.append((
                        vote.get("id"),
                        bill_id,
                        vote.get("motion_text"),
                        vote.get("motion_classification", []),
                        vote_date,
                        vote.get("result"),
                        vote_org.get("id"),
                        vote_org.get("name"),
                        yes_count,
                        no_count,
                        other_count,
                    ))
                
                p.record_success()
                
            except Exception as e:
                logger.error(f"Error processing bill: {e}")
                p.record_failure()
                progress.record_error(f"Bill {bill.get('identifier')}: {str(e)}")
    
    # Bulk upsert bills
    columns = [
        "id", "identifier", "title", "classification", "subject",
        "jurisdiction_id", "jurisdiction_name", "session",
        "from_organization_id", "from_organization_name", "from_organization_classification",
        "first_action_date", "latest_action_date", "latest_action_description",
        "created_at_source", "updated_at_source", "openstates_url"
    ]
    
    bill_count = db_manager.upsert(
        table="openstates_bills",
        columns=columns,
        values=values,
        conflict_columns=["id"],
    )
    
    # Insert sponsors
    if sponsor_values:
        sponsor_columns = ["bill_id", "person_id", "person_name", "classification", "primary_sponsor"]
        db_manager.bulk_insert(
            table="openstates_bill_sponsors",
            columns=sponsor_columns,
            values=sponsor_values,
            on_conflict="DO NOTHING",
        )
    
    # Insert actions
    if action_values:
        action_columns = ["bill_id", "organization_id", "organization_name", "description", 
                         "action_date", "classification", "order_number"]
        db_manager.bulk_insert(
            table="openstates_bill_actions",
            columns=action_columns,
            values=action_values,
            on_conflict="DO NOTHING",
        )
    
    # Insert votes
    if vote_values:
        vote_columns = ["id", "bill_id", "motion_text", "motion_classification", "start_date",
                       "result", "organization_id", "organization_name", 
                       "yes_count", "no_count", "other_count"]
        db_manager.upsert(
            table="openstates_bill_votes",
            columns=vote_columns,
            values=vote_values,
            conflict_columns=["id"],
        )
    
    logger.info(f"Ingested {bill_count} bills")
    logger.info(f"  Sponsors: {len(sponsor_values)}")
    logger.info(f"  Actions: {len(action_values)}")
    logger.info(f"  Votes: {len(vote_values)}")
    
    return bill_count


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Ingest bills data from OpenStates.org API"
    )
    parser.add_argument(
        "--jurisdiction",
        required=True,
        help="Jurisdiction abbreviation (e.g., ca, ny, tx)",
    )
    parser.add_argument(
        "--session",
        help="Legislative session",
    )
    parser.add_argument(
        "--chamber",
        choices=["upper", "lower"],
        help="Chamber filter",
    )
    parser.add_argument(
        "--updated-since",
        help="Filter to bills updated since date (YYYY-MM-DD)",
    )
    parser.add_argument(
        "--api-key",
        default=os.getenv("OPENSTATES_API_KEY"),
        help="OpenStates API key (or set OPENSTATES_API_KEY env var)",
    )
    parser.add_argument(
        "--database-url",
        default=os.getenv("DATABASE_URL"),
        help="PostgreSQL database URL (or set DATABASE_URL env var)",
    )
    
    args = parser.parse_args()
    
    if not args.api_key:
        logger.error("API key required. Set OPENSTATES_API_KEY env var or use --api-key")
        sys.exit(1)
    
    if not args.database_url:
        logger.error("Database URL required. Set DATABASE_URL env var or use --database-url")
        sys.exit(1)
    
    # Initialize clients
    client = OpenStatesClient(args.api_key)
    db_manager = DatabaseManager(args.database_url)
    progress = ProgressReporter(verbose=True)
    
    try:
        # Create tables
        create_tables(db_manager)
        
        # Ingest bills
        logger.info("Starting bill ingestion...")
        bill_count = ingest_bills(
            client,
            db_manager,
            args.jurisdiction,
            args.session,
            args.chamber,
            args.updated_since,
            progress,
        )
        
        # Print summary
        progress.print_summary()
        
        logger.info("Ingestion complete!")
        logger.info(f"  Bills: {bill_count}")
        
    except Exception as e:
        logger.error(f"Ingestion failed: {e}", exc_info=True)
        sys.exit(1)
    finally:
        db_manager.close()


if __name__ == "__main__":
    main()
