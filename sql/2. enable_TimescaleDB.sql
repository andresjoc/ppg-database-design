

-- 1) Enable the extension
CREATE EXTENSION IF NOT EXISTS timescaledb;


-- 2) Convert the ppg_sample table into a hypertable
ALTER TABLE ppg_sample DROP CONSTRAINT pk_ppg_sample;
DROP INDEX IF EXISTS ppg_sample_pk;
SELECT create_hypertable('ppg_sample', 'ts');

--3) Select hypertables
SELECT * FROM timescaledb_information.hypertables;
SELECT tablename FROM pg_tables WHERE schemaname = 'public';

SELECT version();