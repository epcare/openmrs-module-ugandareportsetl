# HMIS 106A Indicator Creation Process Documentation

## Overview

This document outlines the complete process for creating HMIS 106A indicators for new forms, using the HIV Self-Testing Register as a reference implementation.

---

## Process Summary

```
Form Definition → ETL Config → Fact Table → Report Builder Indicators → Reports
```

---

## Phase 1: Form Analysis

### 1.1 Identify Form Details

Locate and analyze the form JSON:

**Location**: `/Users/lubwamasamuel/Projects/mets/ugandaemr/modules/ugandaemrcorepack/configuration/backend_configuration/ampathforms/`

**Example**: `HMIS-ACP-039-HIVSelfTestingRegister.json`

**Key Elements to Extract**:
- Form UUID
- Encounter Type UUID
- Encounter Type Name
- All fields with concept UUIDs
- Field relationships and dependencies

### 1.2 Document Data Elements

Create a mapping of all form fields to concept UUIDs:

| Field Name | Concept UUID | Data Type | Notes |
|------------|--------------|-----------|-------|
| serial_number | 1646AAAAAAAA... | TEXT | Kit serial number |
| distribution_model | 46648b1d-b099... | CODED | Facility/Community |
| hivst_results | 01193606-25bb... | CODED | Reactive/Non-Reactive |

---

## Phase 2: ETL Configuration

### 2.1 Create ETL Config JSON

**Location**: `omod/src/main/resources/_etl/config/<form-name>.json`

**Structure**:
```json
{
  "report_name": "Form_Display_Name",
  "flat_table_name": "mamba_flat_encounter_<form_name>",
  "encounter_type_uuid": "<encounter_type_uuid>",
  "encounter_type_name": "<Encounter Type Name>",
  "concepts_locale": "en",
  "table_columns": {
    "<column_name>": "<concept_uuid>",
    "<column_name>": "<concept_uuid>"
  }
}
```

**Example**: `hiv-self-testing.json`

### 2.2 Column Naming Convention

Convert form field names to snake_case:
- `serialNumber` → `serial_number`
- `hfEntryPoint` → `hf_entry_point`
- `hivstResults` → `hivst_results`

---

## Phase 3: Fact Table Creation

### 3.1 Create Directory Structure

**Location**: `omod/src/main/resources/_etl/derived/<category>/<form_name>/`

**Example**: `derived/hts_new/self_test/`

### 3.2 Create Fact Table SPs

**Files to create**:

1. **`facts/sp_fact_encounter_<name>.sql`**
   ```sql
   -- $BEGIN
   CALL sp_fact_encounter_<name>_create();
   CALL sp_fact_encounter_<name>_insert();
   -- $END
   ```

2. **`facts/sp_fact_encounter_<name>_create.sql`**
   - Creates the fact table
   - Defines indexes
   - Uses proper naming: `mamba_fact_encounter_<name>`

3. **`facts/sp_fact_encounter_<name>_insert.sql`**
   - INSERT SELECT from flat table
   - Joins with patient demographics if needed
   - Maps flat table columns to fact table

4. **`facts/sp_fact_encounter_<name>_query.sql`**
   ```sql
   -- $BEGIN
   -- Query procedures for <Form Name>
   -- $END
   ```

5. **`facts/sp_fact_encounter_<name>_update.sql`**
   ```sql
   -- $BEGIN
   -- Update procedures for <Form Name>
   -- $END
   ```

### 3.3 Fact Table Column Best Practices

**Standard Columns**:
```sql
id                 INT AUTO_INCREMENT PRIMARY KEY,
encounter_id       INT NULL,
client_id          INT NULL,
patient_id         INT NULL,
encounter_date     DATETIME NULL,
location_id        INT NULL,
-- Add form-specific columns below
```

**Index Columns**:
- `client_id`
- `patient_id`
- `encounter_id`
- `encounter_date`
- `location_id`
- Key filter columns (e.g., `distribution_model`, `hivst_results`)

### 3.4 Create Main SP and Makefile

**Main SP**: `sp_data_processing_derived_<name>.sql`
```sql
-- $BEGIN
CALL sp_fact_encounter_<name>_create();
CALL sp_fact_encounter_<name>_insert();
-- $END
```

**Makefile**: `sp_makefile`
```makefile
#############################################################################
##################### <Form Name> Fact Encounter Table SPs  #####################
#############################################################################
facts/sp_fact_encounter_<name>.sql
facts/sp_fact_encounter_<name>_create.sql
facts/sp_fact_encounter_<name>_insert.sql
facts/sp_fact_encounter_<name>_query.sql
facts/sp_fact_encounter_<name>_update.sql

#############################################################################
###### A single stored procedure that invokes (CALLs) the above SPs #########
#############################################################################
sp_data_processing_derived_<name>.sql
```

### 3.5 Update Main Makefile

**Location**: `omod/src/main/resources/_etl/sp_makefile`

Add the line:
```
derived/<category>/<form_name>/sp_data_processing_derived_<name>.sql
```

### 3.6 Update Main ETL SP

**Location**: `omod/src/main/resources/_etl/sp_mamba_data_processing_etl.sql`

Add the CALL:
```sql
CALL sp_data_processing_derived_<name>();
```

---

## Phase 4: Report Builder Indicators

### 4.1 Identify Theme

Query the database for existing themes:
```sql
SELECT report_builder_data_theme_id, uuid, name 
FROM report_builder_data_theme 
WHERE name LIKE '%<keyword>%';
```

**Example**: HTS Self Testing theme
- ID: 17
- UUID: `da34f7c6-1ce4-4eea-a193-a5851b1cb4ba`
- Name: `HTS Self Testing`

### 4.2 Design Indicator Hierarchy

Map out the indicator structure:

```
HT05: HIV Self-Test Kits at Health Facility
├── HT05a: Distributed
│   ├── HT05a1: Directly Assisted
│   └── HT05a2: Unassisted
└── HT05b: HIV Self Test Results
    ├── HT05b1: Results Returned
    ├── HT05b2: Total Positive
    ├── HT05b3: Confirmed Positive
    ├── HT05b4: Linked to HIV Care
    └── HT05b5: Referred to Prevention
```

### 4.3 Create Indicators SQL

**Location**: `sql/<form_name>_indicators.sql`

**SQL Structure**:
```sql
-- Get next available ID
SET @max_id = (SELECT MAX(report_builder_indicator_id) FROM report_builder_indicator);
SET @max_id = IFNULL(@max_id, 0);

-- Set theme UUID
SET @theme_uuid = '<theme_uuid>';

-- Insert each indicator
SET @max_id = @max_id + 1;
INSERT INTO report_builder_indicator (
    report_builder_indicator_id, uuid, name, description, 
    retired, retire_reason, retired_by, date_retired, 
    creator, date_created, changed_by, date_changed,
    code, kind, default_value_type, theme_uuid, 
    config_json, sql_template, denominator_sql_template, meta_json
) VALUES (
    @max_id,
    '<unique_uuid>',
    '<Indicator Code>. <Display Name>',
    '<Description>',
    0, null, null, null, 
    1, NOW(), 1, NOW(),
    '<Indicator Code>.', 'BASE', 'NUMBER', @theme_uuid,
    '<config_json>',
    '<sql_template>',
    null, null
);
```

### 4.4 Config JSON Pattern

**Critical Structure**:
```json
{
  "version": 1,
  "themeUuid": "<theme_uuid>",
  "themeConfig": {
    "sourceTable": "mamba_fact_encounter_<name>",
    "patientIdColumn": "client_id",
    "dateColumn": "encounter_date",
    "locationColumn": "",
    "fields": [],
    "conditions": []
  },
  "conditions": [],
  "customConditions": [
    {
      "id": "custom_<indicator>_<field>",
      "column": "<column_name>",
      "operator": "=",
      "value": "<concept_uuid>"
    }
  ],
  "excludeDateFilter": false,
  "countDistinctPatientId": false,
  "sqlPreview": "<escaped_sql_preview>"
}
```

**Important Notes**:
- `locationColumn` must be empty string `""`
- `fields` must be empty array `[]`
- `conditions` must be empty array `[]`
- All filters go in `customConditions`

### 4.5 SQL Template Pattern

**Standard Query Structure**:
```sql
SELECT
  COUNT(*) AS total
FROM mamba_fact_encounter_<name> a
JOIN mamba_fact_patients_latest_patient_demographics mdp
  ON mdp.client_id = a.client_id
WHERE
  a.encounter_date >= :startDate
  AND a.encounter_date <= :endDate
  AND mdp.birthdate IS NOT NULL
  AND mdp.gender IS NOT NULL
  AND a.<filter_column> = '<concept_uuid>'
  AND a.<filter_column> = '<concept_uuid>';
```

**Operators**:
- Equality: `=`
- IS NOT NULL: `IS NOT NULL` with `value: true`
- LIKE: `LIKE` with `wildcardMode: "contains"`

### 4.6 Generate Unique UUIDs

Use a pattern like: `ht05a1-9a2b-3c4d-5e6f-7g8h9i0j1k2l`

---

## Phase 5: Testing and Deployment

### 5.1 Build Module

```bash
cd /Users/lubwamasamuel/Projects/mets/openmrs/modules/openmrs-module-ugandareportsetl
mvn clean install
```

### 5.2 Deploy ETL

1. Copy `.omod` file to OpenMRS modules directory
2. Restart OpenMRS or reload modules
3. Run "Setup Mamba ETL" scheduled task

### 5.3 Run Indicator SQL

```bash
mysql -u openmrs -popenmrs -D <database> < sql/<form_name>_indicators.sql
```

### 5.4 Verify Indicators

```sql
SELECT report_builder_indicator_id, code, name, theme_uuid
FROM report_builder_indicator
WHERE code LIKE 'HT05%'
ORDER BY code;
```

---

## Concept UUID Reference Patterns

### Common Concept UUIDs

**Yes/No Concepts**:
- Yes: `1065AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA`
- No: `1066AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA`

**HIV Test Results**:
- Positive: `dc866728-30ab-102d-86b0-7a5022ba4115`
- Negative: `dc85aa72-30ab-102d-86b0-7a5022ba4115`
- Reactive: `dc9f3fdd-30ab-102d-86b0-7a5022ba4115`
- Non-Reactive: `dc9f442a-30ab-102d-86b0-7a5022ba4115`

**Other Specify**:
- Other Specify: `dcd68a88-30ab-102d-86b0-7a5022ba4115`

---

## File Structure Summary

```
openmrs-module-ugandareportsetl/
├── sql/
│   └── <form_name>_indicators.sql          # Report Builder indicators
├── omod/src/main/resources/
│   ├── _etl/
│   │   ├── config/
│   │   │   └── <form_name>.json            # ETL configuration
│   │   ├── derived/
│   │   │   └── <category>/<form_name>/
│   │   │       ├── facts/
│   │   │       │   ├── sp_fact_encounter_<name>.sql
│   │   │       │   ├── sp_fact_encounter_<name>_create.sql
│   │   │       │   ├── sp_fact_encounter_<name>_insert.sql
│   │   │       │   ├── sp_fact_encounter_<name>_query.sql
│   │   │       │   └── sp_fact_encounter_<name>_update.sql
│   │   │       ├── sp_data_processing_derived_<name>.sql
│   │   │       ├── sp_makefile
│   │   │       └── README.md
│   │   ├── sp_makefile                     # Updated with new entry
│   │   └── sp_mamba_data_processing_etl.sql  # Updated with new CALL
```

---

## Checklist

### ETL Creation
- [ ] Analyzed form and documented all concept UUIDs
- [ ] Created ETL config JSON in `_etl/config/`
- [ ] Created fact table SPs in `derived/<category>/<form_name>/facts/`
- [ ] Created main SP and makefile
- [ ] Updated main `sp_makefile`
- [ ] Updated main `sp_mamba_data_processing_etl.sql`
- [ ] Created README.md in the form folder

### Indicator Creation
- [ ] Identified theme UUID
- [ ] Designed indicator hierarchy
- [ ] Created indicators SQL file
- [ ] Used correct config_json structure
- [ ] Generated unique UUIDs for each indicator
- [ ] Tested queries against fact table

### Deployment
- [ ] Built module successfully
- [ ] Deployed ETL to OpenMRS
- [ ] Ran Setup Mamba ETL task
- [ ] Ran indicator SQL against database
- [ ] Verified indicators in Report Builder

---

## Quick Reference: Indicator Filter Logic

### Distribution Model (HT05 vs HT06)
- **Health Facility**: `distribution_model = 'ecb88326-0a3f-44a5-9bbf-df4bfc3239e1'`
- **Community**: `distribution_model = '4f4e6d1d-4343-42cc-ba47-2319b8a84369'`

### Testing Approach
- **Directly Assisted**: `hiv_self_testing_approach = '9638bacf-6443-4391-bbc3-f154eaac3245'`
- **Unassisted**: `hiv_self_testing_approach = '534658fe-3682-4007-bee1-3f600edb2818'`

### Results Cascade
1. **Results Returned**: `hivst_results IS NOT NULL`
2. **Total Positive**: `hivst_results = 'dc9f3fdd-30ab-102d-86b0-7a5022ba4115'`
3. **Confirmed Positive**: Add `confirmatory_test_results = 'dc866728-30ab-102d-86b0-7a5022ba4115'`
4. **Linked to Care**: Add `linked_to_hiv_care = '1065AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'`
5. **Referred to Prevention**: `confirmatory_test_results = 'dc85aa72-30ab-102d-86b0-7a5022ba4115'` + `linked_to_hiv_prevention_services = '1065AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'`

---

## Related Documentation

- **CLAUDE.md**: Project-specific guidance
- **ETL deployment workflow**: Build and deploy process
- **Setup Mamba ETL task**: ETL regeneration process
