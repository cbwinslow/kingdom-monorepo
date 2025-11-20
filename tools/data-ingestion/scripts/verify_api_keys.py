#!/usr/bin/env python3
"""
Verify API keys are working correctly.

This script tests all configured API keys by making simple requests to each API.
"""

import logging
import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

from lib.govinfo_client import GovInfoClient
from lib.congress_client import CongressClient
from lib.openstates_client import OpenStatesClient
from dotenv import load_dotenv

load_dotenv()

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)


def verify_govinfo(api_key: str) -> bool:
    """
    Verify GovInfo API key.
    
    Args:
        api_key: API key to verify
        
    Returns:
        True if key is valid
    """
    logger.info("Verifying GovInfo.gov API key...")
    
    try:
        client = GovInfoClient(api_key)
        collections = client.list_collections()
        
        if collections:
            logger.info(f"✓ GovInfo API key is valid ({len(collections)} collections available)")
            return True
        else:
            logger.error("✗ GovInfo API key returned no data")
            return False
            
    except Exception as e:
        logger.error(f"✗ GovInfo API key verification failed: {e}")
        return False


def verify_congress(api_key: str) -> bool:
    """
    Verify Congress.gov API key.
    
    Args:
        api_key: API key to verify
        
    Returns:
        True if key is valid
    """
    logger.info("Verifying Congress.gov API key...")
    
    try:
        client = CongressClient(api_key)
        bills = client.list_bills(congress=118, limit=1)
        
        if bills:
            logger.info("✓ Congress.gov API key is valid")
            return True
        else:
            logger.error("✗ Congress.gov API key returned no data")
            return False
            
    except Exception as e:
        logger.error(f"✗ Congress.gov API key verification failed: {e}")
        return False


def verify_openstates(api_key: str) -> bool:
    """
    Verify OpenStates API key.
    
    Args:
        api_key: API key to verify
        
    Returns:
        True if key is valid
    """
    logger.info("Verifying OpenStates.org API key...")
    
    try:
        client = OpenStatesClient(api_key)
        jurisdictions = client.list_jurisdictions()
        
        if jurisdictions:
            logger.info(f"✓ OpenStates API key is valid ({len(jurisdictions)} jurisdictions available)")
            return True
        else:
            logger.error("✗ OpenStates API key returned no data")
            return False
            
    except Exception as e:
        logger.error(f"✗ OpenStates API key verification failed: {e}")
        return False


def main():
    """Main entry point."""
    print("\n" + "=" * 80)
    print("API KEY VERIFICATION")
    print("=" * 80 + "\n")
    
    results = {}
    
    # Verify GovInfo
    govinfo_key = os.getenv("GOVINFO_API_KEY")
    if govinfo_key:
        results["GovInfo"] = verify_govinfo(govinfo_key)
    else:
        logger.warning("⚠ GOVINFO_API_KEY not set")
        results["GovInfo"] = None
    
    print()
    
    # Verify Congress
    congress_key = os.getenv("CONGRESS_API_KEY")
    if congress_key:
        results["Congress"] = verify_congress(congress_key)
    else:
        logger.warning("⚠ CONGRESS_API_KEY not set")
        results["Congress"] = None
    
    print()
    
    # Verify OpenStates
    openstates_key = os.getenv("OPENSTATES_API_KEY")
    if openstates_key:
        results["OpenStates"] = verify_openstates(openstates_key)
    else:
        logger.warning("⚠ OPENSTATES_API_KEY not set")
        results["OpenStates"] = None
    
    # Print summary
    print("\n" + "=" * 80)
    print("VERIFICATION SUMMARY")
    print("=" * 80)
    
    for api_name, status in results.items():
        if status is True:
            print(f"  ✓ {api_name}: Valid")
        elif status is False:
            print(f"  ✗ {api_name}: Invalid")
        else:
            print(f"  ⚠ {api_name}: Not configured")
    
    print("=" * 80 + "\n")
    
    # Exit with error if any keys are invalid
    if any(status is False for status in results.values()):
        sys.exit(1)
    
    if all(status is None for status in results.values()):
        logger.error("No API keys configured. Please set environment variables.")
        sys.exit(1)
    
    logger.info("All configured API keys are valid!")


if __name__ == "__main__":
    main()
