

'''
    Este script contiene las funciones con las que se realiza el endpont de la coleccion 'Consulta'
'''

from app.modelos.conexion_WH import Conexion_WH
import geopandas as gpd
import pandas as pd
import json
import numpy as np
from shapely.geometry import Point, LineString
from shapely.ops import unary_union

Control_WH = Conexion_WH()

# Esta funcion revisa la informacion recibida 
def Rev_info_geocomportamiento(Info):
    
    # Reviso que el request tenga todos los datos completos y en el formato adecuado
    try: fuente, ID_delito,size_mallado,temporalidad = Info['fuente'],Info['ID_delito'],Info['size_mallado'],Info['temporalidad']
    except: return False
    
    # Si se tiene toda la informacion
    return True

# Esta funcion genera el geojson con base en la informacion solicitada
def Get_Geojson_Delito(Info):
    fuente, ID_delito,size_mallado,temporalidad = Info['fuente'],Info['ID_delito'],Info['size_mallado'],Info['temporalidad']
    
    # Consulto la informacion del comportamiento del delito
    Comportameinto = Control_WH.Comportamiento_Delito(fuente, ID_delito,size_mallado,temporalidad)
    
    # Realizamos el calculo del color
    Depurados = Comportameinto[Comportameinto[temporalidad]!=0]
    Depurados = Depurados[[temporalidad]] / Depurados[temporalidad].sum()
    Depurados = Depurados.sort_values(temporalidad)
    Depurados['Cumsum'] = Depurados[temporalidad].cumsum()
    Bin0 = 0
    Bin1 = Depurados[temporalidad].min()
    Bin2 = Depurados[Depurados['Cumsum']>0.25][temporalidad].values[0] * Comportameinto[temporalidad].sum()
    Bin3 = Depurados[Depurados['Cumsum']>0.50][temporalidad].values[0] * Comportameinto[temporalidad].sum()
    Bin4 = Depurados[Depurados['Cumsum']>0.75][temporalidad].values[0] * Comportameinto[temporalidad].sum()
    Bin5 = Comportameinto[temporalidad].max()+1
    Bins = [Bin0,Bin1,Bin2,Bin3,Bin4,Bin5]
    labels = ['#ffcccc', '#ff9999', '#ff6666', '#ff3232', '#ff0000']
    Comportameinto['Color'] = pd.cut(Comportameinto['LastYear'], bins=Bins, labels=labels, right=False)

    # Abro el geojson requerido
    #######################################  CORREGIR ESTA PARTE ####################################################################
    Ruta_Mallado = 'app\estaticos\Mallados\Hexagonos_Div'+str(size_mallado)+'_Terr.geojson'
    Mallado = gpd.read_file(Ruta_Mallado)
    Mallado = Mallado.rename(columns={'num_id':'ID_poligono'})
    
    # Hago el join de la informacion
    Comportameinto = pd.merge(Comportameinto,Mallado,on='ID_poligono',how='left')
    Comportameinto = gpd.GeoDataFrame(Comportameinto,geometry='geometry')
    
    # Regreso un geojson
    Comportameinto = json.loads(Comportameinto.to_json())
    return Comportameinto


# Esta funcion genera el geojson con base en la informacion solicitada
def Get_Geojson_Delito_Red(Info):
    fuente, ID_delito,size_mallado,temporalidad = Info['fuente'],Info['ID_delito'],Info['size_mallado'],Info['temporalidad']
    
    # Consulto la informacion del comportamiento del delito
    Comportameinto = Control_WH.Comportamiento_Delito(fuente, ID_delito,size_mallado,temporalidad)
    
    # Realizamos el calculo del color
    Depurados = Comportameinto[Comportameinto[temporalidad]!=0]
    Depurados = Depurados[[temporalidad]] / Depurados[temporalidad].sum()
    Depurados = Depurados.sort_values(temporalidad)
    Depurados['Cumsum'] = Depurados[temporalidad].cumsum()
    Bin0 = 0
    Bin1 = Depurados[temporalidad].min()
    Bin2 = Depurados[Depurados['Cumsum']>0.25][temporalidad].values[0] * Comportameinto[temporalidad].sum()
    Bin3 = Depurados[Depurados['Cumsum']>0.50][temporalidad].values[0] * Comportameinto[temporalidad].sum()
    Bin4 = Depurados[Depurados['Cumsum']>0.75][temporalidad].values[0] * Comportameinto[temporalidad].sum()
    Bin5 = Comportameinto[temporalidad].max()+1
    Bins = [Bin0,Bin1,Bin2,Bin3,Bin4,Bin5]
    labels = ['#ffcccc', '#ff9999', '#ff6666', '#ff3232', '#ff0000']
    Comportameinto['Color'] = pd.cut(Comportameinto['LastYear'], bins=Bins, labels=labels, right=False)

    # Abro el geojson requerido
    #######################################  CORREGIR ESTA PARTE (Cuando se tenga el S3) ###############################################
    Ruta_Mallado = 'app\estaticos\Mallados\Hexagonos_Div'+str(size_mallado)+'_Terr.geojson'
    Mallado = gpd.read_file(Ruta_Mallado)
    Mallado = Mallado.rename(columns={'num_id':'ID_poligono'})
    
    # Hago el join de la informacion
    Comportameinto = pd.merge(Comportameinto,Mallado,on='ID_poligono',how='left')
    Comportameinto = gpd.GeoDataFrame(Comportameinto,geometry='geometry')
    
    # Redusco la geoforma incluyendo solo los poligonos con informacion
    Comportameinto = Comportameinto[Comportameinto['Color']!='#ffcccc']
    
    if True:
        Multi_gdf = gpd.GeoDataFrame()
        for cla in ['#ff9999', '#ff6666', '#ff3232', '#ff0000']:
            Aux_gdf = Comportameinto[Comportameinto['Color']==cla]
            Aux_gdf = unary_union(Aux_gdf.geometry)
            Aux_gdf = gpd.GeoDataFrame(geometry=[Aux_gdf])
            Aux_gdf['Color'] = cla
            Multi_gdf = pd.concat([Multi_gdf,Aux_gdf])
        Comportameinto = Multi_gdf
    
    # Regreso un geojson
    Comportameinto = json.loads(Comportameinto.to_json())
    return Comportameinto


# Esta funcion revisa la informacion recibida 
def Rev_info_georuta(Info):
    
    # Reviso que el request tenga todos los datos completos y en el formato adecuado
    try: fuente, ID_delito,temporalidad,geopuntos = Info['fuente'],Info['ID_delito'],Info['temporalidad'],Info['geopuntos']
    except: return False
    
    # Si se tiene toda la informacion
    return True

# Esta funcion revisa la informacion recibida 
def Get_Geojson_Ruta(Info):
    
    # Reviso que el request tenga todos los datos completos y en el formato adecuado
    fuente, ID_delito,temporalidad,geopuntos = Info['fuente'],Info['ID_delito'],Info['temporalidad'],Info['geopuntos']
    
    # Consulto la informacion del comportamiento del delito
    Comportameinto = Control_WH.Comportamiento_Delito(fuente, ID_delito,500,temporalidad)
    
    # Realizamos el calculo del color
    Depurados = Comportameinto[Comportameinto[temporalidad]!=0]
    Depurados = Depurados[[temporalidad]] / Depurados[temporalidad].sum()
    Depurados = Depurados.sort_values(temporalidad)
    Depurados['Cumsum'] = Depurados[temporalidad].cumsum()
    Bin0 = 0
    Bin1 = Depurados[temporalidad].min()
    Bin2 = Depurados[Depurados['Cumsum']>0.25][temporalidad].values[0] * Comportameinto[temporalidad].sum()
    Bin3 = Depurados[Depurados['Cumsum']>0.50][temporalidad].values[0] * Comportameinto[temporalidad].sum()
    Bin4 = Depurados[Depurados['Cumsum']>0.75][temporalidad].values[0] * Comportameinto[temporalidad].sum()
    Bin5 = Comportameinto[temporalidad].max()+1
    Bins = [Bin0,Bin1,Bin2,Bin3,Bin4,Bin5]
    labels = ['#ffcccc', '#ff9999', '#ff6666', '#ff3232', '#ff0000']
    Comportameinto['Color'] = pd.cut(Comportameinto[temporalidad], bins=Bins, labels=labels, right=False)
    
    # Construyo la GeoLinea para la respuesta
    GeoLinea = []
    for num in range(len(geopuntos['geometry']['coordinates'])-1):
        GeoLinea.append(LineString(  [ [geopuntos['geometry']['coordinates'][num][0],geopuntos['geometry']['coordinates'][num][1]],  [geopuntos['geometry']['coordinates'][num+1][0],geopuntos['geometry']['coordinates'][num+1][1]]  ]))
    GeoLinea = gpd.GeoDataFrame(geometry=GeoLinea)
    GeoLinea.set_crs(epsg=4326, inplace=True)
    
    # Construyo el GeoPandas de puntos para su analisis
    Puntos = []
    for num in range(len(geopuntos['geometry']['coordinates'])):
        Puntos.append(Point(  [ geopuntos['geometry']['coordinates'][num][0],geopuntos['geometry']['coordinates'][num][1]   ]))
    Puntos = gpd.GeoDataFrame(geometry=Puntos)
    Puntos.set_crs(epsg=4326, inplace=True)

    # Abrimos e identificamos los poligonos que fueron utilizados o cruzados
    Poligonos = gpd.read_file('app\estaticos\Mallados\Hexagonos_Div500_Terr.geojson')
    Poligonos = Poligonos.rename(columns={'num_id':'ID_poligono'})
    Poligonos_Info = gpd.sjoin(Puntos, Poligonos, how="left", predicate="within")
    
    # Hacemos el mach entre los poligonos identificados y su informacion de comportamiento
    Poligonos_Info = pd.merge(Poligonos_Info,Comportameinto, on='ID_poligono',how='left')
    
    # Calculo el riesgo total del trayecto
    IDs = Poligonos_Info['ID_poligono'].unique()
    SumaDel = Comportameinto[Comportameinto['ID_poligono'].isin(IDs)][temporalidad].sum()
    
    # Regresamos los atributos a la Geolinea
    GeoLinea['Color'] = Poligonos_Info['Color'].values[1:]

    # Regreso un geojson
    GeoLinea = json.loads(GeoLinea.to_json())
    Respuesta = {}
    Respuesta['Globales'] = {'Sum_DelPol': SumaDel}
    Respuesta['GeoJson'] = GeoLinea
    return Respuesta