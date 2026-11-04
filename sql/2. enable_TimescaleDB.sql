-- ==============================================================================
-- 2. Habilitación y Optimización de TimescaleDB para HeartSense PPG Time-Series
-- ==============================================================================

-- 1) Habilitar la extensión TimescaleDB
CREATE EXTENSION IF NOT EXISTS timescaledb;

-- 2) Convertir ppg_sample en Hypertable particionada por 'ts'
-- Como 'ts' está en milisegundos (Unix timestamp ms), se especifica un chunk_time_interval de 1 día:
-- 1 día = 24 * 60 * 60 * 1000 = 86,400,000 milisegundos
SELECT create_hypertable(
    'ppg_sample',
    'ts',
    chunk_time_interval => BIGINT '86400000',
    if_not_exists => TRUE
);

-- 3) Crear índices optimizados para consultas de series temporales y frontend
-- Índice para recuperar muestras de una sesión ordenadas por tiempo (gráfico de Flutter)
CREATE INDEX IF NOT EXISTS idx_ppg_sample_session_ts
ON ppg_sample (id_session, ts ASC);

-- Índice para recuperar historial de sesiones de un usuario ordenadas por fecha reciente
CREATE INDEX IF NOT EXISTS idx_monitoring_session_user_created 
ON monitoring_session (id_user, created_at DESC);

-- 4) Nota sobre la compresión nativa en proveedores en la nube (como Neon):
-- Neon distribuye TimescaleDB bajo licencia Apache 2.0. Las políticas de compresión automática 
-- (add_compression_policy) requieren la licencia propietaria Timescale Community / Cloud (TSL).
-- En caso de usar Timescale Cloud o una instancia autohospedada con licencia completa,
-- se puede activar la compresión ejecutando:
--
-- ALTER TABLE ppg_sample SET (
--     timescaledb.compress,
--     timescaledb.compress_segmentby = 'id_session',
--     timescaledb.compress_orderby = 'ts ASC'
-- );
-- SELECT add_compression_policy('ppg_sample', BIGINT '604800000', if_not_exists => TRUE);
-- SELECT add_retention_policy('ppg_sample', BIGINT '63072000000', if_not_exists => TRUE);

-- 5) Verificación de configuración
SELECT * FROM timescaledb_information.hypertables WHERE hypertable_name = 'ppg_sample';
