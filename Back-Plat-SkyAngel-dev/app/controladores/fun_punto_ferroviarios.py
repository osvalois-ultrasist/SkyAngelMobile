from app.mapper.punto_interes_ferroviarios_mapper import Puntos_ferroviarios_mapper
from collections import OrderedDict
import json

"""Clase que encapsula la logica para procesar los puntos ferroviarios
y transformarlos en formato GeoJson"""
class Punto_ferroviarios_service:
    def __init__(self):
        self.mapper = Puntos_ferroviarios_mapper()
    """ Esta función obtiene los datos ferroviarios, los filtra 
    y los transforma en una estructura GeoJson (FeatureCollection)"""
    def obtener_GeoJson(self):
        # Se obtiene los registros de puntos ferroviarios del mapper
        datos = self.mapper.obtenerFerroviarios()
        # Estructura base del GeoJson
        geojson = {
            "type": "FeatureCollection",
            "features": []
        }
        # Campos obligatorios para el GeoJson
        campos_sin_filtrar = {
            "Entidad",
            "Municipio",
            "Total años 2016-2019",
            "Total años 2020-2024",
        }
        # Iterar sobre cada punto para contruir las features
        for row in datos:
            # Convertir las coordenadas a float
            lat = float(row["latitud"])
            lon = float(row["longitud"])

            # Crear el diccionario de propiedades excluyendo lat y lon
            propiedades = OrderedDict()
            for k, v in row.items():
                if k in ["latitud", "longitud"]:
                    continue
                """ Agregar la proopiedad si su valor es diferente de 0
                o si la propiedad se encuentra en la lista de campos sin filtrar """
                if v !=0 or k in campos_sin_filtrar :
                    propiedades[k] = v
            # Crear la feature GeoJson
            feature = {
                "type": "Feature",
                "geometry": {
                    "type": "Point",
                    "coordinates": [lon, lat]
                },
                "properties": propiedades
            }
            # Agregar la feature a la featurecollection
            geojson["features"].append(feature)
        # Convertimos el diccionario a una cadena json para asegurar el orden
        geojson = json.dumps(geojson, ensure_ascii=False, indent=2)
        # Retornar el GeoJson completo
        return geojson, 200
