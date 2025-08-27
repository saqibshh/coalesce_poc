# Manual Setup Guide: Create COPY Node in Coalesce

Since you're getting file parsing errors, here's how to create the node manually in Coalesce:

## Step 1: Create New Node in Coalesce

1. **Right-click in your project** → **New Node**
2. **Name it**: `CPYD_NODE`
3. **Set Location**: `SRC`
4. **Set Materialization**: `Table`

## Step 2: Configure the Node

1. **Click on the node** to open its properties
2. **Go to the "SQL" tab**
3. **Check "Override SQL"**
4. **Paste this SQL**:

```sql
COPY INTO {{ ref_no_link(node.location.name, node.name) }}
FROM @(
    SELECT stage_name 
    FROM FUGETRON_INTERNAL_DEMO.POC_DEMO.COPY_STAGE_CONTROL 
    WHERE node_name = '{{ node.name }}' 
    AND environment = 'DEV' 
    AND is_active = true
    LIMIT 1
)/DC_POC/2025/08/06
FILE_FORMAT = (
    TYPE = 'CSV',
    FIELD_DELIMITER = ',',
    SKIP_HEADER = 1
)
PATTERN = '.*\\.csv$';
```

## Step 3: Add Columns

Add these columns to the node:

1. **SRC** (VARIANT) - Transform: `$1`
2. **LOAD_TIMESTAMP** (TIMESTAMP_NTZ) - Transform: `current_timestamp()::timestamp_ntz`
3. **FILENAME** (STRING) - Transform: `METADATA$FILENAME`
4. **FILE_ROW_NUMBER** (NUMBER) - Transform: `METADATA$FILE_ROW_NUMBER`
5. **FILE_LAST_MODIFIED** (TIMESTAMP_NTZ) - Transform: `METADATA$FILE_LAST_MODIFIED`
6. **SCAN_TIME** (TIMESTAMP_NTZ) - Transform: `METADATA$START_SCAN_TIME`

## Step 4: Verify Control Table

Run this SQL to make sure your control table has data:

```sql
-- Check if data exists
SELECT * FROM FUGETRON_INTERNAL_DEMO.POC_DEMO.COPY_STAGE_CONTROL 
WHERE node_name = 'CPYD_NODE' AND environment = 'DEV' AND is_active = true;

-- If no data, insert it:
INSERT INTO FUGETRON_INTERNAL_DEMO.POC_DEMO.COPY_STAGE_CONTROL 
(node_name, stage_name, external_uri, subfolder, file_pattern, is_active, environment, created_by, comments) 
VALUES 
('CPYD_NODE', 'MY_STAGE', 's3://my-bucket/data/', 'DC_POC/2025/08/06', '.*\\.csv$', TRUE, 'DEV', 'ADMIN', 'Test configuration');
```

## Step 5: Test the Node

1. **Save the node**
2. **Click "Run"** or **"Deploy"**
3. **Check the logs** - you should see the COPY command executing

## Expected Result

The node should now run:
```sql
COPY INTO FUGETRON_INTERNAL_DEMO.POC_DEMO.CPYD_NODE
FROM @(
    SELECT stage_name 
    FROM FUGETRON_INTERNAL_DEMO.POC_DEMO.COPY_STAGE_CONTROL 
    WHERE node_name = 'CPYD_NODE' 
    AND environment = 'DEV' 
    AND is_active = true
    LIMIT 1
)/DC_POC/2025/08/06
FILE_FORMAT = (TYPE = 'CSV', FIELD_DELIMITER = ',', SKIP_HEADER = 1)
PATTERN = '.*\\.csv$';
```

## Troubleshooting

If it still shows SELECT instead of COPY:
1. **Make sure "Override SQL" is checked**
2. **Make sure the SQL is pasted correctly**
3. **Check that your control table has data for CPYD_NODE**
4. **Try refreshing the node or restarting Coalesce**

This manual approach bypasses any file import issues and should work immediately!
