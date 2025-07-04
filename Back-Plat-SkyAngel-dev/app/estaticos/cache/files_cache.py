
from app.modelos.conexion_s3 import Conexion_S3
from app.configuraciones.config import Config
import json 
import geopandas as gpd
from shapely.geometry import shape

# Obtengo el nombre del bucket
S3Bucket = Config.S3_BUCKET

# Caché global
Cache_GPDPoligonos1km = None
Cache_GeopuntosSky = None

# Esta funcion carga el archivo de poligonos desde S3
def LoadPoligonos():
    
    global Cache_GPDPoligonos1km
    ConS3 = Conexion_S3()
    Ruta = 'poligonos/Polig1km_LastYear_0sum.geojson'    
    Archivo = ConS3.CargarArchivo(S3Bucket,Ruta)
    Contenido = Archivo['Body'].read().decode('utf-8')
    data  = json.loads(Contenido) 
    
    geometries = [shape(feature['geometry']) for feature in data['features']]
    Cache_GPDPoligonos1km = gpd.GeoDataFrame(data['features'], geometry=geometries,crs="EPSG:4326")
    

# Esta funcion carga el archivo de poligonos desde S3
def LoadGeopuntos():
    
    ConS3 = Conexion_S3()
    global Cache_GeopuntosSky
    Ruta ='puntossky/10_GeopuntosSky.geojson'    
    Archivo = ConS3.CargarArchivo(S3Bucket,Ruta)
    Contenido = Archivo['Body'].read().decode('utf-8')
    data  = json.loads(Contenido)  
    geometries = [shape(feature['geometry']) for feature in data['features']]
    Cache_GeopuntosSky = gpd.GeoDataFrame(data['features'], geometry=geometries)
    return Cache_GeopuntosSky

# Se cargan los archivos del s3 
LoadPoligonos()
LoadGeopuntos()