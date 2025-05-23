# Sistema Recomendador de Hoteles

Este sistema proporciona recomendaciones personalizadas de hoteles basadas en las preferencias del usuario y el comportamiento de otros usuarios.

## Características

- Recomendaciones basadas en filtrado colaborativo
- Búsqueda por características y preferencias
- Exploración de hoteles con filtros por categoría y precio
- Interfaz intuitiva y fácil de usar
- Integración con base de datos MySQL

## Requisitos

- Python 3.8 o superior
- MySQL Server
- Conexión a Internet

## Instalación

1. Clonar el repositorio:
```bash
git clone <url-del-repositorio>
cd <nombre-del-directorio>
```

2. Crear un entorno virtual:
```bash
python -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate
```

3. Instalar dependencias:
```bash
pip install -r requirements.txt
```

4. Configurar la base de datos:
   - Crear un archivo `.env` en la raíz del proyecto con las siguientes variables:
   ```
   DB_HOST=localhost
   DB_USER=tu_usuario
   DB_PASSWORD=tu_contraseña
   DB_NAME=hoteles_cartagena
   ```

## Uso

1. Asegúrate de que la base de datos esté configurada y en ejecución.

2. Inicia la aplicación:
```bash
streamlit run app.py
```

3. Abre tu navegador en `http://localhost:8501`

## Estructura del Proyecto

- `app.py`: Interfaz de usuario con Streamlit
- `modelo_recomendacion.py`: Implementación del sistema de recomendación
- `config.py`: Configuración de la base de datos
- `requirements.txt`: Dependencias del proyecto

## Contribuir

Las contribuciones son bienvenidas. Por favor, abre un issue para discutir los cambios propuestos.

## Licencia

Este proyecto está bajo la Licencia MIT. 