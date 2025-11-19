"""
Progress reporting utilities for data ingestion.

Provides progress bars, statistics tracking, and logging for ingestion operations.
"""

import logging
from contextlib import contextmanager
from datetime import datetime
from typing import Optional, Dict, Any, List
from dataclasses import dataclass, field

from tqdm import tqdm

logger = logging.getLogger(__name__)


@dataclass
class IngestionStats:
    """Track statistics for an ingestion operation."""

    start_time: datetime = field(default_factory=datetime.now)
    end_time: Optional[datetime] = None
    total_items: int = 0
    processed_items: int = 0
    successful_items: int = 0
    failed_items: int = 0
    skipped_items: int = 0
    errors: List[str] = field(default_factory=list)
    
    def mark_complete(self):
        """Mark ingestion as complete."""
        self.end_time = datetime.now()
    
    @property
    def duration(self) -> float:
        """Get duration in seconds."""
        if self.end_time is None:
            return (datetime.now() - self.start_time).total_seconds()
        return (self.end_time - self.start_time).total_seconds()
    
    @property
    def success_rate(self) -> float:
        """Get success rate as percentage."""
        if self.processed_items == 0:
            return 0.0
        return (self.successful_items / self.processed_items) * 100
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert stats to dictionary."""
        return {
            "start_time": self.start_time.isoformat(),
            "end_time": self.end_time.isoformat() if self.end_time else None,
            "duration_seconds": round(self.duration, 2),
            "total_items": self.total_items,
            "processed_items": self.processed_items,
            "successful_items": self.successful_items,
            "failed_items": self.failed_items,
            "skipped_items": self.skipped_items,
            "success_rate": round(self.success_rate, 2),
            "error_count": len(self.errors),
        }


class ProgressReporter:
    """Progress reporter for data ingestion operations."""

    def __init__(self, verbose: bool = True):
        """
        Initialize progress reporter.

        Args:
            verbose: Whether to show progress bars
        """
        self.verbose = verbose
        self.stats = IngestionStats()
        self._progress_bar: Optional[tqdm] = None

    @contextmanager
    def track(self, total: int, description: str = "Processing"):
        """
        Track progress for a batch of items.

        Args:
            total: Total number of items
            description: Description for progress bar

        Yields:
            Progress reporter instance
        """
        self.stats.total_items = total
        
        if self.verbose:
            self._progress_bar = tqdm(
                total=total,
                desc=description,
                unit="items",
                ncols=100,
            )
        
        try:
            yield self
        finally:
            if self._progress_bar:
                self._progress_bar.close()
                self._progress_bar = None
            
            self.stats.mark_complete()

    def update(self, n: int = 1):
        """
        Update progress by n items.

        Args:
            n: Number of items to increment
        """
        self.stats.processed_items += n
        if self._progress_bar:
            self._progress_bar.update(n)

    def record_success(self):
        """Record a successful item."""
        self.stats.successful_items += 1
        self.update()

    def record_failure(self):
        """Record a failed item."""
        self.stats.failed_items += 1
        self.update()

    def record_skip(self):
        """Record a skipped item."""
        self.stats.skipped_items += 1
        self.update()

    def record_error(self, error: str):
        """
        Record an error message.

        Args:
            error: Error message
        """
        self.stats.errors.append(error)
        if len(self.stats.errors) <= 10:  # Only log first 10 errors
            logger.error(error)

    def set_postfix(self, **kwargs):
        """
        Set additional information in progress bar.

        Args:
            **kwargs: Key-value pairs to display
        """
        if self._progress_bar:
            self._progress_bar.set_postfix(**kwargs)

    def print_summary(self):
        """Print summary of ingestion statistics."""
        print("\n" + "=" * 80)
        print("INGESTION SUMMARY")
        print("=" * 80)
        
        stats = self.stats.to_dict()
        
        print(f"Duration: {stats['duration_seconds']} seconds")
        print(f"Total Items: {stats['total_items']}")
        print(f"Processed: {stats['processed_items']}")
        print(f"Successful: {stats['successful_items']}")
        print(f"Failed: {stats['failed_items']}")
        print(f"Skipped: {stats['skipped_items']}")
        print(f"Success Rate: {stats['success_rate']}%")
        
        if stats['error_count'] > 0:
            print(f"\nErrors encountered: {stats['error_count']}")
            if self.stats.errors:
                print("\nFirst few errors:")
                for i, error in enumerate(self.stats.errors[:5], 1):
                    print(f"  {i}. {error}")
        
        print("=" * 80 + "\n")

    def get_stats(self) -> Dict[str, Any]:
        """
        Get current statistics.

        Returns:
            Statistics dictionary
        """
        return self.stats.to_dict()
