-- ==============================================================================
-- 2. Habilitación y Optimización de TimescaleDB para HeartSense PPG Time-Series
-- Compatible con TimescaleDB Cloud/Neon y entornos PostgreSQL estándar (Fallback)
-- ==============================================================================

-- 1) y 2) Habilitar extensión TimescaleDB y convertir ppg_sample en Hypertable si está disponible
DO $$
BEGIN
    CREATE EXTENSION IF NOT EXISTS timescaledb;
    PERFORM create_hypertable(
        'ppg_sample',
        'ts',
        chunk_time_interval => BIGINT '86400000',
        if_not_exists => TRUE
    );
    RAISE NOTICE 'TimescaleDB habilitado y ppg_sample configurada como Hypertable (chunk=86400000 ms).';
EXCEPTION
    WHEN undefined_file THEN
        RAISE NOTICE 'TimescaleDB no está instalado en este servidor PostgreSQL. ppg_sample operará como tabla estándar.';
    WHEN undefined_function THEN
        RAISE NOTICE 'Función create_hypertable no disponible. ppg_sample operará como tabla estándar.';
    WHEN OTHERS THEN
        RAISE NOTICE 'Aviso TimescaleDB: %. ppg_sample operará como tabla estándar.', SQLERRM;
END $$;

-- 3) Crear índices optimizados para consultas de series temporales y frontend
-- Índice para recuperar muestras de una sesión ordenadas por tiempo (gráfico de Flutter)
CREATE INDEX IF NOT EXISTS idx_ppg_sample_session_ts
ON ppg_sample (id_session, ts ASC);

-- Índice para recuperar historial de sesiones de un usuario ordenadas por fecha reciente
CREATE INDEX IF NOT EXISTS idx_monitoring_session_user_created 
ON monitoring_session (id_user, created_at DESC);

-- 4) Nota sobre compresión nativa:
-- ALTER TABLE ppg_sample SET (timescaledb.compress, timescaledb.compress_segmentby = 'id_session', timescaledb.compress_orderby = 'ts ASC');
-- SELECT add_compression_policy('ppg_sample', BIGINT '604800000', if_not_exists => TRUE);

-- 5) Verificación de configuración segura
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'timescaledb') THEN
        PERFORM * FROM timescaledb_information.hypertables WHERE hypertable_name = 'ppg_sample';
    END IF;
END $$;
