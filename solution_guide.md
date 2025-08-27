# Solution: Node Only Shows SELECT Instead of COPY

## Problem
Your node is only running:
```sql
SELECT * FROM "FUGETRON_INTERNAL_DEMO"."POC_DEMO"."CPYD_NODE" LIMIT 100
```

Instead of the expected COPY INTO command.

## Root Cause
The custom node type template isn't being used properly. Coalesce is treating it as a regular SQL node.

## Solutions

### **Option 1: Use Override SQL (Recommended)**
Replace your current node with `CPYD_NODE_FIXED.yml`:

1. **Import `CPYD_NODE_FIXED.yml`** into your project
2. **This node has `overrideSQL: true`** which bypasses template generation
3. **It will run the exact COPY command** you want

### **Option 2: Fix Your Current Node**
Modify your existing node to use Override SQL:

```yaml
operation:
  config:
    overrideSQL: true
    customSQL: |
      -- Dynamic COPY with control table
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

### **Option 3: Use Original Data Package**
If you want to stick with the original data package approach:

1. **Change `sqlType` back to `test-pkg:::324`**
2. **Use the original configuration fields** (stageName, externalURI, etc.)
3. **Add Pre-SQL to set session variables**

## Why This Happens

1. **Custom node types** need to be properly registered in Coalesce
2. **Template generation** can fail silently
3. **Override SQL** is more reliable for custom logic

## Testing Steps

### **Step 1: Check Control Table**
```sql
SELECT * FROM FUGETRON_INTERNAL_DEMO.POC_DEMO.COPY_STAGE_CONTROL 
WHERE node_name = 'CPYD_NODE' AND environment = 'DEV' AND is_active = true;
```

### **Step 2: Test Manual COPY**
```sql
-- Replace MY_STAGE with actual stage name from control table
COPY INTO FUGETRON_INTERNAL_DEMO.POC_DEMO.CPYD_NODE
FROM @MY_STAGE/DC_POC/2025/08/06
FILE_FORMAT = (TYPE = 'CSV', FIELD_DELIMITER = ',', SKIP_HEADER = 1)
PATTERN = '.*\\.csv$';
```

### **Step 3: Use Override SQL Node**
Import and test `CPYD_NODE_FIXED.yml` - this should work immediately.

## Expected Result

With the Override SQL approach, you should see:
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

## Recommendation

**Use Option 1 (Override SQL)** - it's the most reliable approach and gives you exactly what you want: a COPY command with dynamic stage name from your control table.
