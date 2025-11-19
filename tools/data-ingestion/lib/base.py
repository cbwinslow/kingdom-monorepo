"""
Base classes for API clients and data ingesters.

Provides common functionality for all API integrations including:
- HTTP request handling with retries
- Rate limiting
- Error handling and logging
- Progress tracking
"""

import logging
import time
from abc import ABC, abstractmethod
from typing import Any, Dict, List, Optional, Generator
from datetime import datetime

import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry
from tenacity import retry, stop_after_attempt, wait_exponential
from ratelimit import limits, sleep_and_retry

from .progress import ProgressReporter

logger = logging.getLogger(__name__)


class BaseAPIClient(ABC):
    """Base class for all API clients."""

    def __init__(
        self,
        api_key: str,
        base_url: str,
        rate_limit_calls: int = 100,
        rate_limit_period: int = 3600,
        max_retries: int = 3,
    ):
        """
        Initialize API client.

        Args:
            api_key: API authentication key
            base_url: Base URL for API endpoints
            rate_limit_calls: Maximum calls per period
            rate_limit_period: Rate limit period in seconds
            max_retries: Maximum number of retry attempts
        """
        self.api_key = api_key
        self.base_url = base_url.rstrip("/")
        self.rate_limit_calls = rate_limit_calls
        self.rate_limit_period = rate_limit_period
        self.max_retries = max_retries

        # Setup session with retry strategy
        self.session = self._create_session()

    def _create_session(self) -> requests.Session:
        """Create requests session with retry configuration."""
        session = requests.Session()
        
        retry_strategy = Retry(
            total=self.max_retries,
            backoff_factor=1,
            status_forcelist=[429, 500, 502, 503, 504],
            allowed_methods=["HEAD", "GET", "OPTIONS", "POST"],
        )
        
        adapter = HTTPAdapter(max_retries=retry_strategy)
        session.mount("http://", adapter)
        session.mount("https://", adapter)
        
        return session

    @abstractmethod
    def _prepare_headers(self) -> Dict[str, str]:
        """Prepare headers for API request. Must be implemented by subclass."""
        pass

    @abstractmethod
    def _prepare_params(self, **kwargs) -> Dict[str, Any]:
        """Prepare query parameters for API request. Must be implemented by subclass."""
        pass

    @sleep_and_retry
    @retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=4, max=10))
    def _make_request(
        self,
        endpoint: str,
        method: str = "GET",
        params: Optional[Dict[str, Any]] = None,
        data: Optional[Dict[str, Any]] = None,
        **kwargs,
    ) -> requests.Response:
        """
        Make HTTP request with rate limiting and retry logic.

        Args:
            endpoint: API endpoint path
            method: HTTP method (GET, POST, etc.)
            params: Query parameters
            data: Request body data
            **kwargs: Additional arguments to pass to requests

        Returns:
            Response object

        Raises:
            requests.HTTPError: If request fails after retries
        """
        url = f"{self.base_url}/{endpoint.lstrip('/')}"
        headers = self._prepare_headers()
        
        if params is None:
            params = {}
        params.update(self._prepare_params(**kwargs))

        logger.debug(f"Making {method} request to {url}")
        
        response = self.session.request(
            method=method,
            url=url,
            headers=headers,
            params=params,
            json=data,
            timeout=30,
        )
        
        # Handle 503 with Retry-After header (common for GovInfo)
        if response.status_code == 503 and "Retry-After" in response.headers:
            retry_after = int(response.headers.get("Retry-After", 30))
            logger.info(f"Received 503, retrying after {retry_after} seconds")
            time.sleep(retry_after)
            return self._make_request(endpoint, method, params, data, **kwargs)
        
        response.raise_for_status()
        return response

    def get(self, endpoint: str, **kwargs) -> Dict[str, Any]:
        """
        Make GET request and return JSON response.

        Args:
            endpoint: API endpoint path
            **kwargs: Additional query parameters

        Returns:
            JSON response as dictionary
        """
        response = self._make_request(endpoint, method="GET", **kwargs)
        return response.json()

    def post(self, endpoint: str, data: Optional[Dict[str, Any]] = None, **kwargs) -> Dict[str, Any]:
        """
        Make POST request and return JSON response.

        Args:
            endpoint: API endpoint path
            data: Request body data
            **kwargs: Additional query parameters

        Returns:
            JSON response as dictionary
        """
        response = self._make_request(endpoint, method="POST", data=data, **kwargs)
        return response.json()

    def paginate(
        self,
        endpoint: str,
        page_size: int = 100,
        max_pages: Optional[int] = None,
        **kwargs,
    ) -> Generator[Dict[str, Any], None, None]:
        """
        Paginate through API results.

        Args:
            endpoint: API endpoint path
            page_size: Number of results per page
            max_pages: Maximum number of pages to fetch (None for all)
            **kwargs: Additional query parameters

        Yields:
            Individual items from paginated results
        """
        page = 0
        offset = 0
        offset_mark = "*"
        
        while True:
            if max_pages is not None and page >= max_pages:
                break

            # Try different pagination styles
            try:
                params = {"pageSize": page_size, "offsetMark": offset_mark, **kwargs}
                response = self.get(endpoint, **params)
            except Exception:
                # Fallback to offset-based pagination
                params = {"limit": page_size, "offset": offset, **kwargs}
                response = self.get(endpoint, **params)

            # Extract items from response
            items = self._extract_items(response)
            
            if not items:
                break

            for item in items:
                yield item

            # Check for next page
            next_page = self._get_next_page(response)
            if not next_page:
                break

            # Update pagination parameters
            offset_mark = next_page.get("offsetMark", offset_mark)
            offset += page_size
            page += 1

    @abstractmethod
    def _extract_items(self, response: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Extract items from API response. Must be implemented by subclass."""
        pass

    @abstractmethod
    def _get_next_page(self, response: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """Get next page information from response. Must be implemented by subclass."""
        pass


class BaseIngester(ABC):
    """Base class for data ingesters."""

    def __init__(
        self,
        api_client: BaseAPIClient,
        db_manager: "DatabaseManager",
        progress_reporter: Optional[ProgressReporter] = None,
    ):
        """
        Initialize ingester.

        Args:
            api_client: API client instance
            db_manager: Database manager instance
            progress_reporter: Progress reporter instance
        """
        self.api_client = api_client
        self.db_manager = db_manager
        self.progress_reporter = progress_reporter or ProgressReporter()
        self.logger = logging.getLogger(self.__class__.__name__)

    @abstractmethod
    def ingest(self, **kwargs) -> Dict[str, Any]:
        """
        Ingest data from API to database.

        Args:
            **kwargs: Ingestion parameters

        Returns:
            Dictionary with ingestion statistics
        """
        pass

    def _track_progress(self, total: int, description: str = "Processing"):
        """
        Create progress tracker.

        Args:
            total: Total number of items to process
            description: Description for progress bar

        Returns:
            Progress tracker context manager
        """
        return self.progress_reporter.track(total, description)

    def _log_stats(self, stats: Dict[str, Any]):
        """
        Log ingestion statistics.

        Args:
            stats: Statistics dictionary
        """
        self.logger.info("Ingestion completed:")
        for key, value in stats.items():
            self.logger.info(f"  {key}: {value}")

    def _handle_error(self, error: Exception, item: Dict[str, Any]):
        """
        Handle ingestion error.

        Args:
            error: Exception that occurred
            item: Item being processed when error occurred
        """
        self.logger.error(f"Error processing item: {error}")
        self.logger.debug(f"Item data: {item}")
        self.progress_reporter.record_error(str(error))
