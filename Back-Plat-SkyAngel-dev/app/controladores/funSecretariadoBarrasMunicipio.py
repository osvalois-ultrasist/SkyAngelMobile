import json
import pandas as pd
from app.mapper.secretariadoBarrasMunicipioMapper import secretariadoBarrasMunicipioMapper

class secretariadoBarrasMunicipioService():
    
    def __init__(self):
        self.secretariadoBarrasMunicipio = secretariadoBarrasMunicipioMapper()

    def obtenerDatos(self, jsonParametros):
        anios = jsonParametros["años"]
        municipio = jsonParametros["municipio"]
        subtipoDeDelito = jsonParametros["subtipoDeDelito"]
        
        # Obtener los datos del mapper
        responseData, code = self.secretariadoBarrasMunicipio.selectIncidentes(anios, municipio, subtipoDeDelito)

        if code == 200:
            # Convertir la lista de diccionarios a un DataFrame
            df = pd.DataFrame(responseData['sumDelitos'])

            # Seleccionar solo las columnas necesarias: anio, municipio, conteo
            dfSmall = df[["anio", "conteo", "entidad", "cveMunicipio", "municipio"]]
            
            # Agrupar los datos por municipio y sumar los crímenes
            dfTotalCrimenes = dfSmall.groupby(['municipio', 'entidad'])['conteo'].sum().reset_index()
            dfTotalCrimenes = dfTotalCrimenes.sort_values('conteo', ascending=False).head(20)

            # Crear el JSON con el formato solicitado
            result = []
            for _, row in dfTotalCrimenes.iterrows():
                result.append({
                    "municipio": f"{row['municipio']}, {row['entidad']}",
                    "crimenes": int(row['conteo'])
                })
                
            result = {
                'title': 'Delitos en los 20 Municipios con Mayor Siniestralidad',
                'serie': {
                    'dataKey': 'crimenes',
                    'color': '#dc143c',
                    'barWidth': 20,
                    'barSpacing': 5, 
                    'fontSize': 14,
                    'chartWidth': "100%",
                    'chartHeight': "100%",
                    'axisColor': '#000',
                    'yAxisWidth': "90%",
                    'xAxisLabel': 'Número de Crímenes',
                    'scaleType': 'band',
                    'layout': 'horizontal',
                    'grid': { 'vertical': True },
                    'margin': { 'top': 10, 'right': 40, 'bottom': 50, 'left': 200 }
                },
                'data': result
            }

            return json.dumps(result), 200
        
       
