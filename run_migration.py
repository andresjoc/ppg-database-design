import os
import psycopg2
from dotenv import load_dotenv


def main():
    # Attempt to load from current directory .env or backend .env
    if os.path.exists('.env'):
        load_dotenv('.env')
    else:
        env_backend = os.path.join('..', '..', 'Backend', 'MSCRUD', 'ppg-monitoring-api', '.env')
        if os.path.exists(env_backend):
            load_dotenv(env_backend)

    db_url = os.getenv('DATABASE_URL')
    if not db_url:
        print('ERROR: DATABASE_URL not found in environment or .env file')
        print('Please set the DATABASE_URL environment variable or create a .env file.')
        return

    sql_path = os.path.join(os.path.dirname(__file__), 'sql', '4. migration_clinical_validation.sql')
    if not os.path.exists(sql_path):
        print(f'ERROR: SQL file not found at {sql_path}')
        return

    with open(sql_path, 'r', encoding='utf-8') as f:
        sql = f.read()

    print('Connecting to PostgreSQL database...')
    conn = psycopg2.connect(db_url)
    conn.autocommit = True
    cur = conn.cursor()

    print('Executing clinical validation migration...')
    cur.execute(sql)
    print('Migration executed successfully!')

    cur.execute("""
        SELECT column_name, data_type 
        FROM information_schema.columns 
        WHERE table_name = 'clinical_validation_record' 
        ORDER BY ordinal_position
    """)
    cols = cur.fetchall()
    print(f'Table clinical_validation_record verified with {len(cols)} columns:')
    for col, dt in cols:
        print(f'  - {col}: {dt}')

    cur.execute("""
        SELECT indexname, indexdef 
        FROM pg_indexes 
        WHERE tablename = 'clinical_validation_record'
    """)
    indexes = cur.fetchall()
    print(f'Indexes created ({len(indexes)}):')
    for idx_name, _ in indexes:
        print(f'  - {idx_name}')

    conn.close()
    print('Migration complete!')


if __name__ == '__main__':
    main()
