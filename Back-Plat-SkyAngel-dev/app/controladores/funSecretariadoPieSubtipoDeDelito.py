import json
import pandas as pd
from app.mapper.secretariadoPieSubtipoDeDelitoMapper import secretariadoPieSubtipoDeDelitoMapper

class secretariadoPieSubtipoDeDelitoService():
    
    def __init__(self):
        self.secretariadoPieSubtipoDeDelito = secretariadoPieSubtipoDeDelitoMapper()

    def obtenerDatos(self, jsonParametros):
        anios = jsonParametros["años"]
        subtipoDeDelito = jsonParametros["subtipoDeDelito"]

        # Obtener los datos del mapper
        responseData, code = self.secretariadoPieSubtipoDeDelito.selectIncidentes(anios, subtipoDeDelito)

        if code == 200:
            # Convertir la lista de diccionarios a un DataFrame
            df = pd.DataFrame(responseData['sumDelitos'])

            # Agrupar los datos por año y sumar los delitos para cada año
            dfGrouped = df.groupby('anio')['conteo'].sum().reset_index()

            # Renombrar las columnas para ajustarse al formato de salida
            dfGrouped.columns = ['label', 'value']

            # Convertir los valores de 'label' a cadenas de texto
            dfGrouped['label'] = dfGrouped['label'].astype(str)

            # Convertir el DataFrame agrupado a un diccionario de listas
            organizedData = dfGrouped.to_dict(orient='records')
            
            return json.dumps(organizedData), 200
        else:
            return responseData, code
