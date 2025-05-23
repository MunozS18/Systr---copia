import streamlit as st
import pandas as pd
import mysql.connector
from config import DB_CONFIG
from modelo_recomendacion import SistemaRecomendacion
import os
from PIL import Image

# Función para obtener la imagen del hotel como objeto PIL Image
def obtener_imagen_hotel(id_hotel):
    ruta_imagen = f"static/images/hoteles/{id_hotel}.jpg"
    if os.path.exists(ruta_imagen):
        try:
            return Image.open(ruta_imagen)
        except Exception as e:
            print(f"Error al abrir imagen {ruta_imagen}: {e}")
            # Si hay un error al abrir la imagen específica, intentar con la por defecto
            ruta_default = "static/images/hoteles/default.jpg"
            if os.path.exists(ruta_default):
                try:
                    return Image.open(ruta_default)
                except Exception as e:
                    print( f"Error al abrir imagen por defecto {ruta_default}: {e}")
                    return None
            return None # O manejar el error de otra forma si la por defecto tampoco existe
    else:
        # Si la imagen específica no existe, usar la por defecto
        ruta_default = "static/images/hoteles/default.jpg"
        if os.path.exists(ruta_default):
            try:
                return Image.open(ruta_default)
            except Exception as e:
                print(f"Error al abrir imagen por defecto {ruta_default}: {e}")
                return None
        return None # Manejar el caso si no hay imagen por defecto

# Configuración de la página
st.set_page_config(
    page_title="Sistema Recomendador de Hoteles",
    page_icon="🏨",
    layout="wide"
)

# Inicializar estado de sesión para login y usuario
if 'logged_in' not in st.session_state:
    st.session_state['logged_in'] = False
if 'id_usuario' not in st.session_state:
    st.session_state['user_id'] = None
if 'user_name' not in st.session_state:
    st.session_state['user_name'] = None

# Inicializar estado de sesión para la selección del menú no logueado
# Aseguramos que siempre tenga un valor por defecto al inicio
if 'auth_menu_selection' not in st.session_state or st.session_state['auth_menu_selection'] not in ["Iniciar Sesión", "Registrarse"]:
    st.session_state['auth_menu_selection'] = "Iniciar Sesión"

# Inicializar el sistema de recomendación (solo se inicializa una vez por sesión con st.cache_resource)
@st.cache_resource
def inicializar_sistema():
    print("Iniciando sistema...") # Mensaje para depuración
    sistema = SistemaRecomendacion()
    sistema.cargar_datos()
    return sistema

sistema = None # Inicializar sistema como None por defecto

# --- SIDEBAR: Título de la Aplicación ---
st.sidebar.title("🏨 Sistema Recomendador")

# Lógica condicional para mostrar contenido según el estado de login
if not st.session_state['logged_in']:
    # --- SIDEBAR: Menú de Autenticación (estilo pestañas con HTML/CSS) ---
    st.sidebar.markdown("---") # Separador visual

    # Inyectar CSS para el estilo de pestañas en la sidebar
    st.sidebar.markdown("""
    <style>
    /* Contenedor principal para las pestañas */
    .auth-tabs-container {
        display: flex;
        flex-direction: row; /* Pestañas en fila */
        justify-content: space-around; /* Espacio equitativo entre pestañas */
        margin-bottom: 15px;
    }

    /* Estilo base para cada pestaña */
    .auth-tab {
        padding: 10px 5px;
        cursor: pointer;
        border-bottom: 3px solid transparent; /* Indicador inactivo */
        color: rgba(255, 255, 255, 0.6); /* Color de texto inactivo */
        font-weight: bold;
        transition: all 0.3s ease-in-out;
        text-decoration: none; /* Remover subrayado del enlace */
    }

    /* Estilo para la pestaña activa */
    .auth-tab.active {
        color: #FF4B4B; /* Color rojo para texto activo */
        border-bottom-color: #FF4B4B; /* Indicador rojo activo */
    }

    .auth-tab:hover {
         color: rgba(255, 255, 255, 0.9); /* Ligeramente más brillante al pasar el mouse */
    }

     /* Estilos para los formularios y elementos dentro de la sidebar */
    div[data-testid="stSidebar"] div.stForm {
         margin: 0; 
         padding: 15px; 
         box-shadow: none;
         background-color: transparent;
    }

    div[data-testid="stSidebar"] input[type="text"], 
    div[data-testid="stSidebar"] input[type="password"],
    div[data-testid="stSidebar"] .stButton button {
         width: 100%; 
         margin-bottom: 10px; 
    }

    div[data-testid="stSidebar"] .stButton button {
        background-color: #007bff; 
        color: white;
        padding: 10px;
        border-radius: 5px;
        border: none;
    }

     div[data-testid="stSidebar"] .stCheckbox div:first-child {
        margin-right: 5px; 
     }
     div[data-testid="stSidebar"] .stMarkdown div:first-child {
        font-size: smaller; 
     }

    </style>
    """, unsafe_allow_html=True)

    # HTML para las pestañas con manejo de clics
    login_class = "auth-tab active" if st.session_state['auth_menu_selection'] == "Iniciar Sesión" else "auth-tab"
    register_class = "auth-tab active" if st.session_state['auth_menu_selection'] == "Registrarse" else "auth-tab"

    st.sidebar.markdown(f"""
    <div class="auth-tabs-container">
        <a href="?auth_menu_selection=Iniciar Sesión" class="{login_class}" target="_self">Iniciar Sesión</a>
        <a href="?auth_menu_selection=Registrarse" class="{register_class}" target="_self">Registrarse</a>
    </div>
    """, unsafe_allow_html=True)

    # Capturar la selección de la URL (o mantener el estado de sesión si no hay query param)
    query_params = st.experimental_get_query_params()
    if "auth_menu_selection" in query_params:
        st.session_state['auth_menu_selection'] = query_params['auth_menu_selection'][0] 

    # --- SIDEBAR: Contenido de Autenticación (formularios en la sidebar) ---
    # Mostrar el contenido en la sidebar basado en la selección del estado de sesión

    # Mostrar el formulario de login si la opción 'Iniciar Sesión' está seleccionada y no está logueado
    if not st.session_state['logged_in'] and st.session_state.get('auth_menu_selection') == "Iniciar Sesión":
     
     
        # --- Formulario de Login (en la sidebar) ---
        with st.sidebar.form("login_form_sidebar"):
            st.subheader("Incia Sesión")
            user_email = st.text_input("Correo electrónico", key='login_email_sidebar')
            user_password = st.text_input("Contraseña", type="password", key='login_password_sidebar')

            col_remember, col_forgot = st.columns(2)
            with col_remember:
                st.checkbox("Recordar")
            with col_forgot:
                st.markdown("<div style='text-align: right;'><a href='#'>Olvidé contraseña</a></div>", unsafe_allow_html=True)

            st.write("")

            login_button = st.form_submit_button("Iniciar sesión")

            # Placeholder para mostrar mensajes de error de login dentro del form
            login_error_placeholder = st.empty()

            if login_button:
                # Limpiar cualquier mensaje de error previo al intentar loguear de nuevo
                login_error_placeholder.empty()

                try:
                    conn = mysql.connector.connect(**DB_CONFIG)
                    cursor = conn.cursor()
                    cursor.execute("SELECT id_usuario, nombre FROM usuario WHERE email = %s AND password = %s", 
                                 (user_email, user_password))
                    usuario = cursor.fetchone()
                    cursor.close()
                    conn.close()

                    if usuario:
                        # Si el login es exitoso, actualizamos el estado y forzamos una reejecución
                        st.session_state['logged_in'] = True
                        st.session_state['id_usuario'] = usuario[0] # Usar 'id_usuario' según la base de datos
                        st.session_state['user_name'] = usuario[1]
                        st.rerun() # Forzar reejecución para mostrar el contenido logueado
                    else:
                        # Si el login falla, mostramos el error en el placeholder
                        login_error_placeholder.error("Correo electrónico o contraseña incorrectos.")

                except Exception as e:
                    # Este error se mostrará si hay un problema de conexión a la BD, por ejemplo
                 
                    print(f"Error técnico al intentar iniciar sesión: {e}") # Imprimir error técnico en consola

    # Mostrar el formulario de registro si la opción 'Registrarse' está seleccionada y no está logueado
    elif not st.session_state['logged_in'] and st.session_state.get('auth_menu_selection') == "Registrarse":
        # --- INDICADOR DE DEBUG --- Si ves este texto, la lógica para mostrar el registro se está ejecutando ---
        st.sidebar.text("--- Mostrando formulario de Registro ---")
        # --- Formulario de Registro (en la sidebar) ---
        with st.sidebar.form("registro_usuario_sidebar"):
            st.subheader("📝 Registro de Usuario")
            nombre = st.text_input("Nombre completo", key='register_nombre_sidebar')
            email = st.text_input("Email", key='register_email_sidebar')
            password = st.text_input("Contraseña", type="password", key='register_password_sidebar')
            edad = st.number_input("Edad", min_value=1, max_value=120, step=1, key='register_edad_sidebar')
            genero = st.selectbox("Género", ("F", "M", "Otro"), key='register_genero_sidebar')
            submit = st.form_submit_button("Registrar")
            if submit:
                if nombre.strip() == "" or email.strip() == "" or password.strip() == "":
                    st.warning("Por favor, completa todos los campos obligatorios.")
                else:
                    try:
                        conn = mysql.connector.connect(**DB_CONFIG)
                        cursor = conn.cursor()
                        cursor.execute(
                            "INSERT INTO usuario (nombre, email, password, edad, genero) VALUES (%s, %s, %s, %s, %s)",
                            (nombre, email, password, edad, genero)
                        )
                        conn.commit()
                        cursor.close()
                        conn.close()
                        st.success("¡Usuario registrado exitosamente! Ahora puedes iniciar sesión.")
                        # Cambiar a la opción de Iniciar Sesión en la sidebar después del registro exitoso
                        st.session_state['auth_menu_selection'] = "Iniciar Sesión"
                        st.experimental_rerun() # Usar experimental_rerun con query_params
                    except Exception as e:
                        st.error(f"Error al registrar usuario: {e}")

    # --- CONTENIDO PRINCIPAL (si no está logueado) ---
    # Mostrar contenido principal basado en la selección de la sidebar no logueada
    # Solo mostramos el contenido principal si no está logueado Y la selección NO es Iniciar Sesión o Registrarse
    # Esto asegura que al inicio, con 'Iniciar Sesión' seleccionado por defecto, solo se vea la barra lateral de login/registro
    if not st.session_state['logged_in'] and st.session_state.get('auth_menu_selection') not in ["Iniciar Sesión", "Registrarse"]:
        if st.session_state['auth_menu_selection'] == "Usuarios registrados": # Aunque ya quitamos esta opción del menú inicial
             
         

            # --- Visualización de usuarios (en el contenido principal) ---
            st.subheader("👥 Usuarios Registrados")
            # Inicializar sistema solo si se necesita para esta sección (acceso a BD)
            if sistema is None:
                 sistema = inicializar_sistema()
            try:
                conn = mysql.connector.connect(**DB_CONFIG)
                usuarios_df = pd.read_sql("SELECT id_usuario, nombre, email, edad, genero FROM usuario", conn)
                conn.close()
                st.dataframe(usuarios_df)
            except Exception as e:
                st.error(f"Error al cargar usuarios: {e}")
        else:
            # Esto se mostrará si hay alguna otra selección inesperada antes de loguear
            st.title("¡Bienvenido al Sistema Recomendador de Hoteles de Cartagena! 🏨 Aqui encontraras el hotel de tu prefenrencia y tus gustos ")
            st.markdown("Por favor, inicia sesión en la barra lateral izquierda.")

elif st.session_state['logged_in']:
    # --- CONTENIDO: Sistema Recomendador (si está logueado) ---
    # Inicializar sistema solo si es necesario para las funcionalidades principales (acceso a BD)
    if sistema is None:
        sistema = inicializar_sistema()

    # --- SIDEBAR: Menú desplegable (si está logueado) ---
    # Definir opciones de menú para usuarios logueados
    menu_options_logged_in = ("Inicio", "Favoritos", "Registro de usuario", "Usuarios registrados")

    # Usar una key única para el selectbox principal
    menu = st.sidebar.selectbox(
        "Menú",
        menu_options_logged_in,
        key='main_menu_selectbox_logged_in' # Agregar una key única para cuando está logueado
    )

    # --- SIDEBAR: Favoritos (por sesión - se mantiene en la sidebar si está logueado) ---
    if 'favoritos' not in st.session_state:
        st.session_state['favoritos'] = []

    if menu == "Favoritos":
        st.sidebar.title("⭐ Tus Favoritos")
        if st.session_state['favoritos']:
            for fav in st.session_state['favoritos']:
                st.sidebar.markdown(f"- {fav}")
        else:
            st.sidebar.info("Aún no tienes favoritos. Agrega desde la sección de hoteles.")

    # --- Contenido principal basado en la selección del menú lateral ---
    if menu == "Inicio":
        st.markdown("""
        # 🏨 Sistema Recomendador de Hoteles
        
        Bienvenido al sistema que te ayuda a descubrir los mejores hoteles de Cartagena según tus gustos y los de otros usuarios.
        """)

        # Pestañas para buscar/recomendar/explorar (solo si está en la página de Inicio)
        pestanas = st.tabs(["🔍 Buscar por características", "👤 Recomendaciones personalizadas", "🏨 Explorar hoteles"])

        # --- Pestaña 1: Buscar por características ---
        with pestanas[0]:
            st.subheader("Buscar hoteles según tus preferencias")
            descripcion = st.text_area(
                "Describe lo que buscas en un hotel (servicios, ubicación, etc.):",
                height=100,
                placeholder="Ejemplo: piscina, spa, restaurante gourmet, centro histórico..."
            )
            if st.button("Buscar hoteles similares", key="buscar_caracteristicas"):
                if descripcion.strip():
                    recomendaciones = sistema.recomendar_por_caracteristicas(descripcion)
                    if recomendaciones:
                        st.success("Resultados encontrados:")
                        for id_hotel, similitud in recomendaciones:
                            hotel = sistema.hoteles_df[sistema.hoteles_df['id_hotel'] == id_hotel].iloc[0]
                            st.markdown(f"### {hotel['nombre']}  ")
                            st.write(f"**Categoría:** {hotel['categoria']}")
                            st.write(f"**Precio promedio:** ${hotel['precio_promedio']:,.2f}")
                            st.write(f"**Ubicación:** {hotel['ubicacion']}")
                            st.write(f"**Descripción:** {hotel['descripcion']}")
                            ruta_imagen = obtener_imagen_hotel(hotel['id_hotel'])
                            if ruta_imagen:
                                st.image(ruta_imagen, width=300)
                            st.progress(min(similitud, 1.0))
                            # Botón para agregar a favoritos
                            if st.button(f"Agregar a favoritos: {hotel['nombre']}", key=f"fav_carac_{id_hotel}"):
                                if hotel['nombre'] not in st.session_state['favoritos']:
                                    st.session_state['favoritos'].append(hotel['nombre'])
                                    st.success(f"Agregado a favoritos: {hotel['nombre']}")
                            st.divider()
                    else:
                        st.warning("No se encontraron hoteles que coincidan con tu búsqueda.")
                else:
                    st.info("Por favor, escribe una descripción para buscar.")

        # --- Pestaña 2: Recomendaciones personalizadas ---
        with pestanas[1]:
            st.subheader("Recomendaciones según tu historial")
            id_usuario = st.number_input("Ingresa tu ID de usuario:", min_value=1, step=1)
            if st.button("Obtener recomendaciones", key="recomendar_usuario"):
                if id_usuario:
                    recomendaciones = sistema.recomendar_por_usuario(id_usuario)
                    if recomendaciones:
                        st.success("Tus recomendaciones:")
                        for hotel_id, puntuacion in recomendaciones:
                            hotel = sistema.hoteles_df[sistema.hoteles_df['id_hotel'] == hotel_id].iloc[0]
                            st.markdown(f"### {hotel['nombre']}  ")
                            st.write(f"**Puntuación estimada:** {puntuacion:.2f}")
                            st.write(f"**Categoría:** {hotel['categoria']}")
                            st.write(f"**Precio promedio:** ${hotel['precio_promedio']:,.2f}")
                            st.write(f"**Ubicación:** {hotel['ubicacion']}")
                            st.write(f"**Descripción:** {hotel['descripcion']}")
                            ruta_imagen = obtener_imagen_hotel(hotel['id_hotel'])
                            if ruta_imagen:
                                st.image(ruta_imagen, width=300)
                            st.progress(min(puntuacion, 1.0))
                            # Botón para agregar a favoritos
                            if st.button(f"Agregar a favoritos: {hotel['nombre']}", key=f"fav_recom_{hotel_id}"):
                                if hotel['nombre'] not in st.session_state['favoritos']:
                                    st.session_state['favoritos'].append(hotel['nombre'])
                                    st.success(f"Agregado a favoritos: {hotel['nombre']}")
                            st.divider()
                    else:
                        st.warning("No se encontraron recomendaciones para este usuario.")
                else:
                    st.info("Por favor, ingresa un ID de usuario válido.")

        # --- Pestaña 3: Explorar hoteles ---
        with pestanas[2]:
            st.subheader("Explora todos los hoteles disponibles")
            col1, col2 = st.columns(2)
            with col1:
                categoria = st.selectbox("Categoría:", ["Todas", "5 estrellas", "4 estrellas", "3 estrellas"])
            with col2:
                precio_max = st.slider("Precio máximo por noche:", 300000, 1000000, 1000000, step=50000)

            hoteles_filtrados = sistema.hoteles_df
            if categoria != "Todas":
                hoteles_filtrados = hoteles_filtrados[hoteles_filtrados['categoria'] == categoria]
            hoteles_filtrados = hoteles_filtrados[hoteles_filtrados['precio_promedio'] <= precio_max]

            if len(hoteles_filtrados) == 0:
                st.warning("No hay hoteles que cumplan con los filtros seleccionados.")
            else:
                for _, hotel in hoteles_filtrados.iterrows():
                    st.markdown(f"### {hotel['nombre']}  ")
                    st.write(f"**Categoría:** {hotel['categoria']}")
                    st.write(f"**Precio promedio:** ${hotel['precio_promedio']:,.2f}")
                    st.write(f"**Ubicación:** {hotel['ubicacion']}")
                    st.write(f"**Descripción:** {hotel['descripcion']}")
                    ruta_imagen = obtener_imagen_hotel(hotel['id_hotel'])
                    if ruta_imagen:
                        st.image(ruta_imagen, width=300)
                    # Botón para agregar a favoritos
                    if st.button(f"Agregar a favoritos: {hotel['nombre']}", key=f"fav_expl_{hotel['id_hotel']}"):
                        if hotel['nombre'] not in st.session_state['favoritos']:
                            st.session_state['favoritos'].append(hotel['nombre'])
                            st.success(f"Agregado a favoritos: {hotel['nombre']}")
                    st.divider()

    elif menu == "Registro de usuario":
         # --- Contenido: Formulario de Registro (si está logueado, accesible desde el menú) ---
        st.subheader("📝 Registrar nuevo usuario")
        st.markdown("Completa los siguientes campos para registrar un nuevo usuario.")
        # Reutilizar el formulario de registro ya definido (asegurando keys únicas)
        with st.form("registro_usuario_logged_in"):
            nombre = st.text_input("Nombre completo", key='register_nombre_li')
            email = st.text_input("Email", key='register_email_li')
            password = st.text_input("Contraseña", type="password", key='register_password_li')
            edad = st.number_input("Edad", min_value=1, max_value=120, step=1, key='register_edad_li')
            genero = st.selectbox("Género", ("F", "M", "Otro"), key='register_genero_li')
            submit = st.form_submit_button("Registrar")
            if submit:
                if nombre.strip() == "" or email.strip() == "" or password.strip() == "":
                    st.warning("Por favor, completa todos los campos obligatorios.")
                else:
                    try:
                        conn = mysql.connector.connect(**DB_CONFIG)
                        cursor = conn.cursor()
                        cursor.execute(
                            "INSERT INTO usuario (nombre, email, password, edad, genero) VALUES (%s, %s, %s, %s, %s)",
                            (nombre, email, password, edad, genero)
                        )
                        conn.commit()
                        cursor.close()
                        conn.close()
                        st.success("¡Usuario registrado exitosamente!")
                    except Exception as e:
                        st.error(f"Error al registrar usuario: {e}")

    elif menu == "Usuarios registrados":
        # --- Contenido: Visualización de usuarios (si está logueado, accesible desde el menú) ---
        st.subheader("👥 Listado de Usuarios Registrados")
        # Inicializar sistema si es necesario para esta sección (acceso a BD)
        if sistema is None:
             sistema = inicializar_sistema()
        try:
            conn = mysql.connector.connect(**DB_CONFIG)
            usuarios_df = pd.read_sql("SELECT id_usuario, nombre, email, edad, genero FROM usuario", conn)
            conn.close()
            st.dataframe(usuarios_df)
        except Exception as e:
            st.error(f"Error al cargar usuarios: {e}")

    # Botón de Logout (en la sidebar cuando está logueado)
    st.sidebar.markdown("---") # Separador
    if st.sidebar.button("Cerrar Sesión", key='logout_button'):
        st.session_state['logged_in'] = False
        st.session_state['user_id'] = None
        st.session_state['user_name'] = None
        st.session_state['favoritos'] = [] # Limpiar favoritos de la sesión anterior
        st.rerun()

# Cerrar conexión al finalizar (esto puede ser problemático con st.cache_resource, mejor manejar conexiones dentro de las funciones que la usan)
# sistema.cerrar_conexion() 