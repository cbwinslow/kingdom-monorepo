# Data Ingestion Scripts

Comprehensive data ingestion scripts for:
- **GovInfo.gov** (OpenDiscourse source) - Congressional records, bills, and federal documents
- **Congress.gov API** - Bills, amendments, members, committees, and congressional data
- **OpenStates.org API** - State legislative data including bills, legislators, and committees

## Features

- 🔄 **Comprehensive API Coverage** - Full mapping of all endpoints to data models
- 📊 **Progress Reporting** - Built-in progress tracking for all ingestion operations
- 🗄️ **PostgreSQL Integration** - Direct ingestion into local PostgreSQL databases
- 🛡️ **Error Handling** - Robust retry mechanisms and error recovery
- 📝 **Detailed Logging** - Complete audit trail of all operations
- 🔍 **API Discovery** - Postman collections and reverse engineering tools

## Quick Start

### Prerequisites

- Python 3.11+
- PostgreSQL 12+
- API Keys:
  - [GovInfo/Congress.gov API Key](https://api.data.gov/signup/) (same key for both)
  - [OpenStates API Key](https://openstates.org/api/register/)

### Installation

```bash
cd tools/data-ingestion
pip install -r requirements.txt
```

### Configuration

Create a `.env` file in this directory:

```env
# API Keys
GOVINFO_API_KEY=your_govinfo_api_key_here
CONGRESS_API_KEY=your_congress_api_key_here
OPENSTATES_API_KEY=your_openstates_api_key_here

# Database Configuration
DATABASE_URL=postgresql://user:password@localhost:5432/dbname

# Optional Settings
LOG_LEVEL=INFO
MAX_RETRIES=3
RATE_LIMIT_CALLS=100
RATE_LIMIT_PERIOD=3600
```

## Usage

### GovInfo.gov (OpenDiscourse)

```bash
# Ingest Congressional Record
python scripts/govinfo/ingest_congressional_record.py --start-date 2024-01-01 --end-date 2024-12-31

# Ingest Bills
python scripts/govinfo/ingest_bills.py --congress 118

# Ingest all collections
python scripts/govinfo/ingest_all.py --start-date 2024-01-01
```

### Congress.gov API

```bash
# Ingest bills
python scripts/congress/ingest_bills.py --congress 118

# Ingest members
python scripts/congress/ingest_members.py --congress 118

# Ingest committees
python scripts/congress/ingest_committees.py --congress 118

# Ingest all for a congress
python scripts/congress/ingest_all.py --congress 118
```

### OpenStates.org

```bash
# Ingest bills for a state
python scripts/openstates/ingest_bills.py --jurisdiction ca --session 2024

# Ingest legislators
python scripts/openstates/ingest_people.py --jurisdiction ca

# Ingest all jurisdictions
python scripts/openstates/ingest_all.py
```

## Architecture

### Directory Structure

```
data-ingestion/
├── lib/                      # Core library modules
│   ├── base.py              # Base classes for all APIs
│   ├── database.py          # Database connection and utilities
│   ├── progress.py          # Progress reporting utilities
│   └── models/              # Pydantic models for each API
│       ├── govinfo.py
│       ├── congress.py
│       └── openstates.py
├── scripts/                 # Ingestion scripts
│   ├── govinfo/            # GovInfo.gov scripts
│   ├── congress/           # Congress.gov scripts
│   └── openstates/         # OpenStates scripts
├── postman/                # Postman collections and discovery tools
├── config/                 # Configuration files and mappings
└── tests/                  # Test suite

```

## API Endpoint Mappings

### GovInfo.gov API

| Collection | Endpoint | Data Model | Script |
|------------|----------|------------|--------|
| Congressional Record (CREC) | `/collections/CREC` | `CongressionalRecord` | `ingest_congressional_record.py` |
| Bills (BILLS) | `/collections/BILLS` | `Bill` | `ingest_bills.py` |
| Federal Register (FR) | `/collections/FR` | `FederalRegister` | `ingest_federal_register.py` |
| Congressional Hearings (CHRG) | `/collections/CHRG` | `Hearing` | `ingest_hearings.py` |
| Congressional Reports (CRPT) | `/collections/CRPT` | `Report` | `ingest_reports.py` |

See [config/govinfo_collections.json](config/govinfo_collections.json) for complete mapping.

### Congress.gov API

| Resource | Endpoint | Data Model | Script |
|----------|----------|------------|--------|
| Bills | `/v3/bill` | `CongressBill` | `ingest_bills.py` |
| Amendments | `/v3/amendment` | `Amendment` | `ingest_amendments.py` |
| Members | `/v3/member` | `Member` | `ingest_members.py` |
| Committees | `/v3/committee` | `Committee` | `ingest_committees.py` |
| Nominations | `/v3/nomination` | `Nomination` | `ingest_nominations.py` |
| Treaties | `/v3/treaty` | `Treaty` | `ingest_treaties.py` |

See [config/congress_endpoints.json](config/congress_endpoints.json) for complete mapping.

### OpenStates.org API v3

| Resource | Endpoint | Data Model | Script |
|----------|----------|------------|--------|
| Jurisdictions | `/jurisdictions` | `Jurisdiction` | `ingest_jurisdictions.py` |
| People | `/people` | `Person` | `ingest_people.py` |
| Bills | `/bills` | `StateBill` | `ingest_bills.py` |
| Committees | `/committees` | `StateCommittee` | `ingest_committees.py` |
| Events | `/events` | `Event` | `ingest_events.py` |

See [config/openstates_endpoints.json](config/openstates_endpoints.json) for complete mapping.

## Database Schema

Database schemas are automatically created on first run. See:
- [db/schemas/govinfo.sql](../../db/schemas/govinfo.sql)
- [db/schemas/congress.sql](../../db/schemas/congress.sql)
- [db/schemas/openstates.sql](../../db/schemas/openstates.sql)

## Progress Reporting

All scripts include detailed progress reporting:
- Overall progress bars
- Items processed/remaining
- Estimated time to completion
- Error counts and recovery
- Database write statistics

## Postman Collections

Pre-built Postman collections are available in the `postman/` directory:
- [GovInfo API Collection](postman/govinfo_collection.json)
- [Congress.gov API Collection](postman/congress_collection.json)
- [OpenStates API Collection](postman/openstates_collection.json)

Import these into Postman to explore and test API endpoints.

## API Discovery Tools

Use the discovery scripts to reverse engineer additional endpoints:

```bash
# Discover GovInfo endpoints
python postman/discover_govinfo.py --output postman/govinfo_discovered.json

# Discover Congress endpoints
python postman/discover_congress.py --output postman/congress_discovered.json

# Discover OpenStates endpoints
python postman/discover_openstates.py --output postman/openstates_discovered.json
```

## Development

### Running Tests

```bash
pytest tests/
```

### Code Quality

```bash
# Format code
black lib/ scripts/ tests/

# Type checking
mypy lib/ scripts/
```

## Troubleshooting

### Rate Limits

All APIs have rate limits. The scripts include automatic rate limiting and retry logic:
- GovInfo/Congress: 5,000 requests/hour (default)
- OpenStates: Varies by tier

### Database Connection Issues

Ensure PostgreSQL is running and credentials are correct in `.env`.

### API Key Issues

Verify your API keys are valid:
```bash
python scripts/verify_api_keys.py
```

## Contributing

Contributions are welcome! Please:
1. Add tests for new features
2. Update documentation
3. Follow existing code style
4. Add progress reporting to new scripts

## License

MIT License - see LICENSE file for details

## Resources

- [GovInfo API Documentation](https://api.govinfo.gov/docs/)
- [Congress.gov API Documentation](https://api.congress.gov/)
- [OpenStates API Documentation](https://docs.openstates.org/api-v3/)
- [GovInfo GitHub](https://github.com/usgpo/api)
- [Congress.gov GitHub](https://github.com/LibraryOfCongress/api.congress.gov)
- [OpenStates GitHub](https://github.com/openstates/api-v3)
