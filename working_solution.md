# Working Solution for Dynamic Stage Configuration

## Problem Analysis
The custom node type (test-pkg:::324) doesn't support SQL queries in configuration fields. We need a different approach.

## Solution: Environment-Based Configuration

### Step 1: Set Up Control Table
```sql
-- Run this to create and populate your control table
CREATE OR REPLACE TABLE COPY_STAGE_CONTROL (
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

-- Insert configurations for different environments
INSERT INTO COPY_STAGE_CONTROL VALUES 
('COPY_NODE', 'DEV_STAGE', 's3://dev-bucket/data/', 'daily/', '.*\.csv$', TRUE, 'DEV', 'ADMIN', 'Development config'),
('COPY_NODE', 'PROD_STAGE', 's3://prod-bucket/data/', 'daily/', '.*\.csv$', TRUE, 'PROD', 'ADMIN', 'Production config'),
('COPY_NODE', 'TEST_STAGE', 's3://test-bucket/data/', 'test/', '.*\.csv$', TRUE, 'TEST', 'ADMIN', 'Test config');
```

### Step 2: Current Working Configuration
Your SRC-COPY_NODE.yml now has:
- **Static values** for immediate functionality
- **Pre-SQL** that logs the configuration being used
- **Environment variable** that you can change to switch environments

### Step 3: How to Switch Environments

#### Option A: Change Environment in Pre-SQL
```sql
-- In your Pre-SQL, change this line:
SET ENV = 'DEV';  -- Change to 'PROD' or 'TEST'
```

#### Option B: Create Environment-Specific Nodes
Create separate nodes for each environment:
- `COPY_NODE_DEV` with `SET ENV = 'DEV';`
- `COPY_NODE_PROD` with `SET ENV = 'PROD';`
- `COPY_NODE_TEST` with `SET ENV = 'TEST';`

### Step 4: Alternative Approach - Use Override SQL

If you want true dynamic configuration, you can use the `overrideSQL` feature:

```yaml
overrideSQL: true
```

Then in the custom SQL field, you can write:
```sql
-- Dynamic COPY based on control table
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
        FROM COPY_STAGE_CONTROL 
        WHERE node_name = '{{ node.name }}' 
        AND environment = 'DEV' 
        AND is_active = true
    ) / (
        SELECT subfolder 
        FROM COPY_STAGE_CONTROL 
        WHERE node_name = '{{ node.name }}' 
        AND environment = 'DEV' 
        AND is_active = true
    )
)
FILE_FORMAT = (
    TYPE = 'CSV',
    FIELD_DELIMITER = ',',
    SKIP_HEADER = 1
)
PATTERN = (
    SELECT file_pattern 
    FROM COPY_STAGE_CONTROL 
    WHERE node_name = '{{ node.name }}' 
    AND environment = 'DEV' 
    AND is_active = true
);
```

### Step 5: Recommended Approach

For now, use the **static configuration with environment logging** approach:

1. **Keep current static values** in your node configuration
2. **Use Pre-SQL** to log which configuration should be used
3. **Manually update** the static values when you need to change environments
4. **Use control table** as documentation and audit trail

### Step 6: Testing

1. Run the control table setup script
2. Test your COPY node with current configuration
3. Check the logs to see which configuration is being used
4. Update static values as needed for different environments

This approach gives you:
✅ **Working configuration** - no SQL compilation errors  
✅ **Environment awareness** - logs show which config should be used  
✅ **Control table** - centralized configuration management  
✅ **Audit trail** - track configuration changes  
✅ **Flexibility** - easy to switch environments manually  

The key is that the custom node type doesn't support dynamic SQL in configuration fields, so we use static values with environment-based logging and manual updates.
