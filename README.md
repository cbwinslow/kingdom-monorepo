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

1. Clone this repository
2. Initialize submodules: `git submodule update --init --recursive`
3. Install dependencies for your target workspace
4. Check the specific README in each workspace for detailed setup

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