-- Verify control table has data for CPYD_NODE
SELECT 'Checking control table for CPYD_NODE...' AS step;

-- Check if the control table exists and has data
SELECT 
    node_name,
    stage_name,
    environment,
    is_active,
    subfolder,
    file_pattern
FROM FUGETRON_INTERNAL_DEMO.POC_DEMO.COPY_STAGE_CONTROL 
WHERE node_name = 'CPYD_NODE' 
AND environment = 'DEV' 
AND is_active = true;

-- If no data found, insert it:
INSERT INTO FUGETRON_INTERNAL_DEMO.POC_DEMO.COPY_STAGE_CONTROL 
(node_name, stage_name, external_uri, subfolder, file_pattern, is_active, environment, created_by, comments) 
VALUES 
('CPYD_NODE', 'MY_STAGE', 's3://my-bucket/data/', 'DC_POC/2025/08/06', '.*\\.csv$', TRUE, 'DEV', 'ADMIN', 'Test configuration for CPYD_NODE')
ON DUPLICATE KEY UPDATE 
    stage_name = VALUES(stage_name),
    external_uri = VALUES(external_uri),
    subfolder = VALUES(subfolder),
    file_pattern = VALUES(file_pattern),
    is_active = VALUES(is_active);

-- Verify the data was inserted/updated
SELECT 'After insert/update:' AS step;
SELECT 
    node_name,
    stage_name,
    environment,
    is_active
FROM FUGETRON_INTERNAL_DEMO.POC_DEMO.COPY_STAGE_CONTROL 
WHERE node_name = 'COPY_CUSTOM' 
AND environment = 'DEV' 
AND is_active = true;

-- Test the exact query that the node will use
SELECT 'Testing the exact query from the node:' AS step;
SELECT stage_name 
FROM FUGETRON_INTERNAL_DEMO.POC_DEMO.COPY_STAGE_CONTROL 
WHERE node_name = 'COPY_CUSTOM' 
AND environment = 'DEV' 
AND is_active = true
LIMIT 1;
