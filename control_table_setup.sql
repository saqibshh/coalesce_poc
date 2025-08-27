-- Control Table for COPY Node Stage Configuration
-- This table will store stage names and other configuration for your COPY nodes

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

-- Insert sample data for your COPY_NODE
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
('COPY_NODE', 'MY_DATA_STAGE', 's3://my-bucket/data/', 'daily/', '.*\.csv$', TRUE, 'DEV', 'ADMIN', 'Main copy node for daily data'),
('COPY_NODE', 'PROD_DATA_STAGE', 's3://prod-bucket/data/', 'daily/', '.*\.csv$', TRUE, 'PROD', 'ADMIN', 'Production copy node'),
('COPY_NODE', 'TEST_STAGE', 's3://test-bucket/', 'test/', '.*\.csv$', FALSE, 'TEST', 'ADMIN', 'Test configuration');

-- Create a view for easier access
CREATE OR REPLACE VIEW V_COPY_STAGE_CONFIG AS
SELECT 
    node_name,
    stage_name,
    external_uri,
    subfolder,
    file_pattern,
    is_active,
    environment,
    created_date,
    updated_date,
    created_by,
    comments
FROM COPY_STAGE_CONTROL
WHERE is_active = TRUE;

-- Grant permissions if needed
-- GRANT SELECT ON COPY_STAGE_CONTROL TO YOUR_ROLE;
-- GRANT SELECT ON V_COPY_STAGE_CONFIG TO YOUR_ROLE;
