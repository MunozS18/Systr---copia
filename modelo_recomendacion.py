import numpy as np
import pandas as pd
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.feature_extraction.text import TfidfVectorizer
import mysql.connector
from config import DB_CONFIG

class SistemaRecomendacion:
    def __init__(self):
        self.conexion = mysql.connector.connect(**DB_CONFIG)
        self.cursor = self.conexion.cursor(dictionary=True)
        self.matriz_ratings = None
        self.similitud_hoteles = None
        self.vectorizador = TfidfVectorizer(stop_words='english')
        
    def cargar_datos(self):
        """Carga los datos necesarios de la base de datos"""
        # Cargar ratings
        self.cursor.execute("""
            SELECT id_usuario, id_hotel, puntuacion
            FROM valoraciones
        """)
        ratings = self.cursor.fetchall()

        if ratings: # Solo crear matriz de ratings si hay datos
            self.matriz_ratings = pd.DataFrame(ratings).pivot(
                index='id_usuario',
                columns='id_hotel',
                values='puntuacion'
            ).fillna(0)
        else:
            self.matriz_ratings = pd.DataFrame() # Inicializar como DataFrame vacío si no hay ratings
            self.similitud_hoteles = None # O inicializar a una matriz vacía si es necesario

        # Cargar información de hoteles
        self.cursor.execute("""
            SELECT h.*, GROUP_CONCAT(i.imagen_url) as imagenes
            FROM hoteles h
            LEFT JOIN imagenes_hoteles i ON h.id_hotel = i.id_hotel
            GROUP BY h.id_hotel
        """)
        hoteles = self.cursor.fetchall()

        if hoteles: # Crear DataFrame de hoteles si hay datos
            self.hoteles_df = pd.DataFrame(hoteles)
            self.hoteles_df['caracteristicas'] = self.hoteles_df.apply(
                lambda x: f"{x['descripcion']} {x['categoria']} {x['ubicacion']}",
                axis=1
            )

            # Calcular similitud entre hoteles solo si hay datos
            tfidf_matrix = self.vectorizador.fit_transform(self.hoteles_df['caracteristicas'])
            self.similitud_hoteles = cosine_similarity(tfidf_matrix)

        else:
            self.hoteles_df = pd.DataFrame() # Inicializar como DataFrame vacío si no hay hoteles
            self.similitud_hoteles = None # O inicializar a una matriz vacía si es necesario
        
    def recomendar_por_usuario(self, id_usuario, n_recomendaciones=5):
        """Genera recomendaciones basadas en el historial del usuario usando filtrado colaborativo basado en usuarios"""
        if id_usuario not in self.matriz_ratings.index:
            return []

        # Calcular similitud entre usuarios
        matriz = self.matriz_ratings.values
        similitud_usuarios = cosine_similarity(matriz)
        usuarios_ids = self.matriz_ratings.index.tolist()
        idx_usuario = usuarios_ids.index(id_usuario)

        # Obtener las puntuaciones del usuario actual
        ratings_usuario = matriz[idx_usuario]

        # Hoteles no calificados por el usuario
        hoteles_no_calificados = np.where(ratings_usuario == 0)[0]

        predicciones = []
        for idx_hotel in hoteles_no_calificados:
            # Puntuaciones de otros usuarios para este hotel
            ratings_otros = matriz[:, idx_hotel]
            # Similitud de los otros usuarios con el usuario actual
            similitudes = similitud_usuarios[idx_usuario]
            # No considerar al propio usuario
            mask = ratings_otros != 0
            if np.sum(mask) == 0:
                continue
            prediccion = np.dot(similitudes[mask], ratings_otros[mask]) / np.sum(similitudes[mask])
            id_hotel = self.matriz_ratings.columns[idx_hotel]
            predicciones.append((id_hotel, prediccion))

        # Ordenar y devolver mejores recomendaciones
        return sorted(predicciones, key=lambda x: x[1], reverse=True)[:n_recomendaciones]
        
    def recomendar_por_caracteristicas(self, descripcion, n_recomendaciones=5):
        """Genera recomendaciones basadas en características"""
        # Vectorizar la descripción
        descripcion_vector = self.vectorizador.transform([descripcion])
        
        # Calcular similitud con todos los hoteles
        similitudes = cosine_similarity(descripcion_vector, self.vectorizador.transform(self.hoteles_df['caracteristicas']))
        
        # Obtener índices de los hoteles más similares
        indices_similares = similitudes[0].argsort()[-n_recomendaciones:][::-1]
        
        return [(self.hoteles_df.iloc[idx]['id_hotel'], similitudes[0][idx]) for idx in indices_similares]
        
    def cerrar_conexion(self):
        """Cierra la conexión a la base de datos"""
        self.cursor.close()
        self.conexion.close() 