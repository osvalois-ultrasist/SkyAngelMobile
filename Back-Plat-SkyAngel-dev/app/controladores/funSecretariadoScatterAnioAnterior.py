import json
import pandas as pd
from app.mapper.secretariadoScatterAnioAnteriorMapper import secretariadoScatterAnioAnteriorMapper

class secretariadoScatterAnioAnteriorService():
    
    def __init__(self):
        self.secretariadoScatterAnioAnterior = secretariadoScatterAnioAnteriorMapper()

    def obtenerDatos(self, jsonParametros):
        anios = jsonParametros["años"]
        mes = jsonParametros["mes"]
        subtipoDeDelito = jsonParametros["subtipoDeDelito"]

        # Obtener los datos del mapper
        responseData, code = self.secretariadoScatterAnioAnterior.selectIncidentes(anios, mes, subtipoDeDelito)

        if code == 200:
            # Convertir la lista de diccionarios a un DataFrame
            df = pd.DataFrame(responseData['sumDelitos'])

            # Crear un diccionario para organizar los datos por año
            dataDict = {}

            # Iterar por cada año en los datos
            for anio in df['anio'].unique():
                dfAnio = df[df['anio'] == anio]

                # Asegurarse de que los datos estén ordenados por mes
                dfAnioSorted = dfAnio.sort_values(by='mes')

                # Convertir la clave del año a string para evitar el error
                dataDict[str(anio)] = dfAnioSorted['conteo'].tolist()

            # Preparar la lista de años en formato string
            years = [str(anio) for anio in sorted(df['anio'].unique(), reverse=True)]

            # Crear la lista de meses
            months = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]

            # Crear la estructura final
            organizedData = {
                "years": years,
                "months": months,
                "data": dataDict
            }
            
            return json.dumps(organizedData), 200
        else:
            return responseData, code
