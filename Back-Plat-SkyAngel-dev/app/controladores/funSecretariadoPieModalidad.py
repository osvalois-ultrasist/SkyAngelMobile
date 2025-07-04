import json
import pandas as pd
from app.mapper.secretariadoPieModalidadMapper import secretariadoPieModalidadMapper

class secretariadoPieModalidadService():
    
    def __init__(self):
        self.secretariadoPieModalidad = secretariadoPieModalidadMapper()

    def obtenerDatos(self, jsonParametros):
        anios = jsonParametros["años"]
        subtipoDeDelito = jsonParametros["subtipoDeDelito"]
        modalidad = jsonParametros["modalidad"]

        # Obtener los datos del mapper
        responseData, code = self.secretariadoPieModalidad.selectIncidentes(anios, subtipoDeDelito, modalidad)

        if code == 200:
            # Convertir la lista de diccionarios a un DataFrame
            df = pd.DataFrame(responseData['sumDelitos'])

            # Crear un diccionario para almacenar las series
            seriesDict = {}

            # Iterar por cada modalidad (Con Violencia, Sin Violencia, etc.)
            for modalidadTipo in df['modalidad'].unique():
                dfModalidad = df[df['modalidad'] == modalidadTipo]

                # Agrupar por año y sumar el conteo de delitos
                dfGrouped = dfModalidad.groupby('anio')['conteo'].sum().reset_index()

                # Convertir los valores a tipos serializables por JSON (int o float)
                dfGrouped['anio'] = dfGrouped['anio'].astype(int)
                dfGrouped['conteo'] = dfGrouped['conteo'].astype(int)

                # Crear una lista de valores que representan los datos para esa modalidad
                seriesDict[modalidadTipo] = dfGrouped['conteo'].tolist()

            # Preparar la lista de años
            years = sorted([int(anio) for anio in df['anio'].unique()])

            # Crear la estructura final
            organizedData = {
                "years": years,
                "series": [
                    {"label": modalidadTipo, "data": seriesDict[modalidadTipo]}
                    for modalidadTipo in seriesDict
                ]
            }
            
            return json.dumps(organizedData), 200
        else:
            return responseData, code
