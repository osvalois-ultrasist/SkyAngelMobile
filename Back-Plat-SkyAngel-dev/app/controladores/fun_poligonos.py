


'''
    Este script contiene las funciones con las que se realiza el endpont de la coleccion 'Consulta'
'''
import json    
import geopandas as gpd
from shapely.geometry import Point, LineString
from shapely.ops import unary_union
from shapely.geometry import shape
import geojson
from app.modelos.conexion_s3 import Conexion_S3
from app.configuraciones.config import Config
from flask import current_app
from shapely.ops import linemerge
from geopandas.tools import sjoin
import traceback
from flask import current_app
from datetime import datetime
from app.estaticos.cache.files_cache import Cache_GPDPoligonos1km, Cache_GeopuntosSky


# Ruta: /sumhoras, Funcion: Sum_Horas-------------------------------------------------------------------------
# Esta funcion regresa el dia y hora actual sumando algunas horas y minutos
def GetPoligonos(Info):

    # Reviso que el request tenga todos los datos completos y en el formato adecuado
    try: no_fuente, no_tempo = Info['fuente'],Info['temporalidad']
    except: return False
    
    Fuentes = {
        0: 'sum',       # Total
        1: 'sumsky',    # Sumatrio de Sky
        2: 'sumsecre',  # Sumatoria de delitos del secretariado
        3: 'sumanerpv', # Sumatorio de delitos de anerpv
    }
    
    Temporlidades = {
        0: 'LastMonth',
        1: 'LasTrimester',
        2: 'LastSemester',
        3: 'LastYear',
    }
    
    # Obtenems el directorio para cargar a
    ConS3 = Conexion_S3()
    Ruta = 'poligonos/Polig1km_'+Temporlidades[no_tempo]+'_0'+Fuentes[no_fuente]+'.geojson'
    Archivo = ConS3.CargarArchivo(Config.S3_BUCKET,Ruta)
    Contenido = Archivo['Body'].read().decode('utf-8')
    Poligono = json.loads(Contenido) 

    return Poligono

# Esta funcion revisa la informacion recibida para la funcion Sum_hours():
def Rev_info_GetPoligionos(Info):
    
    # Reviso que el request tenga todos los datos completos y en el formato adecuado
    try: numhoras, nummin = Info['fuente'],Info['temporalidad']
    except: return False
    return True


# Esta funcion revisa la informacion recibida 
def Rev_info_georuta(Info):
    
    # Reviso que el request tenga todos los datos completos y en el formato adecuado
    try: geopuntos = Info['geopuntos']
    except: return False
    
    # Si se tiene toda la informacion
    return True

# Esta funcion asigna el color del riesgo con base en indice de riesgo
def asignar_color(index_right):
    if index_right == 0:
        #'#ff9999'
        return '#fee08b'
    elif index_right == 1:
        #'#ff6666'
        return '#f46d43'
    elif index_right == 2:
        #'#ff3232'
        return '#d73027'
    elif index_right == 3:
        #'#b30202'
        return  '#70001f' 
    elif index_right == 4:
        #'#ffcccc'
        return '#fffceb'
    else:
        return None  

# Esta funcion asigna el valor del comportamiento del delito
def asignar_valor(index_right):
    if index_right == 0:
        return 2
    elif index_right == 1:
        return 3
    elif index_right == 2:
        return 4
    elif index_right == 3:
        return 5
    elif index_right == 4:
        return 1
    else:
        return None  

# Esta funcion revisa la informacion recibida 
def Get_Geojson_Ruta(Info):
    
    # Reviso que el request tenga todos los datos completos y en el formato adecuado
    geopuntos = Info['geopuntos']

    hora_begin_inside = datetime.now()
    timpos = {}
    # Construyo la GeoLinea para la respuesta
    GeoLinea = []
    for num in range(len(geopuntos['geometry']['coordinates'])-1):
        GeoLinea.append(LineString(  [ [geopuntos['geometry']['coordinates'][num][0],geopuntos['geometry']['coordinates'][num][1]],  [geopuntos['geometry']['coordinates'][num+1][0],geopuntos['geometry']['coordinates'][num+1][1]]  ]))
    GeoLinea = gpd.GeoDataFrame(geometry=GeoLinea)
    GeoLinea.set_crs(epsg=4326, inplace=True)
    timpos['1-ConstruyeGeoline'] =  (datetime.now()-hora_begin_inside).total_seconds()
    #print("Get_Geojson_Ruta 1--- Se construye la geolinea ", (datetime.now()-hora_begin_inside).total_seconds())

    # Construyo el GeoPandas de puntos para su analisis
    Puntos = []
    for num in range(len(geopuntos['geometry']['coordinates'])):
        Puntos.append(Point(  [ geopuntos['geometry']['coordinates'][num][0],geopuntos['geometry']['coordinates'][num][1]   ]))
    Puntos = gpd.GeoDataFrame(geometry=Puntos)
    _=Puntos.set_crs(epsg=4326, inplace=True)
    #print("Get_Geojson_Ruta 2--- Se construye el geodataframe con los puntos de la ruta ", (datetime.now()-hora_begin_inside).total_seconds())
    timpos['2-ConstruyeGeoDataFrame'] =  (datetime.now()-hora_begin_inside).total_seconds()   

    # Abro el archivo de poligions
    Poligonos = Cache_GPDPoligonos1km.copy()
    #print("Get_Geojson_Ruta 3--- Se carga y construye el GPD Poligonos ", (datetime.now()-hora_begin_inside).total_seconds())
    timpos['3-CarganPoligonos'] =  (datetime.now()-hora_begin_inside).total_seconds()   

    # Identifico el color por donde pasan los geopuntos y le asigno su respectivo color como columna
    Poligonos_Info = gpd.sjoin(Puntos, Poligonos, how="left", predicate="within")
    Poligonos_Info['index_right'] = Poligonos_Info['index_right'].fillna(4)
    Poligonos_Info['color'] = Poligonos_Info['index_right'].apply(asignar_color)
    Poligonos_Info['valor'] = Poligonos_Info['index_right'].apply(asignar_valor)
    #print("Get_Geojson_Ruta 4--- Se hace el join de los puntos de la ruta con los poligonos para identificar su riesgo ", (datetime.now()-hora_begin_inside).total_seconds())
    timpos['4-JoinRuta'] =  (datetime.now()-hora_begin_inside).total_seconds()   
        
    # Regresamos los atributos a la Geolinea
    GeoLinea['color'] = Poligonos_Info['color'].values[1:]
    GeoLinea['valor'] = Poligonos_Info['valor'].values[1:]
    GeoLinea = GeoLinea.to_crs(epsg=3395)
    Metadatos = {}
    Metadatos['km_grad1'] = GeoLinea[GeoLinea['valor']==1].length.sum()/1000
    Metadatos['km_grad2'] = GeoLinea[GeoLinea['valor']==2].length.sum()/1000
    Metadatos['km_grad3'] = GeoLinea[GeoLinea['valor']==3].length.sum()/1000
    Metadatos['km_grad4'] = GeoLinea[GeoLinea['valor']==4].length.sum()/1000
    Metadatos['km_grad5'] = GeoLinea[GeoLinea['valor']==5].length.sum()/1000
    Metadatos['riskVal'] = 5*Metadatos['km_grad5'] + 4*Metadatos['km_grad4'] + 3*Metadatos['km_grad3'] + 2*Metadatos['km_grad2'] + 1*Metadatos['km_grad1']
    Metadatos['riskValPromXKm'] = Metadatos['riskVal'] / (GeoLinea.length.sum()/1000)
    #print("Get_Geojson_Ruta 9--- Se arreg identifica el color de las rutas  ", (datetime.now()-hora_begin_inside).total_seconds())
    timpos['5-Coloreado'] =  (datetime.now()-hora_begin_inside).total_seconds()   
 
    GeoLinea = GeoLinea.to_crs(epsg=4326)
    #print("Get_Geojson_Ruta 9---to_crs ", (datetime.now()-hora_begin_inside).total_seconds())
    # Regreso un geojson
    GeoLinea = json.loads(GeoLinea.to_json())
    #print("Get_Geojson_Ruta 9---to_json ", (datetime.now()-hora_begin_inside).total_seconds())
    timpos['6-finalizacion'] =  (datetime.now()-hora_begin_inside).total_seconds()   
        
    Respuesta = {}
    Respuesta['geoJson'] = GeoLinea
    Respuesta['metaDatos'] = Metadatos
    Respuesta['tiempos'] = timpos

    #print("Get_Geojson_Ruta 10--- Se convierte a geojson y se regresa la información FINNNNNN  ", (datetime.now()-hora_begin_inside).total_seconds())
    return Respuesta

# Esta funcion calcula la interseccion con insidentes reportados en sky angel por ruta y hora d esalida
def Get_Geojson_SegTime(Info):

    if True:
        # Reviso que el request tenga todos los datos completos y en el formato adecuado
        geopuntos = Info['geopuntos']
        GeoPuntosSky = Cache_GeopuntosSky.copy()

        # Construyo la GeoLinea para la respuesta
        GeoLinea = []
        for num in range(len(geopuntos['geometry']['coordinates'])-1):
            GeoLinea.append(LineString(  [ [geopuntos['geometry']['coordinates'][num][0],geopuntos['geometry']['coordinates'][num][1]],  [geopuntos['geometry']['coordinates'][num+1][0],geopuntos['geometry']['coordinates'][num+1][1]]  ]))
        GeoLinea = gpd.GeoDataFrame(geometry=GeoLinea)
        GeoLinea.set_crs(epsg=4326, inplace=True)
        
        # Construyo los Geosegmentos para identificar los puntos
        GeoLinea = GeoLinea.to_crs(epsg=3857)
        GeoLinea['Distancia'] = GeoLinea.length/1000
        GeoLinea['CumSum'] = GeoLinea['Distancia'].cumsum()
        GeoLinea['ID_Segmento'] = GeoLinea['CumSum']/60
        GeoLinea['ID_Segmento'] = GeoLinea['ID_Segmento'].astype('int')
        GeoSegmentos = GeoLinea.groupby('ID_Segmento')['geometry'].apply(lambda x: linemerge(list(x))).reset_index()
        GeoSegmentos = gpd.GeoDataFrame(GeoSegmentos, geometry='geometry', crs=GeoLinea.crs)
        GeoSegmentos = GeoSegmentos.to_crs(epsg=4326)
        GeoLinea = GeoLinea.to_crs(epsg=4326)
        NumKm = 3
        GeoSegmentos["geometry"] = GeoSegmentos.geometry.buffer(NumKm*1000/111139)   

        # Identifico los puntos que pertenecen a cada seccion
        Datos_con_segmento = gpd.sjoin(GeoPuntosSky, GeoSegmentos, how="left", predicate="within")
        DelitosSegHora = {}
        Formtato = []
        Datos_con_segmento = Datos_con_segmento[Datos_con_segmento['ID_Segmento'].notna()]
        Datos_con_segmento = Datos_con_segmento.reset_index(drop=True)
        AuxHoras = []
        for numx in range(len(Datos_con_segmento)):
            AuxHoras.append(int(Datos_con_segmento.iloc[numx]['properties']['Hora']))
        Datos_con_segmento['Hora'] =  AuxHoras

        
        for hora in range(24):
            Datos_con_segmento['Seg_HoraSal_'+str(hora)] = (Datos_con_segmento['ID_Segmento'] + hora)%24
            Datos_con_segmento['DifAux'] = Datos_con_segmento['Hora'] - Datos_con_segmento['Seg_HoraSal_'+str(hora)]
            AuxDell = Datos_con_segmento[(Datos_con_segmento['DifAux'] >=-2 )& (Datos_con_segmento['DifAux'] <=2)] 
            AuxFor = {}
            AuxFor['Hora'] = hora
            AuxFor['conteo'] =  len(AuxDell)
            AuxFor['promediobysegmento'] = float(len(AuxDell) / (Datos_con_segmento['ID_Segmento'].max()+1))
            
            Formtato.append(AuxFor)

        # Construyo el geoJson de respuesta
        Respuesta = {}
        Respuesta['delitos_seghora'] = Formtato



    
    return Respuesta 