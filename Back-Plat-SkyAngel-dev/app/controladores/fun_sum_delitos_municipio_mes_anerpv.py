import re
from app.mapper.sum_delitos_municipio_mes_anerpv_mapper import DelitosMunicipiosAnerpv_mapper
from app.modelos.sum_delitos_municipio_mes_anerpv import DelitosMunicipiosAnerpv
from app.mapper.sum_delitos_nacional_mes_anerpv_mapper import DelitosNacionalAnerpv_mapper

class DelitosMunicipiosAnerpv_service():

    def __init__(self):
        self.delitosmunicipiosanerpv_mapper = DelitosMunicipiosAnerpv_mapper()

    # Función para convertir camelCase a snake_case
    def camel_to_snake(self, json_data):
        return {self.camel_to_snake_key(k): v for k, v in json_data.items()}

    # Convierte una clave camelCase a snake_case
    def camel_to_snake_key(self, key):
        return re.sub(r'(?<!^)(?=[A-Z])', '_', key).lower()

    def insert(self, json):
        ent_mod =  DelitosMunicipiosAnerpv(
            json['cve_municipio'],
            json['anio'],
            json['id_mes'],
            json['conteo_robo_transportista'],
            json['conteo_robo_transportista_acumulado'],
        )
        return self.delitosmunicipiosanerpv_mapper.insert(ent_mod)

    def delete(self, json):
        cve_municipio = json['cve_municipio'],
        anio = json['anio'],
        id_mes = json['id_mes']
        return self.delitosmunicipiosanerpv_mapper.delete(cve_municipio, anio, id_mes)

    def select_all(self):
        return self.delitosmunicipiosanerpv_mapper.select_all()

    def select_distinct_municipios(self):
        response = self.delitosmunicipiosanerpv_mapper.select_distinct_municipios()
        response["data"].insert(0,{"value": 0, "label": "TODOS"})
        return response, 200

    def select_municipios_por_id_entidad(self,id_entidad):
         # Validar si la lista está vacía o es nula
        if not id_entidad:
            return {"Error": "Lista de 'id_entidad' vacia o nula"}, 400
        
        response = self.delitosmunicipiosanerpv_mapper.select_municipios_por_id_entidad(id_entidad)
        response["data"].insert(0,{"value": 0, "label": "TODOS"})        
        return response,200

    def select_municipios_entidad(self):
        response = self.delitosmunicipiosanerpv_mapper.select_municipios_entidad()
        response["data"].insert(0,{"value": 0, "label": "TODOS"})
        return response, 200

    def select_vista(self, json):
        # Convertimos las claves del JSON de camelCase a snake_case
        json_snake_case = self.camel_to_snake(json)

        anio = json_snake_case.get('anios')
        id_mes = json_snake_case.get('meses')
        cve_municipio = json_snake_case.get('municipios')
        id_entidad = json_snake_case.get('entidades')

        # Verificar si alguna de las listas es nula o está vacía
        if not anio:
            return {"Error": "El campo 'anios' es obligatorio"}, 400
        if not id_mes:
            return {"Error": "El campo 'meses' es obligatorio"}, 400
        if not cve_municipio:
            return {"Error": "El campo 'municipios' es obligatorio"}, 400
        if not id_entidad:
            return {"Error": "El campo 'entidades' es obligatorio"}, 400

        # Validar si los elementos en las listas son enteros
        if not all(isinstance(i, int) for i in anio):
            return {"Error": "Todos los valores en 'anios' deben ser enteros"}, 400
        if not all(isinstance(i, int) for i in id_mes):
            return {"Error": "Todos los valores en 'meses' deben ser enteros"}, 400
        if not all(isinstance(i, int) for i in cve_municipio):
            return {"Error": "Todos los valores en 'municipios' deben ser enteros"}, 400
        if not all(isinstance(i, int) for i in id_entidad):
            return {"Error": "Todos los valores en 'entidades' deben ser enteros"}, 400
        
        # Si 'entidades' contiene 0, no filtramos por municipio y seleccionamos todos
        if len(id_entidad) == 1 and id_entidad[0] == 0:
            id_entidad = None  # Indicar que no se filtrará por entidades

        # Si 'municipios' contiene 0, no filtramos por municipio y seleccionamos todos
        if len(cve_municipio) == 1 and cve_municipio[0] == 0:
            cve_municipio = None  # Indicar que no se filtrará por municipios

        # Si 'meses' contiene 0, no filtramos por meses y seleccionamos todos
        if len(id_mes) == 1 and id_mes[0] == 0:
            id_mes = None  # Indicar que no se filtrará por meses

        # Si 'anios' contiene 0, no filtramos por anios y seleccionamos todos
        if len(anio) == 1 and anio[0] == 0:
            anio = None  # Indicar que no se filtrará por anios

        del_mun = {
            'anio': anio,
            'id_mes': id_mes,
            'cve_municipio': cve_municipio,
            'id_entidad': id_entidad,
        }
        # Llamar a la función de consulta si la validación pasa
        data = self.delitosmunicipiosanerpv_mapper.select_vista(del_mun)
        valor_nacional, status_code = DelitosNacionalAnerpv_mapper().select_nacional(anio,id_mes)
        data[0]["data"]['00000'] = valor_nacional["valorNacional"]
        return data
