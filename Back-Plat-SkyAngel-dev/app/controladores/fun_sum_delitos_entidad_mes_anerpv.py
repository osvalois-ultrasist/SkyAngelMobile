import re
from app.mapper.sum_delitos_entidad_mes_anerpv_mapper import DelitosEntidadAnerpv_mapper
from app.modelos.sum_delitos_entidad_mes_anerpv import DelitosEntidadAnerpv
from app.mapper.sum_delitos_nacional_mes_anerpv_mapper import DelitosNacionalAnerpv_mapper

class DelitosEntidadAnerpv_service():

    def __init__(self):
        self.delitosentidadanerpv_mapper = DelitosEntidadAnerpv_mapper()

    # Función para convertir camelCase a snake_case
    def camel_to_snake(self, json_data):
        return {self.camel_to_snake_key(k): v for k, v in json_data.items()}

    # Convierte una clave camelCase a snake_case
    def camel_to_snake_key(self, key):
        return re.sub(r'(?<!^)(?=[A-Z])', '_', key).lower()

    def insert(self, json):
        ent_mod =  DelitosEntidadAnerpv(
            json['id_entidad'],
            json['anio'],
            json['id_mes'],
            json['conteo_robo_transportista'],
            json['conteo_robo_transportista_acumulado'],
            json['conteo_robo_vehiculos_pesados'],
            json['conteo_robo_vehiculos_ligeros'],
            json['conteo_robo_vehiculos_privados'],
            json['conteo_robo_turno_matutino'],
            json['conteo_robo_turno_madrugada'],
            json['conteo_robo_turno_vespertino'],
            json['conteo_robo_turno_nocturno']

        )
        return self.delitosentidadanerpv_mapper.insert(ent_mod)

    def delete(self, json):
        id_entidad = json['id_entidad'],
        anio = json['anio'],
        id_mes = json['id_mes'],
        conteo_robo_transportista = json['conteo_robo_transportista'],
        conteo_robo_transportista_acumulado = json['conteo_robo_transportista_acumulado'],
        conteo_robo_vehiculos_pesados = json['conteo_robo_vehiculos_pesados'],
        conteo_robo_vehiculos_ligeros = json['conteo_robo_vehiculos_ligeros'],
        conteo_robo_vehiculos_privados = json['conteo_robo_vehiculos_privados'],
        conteo_robo_turno_matutino = json['conteo_robo_turno_matutino'],
        conteo_robo_turno_madrugada = json['conteo_robo_turno_madrugada'],
        conteo_robo_turno_vespertino = json['conteo_robo_turno_vespertino'],
        conteo_robo_turno_nocturno = json['conteo_robo_turno_nocturno']
        
        return self.delitosentidadanerpv_mapper.delete(id_entidad, anio, id_mes, conteo_robo_transportista, conteo_robo_transportista_acumulado, conteo_robo_vehiculos_pesados, conteo_robo_vehiculos_ligeros, conteo_robo_vehiculos_privados, conteo_robo_turno_matutino, conteo_robo_turno_madrugada, conteo_robo_turno_vespertino, conteo_robo_turno_nocturno)

    def select_all(self):
        return self.delitosentidadanerpv_mapper.select_all()

    def select_distinct_entidades(self):
        response = self.delitosentidadanerpv_mapper.select_distinct_entidades()
        response["data"].insert(0,{"value": 0, "label": "TODOS"})
        return response, 200

    def select_vista(self, json):
        # Convertimos las claves del JSON de camelCase a snake_case
        json_snake_case = self.camel_to_snake(json)

        anio = json_snake_case.get('anios')
        id_mes = json_snake_case.get('meses')
        id_entidad = json_snake_case.get('entidades')

        # Verificar si alguna de las listas es nula o está vacía
        if not anio:
            return {"Error": "El campo 'anios' es obligatorio"}, 400
        if not id_mes:
            return {"Error": "El campo 'meses' es obligatorio"}, 400
        if not id_entidad:
            return {"Error": "El campo 'entidades' es obligatorio"}, 400

        # Validar si los elementos en las listas son enteros
        if not all(isinstance(i, int) for i in anio):
            return {"Error": "Todos los valores en 'anios' deben ser enteros"}, 400
        if not all(isinstance(i, int) for i in id_mes):
            return {"Error": "Todos los valores en 'meses' deben ser enteros"}, 400
        if not all(isinstance(i, int) for i in id_entidad):
            return {"Error": "Todos los valores en 'entidades' deben ser enteros"}, 400
        
        # Si 'entidades' contiene 0, no filtramos por municipio y seleccionamos todos
        if len(id_entidad) == 1 and id_entidad[0] == 0:
            id_entidad = None  # Indicar que no se filtrará por entidades

        # Si 'meses' contiene 0, no filtramos por meses y seleccionamos todos
        if len(id_mes) == 1 and id_mes[0] == 0:
            id_mes = None  # Indicar que no se filtrará por meses

        # Si 'anios' contiene 0, no filtramos por anios y seleccionamos todos
        if len(anio) == 1 and anio[0] == 0:
            anio = None  # Indicar que no se filtrará por anios

        del_mun = DelitosEntidadAnerpv(
            id_entidad=id_entidad,
            anio=anio,
            id_mes=id_mes,
            conteo_robo_transportista=None,  # Este campo no está en el POST
            conteo_robo_transportista_acumulado=None, # Este campo no está en el POST
            conteo_robo_vehiculos_pesados=None, # Este campo no está en el POST
            conteo_robo_vehiculos_ligeros=None, # Este campo no está en el POST
            conteo_robo_vehiculos_privados=None, # Este campo no está en el POST
            conteo_robo_turno_matutino=None, # Este campo no está en el POST
            conteo_robo_turno_madrugada=None, # Este campo no está en el POST
            conteo_robo_turno_vespertino=None, # Este campo no está en el POST
            conteo_robo_turno_nocturno=None, # Este campo no está en el POST
        )
        # Llamar a la función de consulta si la validación pasa
        data = self.delitosentidadanerpv_mapper.select_vista(del_mun)
        valor_nacional, status_code = DelitosNacionalAnerpv_mapper().select_nacional(anio,id_mes)
        data[0]["data"]['00000'] = valor_nacional["valorNacional"]
        return data    