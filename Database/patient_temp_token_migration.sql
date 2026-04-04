-- 1. DROP EXISTING ZOMBIE OBJECTS
DROP VIEW active_patient_tokens;
DROP VIEW patient_token_stats;
DROP SEQUENCE seq_patient_token_id;
DROP TABLE PATIENT_TEMP_TOKEN CASCADE CONSTRAINTS;

-- 2. CREATE TABLE (COMPACTED TO AVOID BUFFER BREAKS)
CREATE TABLE PATIENT_TEMP_TOKEN (
    id NUMBER(19) PRIMARY KEY,
    token VARCHAR2(255) NOT NULL,
    patient_id NUMBER(19),
    patient_first_name VARCHAR2(255),
    patient_last_name VARCHAR2(255),
    patient_email VARCHAR2(255),
    patient_phone VARCHAR2(255),
    appointment_id NUMBER(19),
    clinic_name VARCHAR2(255),
    clinic_location VARCHAR2(255),
    appointment_time TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    is_used NUMBER(1) DEFAULT 0,
    used_at TIMESTAMP,
    accessed_at TIMESTAMP,
    access_count NUMBER(10) DEFAULT 0
);

-- 3. RECREATE SEQUENCE
CREATE SEQUENCE seq_patient_token_id START WITH 1 INCREMENT BY 1;

-- 4. RECREATE INDEXES
CREATE INDEX IDX_PAT_TOKEN ON PATIENT_TEMP_TOKEN(token);
CREATE INDEX IDX_PAT_ID ON PATIENT_TEMP_TOKEN(patient_id);
CREATE INDEX IDX_APP_ID ON PATIENT_TEMP_TOKEN(appointment_id);
CREATE INDEX IDX_TOK_EXP ON PATIENT_TEMP_TOKEN(expires_at);

-- 5. RECREATE VIEWS
CREATE VIEW active_patient_tokens AS
SELECT * FROM PATIENT_TEMP_TOKEN WHERE is_used = 0 AND expires_at > CURRENT_TIMESTAMP;

CREATE VIEW patient_token_stats AS
SELECT patient_id, COUNT(*) as total_tokens FROM PATIENT_TEMP_TOKEN GROUP BY patient_id;

COMMIT;
