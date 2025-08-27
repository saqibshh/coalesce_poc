-- Test script to check control table and provide working solution

-- First, let's check what's in your control table
SELECT * FROM COPY_STAGE_CONTROL WHERE node_name = 'COPY_NODE';

-- If the table is empty or doesn't exist, let's create some test data
INSERT INTO COPY_STAGE_CONTROL (
    node_name, 
    stage_name, 
    external_uri, 
    subfolder, 
    file_pattern,
    is_active,
    environment,
    created_by,
    comments
) VALUES 
('COPY_NODE', 'MY_STAGE', 's3://my-bucket/data/', 'daily/', '.*\.csv$', TRUE, 'DEV', 'ADMIN', 'Test configuration')
ON DUPLICATE KEY UPDATE 
    stage_name = VALUES(stage_name),
    external_uri = VALUES(external_uri),
    subfolder = VALUES(subfolder),
    file_pattern = VALUES(file_pattern);

-- Test the query that should work
SELECT 
    stage_name,
    external_uri,
    subfolder,
    file_pattern
FROM COPY_STAGE_CONTROL 
WHERE node_name = 'COPY_NODE' 
AND is_active = true 
AND environment = 'DEV';
