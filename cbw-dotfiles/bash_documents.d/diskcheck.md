# diskcheck - Check disk space with alerts

## Description
Displays disk space usage with color-coded alerts based on usage percentage threshold.

## Usage
```
diskcheck [threshold]
```

## Parameters
- `threshold` (optional): Alert threshold percentage (default: 80)

## Examples
```
# Check with default 80% threshold
diskcheck

# Check with 90% threshold
diskcheck 90

# Check with 70% threshold (more sensitive)
diskcheck 70
```

## Output Colors
- 🟢 Green: Below threshold-10%
- 🟡 Yellow: Between threshold-10% and threshold
- 🔴 Red: Above threshold (ALERT)

## See Also
- dusort - Sort directories by size
- findlarge - Find large files
- fsize - Get file/directory size
