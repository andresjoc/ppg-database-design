-- =============================================================================
-- MIGRACIÓN CLÍNICA: Auricular Sense (Protocolo Dossier 70 Pacientes)
-- =============================================================================
-- Tabla para almacenamiento de validación clínica, métricas Edge AI y serie
-- temporal PPG completa (1,500 muestras a 25 Hz) con vínculo al evaluador (app_user).
-- =============================================================================

CREATE TABLE IF NOT EXISTS clinical_validation_record (
    id VARCHAR(64) PRIMARY KEY,
    
    -- Relación con el Médico / Evaluador y Dispositivo
    evaluator_user_id INT REFERENCES app_user(id_user) ON DELETE SET NULL,
    id_wearable INT REFERENCES wearable(id_wearable) ON DELETE SET NULL,
    smartwatch_model VARCHAR(64) DEFAULT 'Galaxy Watch 7',
    institution VARCHAR(128) DEFAULT 'Hospital Universitario San Rafael',
    consent_accepted BOOLEAN NOT NULL DEFAULT TRUE,

    -- Identificación y Diseño del Estudio
    patient_code VARCHAR(32) NOT NULL,
    capture_index INT NOT NULL DEFAULT 1,
    cohort VARCHAR(16) NOT NULL,            -- 'AF' o 'CONTROL'

    -- Demografía y Antropometría
    age INT NOT NULL,
    biological_sex VARCHAR(16) NOT NULL,     -- 'Masculino', 'Femenino', 'Otro'
    weight_kg NUMERIC(5, 2) NOT NULL,
    height_cm NUMERIC(5, 2) NOT NULL,
    bmi NUMERIC(4, 1) NOT NULL,

    -- Condiciones Fisiológicas Locales
    skin_temperature NUMERIC(4, 2) NOT NULL, -- Protocolo exige > 32.0 °C
    fitzpatrick_scale INT NOT NULL,          -- 1 a 6
    wrist VARCHAR(16) NOT NULL,              -- 'Izquierda' o 'Derecha'

    -- Antecedentes Médicos y Farmacológicos
    has_af_history BOOLEAN NOT NULL DEFAULT FALSE,
    af_subtype VARCHAR(64),                  -- 'Paroxística', 'Persistente', 'Permanente'
    time_since_diagnosis VARCHAR(64),
    comorbidities JSONB DEFAULT '[]'::jsonb,
    cardio_drugs_12h JSONB DEFAULT '[]'::jsonb,
    device_history JSONB DEFAULT '[]'::jsonb,

    -- Patrón de Oro Médico General (Ground Truth ECG Simultáneo)
    ecg_rhythm_diagnosis VARCHAR(128) NOT NULL,
    ecg_modality VARCHAR(128) NOT NULL,
    evaluating_physician VARCHAR(128),
    ecg_taken_at TIMESTAMP WITH TIME ZONE,
    observations TEXT,

    -- Métricas del Algoritmo, Inferencia Edge AI y Wearable (App)
    ai_af_detected BOOLEAN NOT NULL,
    ai_confidence NUMERIC(5, 4) NOT NULL,
    heart_rate_bpm NUMERIC(5, 2) NOT NULL,
    hrv_rmssd NUMERIC(6, 2) NOT NULL,
    hrv_sdnn NUMERIC(6, 2) NOT NULL DEFAULT 0.0,
    blood_oxygen_level NUMERIC(4, 1),        -- Saturación SpO2 calculada en % para Galaxy Watch
    is_tachycardic BOOLEAN NOT NULL DEFAULT FALSE,
    recorded_beats_count INT NOT NULL DEFAULT 0,
    recording_duration_seconds INT NOT NULL DEFAULT 60,
    validation_outcome VARCHAR(8) NOT NULL,   -- 'VP', 'VN', 'FP', 'FN'

    -- Métricas Clínicas de Referencia del Médico (Ground Truth Fisiológico)
    doctor_heart_rate_bpm NUMERIC(5, 2),     -- FC de referencia tomada por el médico
    doctor_blood_oxygen_level NUMERIC(4, 1), -- SpO2 de referencia tomada por el médico
    doctor_hrv_rmssd NUMERIC(6, 2),          -- HRV de referencia tomado por equipo ECG
    doctor_metrics_observations TEXT,        -- Observaciones y métricas extra (TA, FR, etc.)

    -- Serie Temporal Cruda Completa (Solo muestras y muestreo, limpia de SpO2)
    raw_ppg_data JSONB,

    -- Control de Sincronización
    sync_status VARCHAR(20) NOT NULL DEFAULT 'SYNCED',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    synced_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Índices de alto rendimiento para filtros clínicos y auditoría
CREATE INDEX IF NOT EXISTS idx_cvr_patient_code ON clinical_validation_record(patient_code);
CREATE INDEX IF NOT EXISTS idx_cvr_cohort ON clinical_validation_record(cohort);
CREATE INDEX IF NOT EXISTS idx_cvr_evaluator ON clinical_validation_record(evaluator_user_id);
CREATE INDEX IF NOT EXISTS idx_cvr_outcome ON clinical_validation_record(validation_outcome);
CREATE INDEX IF NOT EXISTS idx_cvr_created_at ON clinical_validation_record(created_at);

-- Migraciones evolutivas para instancias ya desplegadas en Neon
ALTER TABLE clinical_validation_record ADD COLUMN IF NOT EXISTS smartwatch_model VARCHAR(64) DEFAULT 'Galaxy Watch 7';
ALTER TABLE clinical_validation_record ADD COLUMN IF NOT EXISTS consent_accepted BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE clinical_validation_record ADD COLUMN IF NOT EXISTS institution VARCHAR(128) DEFAULT 'Hospital Universitario San Rafael';
ALTER TABLE clinical_validation_record ADD COLUMN IF NOT EXISTS blood_oxygen_level NUMERIC(4, 1);
ALTER TABLE clinical_validation_record ADD COLUMN IF NOT EXISTS doctor_heart_rate_bpm NUMERIC(5, 2);
ALTER TABLE clinical_validation_record ADD COLUMN IF NOT EXISTS doctor_blood_oxygen_level NUMERIC(4, 1);
ALTER TABLE clinical_validation_record ADD COLUMN IF NOT EXISTS doctor_hrv_rmssd NUMERIC(6, 2);
ALTER TABLE clinical_validation_record ADD COLUMN IF NOT EXISTS doctor_metrics_observations TEXT;
