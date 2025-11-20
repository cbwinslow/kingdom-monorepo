"""
Logical operations tools for AI agents.

Provides boolean logic operations, conditional evaluation, and comparison tools.
"""

from typing import Any, List, Dict, Union


def logical_and(*values: bool) -> bool:
    """
    Perform logical AND operation on multiple boolean values.
    
    Args:
        *values: Variable number of boolean values
        
    Returns:
        True if all values are True, False otherwise
    """
    return all(values)


def logical_or(*values: bool) -> bool:
    """
    Perform logical OR operation on multiple boolean values.
    
    Args:
        *values: Variable number of boolean values
        
    Returns:
        True if any value is True, False otherwise
    """
    return any(values)


def logical_not(value: bool) -> bool:
    """
    Perform logical NOT operation on a boolean value.
    
    Args:
        value: Boolean value to negate
        
    Returns:
        Negated boolean value
    """
    return not value


def logical_xor(value1: bool, value2: bool) -> bool:
    """
    Perform logical XOR (exclusive OR) operation on two boolean values.
    
    Args:
        value1: First boolean value
        value2: Second boolean value
        
    Returns:
        True if exactly one value is True, False otherwise
    """
    return value1 != value2


def logical_nand(*values: bool) -> bool:
    """
    Perform logical NAND operation on multiple boolean values.
    
    Args:
        *values: Variable number of boolean values
        
    Returns:
        True if not all values are True, False otherwise
    """
    return not all(values)


def logical_nor(*values: bool) -> bool:
    """
    Perform logical NOR operation on multiple boolean values.
    
    Args:
        *values: Variable number of boolean values
        
    Returns:
        True if no values are True, False otherwise
    """
    return not any(values)


def evaluate_condition(
    left: Any,
    operator: str,
    right: Any,
) -> bool:
    """
    Evaluate a conditional expression.
    
    Args:
        left: Left operand
        operator: Comparison operator (==, !=, <, >, <=, >=, in, not_in, contains, starts_with, ends_with)
        right: Right operand
        
    Returns:
        Boolean result of the comparison
        
    Raises:
        ValueError: If operator is invalid
    """
    operator = operator.lower()
    
    if operator == "==" or operator == "eq" or operator == "equals":
        return left == right
    elif operator == "!=" or operator == "ne" or operator == "not_equals":
        return left != right
    elif operator == "<" or operator == "lt" or operator == "less_than":
        return left < right
    elif operator == ">" or operator == "gt" or operator == "greater_than":
        return left > right
    elif operator == "<=" or operator == "le" or operator == "less_than_or_equal":
        return left <= right
    elif operator == ">=" or operator == "ge" or operator == "greater_than_or_equal":
        return left >= right
    elif operator == "in" or operator == "contains":
        return left in right
    elif operator == "not_in":
        return left not in right
    elif operator == "starts_with":
        return str(left).startswith(str(right))
    elif operator == "ends_with":
        return str(left).endswith(str(right))
    elif operator == "is_none":
        return left is None
    elif operator == "is_not_none":
        return left is not None
    else:
        raise ValueError(f"Invalid operator: {operator}")


def compare_values(value1: Any, value2: Any) -> Dict[str, Union[bool, int]]:
    """
    Compare two values and return comparison results.
    
    Args:
        value1: First value
        value2: Second value
        
    Returns:
        Dictionary with comparison results (equal, less_than, greater_than, etc.)
    """
    result = {
        "equal": value1 == value2,
        "not_equal": value1 != value2,
    }
    
    # Try numeric comparisons
    try:
        result["less_than"] = value1 < value2
        result["greater_than"] = value1 > value2
        result["less_than_or_equal"] = value1 <= value2
        result["greater_than_or_equal"] = value1 >= value2
    except TypeError:
        result["less_than"] = None
        result["greater_than"] = None
        result["less_than_or_equal"] = None
        result["greater_than_or_equal"] = None
    
    # Type comparison
    result["same_type"] = type(value1) == type(value2)
    result["value1_type"] = type(value1).__name__
    result["value2_type"] = type(value2).__name__
    
    return result


def if_then_else(condition: bool, if_true: Any, if_false: Any) -> Any:
    """
    Conditional operation - return one of two values based on a condition.
    
    Args:
        condition: Boolean condition to evaluate
        if_true: Value to return if condition is True
        if_false: Value to return if condition is False
        
    Returns:
        if_true if condition is True, otherwise if_false
    """
    return if_true if condition else if_false


def all_true(values: List[bool]) -> bool:
    """
    Check if all values in a list are True.
    
    Args:
        values: List of boolean values
        
    Returns:
        True if all values are True, False otherwise
    """
    return all(values)


def any_true(values: List[bool]) -> bool:
    """
    Check if any value in a list is True.
    
    Args:
        values: List of boolean values
        
    Returns:
        True if any value is True, False otherwise
    """
    return any(values)


def none_true(values: List[bool]) -> bool:
    """
    Check if no values in a list are True.
    
    Args:
        values: List of boolean values
        
    Returns:
        True if no values are True, False otherwise
    """
    return not any(values)


def count_true(values: List[bool]) -> int:
    """
    Count the number of True values in a list.
    
    Args:
        values: List of boolean values
        
    Returns:
        Count of True values
    """
    return sum(values)


def is_truthy(value: Any) -> bool:
    """
    Check if a value is truthy in Python.
    
    Args:
        value: Value to check
        
    Returns:
        True if value is truthy, False otherwise
    """
    return bool(value)


def is_falsy(value: Any) -> bool:
    """
    Check if a value is falsy in Python.
    
    Args:
        value: Value to check
        
    Returns:
        True if value is falsy, False otherwise
    """
    return not bool(value)


def evaluate_expression(expression: str, variables: Dict[str, Any]) -> bool:
    """
    Evaluate a boolean expression with variables.
    
    Args:
        expression: Boolean expression string (e.g., "x > 5 and y < 10")
        variables: Dictionary of variable names to values
        
    Returns:
        Result of the expression evaluation
        
    Raises:
        ValueError: If expression is invalid
        
    Note:
        Uses eval() which can be dangerous. In production, use a proper
        expression parser or limit to safe operators.
    """
    try:
        # Create a restricted namespace for eval
        namespace = {
            "__builtins__": {},
            "True": True,
            "False": False,
            "None": None,
        }
        namespace.update(variables)
        
        result = eval(expression, namespace)
        return bool(result)
    except Exception as e:
        raise ValueError(f"Invalid expression: {str(e)}")


__all__ = [
    "logical_and",
    "logical_or",
    "logical_not",
    "logical_xor",
    "logical_nand",
    "logical_nor",
    "evaluate_condition",
    "compare_values",
    "if_then_else",
    "all_true",
    "any_true",
    "none_true",
    "count_true",
    "is_truthy",
    "is_falsy",
    "evaluate_expression",
]
