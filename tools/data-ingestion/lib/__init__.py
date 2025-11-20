"""
Data Ingestion Library

Core library for ingesting data from GovInfo.gov, Congress.gov API, and OpenStates.org
into PostgreSQL databases with progress reporting.
"""

__version__ = "1.0.0"

from .base import BaseAPIClient, BaseIngester
from .database import DatabaseManager
from .progress import ProgressReporter

__all__ = [
    "BaseAPIClient",
    "BaseIngester", 
    "DatabaseManager",
    "ProgressReporter",
]
