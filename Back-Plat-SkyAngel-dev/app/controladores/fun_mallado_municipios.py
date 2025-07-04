


'''
    Este script contiene las funciones con las que se realiza el endpont de la coleccion 'Consulta'
'''
import json    
import geopandas as gpd
from shapely.geometry import shape
import geojson
from app.modelos.conexion_s3 import Conexion_S3
from app.configuraciones.config import Config

# Esta funcion revisa la informacion recibida para la funcion Sum_hours():
def Rev_info_GetMalladoMun(Info):
    
    # Reviso que el request tenga todos los datos completos y en el formato adecuado
    try: idMun = Info['idMunicipio']
    except: return False
    return True


# Esta funcion asigna el valor del comportamiento del delito
def asignar_valor(color):
    if color == '#ffcccc':
        return 1
    elif color == '#ff9999':
        return 2
    elif color == '#ff6666':
        return 3
    elif color == '#ff3232':
        return 4
    elif color == '#b30202':
        return 1
    else:
        return None  

# Esta funcion revisa la informacion recibida 
def GetMalladoMun(Info):
    
    # Reviso que el request tenga todos los datos completos y en el formato adecuado
    idMun = Info['idMunicipio']
    
    # Abro el archivo de poligions
    ConS3 = Conexion_S3()
    Ruta = 'mallado_municipios/Mallado_IDMun'+idMun+'.geojson'    
    Archivo = ConS3.CargarArchivo(Config.S3_BUCKET,Ruta)
    Contenido = Archivo['Body'].read().decode('utf-8')
    data = json.loads(Contenido)
    
    geometries = [shape(feature['geometry']) for feature in data['features']]
    PropColor = [feature['properties']['color'] for feature in data['features']]
    Poligonos = gpd.GeoDataFrame( geometry=geometries)
    Poligonos['color'] = PropColor
    Poligonos['color'] = Poligonos['color'].fillna('#ffcccc')
    Poligonos['valor'] = Poligonos['color'].apply(asignar_valor)
  
    Poligonos = json.loads(Poligonos.to_json())
    Respuesta = {}
    Respuesta['geoJson'] = Poligonos
    return Respuesta

# Esta funcion revisa la informacion recibida 
def GetMalladoMun_Full(Info):
    
    # Reviso que el request tenga todos los datos completos y en el formato adecuado
    idMun = Info['idMunicipio']
    
    # Abro el archivo de poligions
    ConS3 = Conexion_S3()
    Ruta = 'mallado_municipios/Mallado_IDMun'+idMun+'.geojson'    
    Archivo = ConS3.CargarArchivo(Config.S3_BUCKET,Ruta)
    Contenido = Archivo['Body'].read().decode('utf-8')
    data = json.loads(Contenido)
    
    Respuesta = {}
    Respuesta['geoJson'] = data
    
    return Respuesta