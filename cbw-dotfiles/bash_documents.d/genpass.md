# genpass - Generate random password

## Description
Generates a secure random password using alphanumeric characters and symbols.

## Usage
```
genpass [length]
```

## Parameters
- `length` (optional): Password length (default: 16)

## Examples
```
# Generate 16-character password
genpass

# Generate 32-character password
genpass 32

# Generate 8-character password
genpass 8

# Save to variable
PASSWORD=$(genpass 20)
echo "Generated: $PASSWORD"
```

## See Also
- genuuid - Generate UUID
- randstr - Random string
- randnum - Random number
