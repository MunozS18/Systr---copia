import os
from dotenv import load_dotenv

# Cargar variables de entorno
try:
    load_dotenv()
except Exception as e:
    print("Advertencia: No se pudo cargar el archivo .env")

# Configuración de la base de datos
DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'user': os.getenv('DB_USER', 'root'),
    'password': os.getenv('DB_PASSWORD', 'KawasakiNinjaH2R'),
    'database': os.getenv('DB_NAME', 'sistema_hoteles_cartagena')
}

# Verificar si las variables de entorno están configuradas
if not all([DB_CONFIG['host'], DB_CONFIG['user'], DB_CONFIG['password'], DB_CONFIG['database']]):
    print("Advertencia: Algunas variables de entorno no están configuradas. Se usarán los valores por defecto.") 