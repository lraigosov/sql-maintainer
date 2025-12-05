import argparse
import random
from datetime import datetime, timedelta
import pandas as pd
from faker import Faker
from sqlalchemy import create_engine
import sys

# Configuración de Faker
fake = Faker('es_ES')

def get_db_connection(server, database, trusted, username, password, driver):
    if trusted:
        conn_str = f'mssql+pyodbc://@{server}/{database}?driver={driver}&trusted_connection=yes'
    else:
        conn_str = f'mssql+pyodbc://{username}:{password}@{server}/{database}?driver={driver}'
    return create_engine(conn_str)

def generate_clients(n):
    print(f"Generando {n} clientes...")
    clients = []
    for _ in range(n):
        clients.append({
            'nombre': fake.name(),
            'email': fake.unique.email(),
            'fecha_alta': fake.date_between(start_date='-2y', end_date='today'),
            'segmento': random.choice(['Retail', 'SMB', 'Enterprise', 'Startup']),
            'region_id': random.randint(1, 3) # Asumiendo 3 regiones iniciales
        })
    return pd.DataFrame(clients)

def generate_sales(n, client_ids, product_ids):
    print(f"Generando {n} ventas...")
    sales = []
    start_date = datetime.now() - timedelta(days=730)
    
    for _ in range(n):
        sales.append({
            'fecha': fake.date_between(start_date='-2y', end_date='today'),
            'cliente_id': random.choice(client_ids),
            'producto_id': random.choice(product_ids),
            'cantidad': random.randint(1, 20),
            'descuento_pct': random.choice([0, 0, 0, 5, 10, 15]),
            'canal': random.choice(['Online', 'Directo', 'Distribuidor', 'Retail'])
        })
    return pd.DataFrame(sales)

def main():
    parser = argparse.ArgumentParser(description='Generador de Datos Masivos para SQL Course')
    parser.add_argument('--server', default='localhost', help='Servidor SQL')
    parser.add_argument('--database', default='SQLCourseDB', help='Base de Datos')
    parser.add_argument('--driver', default='ODBC Driver 17 for SQL Server', help='Driver ODBC')
    parser.add_argument('--trusted', action='store_true', default=True, help='Usar autenticación de Windows')
    parser.add_argument('--user', help='Usuario SQL')
    parser.add_argument('--password', help='Password SQL')
    
    parser.add_argument('--clients', type=int, default=1000, help='Cantidad de clientes a generar')
    parser.add_argument('--sales', type=int, default=10000, help='Cantidad de ventas a generar')
    
    args = parser.parse_args()

    try:
        engine = get_db_connection(args.server, args.database, args.trusted, args.user, args.password, args.driver)
        print("✅ Conexión establecida.")
        
        # 1. Generar e insertar Clientes
        df_clients = generate_clients(args.clients)
        df_clients.to_sql('dim_clientes', engine, if_exists='append', index=False)
        print(f"✅ {args.clients} clientes insertados.")
        
        # Obtener IDs reales para integridad referencial
        client_ids = pd.read_sql("SELECT cliente_id FROM dim_clientes", engine)['cliente_id'].tolist()
        product_ids = pd.read_sql("SELECT producto_id FROM dim_productos", engine)['producto_id'].tolist()
        
        if not product_ids:
            print("❌ No hay productos en dim_productos. Ejecuta dataset_setup.sql primero.")
            return

        # 2. Generar e insertar Ventas
        chunk_size = 5000
        total_sales = args.sales
        print(f"Insertando {total_sales} ventas en bloques de {chunk_size}...")
        
        for i in range(0, total_sales, chunk_size):
            current_chunk = min(chunk_size, total_sales - i)
            df_sales = generate_sales(current_chunk, client_ids, product_ids)
            df_sales.to_sql('fact_ventas', engine, if_exists='append', index=False)
            print(f"   Bloque {i//chunk_size + 1} insertado ({current_chunk} filas).")
            
        print("🎉 Generación de datos completada exitosamente.")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        print("Asegúrate de tener los drivers instalados y la BD configurada.")

if __name__ == '__main__':
    main()
