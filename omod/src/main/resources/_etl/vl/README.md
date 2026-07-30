# Comprehensive Viral Load ETL - Simplified Single Table

**Overview:** Single-table VL ETL that consolidates the comprehensive 35-table design into one manageable episode table while supporting all HMIS 106A VL reporting requirements.

---

## Quick Start

```bash
cd omod/src/main/resources/_etl/vl

# One-command deployment (creates tables, config, procedures, and loads data)
./04_setup.sh stambrose openmrs openmrs

# Or manually:
mysql -u openmrs -popenmrs stambrose < 01_comprehensive_vl_episode.sql
mysql -u openmrs -popenmrs stambrose < 02_config_tables.sql
mysql -u openmrs -popenmrs stambrose < 03_sp_vl_episode_etl.sql
mysql -u openmrs -popenmrs stambrose -e "CALL sp_mamba_fact_vl_episode_etl();"
```

---

## The Architecture

### Before vs After

| Aspect | 35-Table Design | Simplified Design |
|--------|----------------|------------------|
| **Tables** | 35 across 7 layers | **1 episode table + 3 config tables** |
| **Complexity** | Staging → Events → Episodes → Bridges → Marts | Direct episode construction |
| **Maintenance** | Multiple ETL jobs, dependencies | Single stored procedure |
| **Queries** | Join 5+ tables | Single table with indexes |
| **Performance** | Complex joins, materialized views | Direct indexed access |

### What's Included in One Table

The `mamba_fact_viral_load_episode` table contains everything from the comprehensive design:

```
┌─────────────────────────────────────────────────────────────┐
│           mamba_fact_viral_load_episode                       │
│  (All VL data in one comprehensive table)                    │
├─────────────────────────────────────────────────────────────┤
│  • Order info (native + legacy)                              │
│  • Sample/specimen data                                      │
│  • Laboratory results (numeric + qualitative)                │
│  • Suppression interpretation                                │
│  • Clinical context (pregnancy, breastfeeding, ART, regimen) │
│  • Turnaround times                                          │
│  • Testing model (Central Lab vs POC)                        │
│  • Order-result linkage & confidence                         │
│  • Pipeline status                                           │
│  • Due status indicators                                     │
└─────────────────────────────────────────────────────────────┘
```

---

## Key Features

### 1. Dual Workflow Support

| Workflow | Volume | Native Order | Source |
|----------|--------|--------------|--------|
| Legacy ART Card | 99% | No | Observation-based (concept 1271 → 165412) |
| New HMIS ACP 002 | 1% | Yes | Native `test_order` |

Both workflows are extracted, normalized, and unified in one table.

### 2. Order-Result Matching

Matches in priority order:
1. **Direct Order Link** - `obs.order_id` (HIGH confidence)
2. **Accession Number** - Normalized matching (HIGH confidence)
3. **Patient + Date Window** - Configurable 30-day window (MEDIUM confidence)
4. **Same Encounter** - Encounter-based (LOW confidence)

Unmatched records are retained (not discarded):
- `is_orphan_result = 1` - Results without orders
- `is_order_without_result = 1` - Orders without results

### 3. Suppression Calculation

```sql
-- Uses configurable threshold (default: 1000 copies/ml)
CASE
    WHEN qualitative = 'TARGET_NOT_DETECTED' THEN SUPPRESSED
    WHEN numeric < threshold THEN SUPPRESSED
    WHEN numeric >= threshold THEN UNSUPPRESSED
    WHEN qualitative = 'DETECTED' (no numeric) THEN UNSUPPRESSED
    WHEN status = 'INVALID' THEN NULL
END
```

### 4. Testing Model Inference

| Evidence | Testing Model | Confidence |
|----------|--------------|------------|
| Same-day sample & result | POINT_OF_CARE | MEDIUM |
| Dispatch/receipt dates available | CENTRAL_LAB | HIGH |
| Default (no evidence) | CENTRAL_LAB | LOW |

### 5. Turnaround Time Metrics

Calculated durations:
- Order → Collection
- Collection → Result
- Result → Facility Return
- Facility → EMR Entry
- Total Order → Result

---

## Table Structure

### Main Table: `mamba_fact_viral_load_episode`

**80+ fields covering:**
- Identifiers (patient, order, accession)
- Order details (dates, provider, status)
- Sample info (collection, specimen, status)
- Results (numeric, qualitative, interpretation)
- Clinical context (ART, pregnancy, breastfeeding, TB, regimen)
- Suppression (status, threshold, interpretation)
- Testing model (type, confidence, source)
- Linkage (method, confidence, orphan status)
- Turnaround (all interval calculations)
- Due status (next date, overdue, reason)
- Pipeline (current stage)
- ETL metadata (timestamps, rule version)

### Configuration Tables

**`mamba_vl_concept_mapping`** - Maps OpenMRS concepts to ETL fields
- VL Panel, numeric/qualitative results, dates, accession numbers

**`mamba_vl_coded_value_mapping`** - Maps coded answers to canonical values
- Target Not Detected → TARGET_NOT_DETECTED
- Detected → DETECTED
- Poor Sample Quality → POOR_SAMPLE_QUALITY

**`mamba_vl_rule_config`** - Configurable business rules
- Suppression thresholds
- Due intervals by population (established, pregnant, breastfeeding)
- Matching windows
- Turnaround targets

---

## Available Procedures

### Main ETL Procedure

```sql
CALL sp_mamba_fact_vl_episode_etl();
```

**What it does:**
1. Clears existing episodes (truncate)
2. Extracts native orders from `orders` + `test_order`
3. Extracts legacy derived orders from obs (1271 → 165412)
4. Extracts VL result panels from obs (concept 165412)
5. Matches orders to results by accession number
6. Matches remaining by patient + date window
7. Calculates suppression status
8. Infers testing model
9. Calculates turnaround times
10. Returns summary statistics

**Output Summary:**
```
┌─────────────────────────────────┬──────────┐
│ Metric                          │ Value    │
├─────────────────────────────────┼──────────┤
│ total_episodes                  │ 6,500+   │
│ orphan_results                  │ ~6,300   │
│ unmatched_orders                │ ~400     │
│ accession_matched                | ~200     │
│ suppressed_count                │ TBD      │
│ unsuppressed_count              │ TBD      │
│ poc_count                       | TBD      │
└─────────────────────────────────┴──────────┘
```

### Helper Procedures

**Latest VL per Patient:**
```sql
CALL sp_get_latest_vl_per_patient(NULL, '2024-01-01', '2025-12-31');
```

**Pipeline Summary:**
```sql
CALL sp_get_vl_pipeline_summary(NULL, CURDATE());
```

---

## Query Examples

### Suppression Rate by Facility

```sql
SELECT
    location_id,
    COUNT(*) AS total_vl,
    SUM(is_suppressed) AS suppressed,
    SUM(is_unsuppressed) AS unsuppressed,
    ROUND(100 * SUM(is_suppressed) / COUNT(*), 1) AS suppression_rate
FROM mamba_fact_viral_load_episode
WHERE viral_load_clinical_date BETWEEN '2024-01-01' AND '2024-12-31'
  AND result_status = 'VALID'
GROUP BY location_id;
```

### Testing Model Distribution

```sql
SELECT
    testing_model,
    testing_model_confidence,
    COUNT(*) AS count,
    ROUND(AVG(collection_to_result_days), 1) AS avg_turnaround_days
FROM mamba_fact_viral_load_episode
WHERE sample_collection_date IS NOT NULL
  AND viral_load_clinical_date IS NOT NULL
GROUP BY testing_model, testing_model_confidence;
```

### Orphan Results (Data Quality)

```sql
SELECT
    COUNT(*) AS orphan_results,
    COUNT(DISTINCT patient_id) AS affected_patients,
    MIN(viral_load_clinical_date) AS earliest_orphan,
    MAX(viral_load_clinical_date) AS latest_orphan
FROM mamba_fact_viral_load_episode
WHERE is_orphan_result = 1;
```

### Pipeline Status Summary

```sql
SELECT
    pipeline_status,
    COUNT(*) AS count,
    COUNT(DISTINCT patient_id) AS unique_patients
FROM mamba_fact_viral_load_episode
WHERE order_date >= '2024-01-01'
GROUP BY pipeline_status
ORDER BY count DESC;
```

### PMTCT Patients with Latest VL

```sql
SELECT
    patient_id,
    viral_load_clinical_date,
    result_numeric,
    result_qualitative,
    is_suppressed,
    pregnancy_status,
    breastfeeding_status,
    gestational_age_weeks
FROM mamba_fact_viral_load_episode
WHERE (pregnancy_status = 'YES' OR breastfeeding_status = 'YES')
  AND panel_obs_id IS NOT NULL
  AND viral_load_clinical_date = (
      SELECT MAX(viral_load_clinical_date)
      FROM mamba_fact_viral_load_episode vl2
      WHERE vl2.patient_id = mamba_fact_viral_load_episode.patient_id
  );
```

---

## Maintenance

### Refresh Data

```sql
CALL sp_mamba_fact_vl_episode_etl();
```

### Update Configuration

```sql
-- Change suppression threshold
INSERT INTO mamba_vl_rule_config (rule_name, population_group, parameter_name, parameter_value)
VALUES ('SUPPRESSION_THRESHOLD', 'ALL', 'threshold_copies_ml', '2000')
ON DUPLICATE KEY UPDATE parameter_value = '2000';

-- Change matching window
INSERT INTO mamba_vl_rule_config (rule_name, parameter_name, parameter_value)
VALUES ('MATCHING_WINDOW', 'patient_date_match_days', '60')
ON DUPLICATE KEY UPDATE parameter_value = '60';

-- Re-run ETL to apply new rules
CALL sp_mamba_fact_vl_episode_etl();
```

### Add New Concept Mapping

```sql
INSERT INTO mamba_vl_concept_mapping (concept_id, concept_uuid, canonical_field, source_workflow, value_type)
VALUES (12345, 'uuid-here', 'NEW_FIELD', 'NEW_FORM', 'Text');
```

---

## Performance

### Indexes

Key indexes for performance:
- `idx_patient_id` - Patient-based queries
- `idx_location_id` - Facility reporting
- `idx_vl_clinical_date` - Date range queries
- `idx_native_order_id` - Order lookups
- `idx_accession_number` - Lab matching
- `idx_linkage_method` - Data quality queries
- Composite indexes for common filter combinations

### Expected Performance

| Query Type | Expected Time |
|------------|---------------|
| Patient latest VL | < 1s |
| Facility summary | < 2s |
| Full ETL run | < 5min (for ~10k episodes) |

---

## Data Quality Features

### Exposed Issues

The ETL exposes (not hides) data quality problems:
- Orphan results (results without orders)
- Unmatched orders (orders without results)
- Low-confidence matches
- Date conflicts (sample after result, etc.)
- Missing dates
- Numeric-qualitative conflicts
- Multiple orders per result

### Data Quality Query

```sql
SELECT
    'Orphan Results' AS issue_type,
    COUNT(*) AS count
FROM mamba_fact_viral_load_episode WHERE is_orphan_result = 1
UNION ALL
SELECT 'Unmatched Orders', COUNT(*)
FROM mamba_fact_viral_load_episode WHERE is_order_without_result = 1
UNION ALL
SELECT 'Low Confidence Matches', COUNT(*)
FROM mamba_fact_viral_load_episode WHERE linkage_confidence = 'LOW'
UNION ALL
SELECT 'Same Day POC', COUNT(*)
FROM mamba_fact_viral_load_episode WHERE testing_model = 'POINT_OF_CARE'
UNION ALL
SELECT 'Invalid Results', COUNT(*)
FROM mamba_fact_viral_load_episode WHERE result_status = 'INVALID';
```

---

## Files

```
_etl/vl/
├── README.md                           # This file
├── 01_comprehensive_vl_episode.sql     # Main episode table
├── 02_config_tables.sql                # Config tables + seed data
├── 03_sp_vl_episode_etl.sql            # ETL procedures
├── 04_setup.sh                         # Deployment script
└── (old 35-table design archived)      # Roughwork reference
```

---

## Comparison to 35-Table Design

| Requirement | 35-Table Approach | Single-Table Approach |
|-------------|-------------------|----------------------|
| **All VL workflows** | ✅ Yes | ✅ Yes |
| **Order-result matching** | ✅ Complex staging | ✅ Direct in ETL |
| **Suppression logic** | ✅ Rule-driven | ✅ Rule-driven |
| **Due status engine** | ✅ Separate mart | ✅ Inline columns |
| **Turnaround metrics** | ✅ Separate mart | ✅ Calculated columns |
| **Testing model** | ✅ Classification | ✅ Inferred + stored |
| **Data quality** | ✅ Separate mart | ✅ Flags in main table |
| **Incremental ETL** | ✅ Watermark table | ✅ Can be added |
| **Audit trail** | ✅ ETL run logs | ✅ ETL metadata columns |
| **Complexity** | ❌ Very high | ✅ Manageable |
| **Maintenance** | ❌ Complex | ✅ Simple |
| **Query performance** | ⚠️ Multiple joins | ✅ Direct access |

---

## Next Steps

1. **Deploy and Test** - Run setup script and validate data
2. **Configure Rules** - Set facility-specific thresholds and intervals
3. **Schedule ETL** - Set up recurring ETL runs (nightly/weekly)
4. **Build Reports** - Use table for HMIS 106A indicators
5. **Monitor Quality** - Review data quality metrics regularly

---

## References

- Based on: Comprehensive VL ETL Planning Document (35-table design)
- Database: stambrose (UgandaEMR)
- Concepts: 165412 (VL Panel), 856 (Numeric), 1305 (Qualitative), 163023 (VL Date)
- Workflows: Legacy ART Card, New HMIS ACP 002 VL Request Form

---

**Created:** 2026-07-29
**Status:** Ready for deployment
