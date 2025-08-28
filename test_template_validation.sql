-- Test SQL to verify template validation
-- This shows how the modified templates will generate valid SQL in different scenarios

-- Scenario 1: Using control table (when controlTableLoc and controlTableName are provided)
-- Expected SQL from run.sql.j2:
/*
COPY INTO "TARGET_DB"."TARGET_SCHEMA"."TARGET_TABLE" (
    "COLUMN1",
    "COLUMN2",
    "LOAD_TIMESTAMP"
)
FROM (SELECT
    $1::STRING AS "COLUMN1",
    $2::NUMBER AS "COLUMN2",
    current_timestamp()::timestamp_ntz AS "LOAD_TIMESTAMP"
FROM '@"STAGE_DB"."STAGE_SCHEMA".' || (SELECT stage_name FROM "CONTROL_DB"."CONTROL_SCHEMA"."COPY_STAGE_CONTROL" WHERE node_name = 'COPY_NODE' AND is_active = TRUE LIMIT 1) || '/daily/')
FILES = ('test.csv')
FILE_FORMAT = (TYPE = 'CSV' FIELD_DELIMITER = ',');
*/

-- Scenario 2: Using traditional stage name (when controlTableLoc and controlTableName are not provided)
-- Expected SQL from run.sql.j2:
/*
COPY INTO "TARGET_DB"."TARGET_SCHEMA"."TARGET_TABLE" (
    "COLUMN1",
    "COLUMN2",
    "LOAD_TIMESTAMP"
)
FROM (SELECT
    $1::STRING AS "COLUMN1",
    $2::NUMBER AS "COLUMN2",
    current_timestamp()::timestamp_ntz AS "LOAD_TIMESTAMP"
FROM '@"STAGE_DB"."STAGE_SCHEMA".MY_DATA_STAGE/daily/')
FILES = ('test.csv')
FILE_FORMAT = (TYPE = 'CSV' FIELD_DELIMITER = ',');
*/

-- Scenario 3: INFER_SCHEMA with control table (from create.sql.j2)
-- Expected SQL:
/*
CREATE OR REPLACE TABLE TARGET_DB.TARGET_SCHEMA.TARGET_TABLE
USING TEMPLATE (SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
FROM TABLE(
  INFER_SCHEMA(
    LOCATION=>'@"STAGE_DB"."STAGE_SCHEMA".' || (SELECT stage_name FROM "CONTROL_DB"."CONTROL_SCHEMA"."COPY_STAGE_CONTROL" WHERE node_name = 'COPY_NODE' AND is_active = TRUE LIMIT 1) || '/daily/',
    FILES = ('test.csv'),
    FILE_FORMAT=>'"FILE_DB"."FILE_SCHEMA"."MY_FILE_FORMAT"'
  )
));
*/

-- Scenario 4: INFER_SCHEMA with traditional stage name (from create.sql.j2)
-- Expected SQL:
/*
CREATE OR REPLACE TABLE TARGET_DB.TARGET_SCHEMA.TARGET_TABLE
USING TEMPLATE (SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
FROM TABLE(
  INFER_SCHEMA(
    LOCATION=>'@"STAGE_DB"."STAGE_SCHEMA".MY_DATA_STAGE/daily/',
    FILES = ('test.csv'),
    FILE_FORMAT=>'"FILE_DB"."FILE_SCHEMA"."MY_FILE_FORMAT"'
  )
));
*/

-- Test the conditional logic
SELECT 
    CASE 
        WHEN 'CONTROL_DB' IS NOT NULL AND 'COPY_STAGE_CONTROL' IS NOT NULL 
        THEN 'Using control table approach'
        ELSE 'Using traditional stage name approach'
    END AS approach_used;
