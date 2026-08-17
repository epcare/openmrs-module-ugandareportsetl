# Uganda Reports ETL Module

## Overview

The Uganda Reports ETL Module is an OpenMRS module that implements HMIS 106A HIV Prevention, Care and Treatment Indicator Reporting. It provides ETL (Extract, Transform, Load) functionality using the Mamba ETL framework and integrates with Report Builder for generating standardized HIV indicators.

**Key Features:**
- HMIS 106A indicator reporting (7 sections, ~77 indicators)
- Mamba ETL integration for data processing
- Report Builder integration for indicator definition
- REST API for ETL monitoring and status tracking
- Automated ETL execution via scheduled tasks

---

## Documentation

| Document | Description |
|----------|-------------|
| **[REST API Documentation](docs/FRONTEND_API_DOCUMENTATION.md)** | Complete API reference for ETL monitoring endpoints |
| **[HMIS 106A Indicator Creation Guide](docs/HMIS_106A_INDICATOR_CREATION_GUIDE.md)** | Guide for creating and configuring HMIS 106A indicators |

---

## Quick Start

### Installation

1. Build the module:
```bash
mvn clean install
```

2. Upload the resulting `.omod` file via OpenMRS Administration > Manage Modules

Or, drop the `.omod` into the `~/.OpenMRS/modules` folder and restart OpenMRS.

### Initial Setup

After installation, configure the ETL:

1. Navigate to the module settings in OpenMRS
2. Configure database connections (source OpenMRS database, target ETL database)
3. Set ETL execution interval
4. Run the initial ETL via the "Setup Mamba ETL" scheduled task

---

## REST API Endpoints

The module provides REST endpoints for monitoring ETL processes.

**Base URL:** `/ws/rest/v1/ugandareportsetl/etl`

### Available Endpoints

| Endpoint | Description |
|----------|-------------|
| `GET /progress` | Get current ETL execution status |
| `GET /recent?limit=N` | Get recent ETL execution history |
| `GET /errors?limit=N` | Get ETL error log entries |
| `GET /settings` | Get current ETL configuration |
| `GET /status` | Check if ETL is running |

**Example:**
```javascript
// Get current ETL progress
fetch('/openmrs/ws/rest/v1/ugandareportsetl/etl/progress')
  .then(r => r.json())
  .then(data => console.log(data.progressPercentage + '% complete'));
```

See [REST API Documentation](docs/FRONTEND_API_DOCUMENTATION.md) for complete API reference including request/response formats and examples.

---

## HMIS 106A Indicators

### Sections Covered

| Section | Indicators | Status |
|---------|-----------|--------|
| **1A** HIV Care/ART Services | 52 | Partially implemented |
| **1B** Cervical Cancer Services | 6 | Partially implemented |
| **1C** ART Quarterly Cohort Analysis | 3 cohorts | Partially implemented |
| **1D** TPT Completion | 2 | Partially implemented |
| **1E** CrAg-Positive Cohort Monitoring | 3 | Partially implemented |
| **1F** Post-Exposure Prophylaxis | 6 | Planned |
| **1G** Pre-Exposure Prophylaxis | 5 | Planned |

See [HMIS 106A Indicator Creation Guide](docs/HMIS_106A_INDICATOR_CREATION_GUIDE.md) for detailed indicator definitions and creation instructions.

---

## Architecture

### ETL Framework (Mamba)

The module uses Mamba ETL for data processing:

- **Source Database:** OpenMRS production database
- **Target Database:** Analysis/ETL database (separate schema)
- **Processing:** Stored procedures for fact table generation
- **Scheduling:** Automated via OpenMRS scheduled tasks

### Report Builder Integration

Indicators are defined through Report Builder themes:

| Theme Code | Name | Source Table |
|------------|------|--------------|
| HC | HIV Care | `mamba_fact_encounter_hiv_art_card` |
| CX | Cervical Cancer | `mamba_fact_encounter_hiv_art_card` |
| TB | TB Services | `mamba_fact_encounter_hiv_art_card` |
| NCD | NCD Integration | `mamba_fact_encounter_hiv_art_card` |
| VL | Viral Load | `mamba_fact_patients_latest_viral_load` |
| ART | ART Summary | `mamba_fact_encounter_hiv_art_summary` |

---

## Scheduled Tasks

The module provides the following scheduled tasks:

| Task | Description | Usage |
|------|-------------|-------|
| **Setup Mamba ETL** | Initializes and runs the ETL process | Run manually or on schedule |
| **Run Analytics** | Executes analytics queries | Run on schedule for reports |

---

## Building from Source

**Requirements:**
- Java 1.8+
- Maven 3.x+

**Build Commands:**
```bash
# Clean build
mvn clean install

# Build and deploy to OpenMRS (if configured)
mvn clean install -P deploy-web
```

The `.omod` file will be in `omod/target/` after building.

---

## Code Formatting

This project uses Spotless for code formatting. Spotless runs automatically during the build process.

To format code manually:
```bash
mvn spotless:apply
```

To check formatting:
```bash
mvn spotless:check
```

---

## Database Configuration

### Default Database Settings

| Property | Default | Description |
|----------|---------|-------------|
| Source Database | `openmrs` | OpenMRS production database |
| Target Database | `analysis_db` | ETL data warehouse |
| ETL Interval | 3600 seconds | How often ETL runs |

### Database Access

For testing and development, you may need direct database access:
```bash
mysql -u openmrs -popenmrs -D stambrose
```

---

## Troubleshooting

### ETL Not Running

1. Check ETL status via API: `GET /ws/rest/v1/ugandareportsetl/etl/status`
2. Review error logs: `GET /ws/rest/v1/ugandareportsetl/etl/errors`
3. Verify database connectivity in module settings
4. Check scheduled task configuration

### Build Errors

- **webservices.rest dependency not found:** Ensure `webservices.rest-omod-common` dependency is correctly configured in `omod/pom.xml`
- **Compilation errors:** Run `mvn clean` and rebuild

### Missing Indicators

1. Verify ETL has completed successfully
2. Check Report Builder theme configuration
3. Ensure fact tables exist in target database
4. Review indicator SQL definitions

---

## Contributing

When contributing to this module:

1. Follow the existing code style (enforced by Spotless)
2. Add documentation for new indicators
3. Update API docs if adding new endpoints
4. Test ETL procedures before committing

---

## License

This module is licensed under the Mozilla Public License v2.0. See LICENSE file for details.

---

## Support

For issues or questions:
- Check the [REST API Documentation](docs/FRONTEND_API_DOCUMENTATION.md) for API issues
- Review the [HMIS 106A Indicator Creation Guide](docs/HMIS_106A_INDICATOR_CREATION_GUIDE.md) for indicator questions
- Open an issue in the project repository
