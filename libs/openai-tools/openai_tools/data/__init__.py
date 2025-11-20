"""
Data processing tools for AI agents.

Provides tools for parsing, converting, filtering, and transforming data
in various formats (JSON, YAML, CSV, XML).
"""

import json
import csv
import io
from typing import Any, Dict, List, Optional, Union
import yaml


def parse_json(json_string: str) -> Union[Dict[str, Any], List[Any]]:
    """
    Parse a JSON string into a Python object.
    
    Args:
        json_string: JSON string to parse
        
    Returns:
        Parsed JSON as a dictionary or list
        
    Raises:
        json.JSONDecodeError: If JSON is invalid
    """
    return json.loads(json_string)


def stringify_json(data: Union[Dict[str, Any], List[Any]], indent: int = 2) -> str:
    """
    Convert a Python object to a JSON string.
    
    Args:
        data: Python dictionary or list to convert
        indent: Number of spaces for indentation (default: 2)
        
    Returns:
        JSON string representation
    """
    return json.dumps(data, indent=indent, ensure_ascii=False)


def parse_yaml(yaml_string: str) -> Union[Dict[str, Any], List[Any]]:
    """
    Parse a YAML string into a Python object.
    
    Args:
        yaml_string: YAML string to parse
        
    Returns:
        Parsed YAML as a dictionary or list
        
    Raises:
        yaml.YAMLError: If YAML is invalid
    """
    return yaml.safe_load(yaml_string)


def stringify_yaml(data: Union[Dict[str, Any], List[Any]]) -> str:
    """
    Convert a Python object to a YAML string.
    
    Args:
        data: Python dictionary or list to convert
        
    Returns:
        YAML string representation
    """
    return yaml.dump(data, default_flow_style=False, allow_unicode=True)


def parse_csv(
    csv_string: str,
    delimiter: str = ",",
    has_header: bool = True,
) -> List[Dict[str, str]]:
    """
    Parse a CSV string into a list of dictionaries.
    
    Args:
        csv_string: CSV string to parse
        delimiter: Field delimiter (default: ,)
        has_header: Whether the first row is a header (default: True)
        
    Returns:
        List of row dictionaries if has_header=True, otherwise list of lists
    """
    reader = csv.DictReader(io.StringIO(csv_string), delimiter=delimiter) if has_header else csv.reader(io.StringIO(csv_string), delimiter=delimiter)
    
    if has_header:
        return list(reader)
    else:
        return [list(row) for row in reader]


def stringify_csv(
    data: List[Dict[str, Any]],
    delimiter: str = ",",
    include_header: bool = True,
) -> str:
    """
    Convert a list of dictionaries to a CSV string.
    
    Args:
        data: List of dictionaries to convert
        delimiter: Field delimiter (default: ,)
        include_header: Whether to include header row (default: True)
        
    Returns:
        CSV string representation
    """
    if not data:
        return ""
    
    output = io.StringIO()
    
    if include_header:
        fieldnames = list(data[0].keys())
        writer = csv.DictWriter(output, fieldnames=fieldnames, delimiter=delimiter)
        writer.writeheader()
        writer.writerows(data)
    else:
        writer = csv.writer(output, delimiter=delimiter)
        for row in data:
            writer.writerow(row.values())
    
    return output.getvalue()


def convert_format(
    data_string: str,
    from_format: str,
    to_format: str,
) -> str:
    """
    Convert data between different formats.
    
    Args:
        data_string: Data string to convert
        from_format: Source format (json, yaml, csv)
        to_format: Target format (json, yaml, csv)
        
    Returns:
        Converted data string
        
    Raises:
        ValueError: If format is not supported
    """
    from_format = from_format.lower()
    to_format = to_format.lower()
    
    # Parse from source format
    if from_format == "json":
        data = parse_json(data_string)
    elif from_format == "yaml":
        data = parse_yaml(data_string)
    elif from_format == "csv":
        data = parse_csv(data_string)
    else:
        raise ValueError(f"Unsupported source format: {from_format}")
    
    # Convert to target format
    if to_format == "json":
        return stringify_json(data)
    elif to_format == "yaml":
        return stringify_yaml(data)
    elif to_format == "csv":
        return stringify_csv(data)
    else:
        raise ValueError(f"Unsupported target format: {to_format}")


def filter_data(
    data: List[Dict[str, Any]],
    filter_key: str,
    filter_value: Any,
    operator: str = "==",
) -> List[Dict[str, Any]]:
    """
    Filter a list of dictionaries based on a condition.
    
    Args:
        data: List of dictionaries to filter
        filter_key: Key to filter on
        filter_value: Value to compare against
        operator: Comparison operator (==, !=, <, >, <=, >=, in, not_in)
        
    Returns:
        Filtered list of dictionaries
    """
    from openai_tools.logical import evaluate_condition
    
    result = []
    for item in data:
        if filter_key in item:
            if evaluate_condition(item[filter_key], operator, filter_value):
                result.append(item)
    
    return result


def transform_data(
    data: List[Dict[str, Any]],
    transformations: Dict[str, str],
) -> List[Dict[str, Any]]:
    """
    Transform data by renaming or computing new fields.
    
    Args:
        data: List of dictionaries to transform
        transformations: Dictionary mapping new field names to old field names or expressions
        
    Returns:
        Transformed list of dictionaries
    """
    result = []
    
    for item in data:
        new_item = {}
        for new_key, old_key in transformations.items():
            if old_key in item:
                new_item[new_key] = item[old_key]
        result.append(new_item)
    
    return result


def merge_data(*datasets: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """
    Merge multiple datasets into one.
    
    Args:
        *datasets: Variable number of data lists to merge
        
    Returns:
        Merged list of all dictionaries
    """
    result = []
    for dataset in datasets:
        result.extend(dataset)
    return result


def group_by(
    data: List[Dict[str, Any]],
    key: str,
) -> Dict[Any, List[Dict[str, Any]]]:
    """
    Group data by a specific key.
    
    Args:
        data: List of dictionaries to group
        key: Key to group by
        
    Returns:
        Dictionary mapping key values to lists of matching items
    """
    groups: Dict[Any, List[Dict[str, Any]]] = {}
    
    for item in data:
        if key in item:
            group_key = item[key]
            if group_key not in groups:
                groups[group_key] = []
            groups[group_key].append(item)
    
    return groups


def sort_data(
    data: List[Dict[str, Any]],
    sort_key: str,
    reverse: bool = False,
) -> List[Dict[str, Any]]:
    """
    Sort data by a specific key.
    
    Args:
        data: List of dictionaries to sort
        sort_key: Key to sort by
        reverse: Whether to sort in descending order (default: False)
        
    Returns:
        Sorted list of dictionaries
    """
    return sorted(data, key=lambda x: x.get(sort_key), reverse=reverse)


def aggregate_data(
    data: List[Dict[str, Any]],
    group_key: str,
    aggregate_key: str,
    operation: str = "sum",
) -> Dict[Any, Union[int, float, List[Any]]]:
    """
    Aggregate data by grouping and applying an operation.
    
    Args:
        data: List of dictionaries to aggregate
        group_key: Key to group by
        aggregate_key: Key to aggregate
        operation: Aggregation operation (sum, avg, count, min, max, list)
        
    Returns:
        Dictionary mapping group keys to aggregated values
    """
    groups = group_by(data, group_key)
    result = {}
    
    for group_value, items in groups.items():
        values = [item[aggregate_key] for item in items if aggregate_key in item]
        
        if operation == "sum":
            result[group_value] = sum(values)
        elif operation == "avg" or operation == "average":
            result[group_value] = sum(values) / len(values) if values else 0
        elif operation == "count":
            result[group_value] = len(values)
        elif operation == "min":
            result[group_value] = min(values) if values else None
        elif operation == "max":
            result[group_value] = max(values) if values else None
        elif operation == "list":
            result[group_value] = values
        else:
            raise ValueError(f"Unsupported operation: {operation}")
    
    return result


def flatten_dict(
    data: Dict[str, Any],
    parent_key: str = "",
    separator: str = ".",
) -> Dict[str, Any]:
    """
    Flatten a nested dictionary.
    
    Args:
        data: Dictionary to flatten
        parent_key: Parent key prefix (used internally for recursion)
        separator: Separator for nested keys (default: .)
        
    Returns:
        Flattened dictionary
    """
    items = []
    
    for key, value in data.items():
        new_key = f"{parent_key}{separator}{key}" if parent_key else key
        
        if isinstance(value, dict):
            items.extend(flatten_dict(value, new_key, separator).items())
        else:
            items.append((new_key, value))
    
    return dict(items)


def unflatten_dict(
    data: Dict[str, Any],
    separator: str = ".",
) -> Dict[str, Any]:
    """
    Unflatten a flattened dictionary.
    
    Args:
        data: Flattened dictionary
        separator: Separator for nested keys (default: .)
        
    Returns:
        Nested dictionary
    """
    result: Dict[str, Any] = {}
    
    for key, value in data.items():
        parts = key.split(separator)
        current = result
        
        for part in parts[:-1]:
            if part not in current:
                current[part] = {}
            current = current[part]
        
        current[parts[-1]] = value
    
    return result


__all__ = [
    "parse_json",
    "stringify_json",
    "parse_yaml",
    "stringify_yaml",
    "parse_csv",
    "stringify_csv",
    "convert_format",
    "filter_data",
    "transform_data",
    "merge_data",
    "group_by",
    "sort_data",
    "aggregate_data",
    "flatten_dict",
    "unflatten_dict",
]
