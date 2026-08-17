# Frontend Integration Guide - Implementation Gap Analysis

**Date:** 2026-08-15
**Status:** ⚠️ Critical Documentation Gaps Found

---

## Executive Summary

The `FRONTEND_INTEGRATION_GUIDE.md` was authored but the actual implementation has **significant mismatches** with the documented API response formats. This will cause integration failures.

---

## Critical Issues Found

### 1. ❌ ETLErrorLog Model Mismatch

**Documented in Guide:**
```typescript
interface ETLErrorLog {
  id: number;
  timestamp: Date;          // ❌ NOT in implementation
  errorLevel: string;        // ❌ NOT in implementation
  errorMessage: string;
  stackTrace?: string;       // ❌ NOT in implementation
  executionId: number;       // ❌ NOT in implementation
}
```

**Actual Implementation:**
```java
public class ETLErrorLog {
    private Integer id;
    private String procedureName;    // ✅ Exists
    private String errorMessage;    // ✅ Exists
    private Integer errorCode;       // ❌ Not documented
    private String sqlState;         // ❌ Not documented
    private Date errorTime;          // ⚠️ Different from "timestamp"
}
```

**Impact:** HIGH - Any frontend code expecting `errorLevel`, `stackTrace`, or `executionId` will fail.

---

### 2. ❌ ETLSettings Model Mismatch

**Documented in Guide:**
```typescript
interface ETLSettings {
  batchSize: number;              // ❌ NOT in implementation
  scheduleInterval: string;       // ❌ NOT in implementation
  enableErrorLogging: boolean;    // ❌ NOT in implementation
  maxRetryAttempts: number;      // ❌ NOT in implementation
}
```

**Actual Implementation:**
```java
public class ETLSettings {
    private Integer id;
    private String openmrsDatabase;           // ❌ Not documented
    private String etlDatabase;               // ❌ Not documented
    private String conceptsLocale;             // ❌ Not documented
    private Integer tablePartitionNumber;      // ❌ Not documented
    private Boolean incrementalModeSwitch;     // ❌ Not documented
    private Boolean automaticFlatteningModeSwitch; // ❌ Not documented
    private Integer etlIntervalSeconds;       // ❌ Not documented
    private Boolean incrementalModeSwitchCascaded; // ❌ Not documented
    private Integer lastEtlScheduleInsertId;  // ❌ Not documented
}
```

**Impact:** HIGH - **Zero** documented fields match the actual implementation.

---

### 3. ✅ ETLProgressInfo Model Match

**Documented in Guide:**
```typescript
interface ETLProgressInfo {
  id?: number;
  startTime?: Date;
  endTime?: Date;
  nextSchedule?: Date;
  executionDurationSeconds?: number;
  missedScheduleBySeconds?: number;
  completionStatus?: string;
  transactionStatus?: string;
  successOrErrorMessage?: string;
  progressPercentage?: number;
  currentStage?: string;
}
```

**Actual Implementation:**
```java
public class ETLProgressInfo {
    private Integer id;                      // ✅
    private Date startTime;                  // ✅
    private Date endTime;                     // ✅
    private Date nextSchedule;               // ✅
    private Long executionDurationSeconds;   // ✅
    private Long missedScheduleBySeconds;    // ✅
    private String completionStatus;         // ✅
    private String transactionStatus;        // ✅
    private String successOrErrorMessage;    // ✅
    private Double progressPercentage;       // ✅
    private String currentStage;             // ✅
}
```

**Impact:** NONE - Fields match correctly.

---

### 4. ⚠️ ETL Monitor Configuration Issues

The ETL monitor configurations created in `etl_monitor_configurations.sql` use **JSONPath expressions based on the documented guide**, which won't work with the actual API responses.

**Example from the configuration:**
```json
{
    "key": "timestamp",
    "header": "Time",
    "jsonPath": "$.data[*].timestamp",  // ❌ This field doesn't exist in ETLErrorLog
    "columnType": "TIMESTAMP"
}
```

**Should be:**
```json
{
    "key": "errorTime",
    "header": "Time",
    "jsonPath": "$.data[*].errorTime",  // ✅ Matches actual implementation
    "columnType": "TIMESTAMP"
}
```

---

## Response Format Issues

### Error Logs Endpoint (q=errors)

**Documented Response:**
```json
{
  "query": "errors",
  "limit": 50,
  "count": 3,
  "data": [
    {
      "id": 789,
      "timestamp": "2026-08-15T09:45:00",      // ❌ Wrong field
      "errorLevel": "ERROR",                   // ❌ Wrong field
      "errorMessage": "...",
      "stackTrace": "...",                      // ❌ Wrong field
      "executionId": 456                       // ❌ Wrong field
    }
  ]
}
```

**Actual Response (based on implementation):**
```json
{
  "query": "errors",
  "limit": 50,
  "count": 3,
  "data": [
    {
      "id": 789,
      "procedureName": "sp_data_processing_derived_art",  // ✅ Actual field
      "errorMessage": "...",
      "errorCode": 1644,                                   // ✅ Actual field
      "sqlState": "HY000",                                 // ✅ Actual field
      "errorTime": "2026-08-15T09:45:00"                   // ✅ Actual field
    }
  ]
}
```

---

### Settings Endpoint (q=settings)

**Documented Response:**
```json
{
  "query": "settings",
  "data": {
    "batchSize": 1000,              // ❌ Doesn't exist
    "scheduleInterval": "HOURLY",  // ❌ Doesn't exist
    "enableErrorLogging": true,    // ❌ Doesn't exist
    "maxRetryAttempts": 3          // ❌ Doesn't exist
  }
}
```

**Actual Response (based on implementation):**
```json
{
  "query": "settings",
  "data": {
    "id": 1,
    "openmrsDatabase": "openmrs",
    "etlDatabase": "stambrose",
    "conceptsLocale": "en",
    "tablePartitionNumber": 10,
    "incrementalModeSwitch": true,
    "automaticFlatteningModeSwitch": false,
    "etlIntervalSeconds": 3600,
    "incrementalModeSwitchCascaded": true,
    "lastEtlScheduleInsertId": 12345
  }
}
```

---

## Recommendations

### Immediate Actions Required

1. **Update FRONTEND_INTEGRATION_GUIDE.md** with correct model definitions:
   - Replace ETLErrorLog interface with actual fields
   - Replace ETLSettings interface with actual fields
   - Update all example JSON responses

2. **Update ETL Monitor Configurations** in `sql/etl_monitor_configurations.sql`:
   - Fix JSONPath expressions for error logs monitor
   - Fix JSONPath expressions for settings monitor
   - Fix JSONPath expressions for domain-specific monitors

3. **Verify Service Implementation**:
   - Check if `UgandaReportsETLService` implementations populate all fields correctly
   - Ensure JSON serialization produces expected field names

### Updated Model Definitions (for documentation)

**ETLErrorLog (corrected):**
```typescript
interface ETLErrorLog {
  id: number;
  procedureName: string;      // The stored procedure that failed
  errorMessage: string;        // Error message text
  errorCode?: number;          // Database error code
  sqlState?: string;           // SQL state code
  errorTime: Date;             // When the error occurred
}
```

**ETLSettings (corrected):**
```typescript
interface ETLSettings {
  id?: number;
  openmrsDatabase: string;              // Source OpenMRS database name
  etlDatabase: string;                  // Target ETL database name
  conceptsLocale?: string;              // Locale for concept mappings
  tablePartitionNumber?: number;        // Number of table partitions
  incrementalModeSwitch: boolean;        // Enable incremental ETL mode
  automaticFlatteningModeSwitch: boolean;// Enable automatic flattening
  etlIntervalSeconds: number;           // ETL schedule interval in seconds
  incrementalModeSwitchCascaded?: boolean;
  lastEtlScheduleInsertId?: number;
}
```

---

## Verification Steps

1. Check service implementation:
   ```bash
   find . -name "UgandaReportsETLServiceImpl.java"
   ```

2. Test actual API responses:
   ```bash
   curl http://localhost:8088/openmrs/ws/rest/v1/ugandareportsetl?q=errors
   curl http://localhost:8088/openmrs/ws/rest/v1/ugandareportsetl?q=settings
   ```

3. Verify JSON field names match documentation

---

## Files Requiring Updates

1. ✅ `/Users/lubwamasamuel/Projects/mets/openmrs/modules/openmrs-module-ugandareportsetl/FRONTEND_INTEGRATION_GUIDE.md`
2. ⚠️ `/Users/lubwamasamuel/Projects/mets/openmrs/modules/openmrs-module-ugandareportsetl/sql/etl_monitor_configurations.sql`
3. ⚠️ `/Users/lubwamasamuel/Projects/mets/openmrs/modules/openmrs-module-ugandareportsetl/sql/README_ETL_MONITORS.md`

---

## Conclusion

The FRONTEND_INTEGRATION_GUIDE.md contains **significant documentation drift** from the actual implementation. While the REST endpoints and overall structure match, the data model definitions for `ETLErrorLog` and `ETLSettings` are completely incorrect. This will cause:

1. Frontend integration failures
2. ETL monitor configuration failures
3. Developer confusion when implementing against the documented API

**Priority:** HIGH - Update documentation before any frontend integration work begins.