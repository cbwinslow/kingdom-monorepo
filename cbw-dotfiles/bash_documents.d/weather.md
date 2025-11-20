# weather - Get weather report

## Description
Displays current weather information for a location. Requires internet connection.

## Usage
```
weather [location]
```

## Parameters
- `location` (optional): City name or location (default: current location based on IP)

## Examples
```
# Get weather for current location
weather

# Get weather for specific city
weather "New York"

# Get weather for city with country
weather "London,UK"

# Full detailed report
weather_full "Tokyo"
```

## See Also
- weather_full - Detailed weather report
