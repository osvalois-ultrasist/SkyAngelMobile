import json
from app.mapper.secretariadoBarrasMapper import muiBarrasMapper


class funSecretariadoBarrasService():
    
    def __init__(self):
        self.muiBarras = muiBarrasMapper()
        self.diccionarioMeses = {'1':'Enero', '2':'Febrero', '3':'Marzo', '4':'Abril', '5':'Mayo', '6':'Junio', '7':'Julio', '8':'Agosto', '9':'Septiembre', '10':'Octubre', '11':'Noviembre', '12':'Diciembre'}

    def obtenerDatos(self, jsonParametros):
        """
        Este método hace, que resuelve, que utiliza
        """# Leer los parámetros 
        anios = jsonParametros["años"]
        mes = jsonParametros["mes"]
        incidencias = jsonParametros["incidencias"]
        municipios = jsonParametros["municipios"]

        # Obtener los datos del mapper
        responseData, code = self.muiBarras.selectIncidentesMui(anios, mes, incidencias, municipios)

        if code == 200:
            organizedData = self.processCrimeData(responseData)
            return json.dumps(organizedData), 200
        else:
            return responseData, code


    def processCrimeData(self, jsonData):
        data = {'xAxisParam' : [{ 'scaleType': 'band', 'dataKey': 'mes' }]}
        dataByYear = {}

        # Iterar sobre cada incidente en los resultados
        for incidente in jsonData["sumDelitos"]:
            anio = incidente["anio"]
            mes = incidente["idMes"]
            conteo = incidente["conteo"]

            # Organizar los datos por año y mes
            if anio not in dataByYear:
                dataByYear[anio] = {}

            if mes not in dataByYear[anio]:
                dataByYear[anio][mes] = conteo
            
            else:
                dataByYear[anio][mes] += conteo

        data = {
            'xAxisParam' : { 'scaleType': 'band', 'dataKey': 'mes' },
            'yAxisParam': {'label': 'Número de delitos'},
            'mesNombre': self.diccionarioMeses,
            'data': dataByYear,
            'width': [1200],
            'height': [400],
            'color': '#fad0e1',
            'fontSize': 20,
            'fontFamily': 'Verdana'
            }        
        
        return data