-- Test script to verify template generation
-- This shows what the COPY command should look like

-- Expected SQL from the template:
/*
COPY INTO FUGETRON_INTERNAL_DEMO.POC_DEMO.CPYD_NODE
FROM @(
    SELECT stage_name 
    FROM FUGETRON_INTERNAL_DEMO.POC_DEMO.COPY_STAGE_CONTROL 
    WHERE node_name = 'CPYD_NODE' 
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
*/

-- First, let's check if the control table has data:
SELECT 'Checking control table data...' AS step;
SELECT * FROM FUGETRON_INTERNAL_DEMO.POC_DEMO.COPY_STAGE_CONTROL 
WHERE node_name = 'CPYD_NODE' AND environment = 'DEV' AND is_active = true;

-- Check what stage name would be resolved:
SELECT 'Stage name that would be used:' AS step;
SELECT stage_name 
FROM FUGETRON_INTERNAL_DEMO.POC_DEMO.COPY_STAGE_CONTROL 
WHERE node_name = 'CPYD_NODE' 
AND environment = 'DEV' 
AND is_active = true
LIMIT 1;

-- Test if the stage exists:
SELECT 'Checking if stage exists...' AS step;
SHOW STAGES LIKE '%MY_STAGE%';

-- Test a manual COPY command (replace MY_STAGE with actual stage name):
/*
COPY INTO FUGETRON_INTERNAL_DEMO.POC_DEMO.CPYD_NODE
FROM @MY_STAGE/DC_POC/2025/08/06
FILE_FORMAT = (
    TYPE = 'CSV',
    FIELD_DELIMITER = ',',
    SKIP_HEADER = 1
)
PATTERN = '.*\\.csv$';
*/
