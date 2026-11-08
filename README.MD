# PPG Database Design - HeartSense

Este módulo contiene el diseño de base de datos, scripts DDL, extensiones TimescaleDB y respaldos de datos para el sistema de monitoreo cardiovascular distribuido **HeartSense** basado en señales de fotopletismografía (PPG) e inferencia Edge AI.

---

## 📁 Estructura del Directorio

```text
BD/
├── reconstruct_database_complete.sql   # ⭐ SCRIPT MAESTRO: Reconstruye todo (esquema + 104k ciudades + 48 registros clínicos + 15k PPG)
├── neon_data_extracted.sql             # Catálogos geográficos completos (country, region, city)
├── clean_backup_heartsense.sql         # Respaldo histórico estructural
└── ppg-database-design/
    ├── README.MD
    ├── run_migration.py                # Script Python para aplicar la migración clínica sobre Neon
    ├── sql/
    │   ├── 1. db_creation_script.sql   # DDL base (15 tablas relacionales con PK compatible con TimescaleDB)
    │   ├── 2. enable_TimescaleDB.sql   # Creación de Hypertable de ppg_sample particionada por 'ts'
    │   ├── 3. test_inserts.sql         # Inserciones base de prueba (catálogos, usuarios, credenciales, sesiones)
    │   ├── 4. migration_clinical_validation.sql # Migración separada: Tabla clinical_validation_record
    │   └── measurement_consultation.sql # Consultas optimizadas de correlación clínica
    └── model/
        ├── logical/                    # Diagramas y modelos lógicos
        └── physical/                   # Diagramas y modelos físicos
```

---

## 🚀 Métodos de Reconstrucción de la Base de Datos

### Método 1: Reconstrucción Total Automática con Datos Reales (Recomendado)

Restaura el esquema completo, todas las tablas (incluida la de validación clínica), los 104,586 municipios geográficos, las 15,189 muestras de señal PPG y los 48 expedientes de validación clínica del protocolo en una sola operación verificada:

```bash
psql "<DATABASE_URL>" -f "BD/reconstruct_database_complete.sql"
```

---

### Método 2: Reconstrucción Modular Paso a Paso

Si se desea levantar la base de datos de manera granular en el orden arquitectónico establecido:

1. **Crear esquema de tablas base (15 tablas)**:
   ```bash
   psql "<DATABASE_URL>" -f "BD/ppg-database-design/sql/1. db_creation_script.sql"
   ```
2. **Habilitar TimescaleDB y crear Hypertable**:
   ```bash
   psql "<DATABASE_URL>" -f "BD/ppg-database-design/sql/2. enable_TimescaleDB.sql"
   ```
3. **Cargar catálogos geográficos completos** (246 países, 4,666 regiones, 104,586 ciudades):
   ```bash
   psql "<DATABASE_URL>" -f "BD/neon_data_extracted.sql"
   ```
4. **Cargar datos de prueba iniciales**:
   ```bash
   psql "<DATABASE_URL>" -f "BD/ppg-database-design/sql/3. test_inserts.sql"
   ```
5. **Crear la tabla de validación clínica (Protocolo Hospital Universitario San Rafael)**:
   ```bash
   psql "<DATABASE_URL>" -f "BD/ppg-database-design/sql/4. migration_clinical_validation.sql"
   # O alternativamente ejecutando el script de Python:
   python "BD/ppg-database-design/run_migration.py"
   ```

---

## 🛠️ Tecnologías Utilizadas

- **PostgreSQL 17** (Cloud en Neon)
- **TimescaleDB 2.17+** (Particionado automático de series de tiempo para `ppg_sample`)
- **FastAPI / SQLAlchemy** (Microservicios MS CRUD y MS Auth)
- **JSONB** (Almacenamiento de series brutas de fotopletismografía y metadatos clínicos)
