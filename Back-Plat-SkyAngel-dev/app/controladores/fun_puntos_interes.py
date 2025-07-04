import json
from app.mapper.puntos_interes_mapper import Puntos_interes_mapper

""" Clase encargada de convertir los datos obtenidos de puntos de interes de la BD a un GeoJson"""
class Puntos_interes_service():
    # Incializar la clase mapper para poder acceder a sus funciones
    def __init__(self):
        self.mapper = Puntos_interes_mapper()
    # Funcion encargada de convertir los datos obtenidos de la BD a un GeoJson 
    def obtener_GeoJson(self, datos):
        # Crear estructura base del GeoJson
        geojson = {
            "type": "FeatureCollection",
            "features": []
        }
        # Iterar sobre cada punto para contruir las features
        for row in datos:
            # Convertir las coordenadas a float
            lat = float(row["latitud"])
            lon = float(row["longitud"])
            feature = {
                "type": "Feature",
                "geometry": {
                    "type": "Point",
                    "coordinates": [lon, lat]
                },
                # Crear el diccionario de propiedades excluyendo lat,lon y que no sean "S/D" 
                "properties": {k: v for k, v in row.items() 
                               if k not in ["longitud", "latitud"] and v != "S/D"
                               }
            }
            # Agregar la feature a la featurecollection
            geojson["features"].append(feature)
        # Serializar el GeoJson
        geojson_str = json.dumps(geojson, indent=2 ,ensure_ascii=False)
        # Devolver el GeoJson completo
        return geojson_str

    # Funciones encargadas de llamar a las funciones del mapper y devolver el GeoJson
    def select_incidencias(self):
        data= self.mapper.obtenerDatosIncidencias('int_inc_delictivas')
        respuesta = self.obtener_GeoJson(data)
        return respuesta, 200
    
    def select_otras_incidencias(self):
        data= self.mapper.obtenerDatosIncidencias('int_otras_incidencias')
        respuesta = self.obtener_GeoJson(data)
        return respuesta, 200
    
    def select_accidentes(self):
        data= self.mapper.obtenerDatosIncidencias('int_accidentes')
        respuesta = self.obtener_GeoJson(data)
        return respuesta, 200
    
    def select_recuperaciones(self):
        data= self.mapper.obtenerDatosIncidencias('int_recuperacion')
        respuesta = self.obtener_GeoJson(data)
        return respuesta, 200
    
    def select_cachimbas(self):
        data= self.mapper.obtenerDatosCachimbas()
        respuesta = self.obtener_GeoJson(data)
        return respuesta, 200
    
    def select_casetas(self):
        data= self.mapper.obtenerDatosCasetas()
        respuesta = self.obtener_GeoJson(data)
        return respuesta, 200
    
    def select_corralones(self):
        data= self.mapper.obtenerCorralones()
        respuesta = self.obtener_GeoJson(data)
        return respuesta, 200
    
    def select_ministerios(self):
        data= self.mapper.obtenerMinisterios()
        respuesta = self.obtener_GeoJson(data)
        return respuesta, 200
    
    def select_guardia(self):
        data= self.mapper.obtenerGuardia()
        respuesta = self.obtener_GeoJson(data)
        return respuesta, 200
    
    def select_pensiones(self):
        data= self.mapper.obtenerPensiones()
        respuesta = self.obtener_GeoJson(data)
        return respuesta, 200
    
    def select_cobertura(self):
        data= self.mapper.obtenerCobertura()
        respuesta = self.obtener_GeoJson(data)
        return respuesta, 200
    
    def select_paraderos(self):
        data= self.mapper.obtenerParaderos()
        respuesta = self.obtener_GeoJson(data)
        return respuesta, 200
    

    