"""Tests for logical operations."""

import pytest
from openai_tools.logical import (
    logical_and,
    logical_or,
    logical_not,
    logical_xor,
    evaluate_condition,
    compare_values,
    if_then_else,
)


def test_logical_and():
    """Test logical AND operation."""
    assert logical_and(True, True, True) is True
    assert logical_and(True, False, True) is False
    assert logical_and(True) is True
    assert logical_and() is True  # Empty is True


def test_logical_or():
    """Test logical OR operation."""
    assert logical_or(False, False, False) is False
    assert logical_or(True, False, False) is True
    assert logical_or(False) is False
    assert logical_or() is False  # Empty is False


def test_logical_not():
    """Test logical NOT operation."""
    assert logical_not(True) is False
    assert logical_not(False) is True


def test_logical_xor():
    """Test logical XOR operation."""
    assert logical_xor(True, False) is True
    assert logical_xor(False, True) is True
    assert logical_xor(True, True) is False
    assert logical_xor(False, False) is False


def test_evaluate_condition():
    """Test conditional evaluation."""
    assert evaluate_condition(10, "==", 10) is True
    assert evaluate_condition(10, "!=", 5) is True
    assert evaluate_condition(10, ">", 5) is True
    assert evaluate_condition(10, "<", 15) is True
    assert evaluate_condition(10, ">=", 10) is True
    assert evaluate_condition(10, "<=", 10) is True
    
    # String operations
    assert evaluate_condition("hello", "starts_with", "hel") is True
    assert evaluate_condition("hello", "ends_with", "lo") is True
    assert evaluate_condition("e", "in", "hello") is True


def test_compare_values():
    """Test value comparison."""
    result = compare_values(10, 5)
    
    assert result["equal"] is False
    assert result["not_equal"] is True
    assert result["greater_than"] is True
    assert result["less_than"] is False
    
    # Same values
    result2 = compare_values(5, 5)
    assert result2["equal"] is True


def test_if_then_else():
    """Test conditional return."""
    assert if_then_else(True, "yes", "no") == "yes"
    assert if_then_else(False, "yes", "no") == "no"
    assert if_then_else(10 > 5, 100, 200) == 100
