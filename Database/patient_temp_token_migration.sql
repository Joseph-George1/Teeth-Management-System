-- Patient Temporary Token Table
-- Allows patients to access their appointment notifications without permanent login
-- Created: April 5, 2026

CREATE TABLE PATIENT_TEMP_TOKEN (
    id INTEGER PRIMARY KEY,
    token VARCHAR2(50) NOT NULL UNIQUE,
    
    -- Patient Information
    patient_id INTEGER NOT NULL,
    patient_first_name VARCHAR2(100),
    patient_last_name VARCHAR2(100),
    patient_email VARCHAR2(255),
    patient_phone VARCHAR2(20),
    
    -- Appointment Reference
    appointment_id INTEGER NOT NULL,
    clinic_name VARCHAR2(255),
    clinic_location VARCHAR2(255),
    appointment_date TIMESTAMP,
    
    -- Token Lifecycle
    created_at TIMESTAMP DEFAULT SYSDATE,
    expires_at TIMESTAMP NOT NULL,
    
    -- Usage Tracking
    is_used NUMBER(1) DEFAULT 0,
    used_at TIMESTAMP,
    
    -- Access Tracking
    accessed_at TIMESTAMP,
    access_count INTEGER DEFAULT 0,
    
    -- Indexes for fast lookups and cleanup
    CONSTRAINT pk_patient_token PRIMARY KEY (id)
);

-- Create indexes for common queries
CREATE INDEX IDX_PATIENT_TOKEN ON PATIENT_TEMP_TOKEN(token);
CREATE INDEX IDX_PATIENT_ID ON PATIENT_TEMP_TOKEN(patient_id);
CREATE INDEX IDX_APPOINTMENT_ID ON PATIENT_TEMP_TOKEN(appointment_id);
CREATE INDEX IDX_TOKEN_EXPIRY ON PATIENT_TEMP_TOKEN(expires_at);
CREATE INDEX IDX_TOKEN_STATUS ON PATIENT_TEMP_TOKEN(is_used, expires_at);
CREATE INDEX IDX_PATIENT_APPOINTMENT ON PATIENT_TEMP_TOKEN(patient_id, appointment_id);

-- Optional: Sequence for ID generation
CREATE SEQUENCE seq_patient_token_id START WITH 1 INCREMENT BY 1;

-- Optional: View for active tokens
CREATE VIEW active_patient_tokens AS
SELECT * FROM PATIENT_TEMP_TOKEN
WHERE is_used = 0 AND expires_at > SYSDATE
ORDER BY created_at DESC;

-- Optional: View for usage statistics
CREATE VIEW patient_token_stats AS
SELECT 
    patient_id,
    COUNT(*) as total_tokens,
    SUM(CASE WHEN is_used = 0 AND expires_at > SYSDATE THEN 1 ELSE 0 END) as active_tokens,
    SUM(CASE WHEN is_used = 1 THEN 1 ELSE 0 END) as used_tokens,
    MAX(created_at) as last_token_generated
FROM PATIENT_TEMP_TOKEN
GROUP BY patient_id;
