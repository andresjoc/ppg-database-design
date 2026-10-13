-- ==============================================================================
-- 2. Habilitación y Optimización de TimescaleDB para HeartSense PPG Time-Series
-- ==============================================================================

-- 1) Habilitar la extensión TimescaleDB
CREATE EXTENSION IF NOT EXISTS timescaledb;

-- 2) Ajustar restricciones de clave primaria para soportar particionado
-- TimescaleDB requiere que cualquier constraint PRIMARY KEY o UNIQUE incluya la columna de partición temporal ('ts').
ALTER TABLE ppg_sample DROP CONSTRAINT IF EXISTS pk_ppg_sample;
DROP INDEX IF EXISTS ppg_sample_pk;

-- Recrear la clave primaria compuesta (ts + id_ppg_sample)
ALTER TABLE ppg_sample ADD CONSTRAINT pk_ppg_sample PRIMARY KEY (ts, id_ppg_sample);

-- 3) Convertir ppg_sample en Hypertable particionada por 'ts'
-- Como 'ts' está en milisegundos (Unix timestamp ms), especificamos un chunk_time_interval de 1 día:
-- 1 día = 24 * 60 * 60 * 1000 = 86,400,000 milisegundos
SELECT create_hypertable(
    'ppg_sample',
    'ts',
    chunk_time_interval => BIGINT '86400000',
    if_not_exists => TRUE
);

-- 4) Crear índice eficiente para consultas clínicas de series temporales por sesión
CREATE INDEX IF NOT EXISTS idx_ppg_sample_session_ts
ON ppg_sample (id_session, ts DESC);

-- 5) Configurar Compresión Nativa de TimescaleDB
-- Se agrupan los datos por sesión ('id_session') y se comprimen en orden temporal ('ts ASC').
-- Esto permite ratios de compresión de entre 10x y 20x sobre datos enteros de PPG.
ALTER TABLE ppg_sample SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'id_session',
    timescaledb.compress_orderby = 'ts ASC'
);

-- 6) Política de Compresión Automática
-- Comprimir chunks de más de 7 días (7 * 86,400,000 = 604,800,000 ms)
SELECT add_compression_policy('ppg_sample', BIGINT '604800000', if_not_exists => TRUE);

-- 7) Política de Retención Automática
-- Eliminar chunks con datos de más de 2 años (2 * 365 * 86,400,000 = 63,072,000,000 ms)
SELECT add_retention_policy('ppg_sample', BIGINT '63072000000', if_not_exists => TRUE);

-- 8) Verificación de configuración
SELECT * FROM timescaledb_information.hypertables WHERE hypertable_name = 'ppg_sample';
SELECT * FROM timescaledb_information.compression_settings WHERE hypertable_name = 'ppg_sample';