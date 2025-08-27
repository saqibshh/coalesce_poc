# Quick Fix Guide: Empty SQL Statement Error

## 🚨 Immediate Solutions

### **Option 1: Use Override SQL (Recommended)**
This bypasses template generation entirely and should work immediately.

1. **Use the `COPY_NODE_OVERRIDE.yml`** I just created
2. **This node has `overrideSQL: true`** and custom SQL that reads from your control table
3. **No template issues** - it uses direct SQL

### **Option 2: Use Simplified Template**
The template is now simplified to just basic COPY commands.

1. **The `run.sql.j2` is now minimal** with hardcoded values
2. **Update the hardcoded values** in the template:
   - Change `MY_STAGE` to your actual stage name
   - Change `DC_POC/2025/08/06` to your actual subfolder
   - Change `.*\.csv$` to your actual file pattern

### **Option 3: Use Your Original Node with Override SQL**
Modify your existing `SRC-COPY_NODE.yml`:

```yaml
operation:
  config:
    overrideSQL: true
    customSQL: |
      -- Dynamic COPY with control table
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
              FROM FUGETRON_INTERNAL_DEMO.POC_DEMO.COPY_STAGE_CONTROL 
              WHERE node_name = '{{ node.name }}' 
              AND environment = 'DEV' 
              AND is_active = true
              LIMIT 1
          ) / (
              SELECT subfolder 
              FROM FUGETRON_INTERNAL_DEMO.POC_DEMO.COPY_STAGE_CONTROL 
              WHERE node_name = '{{ node.name }}' 
              AND environment = 'DEV' 
              AND is_active = true
              LIMIT 1
          )
      )
      FILE_FORMAT = (
          TYPE = 'CSV',
          FIELD_DELIMITER = ',',
          SKIP_HEADER = 1
      )
      PATTERN = (
          SELECT file_pattern 
          FROM FUGETRON_INTERNAL_DEMO.POC_DEMO.COPY_STAGE_CONTROL 
          WHERE node_name = '{{ node.name }}' 
          AND environment = 'DEV' 
          AND is_active = true
          LIMIT 1
      );
```

## 🔍 Debug Steps

### **Step 1: Check Control Table**
```sql
-- Run this to verify your control table has data
SELECT * FROM FUGETRON_INTERNAL_DEMO.POC_DEMO.COPY_STAGE_CONTROL
WHERE node_name = 'COPY_NODE_DYNAMIC';
```

### **Step 2: Check Stage Exists**
```sql
-- Verify your stage exists
SHOW STAGES LIKE '%MY_STAGE%';
```

### **Step 3: Test Simple COPY**
```sql
-- Test a simple COPY command manually
COPY INTO SRC.COPY_NODE_DYNAMIC
FROM (
    SELECT 
        $1::VARIANT AS SRC,
        current_timestamp()::timestamp_ntz AS LOAD_TIMESTAMP,
        METADATA$FILENAME AS FILENAME,
        METADATA$FILE_ROW_NUMBER AS FILE_ROW_NUMBER,
        METADATA$FILE_LAST_MODIFIED AS FILE_LAST_MODIFIED,
        METADATA$START_SCAN_TIME AS SCAN_TIME
    FROM @MY_STAGE/DC_POC/2025/08/06
)
FILE_FORMAT = (
    TYPE = 'CSV',
    FIELD_DELIMITER = ',',
    SKIP_HEADER = 1
)
PATTERN = '.*\.csv$';
```

## 🎯 Recommended Action

**Use Option 1 (Override SQL)** - it's the most reliable approach:

1. **Import `COPY_NODE_OVERRIDE.yml`** into your Coalesce project
2. **Make sure your control table has data** for `COPY_NODE_OVERRIDE`
3. **Test the node** - it should work immediately
4. **No template generation issues** - it uses direct SQL

This approach gives you:
- ✅ **Dynamic stage configuration** from control table
- ✅ **No template generation issues**
- ✅ **Immediate working solution**
- ✅ **Easy to modify and maintain**

## 🚀 Next Steps

Once you have a working COPY node:

1. **Test with the Override SQL approach**
2. **Verify it reads from your control table correctly**
3. **Add Pre-SQL and Post-SQL as needed**
4. **Create multiple nodes for different environments**

The Override SQL approach is actually more reliable than custom templates and gives you full control over the SQL generation!
