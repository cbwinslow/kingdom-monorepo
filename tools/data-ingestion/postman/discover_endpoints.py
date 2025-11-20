#!/usr/bin/env python3
"""
Discover and reverse engineer API endpoints.

This script probes API endpoints to discover available parameters, response
structures, and undocumented features. Useful for understanding API capabilities.
"""

import argparse
import json
import logging
import os
import sys
from pathlib import Path
from typing import Dict, Any, List, Set
from datetime import datetime
import requests

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


class EndpointDiscoverer:
    """Discover and analyze API endpoints."""
    
    def __init__(self, client):
        """
        Initialize discoverer.
        
        Args:
            client: API client instance
        """
        self.client = client
        self.discoveries = {
            "endpoints": [],
            "discovered_at": datetime.now().isoformat(),
        }
    
    def probe_endpoint(
        self,
        endpoint: str,
        params: Dict[str, Any] = None,
    ) -> Dict[str, Any]:
        """
        Probe an endpoint to understand its structure.
        
        Args:
            endpoint: Endpoint path
            params: Query parameters
            
        Returns:
            Discovery information
        """
        logger.info(f"Probing endpoint: {endpoint}")
        
        try:
            response = self.client.get(endpoint, **(params or {}))
            
            discovery = {
                "endpoint": endpoint,
                "success": True,
                "response_keys": list(response.keys()) if isinstance(response, dict) else [],
                "response_type": type(response).__name__,
                "sample_structure": self._analyze_structure(response),
            }
            
            # Try to extract pagination info
            if isinstance(response, dict):
                if "pagination" in response:
                    discovery["pagination"] = response["pagination"]
                if "nextPage" in response:
                    discovery["has_pagination"] = True
            
            return discovery
            
        except Exception as e:
            logger.warning(f"Failed to probe {endpoint}: {e}")
            return {
                "endpoint": endpoint,
                "success": False,
                "error": str(e),
            }
    
    def _analyze_structure(self, data: Any, max_depth: int = 3, depth: int = 0) -> Any:
        """
        Analyze data structure recursively.
        
        Args:
            data: Data to analyze
            max_depth: Maximum recursion depth
            depth: Current depth
            
        Returns:
            Structure description
        """
        if depth >= max_depth:
            return "..."
        
        if isinstance(data, dict):
            return {
                k: self._analyze_structure(v, max_depth, depth + 1)
                for k, v in list(data.items())[:5]  # Limit to first 5 keys
            }
        elif isinstance(data, list):
            if len(data) > 0:
                return [self._analyze_structure(data[0], max_depth, depth + 1)]
            return []
        else:
            return type(data).__name__
    
    def discover_query_parameters(
        self,
        endpoint: str,
        known_params: List[str] = None,
    ) -> Set[str]:
        """
        Try to discover additional query parameters.
        
        Args:
            endpoint: Endpoint path
            known_params: List of known parameters to test
            
        Returns:
            Set of working parameters
        """
        logger.info(f"Discovering parameters for: {endpoint}")
        
        working_params = set()
        
        # Common parameter names to try
        common_params = [
            "limit", "offset", "page", "pageSize", "offsetMark",
            "sort", "order", "filter", "query", "q",
            "fromDate", "toDate", "startDate", "endDate",
            "collection", "congress", "session", "jurisdiction",
            "chamber", "type", "status", "format",
        ]
        
        test_params = (known_params or []) + common_params
        
        for param in test_params:
            try:
                # Try parameter with a reasonable test value
                test_value = self._get_test_value(param)
                response = self.client.get(endpoint, **{param: test_value})
                
                # If no error, parameter is accepted
                working_params.add(param)
                logger.info(f"  ✓ Parameter '{param}' works")
                
            except Exception as e:
                # Parameter might not be valid
                logger.debug(f"  ✗ Parameter '{param}' failed: {e}")
        
        return working_params
    
    def _get_test_value(self, param: str) -> str:
        """Get appropriate test value for a parameter."""
        if param in ["limit", "pageSize"]:
            return "10"
        elif param in ["offset", "page"]:
            return "0"
        elif param in ["offsetMark"]:
            return "*"
        elif param in ["congress"]:
            return "118"
        elif param in ["year"]:
            return "2024"
        elif param in ["jurisdiction"]:
            return "ca"
        elif "date" in param.lower():
            return "2024-01-01"
        else:
            return "test"
    
    def generate_report(self) -> str:
        """
        Generate discovery report.
        
        Returns:
            Formatted report string
        """
        report = ["", "=" * 80, "API ENDPOINT DISCOVERY REPORT", "=" * 80, ""]
        
        report.append(f"Discovered at: {self.discoveries['discovered_at']}")
        report.append(f"Total endpoints probed: {len(self.discoveries['endpoints'])}")
        report.append("")
        
        for discovery in self.discoveries["endpoints"]:
            report.append(f"\nEndpoint: {discovery['endpoint']}")
            report.append(f"  Success: {discovery['success']}")
            
            if discovery['success']:
                report.append(f"  Response type: {discovery['response_type']}")
                if discovery.get('response_keys'):
                    report.append(f"  Response keys: {', '.join(discovery['response_keys'])}")
                if discovery.get('has_pagination'):
                    report.append("  Has pagination: Yes")
                if discovery.get('working_params'):
                    report.append(f"  Working parameters: {', '.join(discovery['working_params'])}")
            else:
                report.append(f"  Error: {discovery['error']}")
        
        report.append("")
        report.append("=" * 80)
        report.append("")
        
        return "\n".join(report)


def discover_govinfo(api_key: str) -> Dict[str, Any]:
    """Discover GovInfo API endpoints."""
    logger.info("Discovering GovInfo.gov API...")
    
    client = GovInfoClient(api_key)
    discoverer = EndpointDiscoverer(client)
    
    # Probe key endpoints
    endpoints = [
        ("collections", {}),
        ("collections/BILLS/2024-01-01T00:00:00Z", {"offsetMark": "*", "pageSize": "10"}),
        ("published/2024-01-01", {"offsetMark": "*", "pageSize": "10"}),
    ]
    
    for endpoint, params in endpoints:
        discovery = discoverer.probe_endpoint(endpoint, params)
        discoverer.discoveries["endpoints"].append(discovery)
    
    return discoverer.discoveries


def discover_congress(api_key: str) -> Dict[str, Any]:
    """Discover Congress.gov API endpoints."""
    logger.info("Discovering Congress.gov API...")
    
    client = CongressClient(api_key)
    discoverer = EndpointDiscoverer(client)
    
    # Probe key endpoints
    endpoints = [
        ("bill/118", {"limit": "10"}),
        ("member/118", {"limit": "10"}),
        ("committee/118", {"limit": "10"}),
    ]
    
    for endpoint, params in endpoints:
        discovery = discoverer.probe_endpoint(endpoint, params)
        discoverer.discoveries["endpoints"].append(discovery)
    
    return discoverer.discoveries


def discover_openstates(api_key: str) -> Dict[str, Any]:
    """Discover OpenStates API endpoints."""
    logger.info("Discovering OpenStates.org API...")
    
    client = OpenStatesClient(api_key)
    discoverer = EndpointDiscoverer(client)
    
    # Probe key endpoints
    endpoints = [
        ("jurisdictions", {}),
        ("people", {"jurisdiction": "ca", "per_page": "10"}),
        ("bills", {"jurisdiction": "ca", "per_page": "10"}),
    ]
    
    for endpoint, params in endpoints:
        discovery = discoverer.probe_endpoint(endpoint, params)
        discoverer.discoveries["endpoints"].append(discovery)
    
    return discoverer.discoveries


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Discover and reverse engineer API endpoints"
    )
    parser.add_argument(
        "--api",
        choices=["govinfo", "congress", "openstates", "all"],
        default="all",
        help="Which API to discover",
    )
    parser.add_argument(
        "--output",
        help="Output file for discoveries (JSON)",
    )
    parser.add_argument(
        "--govinfo-key",
        default=os.getenv("GOVINFO_API_KEY"),
        help="GovInfo API key",
    )
    parser.add_argument(
        "--congress-key",
        default=os.getenv("CONGRESS_API_KEY"),
        help="Congress API key",
    )
    parser.add_argument(
        "--openstates-key",
        default=os.getenv("OPENSTATES_API_KEY"),
        help="OpenStates API key",
    )
    
    args = parser.parse_args()
    
    discoveries = {}
    
    # Discover APIs
    if args.api in ["govinfo", "all"] and args.govinfo_key:
        try:
            discoveries["govinfo"] = discover_govinfo(args.govinfo_key)
        except Exception as e:
            logger.error(f"Failed to discover GovInfo: {e}")
    
    if args.api in ["congress", "all"] and args.congress_key:
        try:
            discoveries["congress"] = discover_congress(args.congress_key)
        except Exception as e:
            logger.error(f"Failed to discover Congress: {e}")
    
    if args.api in ["openstates", "all"] and args.openstates_key:
        try:
            discoveries["openstates"] = discover_openstates(args.openstates_key)
        except Exception as e:
            logger.error(f"Failed to discover OpenStates: {e}")
    
    # Output results
    if args.output:
        output_path = Path(args.output)
        with open(output_path, "w") as f:
            json.dump(discoveries, f, indent=2)
        logger.info(f"\n✓ Discoveries saved to: {output_path}")
    
    # Print summary
    print("\n" + "=" * 80)
    print("DISCOVERY SUMMARY")
    print("=" * 80)
    for api_name, api_discoveries in discoveries.items():
        print(f"\n{api_name.upper()}:")
        print(f"  Endpoints discovered: {len(api_discoveries.get('endpoints', []))}")
        successful = sum(1 for e in api_discoveries.get('endpoints', []) if e.get('success'))
        print(f"  Successful: {successful}")
    print("\n" + "=" * 80 + "\n")


if __name__ == "__main__":
    main()
