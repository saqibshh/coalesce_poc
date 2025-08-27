-- Debug script to test template generation

-- First, let's check if the control table exists and has data
SELECT 'Checking control table...' AS debug_step;

SELECT 
    node_name,
    stage_name,
    environment,
    is_active
FROM FUGETRON_INTERNAL_DEMO.POC_DEMO.COPY_STAGE_CONTROL
WHERE node_name = 'COPY_NODE_DYNAMIC';

-- Test the individual queries that the template will use
SELECT 'Testing stage name query...' AS debug_step;

SELECT stage_name 
FROM FUGETRON_INTERNAL_DEMO.POC_DEMO.COPY_STAGE_CONTROL 
WHERE node_name = 'COPY_NODE_DYNAMIC' 
AND environment = 'DEV' 
AND is_active = true
LIMIT 1;

SELECT 'Testing subfolder query...' AS debug_step;

SELECT subfolder 
FROM FUGETRON_INTERNAL_DEMO.POC_DEMO.COPY_STAGE_CONTROL 
WHERE node_name = 'COPY_NODE_DYNAMIC' 
AND environment = 'DEV' 
AND is_active = true
LIMIT 1;

SELECT 'Testing file pattern query...' AS debug_step;

SELECT file_pattern 
FROM FUGETRON_INTERNAL_DEMO.POC_DEMO.COPY_STAGE_CONTROL 
WHERE node_name = 'COPY_NODE_DYNAMIC' 
AND environment = 'DEV' 
AND is_active = true
LIMIT 1;

-- Test a simple COPY command with hardcoded values
SELECT 'Testing simple COPY command...' AS debug_step;

-- This should work if the stage exists
-- COPY INTO SRC.COPY_NODE_DYNAMIC
-- FROM (
--     SELECT 
--         $1::VARIANT AS SRC,
--         current_timestamp()::timestamp_ntz AS LOAD_TIMESTAMP,
--         METADATA$FILENAME AS FILENAME,
--         METADATA$FILE_ROW_NUMBER AS FILE_ROW_NUMBER,
--         METADATA$FILE_LAST_MODIFIED AS FILE_LAST_MODIFIED,
--         METADATA$START_SCAN_TIME AS SCAN_TIME
--     FROM @MY_STAGE/DC_POC/2025/08/06
-- )
-- FILE_FORMAT = (
--     TYPE = 'CSV',
--     FIELD_DELIMITER = ',',
--     SKIP_HEADER = 1
-- )
-- PATTERN = '.*\.csv$';
