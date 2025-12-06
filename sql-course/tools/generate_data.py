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

def generate_subscriptions(n, client_ids):
    print(f"Generando {n} suscripciones...")
    subs = []
    plans = {'Basic': 100, 'Standard': 250, 'Premium': 500, 'Enterprise': 1000}
    
    for _ in range(n):
        plan = random.choice(list(plans.keys()))
        start_date = fake.date_between(start_date='-2y', end_date='today')
        is_active = random.choice([0, 1])
        end_date = None
        if not is_active:
            end_date = fake.date_between(start_date=start_date, end_date='today')
            
        subs.append({
            'cliente_id': random.choice(client_ids),
            'fecha_inicio': start_date,
            'fecha_fin': end_date,
            'plan': plan,
            'mrr': plans[plan],
            'activo': is_active
        })
    return pd.DataFrame(subs)

def generate_inventory(product_ids):
    print(f"Generando inventario para {len(product_ids)} productos...")
    inventory = []
    # Snapshot actual
    date = datetime.now().date()
    
    for pid in product_ids:
        initial = random.randint(10, 500)
        final = max(0, initial - random.randint(0, initial))
        inventory.append({
            'producto_id': pid,
            'fecha': date,
            'stock_inicial': initial,
            'stock_final': final,
            'reposiciones': random.choice([0, 0, 10, 50, 100])
        })
    return pd.DataFrame(inventory)

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
    parser.add_argument('--subs', type=int, default=1000, help='Cantidad de suscripciones a generar')
    
    args = parser.parse_args()

    try:
        engine = get_db_connection(args.server, args.database, args.trusted, args.user, args.password, args.driver)
        print("✅ Conexión establecida.")
        
        # 1. Generar e insertar Clientes
        df_clients = generate_clients(args.clients)
        df_clients.to_sql('dim_clientes', engine, if_exists='append', index=False)
        print(f"✅ {args.clients} clientes insertados.")
        
        # Obtener IDs
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

        # 3. Generar e insertar Suscripciones
        df_subs = generate_subscriptions(args.subs, client_ids)
        df_subs.to_sql('fact_suscripciones', engine, if_exists='append', index=False)
        print(f"✅ {args.subs} suscripciones insertadas.")

        # 4. Generar e insertar Inventario (Snapshot diario)
        df_inv = generate_inventory(product_ids)
        df_inv.to_sql('fact_inventario', engine, if_exists='append', index=False)
        print(f"✅ Inventario generado para {len(product_ids)} productos.")
            
        print("🎉 Generación de datos completada exitosamente.")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        print("Asegúrate de tener los drivers instalados y la BD configurada.")

if __name__ == '__main__':
    main()
