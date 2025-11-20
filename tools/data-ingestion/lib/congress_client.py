"""
Congress.gov API client implementation.

Provides access to Congress.gov API v3 endpoints for bills, amendments, 
members, committees, and other congressional data.
"""

import logging
from typing import Dict, Any, List, Optional

from .base import BaseAPIClient

logger = logging.getLogger(__name__)


class CongressClient(BaseAPIClient):
    """Client for Congress.gov API v3."""

    BASE_URL = "https://api.congress.gov/v3"

    def __init__(self, api_key: str, **kwargs):
        """
        Initialize Congress.gov API client.

        Args:
            api_key: API key from api.data.gov
            **kwargs: Additional arguments for BaseAPIClient
        """
        super().__init__(
            api_key=api_key,
            base_url=self.BASE_URL,
            rate_limit_calls=5000,  # 5000 requests per hour
            rate_limit_period=3600,
            **kwargs,
        )

    def _prepare_headers(self) -> Dict[str, str]:
        """Prepare headers for Congress API request."""
        return {
            "Accept": "application/json",
            "User-Agent": "kingdom-monorepo-data-ingestion/1.0",
        }

    def _prepare_params(self, **kwargs) -> Dict[str, Any]:
        """Prepare query parameters including API key."""
        params = {"api_key": self.api_key, "format": "json"}
        params.update(kwargs)
        return params

    def _extract_items(self, response: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Extract items from Congress API response."""
        # Congress API typically wraps items in a type-specific key
        for key in ["bills", "amendments", "members", "committees", "nominations", 
                    "treaties", "summaries", "actions", "cosponsors", "subjects",
                    "relatedBills", "titles", "textVersions", "hearings", "reports"]:
            if key in response:
                return response[key]
        return []

    def _get_next_page(self, response: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """Get next page information from Congress response."""
        pagination = response.get("pagination", {})
        if pagination.get("next"):
            return {"offset": pagination.get("count", 0)}
        return None

    # Bills endpoints

    def list_bills(
        self,
        congress: Optional[int] = None,
        bill_type: Optional[str] = None,
        limit: int = 250,
    ) -> List[Dict[str, Any]]:
        """
        List bills.

        Args:
            congress: Congress number (e.g., 118)
            bill_type: Bill type (hr, s, hjres, sjres, hconres, sconres, hres, sres)
            limit: Number of results per page (max 250)

        Returns:
            List of bills
        """
        endpoint = "bill"
        if congress:
            endpoint += f"/{congress}"
            if bill_type:
                endpoint += f"/{bill_type}"

        results = []
        for item in self.paginate(endpoint, page_size=limit):
            results.append(item)

        return results

    def get_bill_details(
        self,
        congress: int,
        bill_type: str,
        bill_number: int,
    ) -> Dict[str, Any]:
        """
        Get detailed information for a specific bill.

        Args:
            congress: Congress number
            bill_type: Bill type (hr, s, etc.)
            bill_number: Bill number

        Returns:
            Bill details
        """
        endpoint = f"bill/{congress}/{bill_type}/{bill_number}"
        response = self.get(endpoint)
        return response.get("bill", {})

    def get_bill_actions(
        self,
        congress: int,
        bill_type: str,
        bill_number: int,
    ) -> List[Dict[str, Any]]:
        """
        Get actions for a bill.

        Args:
            congress: Congress number
            bill_type: Bill type
            bill_number: Bill number

        Returns:
            List of bill actions
        """
        endpoint = f"bill/{congress}/{bill_type}/{bill_number}/actions"
        results = []
        for item in self.paginate(endpoint):
            results.append(item)
        return results

    def get_bill_cosponsors(
        self,
        congress: int,
        bill_type: str,
        bill_number: int,
    ) -> List[Dict[str, Any]]:
        """
        Get cosponsors for a bill.

        Args:
            congress: Congress number
            bill_type: Bill type
            bill_number: Bill number

        Returns:
            List of cosponsors
        """
        endpoint = f"bill/{congress}/{bill_type}/{bill_number}/cosponsors"
        results = []
        for item in self.paginate(endpoint):
            results.append(item)
        return results

    # Amendments endpoints

    def list_amendments(
        self,
        congress: Optional[int] = None,
        amendment_type: Optional[str] = None,
        limit: int = 250,
    ) -> List[Dict[str, Any]]:
        """
        List amendments.

        Args:
            congress: Congress number
            amendment_type: Amendment type (hamdt, samdt)
            limit: Number of results per page

        Returns:
            List of amendments
        """
        endpoint = "amendment"
        if congress:
            endpoint += f"/{congress}"
            if amendment_type:
                endpoint += f"/{amendment_type}"

        results = []
        for item in self.paginate(endpoint, page_size=limit):
            results.append(item)

        return results

    def get_amendment_details(
        self,
        congress: int,
        amendment_type: str,
        amendment_number: int,
    ) -> Dict[str, Any]:
        """
        Get detailed information for an amendment.

        Args:
            congress: Congress number
            amendment_type: Amendment type
            amendment_number: Amendment number

        Returns:
            Amendment details
        """
        endpoint = f"amendment/{congress}/{amendment_type}/{amendment_number}"
        response = self.get(endpoint)
        return response.get("amendment", {})

    # Members endpoints

    def list_members(
        self,
        congress: Optional[int] = None,
        limit: int = 250,
    ) -> List[Dict[str, Any]]:
        """
        List members of Congress.

        Args:
            congress: Congress number
            limit: Number of results per page

        Returns:
            List of members
        """
        endpoint = "member"
        if congress:
            endpoint += f"/{congress}"

        results = []
        for item in self.paginate(endpoint, page_size=limit):
            results.append(item)

        return results

    def get_member_details(self, bioguide_id: str) -> Dict[str, Any]:
        """
        Get detailed information for a member.

        Args:
            bioguide_id: Member's bioguide ID

        Returns:
            Member details
        """
        endpoint = f"member/{bioguide_id}"
        response = self.get(endpoint)
        return response.get("member", {})

    def get_member_sponsored_legislation(
        self,
        bioguide_id: str,
    ) -> List[Dict[str, Any]]:
        """
        Get legislation sponsored by a member.

        Args:
            bioguide_id: Member's bioguide ID

        Returns:
            List of sponsored legislation
        """
        endpoint = f"member/{bioguide_id}/sponsored-legislation"
        results = []
        for item in self.paginate(endpoint):
            results.append(item)
        return results

    def get_member_cosponsored_legislation(
        self,
        bioguide_id: str,
    ) -> List[Dict[str, Any]]:
        """
        Get legislation cosponsored by a member.

        Args:
            bioguide_id: Member's bioguide ID

        Returns:
            List of cosponsored legislation
        """
        endpoint = f"member/{bioguide_id}/cosponsored-legislation"
        results = []
        for item in self.paginate(endpoint):
            results.append(item)
        return results

    # Committees endpoints

    def list_committees(
        self,
        congress: Optional[int] = None,
        chamber: Optional[str] = None,
        limit: int = 250,
    ) -> List[Dict[str, Any]]:
        """
        List committees.

        Args:
            congress: Congress number
            chamber: Chamber (house, senate, joint)
            limit: Number of results per page

        Returns:
            List of committees
        """
        endpoint = "committee"
        if congress:
            endpoint += f"/{congress}"
        
        params = {}
        if chamber:
            params["chamber"] = chamber

        results = []
        for item in self.paginate(endpoint, page_size=limit, **params):
            results.append(item)

        return results

    def get_committee_details(
        self,
        chamber: str,
        committee_code: str,
    ) -> Dict[str, Any]:
        """
        Get detailed information for a committee.

        Args:
            chamber: Chamber (house, senate, joint)
            committee_code: Committee code

        Returns:
            Committee details
        """
        endpoint = f"committee/{chamber}/{committee_code}"
        response = self.get(endpoint)
        return response.get("committee", {})

    # Nominations endpoints

    def list_nominations(
        self,
        congress: Optional[int] = None,
        limit: int = 250,
    ) -> List[Dict[str, Any]]:
        """
        List nominations.

        Args:
            congress: Congress number
            limit: Number of results per page

        Returns:
            List of nominations
        """
        endpoint = "nomination"
        if congress:
            endpoint += f"/{congress}"

        results = []
        for item in self.paginate(endpoint, page_size=limit):
            results.append(item)

        return results

    # Treaties endpoints

    def list_treaties(
        self,
        congress: Optional[int] = None,
        limit: int = 250,
    ) -> List[Dict[str, Any]]:
        """
        List treaties.

        Args:
            congress: Congress number
            limit: Number of results per page

        Returns:
            List of treaties
        """
        endpoint = "treaty"
        if congress:
            endpoint += f"/{congress}"

        results = []
        for item in self.paginate(endpoint, page_size=limit):
            results.append(item)

        return results

    # Summaries endpoints

    def list_summaries(
        self,
        congress: Optional[int] = None,
        limit: int = 250,
    ) -> List[Dict[str, Any]]:
        """
        List bill summaries.

        Args:
            congress: Congress number
            limit: Number of results per page

        Returns:
            List of summaries
        """
        endpoint = "summaries"
        if congress:
            endpoint += f"/{congress}"

        results = []
        for item in self.paginate(endpoint, page_size=limit):
            results.append(item)

        return results

    # Congressional Records endpoints

    def list_congressional_record(
        self,
        year: Optional[int] = None,
        month: Optional[int] = None,
        day: Optional[int] = None,
        limit: int = 250,
    ) -> List[Dict[str, Any]]:
        """
        List Congressional Record.

        Args:
            year: Year
            month: Month
            day: Day
            limit: Number of results per page

        Returns:
            List of Congressional Record items
        """
        endpoint = "congressional-record"
        if year:
            endpoint += f"/{year}"
            if month:
                endpoint += f"/{month}"
                if day:
                    endpoint += f"/{day}"

        results = []
        for item in self.paginate(endpoint, page_size=limit):
            results.append(item)

        return results
