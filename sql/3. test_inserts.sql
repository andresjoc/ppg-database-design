-- ==============================================================================
-- 3. Inserciones de Datos de Prueba para Auricular Sense
-- Compatible con PostgreSQL 17, Neon Database y TimescaleDB
-- ==============================================================================

-- 1. Catálogos Base (ON CONFLICT DO NOTHING para evitar duplicados si ya existen)
INSERT INTO COMPUTE_STATUS (ID_COMPUTE_STATUS, NAME, DESCRIPTION) VALUES
(1, 'PENDING', 'Session waiting to be processed'),
(2, 'COMPLETED', 'Session processed successfully'),
(3, 'ERROR', 'Session processing failed')
ON CONFLICT (ID_COMPUTE_STATUS) DO NOTHING;

INSERT INTO SEVERITY_LEVEL (ID_SEVERITY_LEVEL, NAME, DESCRIPTION) VALUES
(1, 'LOW', 'Low severity alert'),
(2, 'MEDIUM', 'Medium severity alert'),
(3, 'HIGH', 'High severity alert')
ON CONFLICT (ID_SEVERITY_LEVEL) DO NOTHING;

INSERT INTO METRIC_TYPE (ID_METRIC_TYPE, UNIT, MIN_VALUE, MAX_VALUE, IS_DERIVED, NAME) VALUES
(1, 'bpm', 40.00, 200.00, false, 'Heart Rate'),
(2, '%', 70.00, 100.00, false, 'Oxygen Saturation'),
(3, 'ms', 0.00, 300.00, true, 'HRV'),
(4, 'bool', 0, 1, false, 'Tachycardia Detected'),
(5, '%', 0, 1, true, 'AF Confidence'),
(6, 'bool', 0, 1, false, 'AF Detected')
ON CONFLICT (ID_METRIC_TYPE) DO NOTHING;

INSERT INTO WEARABLE_MODEL (ID_WEARABLE_MODEL, BRAND, MODEL) VALUES
(1, 'Samsung', 'Galaxy Watch 4'),
(2, 'Samsung', 'Galaxy Watch 7'),
(3, 'PineTime', 'Dev Kit')
ON CONFLICT (ID_WEARABLE_MODEL) DO NOTHING;

-- 1.1 Catálogo Geográfico Mínimo (Garantiza que existan las ciudades referenciadas si no se cargó neon_data_extracted.sql)
INSERT INTO COUNTRY (ID_COUNTRY, NAME) VALUES (49, 'Colombia') ON CONFLICT (ID_COUNTRY) DO NOTHING;
INSERT INTO REGION (ID_REGION, ID_COUNTRY, NAME) VALUES 
(976, 49, 'Cundinamarca'),
(964, 49, 'Antioquia')
ON CONFLICT (ID_REGION) DO NOTHING;
INSERT INTO CITY (ID_CITY, ID_REGION, NAME) VALUES 
(7796, 976, 'Bogota'),
(17336, 964, 'Envigado')
ON CONFLICT (ID_CITY) DO NOTHING;

-- 2. Usuarios de Prueba (Usa IDs de ciudades existentes: 7796=Bogotá, 17336=Envigado)
INSERT INTO APP_USER (
  ID_USER, ID_CITY, EMAIL, FIRST_NAME, LAST_NAME, BIRTH_DATE
) VALUES
(1, 7796, 'ana.perez@test.com', 'Ana', 'Pérez', '1998-05-12'),
(2, 17336, 'carlos.gomez@test.com', 'Carlos', 'Gómez', '1995-09-20'),
(3, 7796, 'laura.martinez@test.com', 'Laura', 'Martínez', '2000-01-15')
ON CONFLICT (ID_USER) DO NOTHING;

-- 3. Credenciales de autenticación (Password: Test1234! para pruebas en MSAuth)
INSERT INTO AUTH_CREDENTIAL (
  ID_CREDENTIAL, ID_USER, PASSWORD_HASH, IS_ACTIVE
) VALUES
(1, 1, '$2b$12$L1AGUvpJTKxwObXFT8V4H.0mO6bFQHL79NZVRdO11XB/AgOjfrK6a', true),
(2, 2, '$2b$12$8FVRdQj33nPzvXAUVHwR..fBMM2lbPmbb19Oy1pXvyJQgl9fOrES.', true),
(3, 3, '$2b$12$UzqOBfEYO/nDXEcIu2tR.OAwmAXUoNf04RnjI3HNnxpi8l4qKE9z.', true)
ON CONFLICT (ID_CREDENTIAL) DO NOTHING;

-- 4. Wearables asociados
INSERT INTO WEARABLE (
  ID_WEARABLE, ID_USER, ID_WEARABLE_MODEL
) VALUES
(1, 1, 1),
(2, 2, 2),
(3, 3, 3)
ON CONFLICT (ID_WEARABLE) DO NOTHING;

-- 5. Fichas de Salud
INSERT INTO HEALTH_RECORD (
  ID_HEALTH_RECORD, ID_USER, WEIGHT_KG, HEIGHT_CM
) VALUES
(1, 1, 62.50, 165.0),
(2, 2, 78.20, 175.5),
(3, 3, 55.80, 160.2)
ON CONFLICT (ID_HEALTH_RECORD) DO NOTHING;

-- 6. Sesiones de Monitoreo
INSERT INTO MONITORING_SESSION (
  ID_SESSION, ID_USER, ID_WEARABLE, ID_COMPUTE_STATUS, DATE_TIME, IS_DELTA_ENCODED
) VALUES
(1, 1, 1, 2, '2026-04-20', true),
(2, 2, 2, 2, '2026-04-21', false),
(3, 3, 3, 1, '2026-04-22', true)
ON CONFLICT (ID_SESSION) DO NOTHING;

-- 7. Mediciones Clínicas
INSERT INTO MEASUREMENT (
  ID_MEASUREMENT, ID_METRIC_TYPE, ID_SESSION, VALUE, ERROR_MESSAGE, RECORDED_AT
) VALUES
(1, 1, 1, 72.0000, NULL, CURRENT_TIMESTAMP),
(2, 2, 1, 98.0000, NULL, CURRENT_TIMESTAMP),
(3, 1, 2, 88.0000, NULL, CURRENT_TIMESTAMP),
(4, 2, 2, 94.0000, NULL, CURRENT_TIMESTAMP),
(5, 3, 3, NULL, 'Unable to calculate HRV', CURRENT_TIMESTAMP)
ON CONFLICT (ID_MEASUREMENT) DO NOTHING;

-- 8. Muestras PPG (Timestamps Unix realistas en ms: año 2026)
INSERT INTO PPG_SAMPLE (
  ID_PPG_SAMPLE, ID_SESSION, TS, GREEN, RED, IR
) VALUES
(1, 1, 1776643200000, 520, 310, 410),
(2, 1, 1776643200040, 530, 315, 420),
(3, 2, 1776729600000, 610, 350, 455),
(4, 2, 1776729600040, 605, 348, 450),
(5, 3, 1776816000000, 490, 300, 390);

-- 9. Alertas
INSERT INTO ALERT (
  ID_ALERT, ID_SESSION, ID_SEVERITY_LEVEL, DESCRIPTION
) VALUES
(1, 1, 1, 'Heart rate within normal range'),
(2, 2, 2, 'Oxygen saturation slightly below expected range'),
(3, 3, 3, 'HRV could not be calculated')
ON CONFLICT (ID_ALERT) DO NOTHING;

-- 10. Sincronización segura de secuencias Identity (PostgreSQL 17)
DO $$
DECLARE
    seq_name text;
    max_val bigint;
    rec record;
    tables_cols text[][] := ARRAY[
        ['app_user', 'id_user'],
        ['auth_credential', 'id_credential'],
        ['wearable', 'id_wearable'],
        ['health_record', 'id_health_record'],
        ['monitoring_session', 'id_session'],
        ['measurement', 'id_measurement'],
        ['alert', 'id_alert'],
        ['ppg_sample', 'id_ppg_sample']
    ];
BEGIN
    FOR i IN 1 .. array_length(tables_cols, 1) LOOP
        seq_name := pg_get_serial_sequence('public.' || tables_cols[i][1], tables_cols[i][2]);
        IF seq_name IS NOT NULL THEN
            EXECUTE format('SELECT COALESCE(MAX(%I), 1) FROM %I', tables_cols[i][2], tables_cols[i][1]) INTO max_val;
            PERFORM setval(seq_name, max_val, true);
        END IF;
    END LOOP;
END $$;
