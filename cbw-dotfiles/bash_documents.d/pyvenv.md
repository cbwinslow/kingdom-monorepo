# pyvenv - Create Python virtual environment

## Description
Creates and activates a Python virtual environment in one command.

## Usage
```
pyvenv [venv_name]
```

## Parameters
- `venv_name` (optional): Virtual environment directory name (default: .venv)

## Examples
```
# Create and activate default .venv
pyvenv

# Create and activate custom named venv
pyvenv myenv

# Typical workflow
pyvenv              # Create venv
pip install flask   # Install packages
pydeactivate        # Deactivate when done
```

## See Also
- pyreqs - Install from requirements.txt
- pysave - Save requirements.txt
- pydeactivate - Deactivate virtual environment
