#!/usr/bin/env python3
"""
Generate Postman collections for all APIs.

This script generates comprehensive Postman collections for GovInfo.gov,
Congress.gov API, and OpenStates.org API based on the endpoint configurations.
"""

import json
import logging
from pathlib import Path
from typing import Dict, List, Any
from datetime import datetime

logger = logging.getLogger(__name__)


def create_postman_request(
    name: str,
    method: str,
    url: str,
    description: str = "",
    params: List[Dict[str, Any]] = None,
    headers: List[Dict[str, Any]] = None,
) -> Dict[str, Any]:
    """Create a Postman request object."""
    request = {
        "name": name,
        "request": {
            "method": method,
            "header": headers or [],
            "url": {
                "raw": url,
                "host": url.split("://")[1].split("/")[0].split("."),
                "path": url.split("://")[1].split("/")[1:] if "/" in url.split("://")[1] else [],
                "query": params or [],
            },
            "description": description,
        },
        "response": [],
    }
    return request


def generate_govinfo_collection() -> Dict[str, Any]:
    """Generate Postman collection for GovInfo.gov API."""
    
    collection = {
        "info": {
            "name": "GovInfo.gov API",
            "description": "Comprehensive collection for GovInfo.gov API endpoints",
            "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json",
        },
        "variable": [
            {
                "key": "base_url",
                "value": "https://api.govinfo.gov",
                "type": "string",
            },
            {
                "key": "api_key",
                "value": "YOUR_API_KEY_HERE",
                "type": "string",
            },
        ],
        "item": [],
    }
    
    # Collections folder
    collections_folder = {
        "name": "Collections",
        "description": "Discovery endpoints for collections",
        "item": [
            create_postman_request(
                name="List Collections",
                method="GET",
                url="{{base_url}}/collections?api_key={{api_key}}",
                description="Get list of all available collections",
            ),
            create_postman_request(
                name="Congressional Record Updates",
                method="GET",
                url="{{base_url}}/collections/CREC/2024-01-01T00:00:00Z?offsetMark=*&pageSize=100&api_key={{api_key}}",
                description="Get Congressional Record packages updated since date",
            ),
            create_postman_request(
                name="Bills Updates",
                method="GET",
                url="{{base_url}}/collections/BILLS/2024-01-01T00:00:00Z?offsetMark=*&pageSize=100&api_key={{api_key}}",
                description="Get Bills packages updated since date",
            ),
        ],
    }
    
    # Packages folder
    packages_folder = {
        "name": "Packages",
        "description": "Retrieval endpoints for packages",
        "item": [
            create_postman_request(
                name="Get Package Summary",
                method="GET",
                url="{{base_url}}/packages/BILLS-118hr1/summary?api_key={{api_key}}",
                description="Get summary metadata for a package",
            ),
            create_postman_request(
                name="Get Package Granules",
                method="GET",
                url="{{base_url}}/packages/CREC-2024-01-03/granules?offsetMark=*&pageSize=100&api_key={{api_key}}",
                description="Get granules within a package",
            ),
            create_postman_request(
                name="Get Granule Summary",
                method="GET",
                url="{{base_url}}/packages/CREC-2024-01-03/granules/CREC-2024-01-03-pt1-PgH1/summary?api_key={{api_key}}",
                description="Get summary metadata for a granule",
            ),
        ],
    }
    
    # Published folder
    published_folder = {
        "name": "Published",
        "description": "Discovery by publication date",
        "item": [
            create_postman_request(
                name="Get Published Packages",
                method="GET",
                url="{{base_url}}/published/2024-01-01/2024-12-31?offsetMark=*&pageSize=100&collection=BILLS&api_key={{api_key}}",
                description="Get packages published within date range",
            ),
        ],
    }
    
    # Related folder
    related_folder = {
        "name": "Related",
        "description": "Related content discovery",
        "item": [
            create_postman_request(
                name="Get Related Packages",
                method="GET",
                url="{{base_url}}/related/BILLS-118hr1?api_key={{api_key}}",
                description="Get packages related to an access ID",
            ),
        ],
    }
    
    # Search folder
    search_folder = {
        "name": "Search",
        "description": "Search endpoints",
        "item": [
            {
                "name": "Search Content",
                "request": {
                    "method": "POST",
                    "header": [
                        {
                            "key": "Content-Type",
                            "value": "application/json",
                        },
                    ],
                    "body": {
                        "mode": "raw",
                        "raw": json.dumps({
                            "query": "collection:(BILLS) congress:118",
                            "pageSize": "100",
                            "offsetMark": "*",
                            "sorts": [
                                {
                                    "field": "score",
                                    "sortOrder": "DESC",
                                }
                            ],
                        }, indent=2),
                    },
                    "url": {
                        "raw": "{{base_url}}/search",
                        "host": ["api", "govinfo", "gov"],
                        "path": ["search"],
                    },
                    "description": "Search GovInfo content",
                },
                "response": [],
            },
        ],
    }
    
    collection["item"] = [
        collections_folder,
        packages_folder,
        published_folder,
        related_folder,
        search_folder,
    ]
    
    return collection


def generate_congress_collection() -> Dict[str, Any]:
    """Generate Postman collection for Congress.gov API."""
    
    collection = {
        "info": {
            "name": "Congress.gov API v3",
            "description": "Comprehensive collection for Congress.gov API v3 endpoints",
            "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json",
        },
        "variable": [
            {
                "key": "base_url",
                "value": "https://api.congress.gov/v3",
                "type": "string",
            },
            {
                "key": "api_key",
                "value": "YOUR_API_KEY_HERE",
                "type": "string",
            },
        ],
        "item": [],
    }
    
    # Bills folder
    bills_folder = {
        "name": "Bills",
        "description": "Congressional bills and legislation",
        "item": [
            create_postman_request(
                name="List Bills",
                method="GET",
                url="{{base_url}}/bill/118?api_key={{api_key}}&format=json&limit=250",
                description="List bills for Congress 118",
            ),
            create_postman_request(
                name="Get Bill Details",
                method="GET",
                url="{{base_url}}/bill/118/hr/1?api_key={{api_key}}&format=json",
                description="Get details for a specific bill",
            ),
            create_postman_request(
                name="Get Bill Actions",
                method="GET",
                url="{{base_url}}/bill/118/hr/1/actions?api_key={{api_key}}&format=json&limit=250",
                description="Get actions for a bill",
            ),
            create_postman_request(
                name="Get Bill Cosponsors",
                method="GET",
                url="{{base_url}}/bill/118/hr/1/cosponsors?api_key={{api_key}}&format=json&limit=250",
                description="Get cosponsors for a bill",
            ),
        ],
    }
    
    # Members folder
    members_folder = {
        "name": "Members",
        "description": "Members of Congress",
        "item": [
            create_postman_request(
                name="List Members",
                method="GET",
                url="{{base_url}}/member/118?api_key={{api_key}}&format=json&limit=250",
                description="List members for Congress 118",
            ),
            create_postman_request(
                name="Get Member Details",
                method="GET",
                url="{{base_url}}/member/A000055?api_key={{api_key}}&format=json",
                description="Get details for a member by bioguide ID",
            ),
            create_postman_request(
                name="Get Sponsored Legislation",
                method="GET",
                url="{{base_url}}/member/A000055/sponsored-legislation?api_key={{api_key}}&format=json&limit=250",
                description="Get legislation sponsored by a member",
            ),
        ],
    }
    
    # Committees folder
    committees_folder = {
        "name": "Committees",
        "description": "Congressional committees",
        "item": [
            create_postman_request(
                name="List Committees",
                method="GET",
                url="{{base_url}}/committee/118?api_key={{api_key}}&format=json&limit=250",
                description="List committees for Congress 118",
            ),
            create_postman_request(
                name="Get Committee Details",
                method="GET",
                url="{{base_url}}/committee/house/hsag?api_key={{api_key}}&format=json",
                description="Get details for a committee",
            ),
        ],
    }
    
    # Amendments folder
    amendments_folder = {
        "name": "Amendments",
        "description": "Amendments to bills",
        "item": [
            create_postman_request(
                name="List Amendments",
                method="GET",
                url="{{base_url}}/amendment/118?api_key={{api_key}}&format=json&limit=250",
                description="List amendments for Congress 118",
            ),
        ],
    }
    
    collection["item"] = [
        bills_folder,
        members_folder,
        committees_folder,
        amendments_folder,
    ]
    
    return collection


def generate_openstates_collection() -> Dict[str, Any]:
    """Generate Postman collection for OpenStates API."""
    
    collection = {
        "info": {
            "name": "OpenStates API v3",
            "description": "Comprehensive collection for OpenStates.org API v3 endpoints",
            "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json",
        },
        "variable": [
            {
                "key": "base_url",
                "value": "https://v3.openstates.org",
                "type": "string",
            },
            {
                "key": "api_key",
                "value": "YOUR_API_KEY_HERE",
                "type": "string",
            },
        ],
        "item": [],
    }
    
    # Jurisdictions folder
    jurisdictions_folder = {
        "name": "Jurisdictions",
        "description": "State and local jurisdictions",
        "item": [
            {
                "name": "List Jurisdictions",
                "request": {
                    "method": "GET",
                    "header": [
                        {
                            "key": "X-API-KEY",
                            "value": "{{api_key}}",
                        },
                    ],
                    "url": {
                        "raw": "{{base_url}}/jurisdictions",
                        "host": ["v3", "openstates", "org"],
                        "path": ["jurisdictions"],
                    },
                    "description": "List all jurisdictions",
                },
                "response": [],
            },
        ],
    }
    
    # People folder
    people_folder = {
        "name": "People",
        "description": "Legislators and officials",
        "item": [
            {
                "name": "List People",
                "request": {
                    "method": "GET",
                    "header": [
                        {
                            "key": "X-API-KEY",
                            "value": "{{api_key}}",
                        },
                    ],
                    "url": {
                        "raw": "{{base_url}}/people?jurisdiction=ca&per_page=100",
                        "host": ["v3", "openstates", "org"],
                        "path": ["people"],
                        "query": [
                            {"key": "jurisdiction", "value": "ca"},
                            {"key": "per_page", "value": "100"},
                        ],
                    },
                    "description": "List people for California",
                },
                "response": [],
            },
        ],
    }
    
    # Bills folder
    bills_folder = {
        "name": "Bills",
        "description": "State bills and legislation",
        "item": [
            {
                "name": "Search Bills",
                "request": {
                    "method": "GET",
                    "header": [
                        {
                            "key": "X-API-KEY",
                            "value": "{{api_key}}",
                        },
                    ],
                    "url": {
                        "raw": "{{base_url}}/bills?jurisdiction=ca&session=2024&per_page=100",
                        "host": ["v3", "openstates", "org"],
                        "path": ["bills"],
                        "query": [
                            {"key": "jurisdiction", "value": "ca"},
                            {"key": "session", "value": "2024"},
                            {"key": "per_page", "value": "100"},
                        ],
                    },
                    "description": "Search bills for California 2024 session",
                },
                "response": [],
            },
        ],
    }
    
    collection["item"] = [
        jurisdictions_folder,
        people_folder,
        bills_folder,
    ]
    
    return collection


def main():
    """Main entry point."""
    logging.basicConfig(level=logging.INFO)
    
    output_dir = Path(__file__).parent
    
    # Generate collections
    logger.info("Generating Postman collections...")
    
    collections = {
        "govinfo_collection.json": generate_govinfo_collection(),
        "congress_collection.json": generate_congress_collection(),
        "openstates_collection.json": generate_openstates_collection(),
    }
    
    # Write collections to files
    for filename, collection in collections.items():
        output_path = output_dir / filename
        with open(output_path, "w") as f:
            json.dump(collection, f, indent=2)
        logger.info(f"Generated {filename}")
    
    logger.info("✓ All Postman collections generated successfully")
    logger.info(f"  Output directory: {output_dir}")
    logger.info("\nTo use these collections:")
    logger.info("1. Import them into Postman")
    logger.info("2. Set the api_key variable with your actual API key")
    logger.info("3. Start making requests!")


if __name__ == "__main__":
    main()
