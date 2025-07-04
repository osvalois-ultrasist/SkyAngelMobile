import json
import pandas as pd
from app.mapper.secretariadoPieAnualesMapper import secretariadoPieAnualesMapper

class secretariadoPieAnualesService():
    
    def __init__(self):
        self.secretariadoPieAnuales = secretariadoPieAnualesMapper()

    def obtenerDatos(self, jsonParametros):
        anios = jsonParametros["años"]
        
        # Obtener los datos del mapper
        responseData, code = self.secretariadoPieAnuales.selectIncidentes(anios)

        if code == 200:
            # Convertir la lista de diccionarios a un DataFrame
            df = pd.DataFrame(responseData['sumDelitos'])

            # Seleccionar solo las columnas deseadas (anio y conteo)
            dfSmall = df[["anio", "conteo"]]

            # Agrupar por año (anio) y sumar los delitos (conteo)
            dfGrouped = dfSmall.groupby("anio")["conteo"].sum().reset_index()

            # Renombrar columnas: 'anio' como 'label' y 'conteo' como 'value'
            dfGrouped.columns = ["label", "value"]

            # Convertir los valores de 'label' (años) a cadenas de texto
            dfGrouped["label"] = dfGrouped["label"].astype(str)

            # Convertir el DataFrame agrupado en un diccionario con la estructura deseada
            organizedData = dfGrouped.to_dict(orient='records')
            
            # Retornar el JSON organizado
            return json.dumps(organizedData), 200
        else:
            # Retornar el error si el código no es 200
            return responseData, code
