import json
from flask import jsonify
from app.mapper.pendiente_mapper import Mui_barras_mapper


class Mui_barras_service():
    
    def __init__(self):
        self.mui_barras = Mui_barras_mapper()

    def obtener_datos(self, json_parametros):
        # Leer los parámetros
        anios = json_parametros["años"]
        incidencias = json_parametros["incidencias"]
        mes = json_parametros["mes"]
        entidad = json_parametros["entidad"]
        cve_municipio = json_parametros["cve_municipio"]
        municipio = json_parametros["municipio"]
        bien_juridico_afectado = json_parametros["bien_juridico_afectado"]
        tipo_de_delito = json_parametros["tipo_de_delito"]
        subtipo_de_delito = json_parametros["subtipo_de_delito"]
        modalidad = json_parametros["modalidad"]

        # Obtener los datos del mapper
        response_data, code = self.mui_barras.select_incidentes_mui(anios, incidencias, mes, entidad, cve_municipio, municipio
                                                                    , bien_juridico_afectado, tipo_de_delito
                                                                    , subtipo_de_delito, modalidad)

        if code == 200:
            # Trabajar directamente con el diccionario response_data
            organized_data = self.process_crime_data(response_data)
            return json.dumps(organized_data), 200
        else:
            return response_data, code


    def process_crime_data(self, json_data):
        data_by_year = {}

        # Iterar sobre cada incidente en los resultados
        for incidente in json_data["sum_delitos"]:
            anio = incidente["anio"]
            conteo = incidente["conteo"]
            mes = incidente["mes"]
            entidad = incidente["entidad"]
            cve_municipio = incidente["cve_municipio"]
            municipio = incidente["municipio"]
            bien_juridico_afectado = incidente["bien_juridico_afectado"]
            tipo_de_delito = incidente["tipo_de_delito"]
            subtipo_de_delito = incidente["subtipo_de_delito"]
            modalidad = incidente["modalidad"]

            # Organizar los datos por año y mes
            
            # Organizar los datos por año y mes
            if anio not in data_by_year:
                data_by_year[anio] = {}

            if mes not in data_by_year[anio]:
                data_by_year[anio][mes] = {}

            if entidad not in data_by_year[anio][mes]:
                data_by_year[anio][mes][entidad] = {}

            if cve_municipio not in data_by_year[anio][mes][entidad]:
                data_by_year[anio][mes][entidad][cve_municipio] = {}

            if municipio not in data_by_year[anio][mes][entidad][cve_municipio]:
                data_by_year[anio][mes][entidad][cve_municipio][municipio] = {}

            if bien_juridico_afectado not in data_by_year[anio][mes][entidad][cve_municipio][municipio]:
                data_by_year[anio][mes][entidad][cve_municipio][municipio][bien_juridico_afectado] = {}

            if tipo_de_delito not in data_by_year[anio][mes][entidad][cve_municipio][municipio][bien_juridico_afectado]:
                data_by_year[anio][mes][entidad][cve_municipio][municipio][bien_juridico_afectado][tipo_de_delito] = {}

            if subtipo_de_delito not in data_by_year[anio][mes][entidad][cve_municipio][municipio][bien_juridico_afectado][tipo_de_delito]:
                data_by_year[anio][mes][entidad][cve_municipio][municipio][bien_juridico_afectado][tipo_de_delito][subtipo_de_delito] = {}

            # Finalmente, se guarda el conteo en la modalidad
            data_by_year[anio][mes][entidad][cve_municipio][municipio][bien_juridico_afectado][tipo_de_delito][subtipo_de_delito][modalidad] = conteo

        return data_by_year
