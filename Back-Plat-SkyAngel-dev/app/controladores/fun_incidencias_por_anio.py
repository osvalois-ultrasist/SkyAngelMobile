import json
from app.mapper.incidencias_por_anio_mapper import Incidencias_por_anio_mapper

class Incidencias_por_anio_service():

    def __init__(self):
        self.incidencias_por_anio = Incidencias_por_anio_mapper()
        
        
    def grafica(self, json_parametros):
        # Leer los parámetros del JSON
        anios = json_parametros["años"]
        mes = json_parametros["mes"]
        incidencias = json_parametros["incidencias"]
        municipios = json_parametros["municipios"]

        # Obtener los datos del mapper
        response_data, code = self.incidencias_por_anio.select_incidentes(anios, mes, incidencias, municipios)

        if code == 200:
            # Procesar los datos para organizarlos por año y mes
            organized_data = self.process_crime_data(response_data)
            return json.dumps(organized_data), 200
        else:
            return response_data, code


    def process_crime_data(self, json_data):
        data_by_year = {}

        # Iterar sobre cada incidente en los resultados
        for incidente in json_data["sum_delitos"]:
            anio = incidente["anio"]
            mes = incidente["id_mes"]
            conteo = incidente["conteo"]

            # Organizar los datos por año y mes
            if anio not in data_by_year:
                data_by_year[anio] = {}
            if mes not in data_by_year[anio]:
                data_by_year[anio][mes] = conteo
            else:
                data_by_year[anio][mes] += conteo

        return data_by_year
