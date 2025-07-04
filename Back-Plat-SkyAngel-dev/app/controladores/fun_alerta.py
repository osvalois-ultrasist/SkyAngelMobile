from app.mapper.alerta_mapper import Alerta_mapper
from app.controladores.fun_puntos_interes import Puntos_interes_service
from app.modelos.alerta import Alerta
import locale
import re
from datetime import datetime

'''Servicio encargado de procesar las alertas y obtener las alertas activas''' 
class AlertaService():
    def __init__(self):
        self.alerta_mapper = Alerta_mapper()

    '''Función para procesar json de alerta recibida y agregar 
    campos adicionales'''
    def alerta_completa(self,data):
        coordenadas=data.get("coordenadas", "")
        # Validar coordenadas con regex
        validar_coord = re.compile(
             r"^\s*((3[0-2](\.\d+)?|2[0-9](\.\d+)?|1[5-9](\.\d+)?|14\.(3[8-9]|\d{2,})))\s*,\s*-((11[0-7](\.\d+)?|118\.(\d|[0-3]\d|4[0-4])|10[0-9](\.\d+)?|9[0-9](\.\d+)?|8[6-9](\.\d+)?|86\.(7[1-9]|[8-9]\d*)))\s*$"
             )
        if not validar_coord.match(coordenadas):
            raise ValueError("Coordenadas invalidas o fuera de rango")
        
        lat_str, lon_str = coordenadas.strip().split(",")

        lat = float(lat_str.strip())
        lng = float(lon_str.strip())
        # Se formatea fecha/hora de México
        locale.setlocale(locale.LC_ALL, 'es_MX.UTF-8')
        
        actual_fecha = datetime.now()
        fecha = actual_fecha.strftime("%Y-%m-%d")
        dia_semana = actual_fecha.strftime("%A").capitalize()
        hora = actual_fecha.strftime("%H:%M")

        alerta_datos = {
            "tipo_alerta": data.get("tipo", "").strip(),
            "incidencia_alerta": data.get("incidencia", "").strip(),
            "fecha_alerta": fecha,
            "dia_semana": dia_semana,
            "hora_alerta": hora, 
            "comentario_alerta": data.get("comentario", "").strip(),
            "operador_de_unidad": None,
            "central": None,
            "linea_transportista": None,
            "latitud_alerta": lat,
            "longitud_alerta": lng,
            "id_estatus_alerta": 1
        }

        return alerta_datos   
    
    # Convierte alerta en GeoJSON
    def convertir_a_feature(self, data):
         # Se crea objeto geometry para GeoJSON [lng, lat]
        geometry = {
            "type": "Point",
            "coordinates": [data["longitud_alerta"], data["latitud_alerta"]]
        }
        campos_a_excluir = {"linea_transportista", "central", "operador_de_unidad", "status"}
        # Se crean las propiedades excluyendo lat y lng
        properties = {k: v for k, v in data.items() if k not in ["latitud_alerta", "longitud_alerta"] and k not in campos_a_excluir}

        feature = {
            "type": "Feature",
            "geometry": geometry,
            "properties": properties
        }
        return feature

    # Procesa la alerta recibida y la guarda en el archivo
    def emitir_alerta(self, data):
            # Convertimos la alerta a GeoJSON (Feature)
            response = self.convertir_a_feature(data)
            # Emitimos la alerta convertida a GeoJSON a todos los clientes conectados
            from app import socketio # Importamos socketio
            socketio.emit('receiveAlert', response)
    
    # Guarda la alerta en la base de datos
    def insert(self, json):
        alt_mod = Alerta(-1,
            json['tipo_alerta'],
            json['incidencia_alerta'],
            json['fecha_alerta'],
            json['dia_semana'],
            json['hora_alerta'],
            json['comentario_alerta'],
            json['operador_de_unidad'],
            json['central'],
            json['linea_transportista'],
            json['latitud_alerta'],
            json['longitud_alerta'],
            json['id_estatus_alerta']
        )
        return self.alerta_mapper.insert(alt_mod)
    
    # Obtiene las alertas activas del archivo
    def get_alertas_activas(self):
            # Obtenemos las alertas activas
            alerta = self.alerta_mapper.get_alertas()
            # Retornamos FeatureCollection GeoJSON
            respuesta = Puntos_interes_service().obtener_GeoJson(alerta)
            return respuesta 
        
    # Función que devuelve lista delas categorias (tipos de incidencia)
    def obtener_categorias (self):
        categorias =[
            {"id": 1, "nombre": "Incidencias delictivas"},
            {"id": 2, "nombre": "Otras incidencias en ruta"},
            {"id": 3, "nombre": "Accidentes"},
            {"id": 4, "nombre": "Recuperaciones"}
        ]
        return categorias
    
    # Obtiene las subcategorias (subtipos de incidencia)
    def obtener_subcategorias(self):
        return self.alerta_mapper.obtener_subcategorias()
    
    # Actualiza el status de la alerta
    def actualizar_estatus_alerta(self):
        cantidad = self.alerta_mapper.update_estatus()
        #print(f"Alertas desactivadas: {cantidad}")
        return cantidad