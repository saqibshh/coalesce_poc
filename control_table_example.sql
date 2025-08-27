-- Example Control Table for Dynamic COPY Node Configuration
-- This table stores configuration parameters for COPY nodes

CREATE OR REPLACE TABLE COPY_CONTROL_TABLE (
    table_name VARCHAR(255) NOT NULL,
    stage_name VARCHAR(255) NOT NULL,
    external_uri VARCHAR(500),
    subfolder VARCHAR(255),
    file_type VARCHAR(50) DEFAULT 'CSV',
    field_delimiter VARCHAR(10) DEFAULT ',',
    skip_header NUMBER DEFAULT 1,
    file_pattern VARCHAR(255) DEFAULT '.*',
    is_active BOOLEAN DEFAULT TRUE,
    created_date TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_date TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    created_by VARCHAR(100),
    comments VARCHAR(1000)
);

-- Insert example data
INSERT INTO COPY_CONTROL_TABLE (
    table_name, 
    stage_name, 
    external_uri, 
    subfolder, 
    file_type, 
    field_delimiter, 
    skip_header, 
    file_pattern,
    is_active,
    created_by,
    comments
) VALUES 
('COPY_NODE', 'MY_STAGE', 's3://my-bucket/data/', 'daily/', 'CSV', ',', 1, '.*\.csv$', TRUE, 'ADMIN', 'Main copy node configuration'),
('COPY_NODE_2', 'ANOTHER_STAGE', 's3://another-bucket/files/', 'monthly/', 'JSON', NULL, 0, '.*\.json$', TRUE, 'ADMIN', 'JSON file copy configuration'),
('COPY_NODE_3', 'TEST_STAGE', 's3://test-bucket/', NULL, 'PARQUET', NULL, 0, '.*\.parquet$', FALSE, 'ADMIN', 'Inactive configuration');

-- Create a view for easier access
CREATE OR REPLACE VIEW V_COPY_CONTROL AS
SELECT 
    table_name,
    stage_name,
    external_uri,
    subfolder,
    file_type,
    field_delimiter,
    skip_header,
    file_pattern,
    is_active,
    created_date,
    updated_date,
    created_by,
    comments
FROM COPY_CONTROL_TABLE
WHERE is_active = TRUE;

-- Example of how to use the control table in a COPY node configuration:
-- In your COPY node's stageName field, you can use:
-- SELECT stage_name FROM COPY_CONTROL_TABLE WHERE table_name = 'COPY_NODE' AND is_active = TRUE

-- Or in the externalURI field:
-- SELECT external_uri FROM COPY_CONTROL_TABLE WHERE table_name = 'COPY_NODE' AND is_active = TRUE
