# Kingdom Monorepo

A comprehensive monorepo for all development projects, tools, and infrastructure.

## Structure

- **agents/** - AI agents, crews, tools, and toolsets
- **ansible/** - Infrastructure as code and automation
- **apps/** - GUI, TUI, web, and mobile applications
- **data/** - Knowledge bases, indexes, and data stores
- **db/** - Database schemas and migrations
- **docs/** - Documentation, handbooks, and project notes
- **infra/** - Infrastructure configuration and deployment
- **libs/** - Shared libraries and utilities
- **projects/** - Active and archived projects
- **research/** - Research and experimental work
- **services/** - Microservices and APIs
- **tools/** - Development tools and utilities

## Getting Started

### Quick Setup
```bash
# Clone the repository
git clone https://github.com/cbwinslow/kingdom-monorepo.git
cd kingdom-monorepo

# Run the setup script (handles submodules properly)
./setup.sh

# Install dependencies and bootstrap
make bootstrap
```

### Manual Setup
```bash
# Clone the repository
git clone https://github.com/cbwinslow/kingdom-monorepo.git
cd kingdom-monorepo

# Initialize main submodules
git submodule update --init

# Handle opendiscourse separately (has nested submodules)
cd opendiscourse
git submodule update --init --recursive || echo "Some nested submodules may need manual setup"
cd ..

# Install dependencies
make bootstrap
```

## Submodules

This monorepo uses Git submodules to organize related repositories:

- `cloudcurio-monorepo` - CloudCurio tools and infrastructure
- `opendiscourse` - Political data intelligence platform
- `cbw-dotfiles` - Personal dotfiles and environment setup
- `cbw-knowledge-base` - Personal knowledge base

## Development

Each workspace is independently manageable but shares common tooling and configuration at the root level.

## License

See LICENSE file for details.