-- measurement_consultation
-- Consulta optimizada para la correlación clínica entre métricas resumidas y muestras de señal
-- Evita el producto cartesiano masivo al no mezclar todas las métricas en un solo JOIN de 1:N

-- Opción 1: Consulta de métricas calculadas y perfil clínico de la sesión
SELECT
    ms.id_session,
    ms.date_time,
    u.id_user,
    u.first_name AS firstname,
    u.last_name AS lastname,
    hr.weight_kg,
    hr.height_cm,
    mt.name AS metric_type_name,
    mt.unit AS metric_unit,
    m.value AS metric_value,
    m.recorded_at AS metric_recorded_at
FROM monitoring_session ms
INNER JOIN App_User u
    ON ms.id_user = u.id_user
LEFT JOIN health_record hr
    ON u.id_user = hr.id_user
LEFT JOIN Measurement m
    ON ms.id_session = m.id_session
LEFT JOIN metric_type mt
    ON m.id_metric_type = mt.id_metric_type
ORDER BY ms.id_session DESC, m.recorded_at ASC;

-- Opción 2: Consulta de muestras continuas (PPG time-series) para una sesión dada
SELECT
    ppg.id_session,
    ppg.ts,
    ppg.green,
    ppg.red,
    ppg.ir
FROM ppg_sample ppg
WHERE ppg.id_session = :target_session_id
ORDER BY ppg.ts ASC;