import re
from app.mapper.sum_delitos_nacional_mes_anerpv_mapper import DelitosNacionalAnerpv_mapper
from app.modelos.sum_delitos_nacional_mes_anerpv import DelitosNacionalAnerpv

class DelitosNacionalAnerpv_service():

    def __init__(self):
        self.delitosnacionalanerpv = DelitosNacionalAnerpv_mapper()

    # Función para convertir camelCase a snake_case
    def camel_to_snake(self, json_data):
        return {self.camel_to_snake_key(k): v for k, v in json_data.items()}

    # Convierte una clave camelCase a snake_case
    def camel_to_snake_key(self, key):
        return re.sub(r'(?<!^)(?=[A-Z])', '_', key).lower()

    def insert(self, json):
        # Convertimos las claves del JSON de camelCase a snake_case
        json_snake_case = self.camel_to_snake(json)

        ent_mod =  DelitosNacionalAnerpv(
            json_snake_case['anio'],
            json_snake_case['id_mes'],
            json_snake_case['conteo_robo_transportista'],
            json_snake_case['conteo_robo_transportista_acumulado'],
            json_snake_case['conteo_robo_vehiculos_pesados'],
            json_snake_case['conteo_robo_vehiculos_ligeros'],
            json_snake_case['conteo_robo_vehiculos_privados'],
            json_snake_case['conteo_robo_turno_matutino'],
            json_snake_case['conteo_robo_turno_madrugada'],
            json_snake_case['conteo_robo_turno_vespertino'],
            json_snake_case['conteo_robo_turno_nocturno'],
            json_snake_case['conteo_robo_lunes'],
            json_snake_case['conteo_robo_martes'],
            json_snake_case['conteo_robo_miercoles'],
            json_snake_case['conteo_robo_jueves'],
            json_snake_case['conteo_robo_viernes'],
            json_snake_case['conteo_robo_sabado'],
            json_snake_case['conteo_robo_domingo']
        )
        return self.delitosnacionalanerpv.insert(ent_mod)

    ## PENDIENTE POR REVISAR PARA EL UPDATE
    def update(self, id_modalidad_anerpv, json):
        # Verificar si los datos 'entidad_modalidad_anerpv' está en el JSON
        if 'modalidad_anerpv' not in json or not json['modalidad_anerpv'].strip():
            return {"Error": "El campo 'modalidad_anerpv' es obligatorio y no debe estar vacío"}, 400
        ent_mod =  EntidadDelitosdAnerpv(
            id_modalidad_anerpv,
            json['modalidad_anerpv'])
        return self.delitosnacionalanerpv.update(ent_mod)

    def delete(self, json):
        # Convertimos las claves del JSON de camelCase a snake_case
        json_snake_case = self.camel_to_snake(json)

        ent_mod =  DelitosNacionalAnerpv(
            json_snake_case['anio'],
            json_snake_case['id_mes'],
            json_snake_case['conteo_robo_transportista'],
            json_snake_case['conteo_robo_transportista_acumulado'],
            json_snake_case['conteo_robo_vehiculos_pesados'],
            json_snake_case['conteo_robo_vehiculos_ligeros'],
            json_snake_case['conteo_robo_vehiculos_privados'],
            json_snake_case['conteo_robo_turno_matutino'],
            json_snake_case['conteo_robo_turno_madrugada'],
            json_snake_case['conteo_robo_turno_vespertino'],
            json_snake_case['conteo_robo_turno_nocturno'],
            json_snake_case['conteo_robo_lunes'],
            json_snake_case['conteo_robo_martes'],
            json_snake_case['conteo_robo_miercoles'],
            json_snake_case['conteo_robo_jueves'],
            json_snake_case['conteo_robo_viernes'],
            json_snake_case['conteo_robo_sabado'],
            json_snake_case['conteo_robo_domingo']
        )
        
        return self.delitosnacionalanerpv.delete(ent_mod)

    def select_all(self):
        return self.delitosnacionalanerpv.select_all()

    def select_anio(self, anio, id_mes):
        # Verificar si alguna de las listas es nula o está vacía
        if not anio:
            return {"Error": "El campo 'anios' es obligatorio"}, 400
        if not id_mes:
            return {"Error": "El campo 'meses' es obligatorio"}, 400

        # Validar si los elementos en las listas son enteros
        if not all(isinstance(i, int) for i in anio):
            return {"Error": "Todos los valores en 'anios' deben ser enteros"}, 400
        if not all(isinstance(i, int) for i in id_mes):
            return {"Error": "Todos los valores en 'meses' deben ser enteros"}, 400

        # Si 'meses' contiene 0, no filtramos por meses y seleccionamos todos
        if len(id_mes) == 1 and id_mes[0] == 0:
            id_mes = None  # Indicar que no se filtrará por meses

        # Si 'anios' contiene 0, no filtramos por anios y seleccionamos todos
        if len(anio) == 1 and anio[0] == 0:
            anio = None  # Indicar que no se filtrará por anios

        sum_nac = DelitosNacionalAnerpv(
            anio = anio,
            id_mes = id_mes,
            conteo_robo_transportista = None, 
            conteo_robo_transportista_acumulado = None, 
            conteo_robo_vehiculos_pesados = None, 
            conteo_robo_vehiculos_ligeros = None, 
            conteo_robo_vehiculos_privados = None, 
            conteo_robo_turno_matutino = None, 
            conteo_robo_turno_madrugada = None, 
            conteo_robo_turno_vespertino = None, 
            conteo_robo_turno_nocturno = None, 
            conteo_robo_lunes = None, 
            conteo_robo_martes = None, 
            conteo_robo_miercoles = None, 
            conteo_robo_jueves = None, 
            conteo_robo_viernes = None, 
            conteo_robo_sabado = None, 
            conteo_robo_domingo = None
        )
        
        return self.delitosnacionalanerpv.select_anio(sum_nac)
