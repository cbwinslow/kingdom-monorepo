# pomodoro - Pomodoro technique timer

## Description
Runs a complete Pomodoro cycle with work session and break. Default is 25 minutes work, 5 minutes break.

## Usage
```
pomodoro [work_minutes] [break_minutes]
```

## Parameters
- `work_minutes` (optional): Work session duration in minutes (default: 25)
- `break_minutes` (optional): Break duration in minutes (default: 5)

## Examples
```
# Standard Pomodoro (25 min work, 5 min break)
pomodoro

# Custom timing (50 min work, 10 min break)
pomodoro 50 10

# Short session (15 min work, 3 min break)
pomodoro 15 3
```

## See Also
- timer - Countdown timer
- stopwatch - Elapsed time counter
