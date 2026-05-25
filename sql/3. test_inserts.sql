


INSERT INTO COUNTRY (ID_COUNTRY, NAME) VALUES
(1, 'Colombia'),
(2, 'MÃ©xico');

INSERT INTO CITY (ID_CITY, ID_COUNTRY, NAME) VALUES
(1, 1, 'BogotÃ¡'),
(2, 1, 'MedellÃ­n'),
(3, 2, 'Ciudad de MÃ©xico');

INSERT INTO COMPUTE_STATUS (ID_COMPUTE_STATUS, NAME, DESCRIPTION) VALUES
(1, 'PENDING', 'Session waiting to be processed'),
(2, 'COMPLETED', 'Session processed successfully'),
(3, 'ERROR', 'Session processing failed');

INSERT INTO SEVERITY_LEVEL (ID_SEVERITY_LEVEL, NAME, DESCRIPTION) VALUES
(1, 'LOW', 'Low severity alert'),
(2, 'MEDIUM', 'Medium severity alert'),
(3, 'HIGH', 'High severity alert');

INSERT INTO METRIC_TYPE (ID_METRIC_TYPE, UNIT, MIN_VALUE, MAX_VALUE, IS_DERIVED, NAME) VALUES
(1, 'bpm', 40.00, 200.00, false, 'Heart Rate'),
(2, '%', 70.00, 100.00, false, 'Oxygen Saturation'),
(3, 'ms', 0.00, 300.00, true, 'HRV'),
(4, 'bool', 0, 1, false, 'Tachycardia Detected'),
(5, '%', 0, 1, true, 'AF Confidence'),
(6, 'bool', 0, 1, false, 'AF Detected');


INSERT INTO WEARABLE_MODEL (ID_WEARABLE_MODEL, BRAND, MODEL) VALUES
(1, 'Samsung', 'Galaxy Watch 4'),
(2, 'Samsung', 'Galaxy Watch 7'),
(3, 'PineTime', 'Dev Kit');

-- Usuarios
INSERT INTO APP_USER (
  ID_USER, ID_CITY, EMAIL, FIRST_NAME, LAST_NAME, BIRTH_DATE
) VALUES
(1, 1, 'ana.perez@test.com', 'Ana', 'Pérez', '1998-05-12'),
(2, 2, 'carlos.gomez@test.com', 'Carlos', 'Gómez', '1995-09-20'),
(3, 3, 'laura.martinez@test.com', 'Laura', 'Martínez', '2000-01-15');

-- Credenciales de autenticación
INSERT INTO AUTH_CREDENTIAL (
  ID_CREDENTIAL, ID_USER, PASSWORD_HASH, IS_ACTIVE
) VALUES
(1, 1, 'hash_ana_123', true),
(2, 2, 'hash_carlos_123', true),
(3, 3, 'hash_laura_123', true);

-- Wearables
INSERT INTO WEARABLE (
  ID_WEARABLE, ID_USER, ID_WEARABLE_MODEL
) VALUES
(1, 1, 1),
(2, 2, 2),
(3, 3, 3);


INSERT INTO HEALTH_RECORD (
  ID_HEALTH_RECORD, ID_USER, WEIGHT_KG, HEIGHT_CM
) VALUES
(1, 1, 62.50, 165.0),
(2, 2, 78.20, 175.5),
(3, 3, 55.80, 160.2);

INSERT INTO MONITORING_SESSION (
  ID_SESSION, ID_USER, ID_WEARABLE, ID_COMPUTE_STATUS, DATE_TIME, IS_DELTA_ENCODED
) VALUES
(1, 1, 1, 2, '2026-04-20', true),
(2, 2, 2, 2, '2026-04-21', false),
(3, 3, 3, 1, '2026-04-22', true);


INSERT INTO MEASUREMENT (
  ID_MEASUREMENT, ID_METRIC_TYPE, ID_SESSION, VALUE, ERROR_MESSAGE, RECORDED_AT
) VALUES
(1, 1, 1, 72.0000, NULL, '2026-04-20'),
(2, 2, 1, 98.0000, NULL, '2026-04-20'),
(3, 1, 2, 88.0000, NULL, '2026-04-21'),
(4, 2, 2, 94.0000, NULL, '2026-04-21'),
(5, 3, 3, NULL, 'Unable to calculate HRV', '2026-04-22');


INSERT INTO PPG_SAMPLE (
  ID_PPG_SAMPLE, ID_SESSION, TS, GREEN, RED, IR
) VALUES
(1, 1, 1000, 520, 310, 410),
(2, 1, 2000, 530, 315, 420),
(3, 2, 1000, 610, 350, 455),
(4, 2, 2000, 605, 348, 450),
(5, 3, 1000, 490, 300, 390);


INSERT INTO ALERT (
  ID_ALERT, ID_SESSION, ID_SEVERITY_LEVEL, DESCRIPTION
) VALUES
(1, 1, 1, 'Heart rate within normal range'),
(2, 2, 2, 'Oxygen saturation slightly below expected range'),
(3, 3, 3, 'HRV could not be calculated');



SELECT setval('country_id_country_seq', COALESCE((SELECT MAX(id_country) FROM country), 1), true);

SELECT setval('city_id_city_seq', COALESCE((SELECT MAX(id_city) FROM city), 1), true);

SELECT setval('app_user_id_user_seq', COALESCE((SELECT MAX(id_user) FROM app_user), 1), true);

SELECT setval('auth_credential_id_credential_seq', COALESCE((SELECT MAX(id_credential) FROM auth_credential), 1), true);

SELECT setval('health_record_id_health_record_seq', COALESCE((SELECT MAX(id_health_record) FROM health_record), 1), true);

SELECT setval('wearable_model_id_wearable_model_seq', COALESCE((SELECT MAX(id_wearable_model) FROM wearable_model), 1), true);

SELECT setval('wearable_id_wearable_seq', COALESCE((SELECT MAX(id_wearable) FROM wearable), 1), true);

SELECT setval('monitoring_session_id_session_seq', COALESCE((SELECT MAX(id_session) FROM monitoring_session), 1), true);

SELECT setval('metric_type_id_metric_type_seq', COALESCE((SELECT MAX(id_metric_type) FROM metric_type), 1), true);

SELECT setval('measurement_id_measurement_seq', COALESCE((SELECT MAX(id_measurement) FROM measurement), 1), true);

SELECT setval('severity_level_id_severity_level_seq', COALESCE((SELECT MAX(id_severity_level) FROM severity_level), 1), true);

SELECT setval('alert_id_alert_seq', COALESCE((SELECT MAX(id_alert) FROM alert), 1), true);

SELECT setval('compute_status_id_compute_status_seq', COALESCE((SELECT MAX(id_compute_status) FROM compute_status), 1), true);

SELECT setval('ppg_sample_id_ppg_sample_seq', COALESCE((SELECT MAX(id_ppg_sample) FROM ppg_sample), 1), true);
