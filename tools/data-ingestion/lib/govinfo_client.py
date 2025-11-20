"""
GovInfo.gov API client implementation.

Provides access to GovInfo API endpoints for Congressional Record, Bills, 
Federal Register, and other government documents.
"""

import logging
from typing import Dict, Any, List, Optional

from .base import BaseAPIClient

logger = logging.getLogger(__name__)


class GovInfoClient(BaseAPIClient):
    """Client for GovInfo.gov API."""

    BASE_URL = "https://api.govinfo.gov"

    def __init__(self, api_key: str, **kwargs):
        """
        Initialize GovInfo API client.

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
        """Prepare headers for GovInfo API request."""
        return {
            "Accept": "application/json",
            "User-Agent": "kingdom-monorepo-data-ingestion/1.0",
        }

    def _prepare_params(self, **kwargs) -> Dict[str, Any]:
        """Prepare query parameters including API key."""
        params = {"api_key": self.api_key}
        params.update(kwargs)
        return params

    def _extract_items(self, response: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Extract items from GovInfo API response."""
        # GovInfo uses different keys for different endpoints
        if "packages" in response:
            return response["packages"]
        elif "granules" in response:
            return response["granules"]
        elif "results" in response:
            return response["results"]
        return []

    def _get_next_page(self, response: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """Get next page information from GovInfo response."""
        if "nextPage" in response:
            next_page_url = response["nextPage"]
            # Extract offsetMark from nextPage URL
            if "offsetMark=" in next_page_url:
                offset_mark = next_page_url.split("offsetMark=")[1].split("&")[0]
                return {"offsetMark": offset_mark}
        return None

    # Collections endpoints
    
    def list_collections(self) -> List[Dict[str, Any]]:
        """
        Get list of available collections.

        Returns:
            List of collection information
        """
        response = self.get("collections")
        return response.get("collections", [])

    def get_collection_updates(
        self,
        collection_code: str,
        start_date: str,
        end_date: Optional[str] = None,
        page_size: int = 100,
    ) -> List[Dict[str, Any]]:
        """
        Get packages updated in a collection within date range.

        Args:
            collection_code: Collection code (e.g., BILLS, CREC)
            start_date: Start date in ISO format (YYYY-MM-DDTHH:MM:SSZ)
            end_date: Optional end date in ISO format
            page_size: Number of results per page

        Returns:
            List of package IDs and metadata
        """
        endpoint = f"collections/{collection_code}/{start_date}"
        if end_date:
            endpoint += f"/{end_date}"

        results = []
        for item in self.paginate(endpoint, page_size=page_size):
            results.append(item)

        return results

    # Published endpoints

    def get_published_packages(
        self,
        start_date: str,
        end_date: Optional[str] = None,
        collections: Optional[List[str]] = None,
        page_size: int = 100,
    ) -> List[Dict[str, Any]]:
        """
        Get packages published within date range.

        Args:
            start_date: Start date (YYYY-MM-DD)
            end_date: Optional end date (YYYY-MM-DD)
            collections: Optional list of collection codes
            page_size: Number of results per page

        Returns:
            List of packages
        """
        endpoint = f"published/{start_date}"
        if end_date:
            endpoint += f"/{end_date}"

        params = {}
        if collections:
            params["collection"] = ",".join(collections)

        results = []
        for item in self.paginate(endpoint, page_size=page_size, **params):
            results.append(item)

        return results

    # Package endpoints

    def get_package_summary(self, package_id: str) -> Dict[str, Any]:
        """
        Get summary metadata for a package.

        Args:
            package_id: Package ID (e.g., BILLS-118hr1)

        Returns:
            Package summary information
        """
        return self.get(f"packages/{package_id}/summary")

    def get_package_granules(
        self,
        package_id: str,
        page_size: int = 100,
    ) -> List[Dict[str, Any]]:
        """
        Get granules (subdivisions) within a package.

        Args:
            package_id: Package ID
            page_size: Number of results per page

        Returns:
            List of granules
        """
        results = []
        endpoint = f"packages/{package_id}/granules"
        
        for item in self.paginate(endpoint, page_size=page_size):
            results.append(item)

        return results

    def get_granule_summary(self, package_id: str, granule_id: str) -> Dict[str, Any]:
        """
        Get summary metadata for a granule.

        Args:
            package_id: Package ID
            granule_id: Granule ID

        Returns:
            Granule summary information
        """
        return self.get(f"packages/{package_id}/granules/{granule_id}/summary")

    # Related endpoints

    def get_related_packages(
        self,
        access_id: str,
        relationship_type: Optional[str] = None,
    ) -> List[Dict[str, Any]]:
        """
        Get packages related to an access ID.

        Args:
            access_id: Access ID (e.g., BILLS-118hr1)
            relationship_type: Optional relationship type filter

        Returns:
            List of related packages
        """
        endpoint = f"related/{access_id}"
        if relationship_type:
            endpoint += f"/{relationship_type}"

        return self.get(endpoint)

    # Search endpoint

    def search(
        self,
        query: str,
        page_size: int = 100,
        offset_mark: str = "*",
        sort_field: str = "score",
        sort_order: str = "DESC",
    ) -> Dict[str, Any]:
        """
        Search GovInfo content.

        Args:
            query: Search query string
            page_size: Number of results per page
            offset_mark: Pagination offset mark
            sort_field: Field to sort by (score, publishdate, lastModified, title)
            sort_order: Sort order (ASC or DESC)

        Returns:
            Search results
        """
        data = {
            "query": query,
            "pageSize": str(page_size),
            "offsetMark": offset_mark,
            "sorts": [
                {
                    "field": sort_field,
                    "sortOrder": sort_order,
                }
            ],
        }

        return self.post("search", data=data)

    # Convenience methods for specific collections

    def get_congressional_record(
        self,
        start_date: str,
        end_date: Optional[str] = None,
        page_size: int = 100,
    ) -> List[Dict[str, Any]]:
        """
        Get Congressional Record packages.

        Args:
            start_date: Start date in ISO format
            end_date: Optional end date in ISO format
            page_size: Number of results per page

        Returns:
            List of Congressional Record packages
        """
        return self.get_collection_updates("CREC", start_date, end_date, page_size)

    def get_bills(
        self,
        start_date: str,
        end_date: Optional[str] = None,
        page_size: int = 100,
    ) -> List[Dict[str, Any]]:
        """
        Get bill packages.

        Args:
            start_date: Start date in ISO format
            end_date: Optional end date in ISO format
            page_size: Number of results per page

        Returns:
            List of bill packages
        """
        return self.get_collection_updates("BILLS", start_date, end_date, page_size)

    def get_federal_register(
        self,
        start_date: str,
        end_date: Optional[str] = None,
        page_size: int = 100,
    ) -> List[Dict[str, Any]]:
        """
        Get Federal Register packages.

        Args:
            start_date: Start date in ISO format
            end_date: Optional end date in ISO format
            page_size: Number of results per page

        Returns:
            List of Federal Register packages
        """
        return self.get_collection_updates("FR", start_date, end_date, page_size)
