"""
OpenStates.org API v3 client implementation.

Provides access to OpenStates API endpoints for state legislative data including
jurisdictions, people, bills, committees, and events.
"""

import logging
from typing import Dict, Any, List, Optional

from .base import BaseAPIClient

logger = logging.getLogger(__name__)


class OpenStatesClient(BaseAPIClient):
    """Client for OpenStates.org API v3."""

    BASE_URL = "https://v3.openstates.org"

    def __init__(self, api_key: str, **kwargs):
        """
        Initialize OpenStates API client.

        Args:
            api_key: OpenStates API key
            **kwargs: Additional arguments for BaseAPIClient
        """
        super().__init__(
            api_key=api_key,
            base_url=self.BASE_URL,
            rate_limit_calls=1000,  # Conservative default, varies by tier
            rate_limit_period=3600,
            **kwargs,
        )

    def _prepare_headers(self) -> Dict[str, str]:
        """Prepare headers for OpenStates API request."""
        return {
            "Accept": "application/json",
            "X-API-KEY": self.api_key,
            "User-Agent": "kingdom-monorepo-data-ingestion/1.0",
        }

    def _prepare_params(self, **kwargs) -> Dict[str, Any]:
        """Prepare query parameters (API key in header, not params)."""
        return kwargs

    def _extract_items(self, response: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Extract items from OpenStates API response."""
        if "results" in response:
            return response["results"]
        return []

    def _get_next_page(self, response: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """Get next page information from OpenStates response."""
        pagination = response.get("pagination", {})
        if pagination.get("next"):
            # Extract page number or offset from next URL
            next_url = pagination["next"]
            if "page=" in next_url:
                page = int(next_url.split("page=")[1].split("&")[0])
                return {"page": page}
        return None

    # Jurisdictions endpoints

    def list_jurisdictions(self) -> List[Dict[str, Any]]:
        """
        List all available jurisdictions.

        Returns:
            List of jurisdictions
        """
        response = self.get("jurisdictions")
        return response.get("results", [])

    def get_jurisdiction_details(self, jurisdiction_id: str) -> Dict[str, Any]:
        """
        Get detailed information for a jurisdiction.

        Args:
            jurisdiction_id: Jurisdiction ID (e.g., ocd-jurisdiction/country:us/state:ca)

        Returns:
            Jurisdiction details
        """
        return self.get(f"jurisdictions/{jurisdiction_id}")

    # People endpoints

    def list_people(
        self,
        jurisdiction: Optional[str] = None,
        name: Optional[str] = None,
        district: Optional[str] = None,
        party: Optional[str] = None,
        current_role: bool = True,
        per_page: int = 100,
    ) -> List[Dict[str, Any]]:
        """
        List people (legislators, governors, etc.).

        Args:
            jurisdiction: Jurisdiction ID or abbreviation (e.g., ca)
            name: Filter by name
            district: Filter by district
            party: Filter by party
            current_role: Whether to filter to current roles only
            per_page: Number of results per page

        Returns:
            List of people
        """
        params = {"per_page": per_page}
        
        if jurisdiction:
            params["jurisdiction"] = jurisdiction
        if name:
            params["name"] = name
        if district:
            params["district"] = district
        if party:
            params["party"] = party
        if not current_role:
            params["current_role"] = "false"

        results = []
        for item in self.paginate("people", page_size=per_page, **params):
            results.append(item)

        return results

    def get_people_by_location(
        self,
        lat: float,
        lng: float,
    ) -> List[Dict[str, Any]]:
        """
        Get legislators for a given location.

        Args:
            lat: Latitude
            lng: Longitude

        Returns:
            List of people representing that location
        """
        params = {"lat": lat, "lng": lng}
        response = self.get("people.geo", **params)
        return response.get("results", [])

    def get_person_details(self, person_id: str) -> Dict[str, Any]:
        """
        Get detailed information for a person.

        Args:
            person_id: Person ID (e.g., ocd-person/...)

        Returns:
            Person details
        """
        return self.get(f"people/{person_id}")

    # Bills endpoints

    def search_bills(
        self,
        jurisdiction: Optional[str] = None,
        session: Optional[str] = None,
        chamber: Optional[str] = None,
        query: Optional[str] = None,
        subject: Optional[str] = None,
        classification: Optional[str] = None,
        updated_since: Optional[str] = None,
        per_page: int = 100,
    ) -> List[Dict[str, Any]]:
        """
        Search bills.

        Args:
            jurisdiction: Jurisdiction ID or abbreviation
            session: Legislative session
            chamber: Chamber (upper, lower)
            query: Text search query
            subject: Filter by subject
            classification: Bill classification (bill, resolution, etc.)
            updated_since: Filter to bills updated since date (YYYY-MM-DD)
            per_page: Number of results per page

        Returns:
            List of bills
        """
        params = {"per_page": per_page}
        
        if jurisdiction:
            params["jurisdiction"] = jurisdiction
        if session:
            params["session"] = session
        if chamber:
            params["chamber"] = chamber
        if query:
            params["q"] = query
        if subject:
            params["subject"] = subject
        if classification:
            params["classification"] = classification
        if updated_since:
            params["updated_since"] = updated_since

        results = []
        for item in self.paginate("bills", page_size=per_page, **params):
            results.append(item)

        return results

    def get_bill_by_id(self, bill_id: str) -> Dict[str, Any]:
        """
        Get bill by internal ID.

        Args:
            bill_id: Bill ID (e.g., ocd-bill/...)

        Returns:
            Bill details
        """
        return self.get(f"bills/{bill_id}")

    def get_bill_by_jurisdiction(
        self,
        jurisdiction: str,
        session: str,
        identifier: str,
    ) -> Dict[str, Any]:
        """
        Get bill by jurisdiction, session, and identifier.

        Args:
            jurisdiction: Jurisdiction abbreviation (e.g., ca)
            session: Legislative session
            identifier: Bill identifier (e.g., HB1)

        Returns:
            Bill details
        """
        endpoint = f"bills/{jurisdiction}/{session}/{identifier}"
        return self.get(endpoint)

    # Committees endpoints

    def list_committees(
        self,
        jurisdiction: Optional[str] = None,
        chamber: Optional[str] = None,
        per_page: int = 100,
    ) -> List[Dict[str, Any]]:
        """
        List committees.

        Args:
            jurisdiction: Jurisdiction ID or abbreviation
            chamber: Chamber (upper, lower)
            per_page: Number of results per page

        Returns:
            List of committees
        """
        params = {"per_page": per_page}
        
        if jurisdiction:
            params["jurisdiction"] = jurisdiction
        if chamber:
            params["chamber"] = chamber

        results = []
        for item in self.paginate("committees", page_size=per_page, **params):
            results.append(item)

        return results

    def get_committee_details(self, committee_id: str) -> Dict[str, Any]:
        """
        Get detailed information for a committee.

        Args:
            committee_id: Committee ID (e.g., ocd-organization/...)

        Returns:
            Committee details
        """
        return self.get(f"committees/{committee_id}")

    # Events endpoints

    def list_events(
        self,
        jurisdiction: Optional[str] = None,
        start_date: Optional[str] = None,
        end_date: Optional[str] = None,
        per_page: int = 100,
    ) -> List[Dict[str, Any]]:
        """
        List events (hearings, sessions, etc.).

        Args:
            jurisdiction: Jurisdiction ID or abbreviation
            start_date: Filter to events on or after date (YYYY-MM-DD)
            end_date: Filter to events on or before date (YYYY-MM-DD)
            per_page: Number of results per page

        Returns:
            List of events
        """
        params = {"per_page": per_page}
        
        if jurisdiction:
            params["jurisdiction"] = jurisdiction
        if start_date:
            params["start_date"] = start_date
        if end_date:
            params["end_date"] = end_date

        results = []
        for item in self.paginate("events", page_size=per_page, **params):
            results.append(item)

        return results

    def get_event_details(self, event_id: str) -> Dict[str, Any]:
        """
        Get detailed information for an event.

        Args:
            event_id: Event ID (e.g., ocd-event/...)

        Returns:
            Event details
        """
        return self.get(f"events/{event_id}")

    # Convenience methods

    def get_all_states(self) -> List[str]:
        """
        Get list of all state abbreviations.

        Returns:
            List of state abbreviations
        """
        jurisdictions = self.list_jurisdictions()
        states = []
        
        for jurisdiction in jurisdictions:
            jurisdiction_id = jurisdiction.get("id", "")
            if "country:us/state:" in jurisdiction_id:
                state = jurisdiction_id.split("state:")[1].split("/")[0]
                states.append(state)
        
        return sorted(states)

    def get_current_legislators_by_state(self, state: str) -> List[Dict[str, Any]]:
        """
        Get current legislators for a state.

        Args:
            state: State abbreviation (e.g., ca)

        Returns:
            List of current legislators
        """
        return self.list_people(jurisdiction=state, current_role=True)

    def get_recent_bills_by_state(
        self,
        state: str,
        session: Optional[str] = None,
        days: int = 30,
    ) -> List[Dict[str, Any]]:
        """
        Get recent bills for a state.

        Args:
            state: State abbreviation
            session: Optional session filter
            days: Number of days back to search

        Returns:
            List of recent bills
        """
        from datetime import datetime, timedelta
        
        updated_since = (datetime.now() - timedelta(days=days)).strftime("%Y-%m-%d")
        
        return self.search_bills(
            jurisdiction=state,
            session=session,
            updated_since=updated_since,
        )
