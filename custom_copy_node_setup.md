# Custom CopyDynamic Node Setup Guide

## Overview
I've created a custom node type called **CopyDynamic** that properly executes Pre-SQL and dynamically reads stage configuration from your control table.

## What's Different from the Original Node

### ✅ **Guaranteed Pre-SQL Execution**
- The custom template explicitly executes Pre-SQL before the COPY operation
- You can add any SQL logic in Pre-SQL (logging, session variables, etc.)

### ✅ **Dynamic Stage Configuration**
- Reads stage name, subfolder, and file pattern directly from your control table
- No more static values or session variable issues

### ✅ **Environment-Based Configuration**
- Dropdown to select environment (DEV/PROD/TEST)
- Automatically filters control table by environment

## Setup Steps

### Step 1: Control Table Setup
```sql
-- Create the control table if it doesn't exist
CREATE OR REPLACE TABLE FUGETRON_INTERNAL_DEMO.POC_DEMO.COPY_STAGE_CONTROL (
    node_name VARCHAR(255) NOT NULL,
    stage_name VARCHAR(255) NOT NULL,
    external_uri VARCHAR(500),
    subfolder VARCHAR(255),
    file_pattern VARCHAR(255) DEFAULT '.*',
    is_active BOOLEAN DEFAULT TRUE,
    environment VARCHAR(50) DEFAULT 'DEV',
    created_date TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_date TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    created_by VARCHAR(100),
    comments VARCHAR(1000)
);

-- Insert your stage configurations
INSERT INTO FUGETRON_INTERNAL_DEMO.POC_DEMO.COPY_STAGE_CONTROL VALUES 
('COPY_NODE_DYNAMIC', 'MY_STAGE', 's3://my-bucket/data/', 'DC_POC/2025/08/06', '.*\.csv$', TRUE, 'DEV', 'ADMIN', 'Development config'),
('COPY_NODE_DYNAMIC', 'PROD_STAGE', 's3://prod-bucket/data/', 'DC_POC/2025/08/06', '.*\.csv$', TRUE, 'PROD', 'ADMIN', 'Production config');
```

### Step 2: Use the Custom Node
Replace your existing SRC-COPY_NODE with the new COPY_NODE_DYNAMIC:

**Configuration:**
- **Control Table Schema**: `FUGETRON_INTERNAL_DEMO.POC_DEMO`
- **Control Table Name**: `COPY_STAGE_CONTROL`
- **Environment**: `DEV` (or PROD/TEST)
- **File Type**: `CSV`
- **Field Delimiter**: `,`
- **Skip Header**: `1`

**Pre-SQL Example:**
```sql
-- Log the configuration being used
SELECT 
  'Using CopyDynamic node with environment: ' || '{{ config.environment }}' ||
  ', Control table: ' || '{{ config.controlTableSchema }}.{{ config.controlTableName }}' AS config_info;

-- You can add any additional Pre-SQL logic here
-- For example, setting session variables, logging, etc.
```

### Step 3: How It Works

When the node runs:

1. **Pre-SQL executes first** (guaranteed)
2. **Template reads from control table**:
   ```sql
   SELECT stage_name FROM FUGETRON_INTERNAL_DEMO.POC_DEMO.COPY_STAGE_CONTROL 
   WHERE node_name = 'COPY_NODE_DYNAMIC' 
   AND environment = 'DEV' 
   AND is_active = true
   ```
3. **COPY command uses dynamic values**:
   ```sql
   COPY INTO SRC.COPY_NODE_DYNAMIC
   FROM @[STAGE_NAME_FROM_CONTROL_TABLE]/[SUBFOLDER_FROM_CONTROL_TABLE]
   FILE_FORMAT = (TYPE = 'CSV', FIELD_DELIMITER = ',', SKIP_HEADER = 1)
   PATTERN = [FILE_PATTERN_FROM_CONTROL_TABLE]
   ```

## Benefits

✅ **Pre-SQL Always Executes** - No more issues with Pre-SQL not running  
✅ **True Dynamic Configuration** - Stage names from control table  
✅ **Environment Management** - Easy DEV/PROD/TEST switching  
✅ **Centralized Control** - All configs in one table  
✅ **Audit Trail** - Track configuration changes  
✅ **No SQL Compilation Errors** - Proper template handling  

## Environment Switching

To switch environments:
1. **Change the Environment dropdown** in the node configuration
2. **Or create separate nodes** for each environment:
   - `COPY_NODE_DYNAMIC_DEV` with Environment = DEV
   - `COPY_NODE_DYNAMIC_PROD` with Environment = PROD
   - `COPY_NODE_DYNAMIC_TEST` with Environment = TEST

## Testing

1. **Run the control table setup script**
2. **Use the COPY_NODE_DYNAMIC configuration**
3. **Check the logs** - you should see Pre-SQL execution and dynamic stage resolution
4. **Verify the COPY operation** uses the correct stage from your control table

This custom node type solves all the issues you were having with the original node and gives you the true dynamic stage configuration workflow you wanted!
