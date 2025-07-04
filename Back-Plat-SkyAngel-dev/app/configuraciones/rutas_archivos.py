import os
from app.configuraciones.config import Config

# Define la base path del proyecto
BASE_PATH = os.path.dirname(os.path.dirname(__file__))

# AWS S3 Configuración
BUCKET_NAME = Config.S3_BUCKET
KEY_DATOS_GEOGRAFICOS = 'archivos/geo_rep_muns.json'
KEY_DATOS_GEOGRAFICOS_MUN = 'archivos/topojson-municipality.json'
KEY_DATOS_GEOGRAFICOS_ENT = 'archivos/topojson-entity.json'
KEY_DATOS_HEXAGONOS = 'archivos/mallado-simple.json'
KEY_DATOS_REACCIONES_BARRAS = 'reacciones/reacciones_barras_cualquier.json'
KEY_DATOS_REACCIONES_SCATTER = 'reacciones/reacciones_scatter_cualquier.json'
KEY_DATOS_REACCIONES_TABLA = 'reacciones/reacciones_tabla_cualquier.json'
MAPAS = 'mapas/geojson/'

#Ruta files/Delitos_Anidados.json
archivo_delitos_anidados = os.path.join(BASE_PATH, 'files', 'Delitos_Anidados.json')

#Ruta files/delitos.xlsx
archivo_delitos = os.path.join(BASE_PATH, 'files', 'delitos.xlsx')

#Ruta files/DELITOS_SECRETARIADO_MUNICIPIO.xlsx
archivo_delitos_secretariado = os.path.join(BASE_PATH, 'files', 'DELITOS_SECRETARIADO_MUNICIPIO.csv')

#Ruta files/Polig1km_LastYear_0sum.geojson
archivo_hexagonos = os.path.join(BASE_PATH, 'files', 'mallado-simple.json')

#Ruta files/geo_rep_muns.json
archivo_datosGeograficos = os.path.join(BASE_PATH, 'files', 'geo_rep_muns.json')

#Ruta files/01_DatosProc_Sky(complementos).json
archivo_complementos = os.path.join(BASE_PATH, 'files', '01_DatosProc_Sky(complementos).json')

#Ruta files/01_DatosProc_Sky(localizacion).json
archivo_localizacion = os.path.join(BASE_PATH, 'files', '01_DatosProc_Sky(localizacion).json')

#Ruta files/01_DatosProc_Sky(puntos).json
archivo_puntos = os.path.join(BASE_PATH, 'files', '01_DatosProc_Sky(puntos).json')

#Ruta files/tweets.json
archivo_tweets = os.path.join(BASE_PATH, 'files', 'tweets.json')

#Ruta files/alertas.json
archivo_alertas = os.path.join(BASE_PATH, 'files', 'alertas.json')