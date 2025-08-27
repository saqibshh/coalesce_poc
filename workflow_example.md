# COPY Node Workflow with Control Table

## Setup Steps:

### 1. Create the Control Table
Run the `control_table_setup.sql` script to create the `COPY_STAGE_CONTROL` table.

### 2. Populate Control Table
Insert your stage configurations:

```sql
-- For Development
INSERT INTO COPY_STAGE_CONTROL (node_name, stage_name, external_uri, subfolder, environment) 
VALUES ('COPY_NODE', 'DEV_STAGE', 's3://dev-bucket/data/', 'daily/', 'DEV');

-- For Production  
INSERT INTO COPY_STAGE_CONTROL (node_name, stage_name, external_uri, subfolder, environment) 
VALUES ('COPY_NODE', 'PROD_STAGE', 's3://prod-bucket/data/', 'daily/', 'PROD');
```

### 3. Configure Your COPY Node
Your `SRC-COPY_NODE.yml` is now configured to:
- Read stage name from control table
- Read external URI from control table  
- Read subfolder from control table
- Use environment-specific configurations

### 4. How It Works

When your COPY node runs:

1. **Pre-SQL executes first** and sets session variables:
   ```sql
   SET STAGE_NAME = (SELECT stage_name FROM COPY_STAGE_CONTROL WHERE node_name = 'COPY_NODE' AND environment = 'DEV');
   SET EXTERNAL_URI = (SELECT external_uri FROM COPY_STAGE_CONTROL WHERE node_name = 'COPY_NODE' AND environment = 'DEV');
   SET SUBFOLDER = (SELECT subfolder FROM COPY_STAGE_CONTROL WHERE node_name = 'COPY_NODE' AND environment = 'DEV');
   ```

2. **COPY command uses these variables**:
   ```sql
   COPY INTO SRC.COPY_NODE
   FROM @$STAGE_NAME/$SUBFOLDER
   FILE_FORMAT = (TYPE = 'CSV', FIELD_DELIMITER = ',', SKIP_HEADER = 1)
   ```

### 5. Environment Switching

To switch environments, just update the environment filter in Pre-SQL:
- Change `AND environment = 'DEV'` to `AND environment = 'PROD'`
- Or use a parameter/variable for environment

### 6. Benefits

✅ **Centralized Configuration**: All stage names in one table  
✅ **Environment Management**: Different configs for DEV/PROD/TEST  
✅ **Easy Updates**: Change stage names without touching node config  
✅ **Audit Trail**: Track who changed what and when  
✅ **Active/Inactive**: Disable configurations without deleting  

### 7. Example Control Table Data

| node_name | stage_name | external_uri | subfolder | environment | is_active |
|-----------|------------|--------------|-----------|-------------|-----------|
| COPY_NODE | DEV_STAGE | s3://dev-bucket/ | daily/ | DEV | true |
| COPY_NODE | PROD_STAGE | s3://prod-bucket/ | daily/ | PROD | true |
| COPY_NODE | TEST_STAGE | s3://test-bucket/ | test/ | TEST | false |

This workflow gives you the flexibility to manage your COPY node configurations dynamically through a control table!
