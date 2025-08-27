# Troubleshooting Guide: Empty SQL Statement Error

## Problem
You're getting "SQL compilation error: Empty SQL statement" when using the custom CopyDynamic node.

## Possible Causes & Solutions

### 1. **Template Generation Issue**
The Jinja2 template might not be generating valid SQL.

**Solution**: Use the simplified template first:
- Rename `run.sql.j2` to `run.sql.j2.backup`
- Rename `run_simple.sql.j2` to `run.sql.j2`
- Test with the simplified version

### 2. **Control Table Missing or Empty**
The control table might not exist or be empty.

**Solution**: Run the debug script:
```sql
-- Run debug_template.sql to check:
-- 1. If control table exists
-- 2. If it has data for your node
-- 3. If individual queries work
```

### 3. **Template Variables Not Resolving**
The template variables might not be getting the correct values.

**Solution**: Check the node configuration:
- Verify `controlTableSchema` is correct
- Verify `controlTableName` is correct
- Verify `environment` matches your data

### 4. **Stage Does Not Exist**
The stage referenced in the control table might not exist.

**Solution**: 
```sql
-- Check if the stage exists
SHOW STAGES LIKE '%MY_STAGE%';

-- Create the stage if needed
CREATE STAGE MY_STAGE
URL = 's3://your-bucket/'
FILE_FORMAT = (TYPE = 'CSV');
```

## Step-by-Step Debugging

### Step 1: Run Debug Script
```sql
-- Execute debug_template.sql
-- This will show you exactly what's happening
```

### Step 2: Check Control Table
```sql
-- Verify your control table has the right data
SELECT * FROM FUGETRON_INTERNAL_DEMO.POC_DEMO.COPY_STAGE_CONTROL
WHERE node_name = 'COPY_NODE_DYNAMIC';
```

### Step 3: Test Simple Template
Use the simplified template (`run_simple.sql.j2`) which uses hardcoded values:
- Stage: `MY_STAGE`
- Subfolder: `DC_POC/2025/08/06`
- Pattern: `.*\.csv$`

### Step 4: Check Node Configuration
Verify your node configuration:
```yaml
config:
  controlTableSchema: FUGETRON_INTERNAL_DEMO.POC_DEMO
  controlTableName: COPY_STAGE_CONTROL
  environment: DEV
  fileType: CSV
  fieldDelim: ","
  skipHeader: "1"
```

## Alternative Approach

If the custom node continues to have issues, you can use the **Override SQL** approach:

1. **Set `overrideSQL: true`** in your node configuration
2. **Use this custom SQL**:

```sql
-- Dynamic COPY with control table
COPY INTO {{ ref_no_link(node.location.name, node.name) }}
FROM (
    SELECT 
        $1::VARIANT AS SRC,
        current_timestamp()::timestamp_ntz AS LOAD_TIMESTAMP,
        METADATA$FILENAME AS FILENAME,
        METADATA$FILE_ROW_NUMBER AS FILE_ROW_NUMBER,
        METADATA$FILE_LAST_MODIFIED AS FILE_LAST_MODIFIED,
        METADATA$START_SCAN_TIME AS SCAN_TIME
    FROM @(
        SELECT stage_name 
        FROM FUGETRON_INTERNAL_DEMO.POC_DEMO.COPY_STAGE_CONTROL 
        WHERE node_name = '{{ node.name }}' 
        AND environment = 'DEV' 
        AND is_active = true
        LIMIT 1
    ) / (
        SELECT subfolder 
        FROM FUGETRON_INTERNAL_DEMO.POC_DEMO.COPY_STAGE_CONTROL 
        WHERE node_name = '{{ node.name }}' 
        AND environment = 'DEV' 
        AND is_active = true
        LIMIT 1
    )
)
FILE_FORMAT = (
    TYPE = 'CSV',
    FIELD_DELIMITER = ',',
    SKIP_HEADER = 1
)
PATTERN = (
    SELECT file_pattern 
    FROM FUGETRON_INTERNAL_DEMO.POC_DEMO.COPY_STAGE_CONTROL 
    WHERE node_name = '{{ node.name }}' 
    AND environment = 'DEV' 
    AND is_active = true
    LIMIT 1
);
```

## Quick Fix

If you need a working solution immediately:

1. **Use the simplified template** (rename `run_simple.sql.j2` to `run.sql.j2`)
2. **Update the hardcoded values** in the template to match your environment
3. **Test the node** - it should work with static values
4. **Gradually add dynamic functionality** once the basic template works

This approach will get you a working COPY node while we debug the template generation issue.
