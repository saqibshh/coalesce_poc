-- Test to verify if the original data package (test-pkg:::324) accepts Pre-SQL

-- First, let's check if your control table has data:
SELECT 'Checking control table...' AS step;
SELECT * FROM FUGETRON_INTERNAL_DEMO.POC_DEMO.COPY_STAGE_CONTROL 
WHERE node_name = 'SRC-COPY_NODE' AND environment = 'DEV' AND is_active = true;

-- Test the Pre-SQL commands that would be used:
SELECT 'Testing Pre-SQL commands...' AS step;

-- Test setting session variables
SET STAGE_NAME = (
  SELECT stage_name 
  FROM FUGETRON_INTERNAL_DEMO.POC_DEMO.COPY_STAGE_CONTROL 
  WHERE node_name = 'SRC-COPY_NODE' 
  AND environment = 'DEV' 
  AND is_active = true
  LIMIT 1
);

SET EXTERNAL_URI = (
  SELECT external_uri 
  FROM FUGETRON_INTERNAL_DEMO.POC_DEMO.COPY_STAGE_CONTROL 
  WHERE node_name = 'SRC-COPY_NODE' 
  AND environment = 'DEV' 
  AND is_active = true
  LIMIT 1
);

SET SUBFOLDER = (
  SELECT subfolder 
  FROM FUGETRON_INTERNAL_DEMO.POC_DEMO.COPY_STAGE_CONTROL 
  WHERE node_name = 'SRC-COPY_NODE' 
  AND environment = 'DEV' 
  AND is_active = true
  LIMIT 1
);

SET FILE_PATTERN = (
  SELECT file_pattern 
  FROM FUGETRON_INTERNAL_DEMO.POC_DEMO.COPY_STAGE_CONTROL 
  WHERE node_name = 'SRC-COPY_NODE' 
  AND environment = 'DEV' 
  AND is_active = true
  LIMIT 1
);

-- Check if the variables were set:
SELECT 'Checking session variables...' AS step;
SELECT $STAGE_NAME AS stage_name, $EXTERNAL_URI AS external_uri, $SUBFOLDER AS subfolder, $FILE_PATTERN AS file_pattern;
