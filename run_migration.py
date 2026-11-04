import os
import psycopg2
from dotenv import load_dotenv

def main():
    env_path = os.path.join('Backend', 'MSCRUD', 'ppg-monitoring-api', '.env')
    load_dotenv(env_path)
    db_url = os.getenv('DATABASE_URL')
    if not db_url:
        print('ERROR: DATABASE_URL not found')
        return

    sql_path = os.path.join('BD', 'ppg-database-design', 'sql', '4. migration_clinical_validation.sql')
    with open(sql_path, 'r', encoding='utf-8') as f:
        sql = f.read()

    print('Connecting to Neon PostgreSQL...')
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
    print(f'Table clinical_validation_record created with {len(cols)} columns:')
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
    print('Done!')

if __name__ == '__main__':
    main()
