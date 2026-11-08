# Auricular Sense - PPG Database Design & Time-Series Engine

Repositorio oficial del diseño de base de datos, scripts DDL, configuración de series de tiempo en **TimescaleDB** y esquemas relacionales para el ecosistema distribuido de monitoreo cardiovascular y detección de arritmias **Auricular Sense**.

Este almacén centralizado provee soporte transaccional y analítico de alta concurrencia para los microservicios de backend (**MS AUTH** y **MS CRUD**), persistiendo sesiones clínicas, métricas fisiológicas derivadas (BPM, RMSSD, SDNN, $\text{SpO}_2$), alertas de Fibrilación Auricular (FA) y millones de muestras crudas de fotopletismografía (PPG a 25 Hz).

---

## 🏗️ Arquitectura de Datos y Tecnologías

* **Motor Principal:** PostgreSQL 15, 16 o 17 (Compatible con entornos locales y nubes serverless como **Neon Database**).
* **Motor de Series Temporales:** **TimescaleDB 2.17+** (Particionamiento automático en *Hypertables* sobre `ppg_sample` por timestamp `ts`).
* **Microservicios Conectados:**
  * **MS AUTH (`heartsense-authentication`):** Gestión de usuarios en `app_user` y credenciales criptográficas con hash bcrypt en `auth_credential`.
  * **MS CRUD (`ppg-monitoring-api`):** Ingestión por lotes (`POST /monitoring_sessions/batch`) en `monitoring_session`, `measurement`, `alert` y `ppg_sample`.
* **Seguridad y Tipos Especiales:** `TIMESTAMPTZ` para sincronización horaria UTC, `JSONB` para telemetría compacta y claves primarias compuestas compatibles con particionamiento temporal.

---

## 📁 Estructura del Repositorio

```text
ppg-database-design/
├── README.MD                                 # Documentación técnica maestra y guía de replicación
├── run_migration.py                          # Script utilitario en Python para ejecutar migraciones
├── sql/
│   ├── 1. db_creation_script.sql             # DDL base: Creación de las 15 tablas relacionales e índices
│   ├── 2. enable_TimescaleDB.sql             # Conversión de ppg_sample a Hypertable (con fallback seguro)
│   ├── 3. test_inserts.sql                   # Catálogos base, usuarios de prueba, dispositivos y sesiones
│   ├── 4. migration_clinical_validation.sql   # Protocolo clínico: Tabla clinical_validation_record (46 variables)
│   └── measurement_consultation.sql           # Consultas analíticas y de correlación clínica optimizadas
└── model/
    ├── logical/                              # Diagramas entidad-relación conceptuales y lógicos
    └── physical/                             # Modelos físicos de base de datos y esquemas de particionamiento
```

---

## 📊 Diccionario de Datos del Esquema (15 Tablas Base)

El esquema relacional base se divide en 6 dominios funcionales:

### 1. Seguridad e Identidad (MS AUTH)
* **`app_user`:** Información demográfica de pacientes y usuarios (nombre, apellido, email, teléfono, fecha de nacimiento, sexo biológico, ubicación).
* **`auth_credential`:** Hash seguro de contraseñas (bcrypt), estado de activación de cuenta y fecha de última actualización.

### 2. Catálogos Geográficos
* **`country`:** Catálogo de países normalizados (código ISO y nombre).
* **`region`:** Departamentos, estados o provincias.
* **`city`:** Municipios y ciudades (necesario para el registro demográfico de pacientes).

### 3. Dispositivos Wearables (Adquisición)
* **`wearable_model`:** Marcas y modelos certificados (ej. *PineTime InfiniTime*, *Samsung Galaxy Watch 4/7*).
* **`wearable`:** Unidades físicas registradas asociadas a su dirección MAC y número de serie.

### 4. Sesiones de Monitoreo y Métricas (MS CRUD)
* **`compute_status`:** Estados de procesamiento de sesión (`PENDING`, `COMPLETED`, `FAILED`).
* **`monitoring_session`:** Sesión de telemetría médica iniciada desde la app móvil (inicio, fin, dispositivo y usuario).
* **`metric_type`:** Tipos de métricas clínicas soportadas (`BPM`, `RMSSD`, `SDNN`, `SPO2`).
* **`measurement`:** Valores consolidados calculados por el motor DSP para cada sesión.

### 5. Detección de Arritmias y Alertas Clínicas
* **`severity_level`:** Niveles de severidad (`NORMAL`, `MODERATE`, `CRITICAL`).
* **`alert`:** Episodios de arritmia detectados (Fibrilación Auricular), con marca de tiempo precisa y nivel de severidad.

### 6. Historial Médico y Series de Tiempo
* **`health_record`:** Antecedentes médicos, condiciones preexistentes y notas clínicas.
* **`ppg_sample`:** Muestras discretas de la señal PPG (valores del sensor infrarrojo/rojo a 25 Hz). Posee clave primaria compuesta `(id_sample, ts)` para habilitar el particionamiento de TimescaleDB.

---

## ⚡ Configuración de TimescaleDB (Series Temporales)

La tabla `ppg_sample` está diseñada para almacenar millones de puntos discretos de fotopletismografía. El script `sql/2. enable_TimescaleDB.sql` ejecuta la partición en bloques de tiempo diarios:

```sql
SELECT create_hypertable(
    'ppg_sample', 
    'ts', 
    chunk_time_interval => INTERVAL '1 day', 
    if_not_exists => TRUE
);
```

> **Nota de compatibilidad:** Si el servidor PostgreSQL destino no tiene instalada la extensión TimescaleDB (ej. PostgreSQL estándar sin plugins), el script detecta automáticamente la ausencia de la extensión y mantiene `ppg_sample` como una tabla relacional tradicional sin abortar la ejecución.

---

## 🚀 Guía de Replicación Paso a Paso (Paso a Paso)

### Prerrequisitos
* **PostgreSQL:** Versión 15, 16 o 17 instalada localmente, en Docker o en un proveedor Cloud (Neon, Supabase, AWS RDS).
* **Cliente SQL:** `psql` (CLI de PostgreSQL), **DBeaver**, **pgAdmin 4** o VS Code Database Extension.
* **(Opcional) Python 3.10+:** Para ejecutar el script de migración automática `run_migration.py`.

---

### Opción A: Despliegue con Docker (Recomendado para desarrollo local)

Si deseas levantar una base de datos local con PostgreSQL y TimescaleDB listos en 1 minuto:

```bash
docker run -d \
  --name auricular-sense-timescale \
  -p 5432:5432 \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=heartsense \
  timescale/timescaledb-ha:pg16-latest
```

---

### Opción B: Ejecución Secuencial con `psql`

Con tu cadena de conexión a mano (ejemplo: `postgresql://postgres:postgres@localhost:5432/heartsense` o tu URL de Neon Cloud), ejecuta los scripts en el orden estricto de dependencias:

#### Paso 1: Crear las 15 tablas relacionales e índices
```bash
psql "<DATABASE_URL>" -f "sql/1. db_creation_script.sql"
```

#### Paso 2: Habilitar TimescaleDB y particionar `ppg_sample`
```bash
psql "<DATABASE_URL>" -f "sql/2. enable_TimescaleDB.sql"
```

#### Paso 3: Cargar catálogos maestros y datos de prueba
Inserta los tipos de métricas, estados de cómputo, modelos de reloj y usuarios de demostración:
```bash
psql "<DATABASE_URL>" -f "sql/3. test_inserts.sql"
```

#### Paso 4: (Opcional) Habilitar Protocolo de Validación Clínica
Si se va a trabajar con los registros de validación hospitalaria contra ECG (*Gold Standard*):
```bash
psql "<DATABASE_URL>" -f "sql/4. migration_clinical_validation.sql"
```
*O alternativamente mediante Python:*
```bash
python run_migration.py
```

---

## 🔍 Consultas de Verificación

Para confirmar que la base de datos se desplegó exitosamente, ejecuta las siguientes consultas en tu consola `psql` o cliente SQL:

### 1. Verificar que las 15 tablas existen
```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
```

### 2. Verificar estado de la Hypertable TimescaleDB
```sql
SELECT hypertable_schema, hypertable_name, num_chunks 
FROM timescaledb_information.hypertables 
WHERE hypertable_name = 'ppg_sample';
```

### 3. Verificar inserción de usuarios y catálogos de prueba
```sql
SELECT u.id_user, u.first_name, u.last_name, u.email, c.id_credential IS NOT NULL AS has_credentials
FROM app_user u
LEFT JOIN auth_credential c ON u.id_user = c.id_user;
```

---

## 📦 Scripts Maestros de Restauración (Carpeta Raíz `BD/`)

Si te encuentras trabajando desde la raíz del ecosistema Auricular Sense, la carpeta contenedora `BD/` incluye scripts adicionales para restauraciones completas en una sola orden:

* **`neon_data_extracted.sql`**: Catálogo geográfico mundial completo (246 países, 4,666 departamentos y 104,586 municipios) requerido para el registro en la aplicación móvil.
* **`reconstruct_database_complete.sql`**: Script maestro consolidado que levanta el esquema completo (16 tablas) y restaura los datos de producción incluyendo catálogos completos y expedientes clínicos reales.

```bash
psql "<DATABASE_URL>" -f "../reconstruct_database_complete.sql"
```

---

## 🔒 Seguridad y Buenas Prácticas

1. **Nunca subas credenciales en claro:** Utiliza siempre variables de entorno (`DATABASE_URL`).
2. **Hasheo de Contraseñas:** Las contraseñas en `auth_credential` siempre deben ser procesadas con `bcrypt` (manejado de forma automática por **MS AUTH**).
3. **Zonas Horarias:** Toda marca temporal en `ts`, `start_time` y `created_at` utiliza `TIMESTAMPTZ` en UTC para garantizar coherencia entre los smartwatches, el móvil y los servidores.
