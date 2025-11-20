# todo - Simple TODO list manager

## Description
Manages a simple TODO list stored in ~/.todo.txt with add, done, and clear operations.

## Usage
```
todo                    # Show TODO list
todo add <item>         # Add item to list
todo done <number>      # Mark item as done (remove)
todo clear              # Clear entire list
```

## Parameters
- `add <item>`: Item text to add
- `done <number>`: Line number to remove
- `clear`: No parameters

## Examples
```
# Show current TODO list
todo

# Add items
todo add "Review pull requests"
todo add "Update documentation"
todo add "Deploy to production"

# Mark item 2 as done
todo done 2

# Clear all items
todo clear
```

## See Also
- note - Quick note taking
- shownotes - Show recent notes
- bookmark - Bookmark directories
