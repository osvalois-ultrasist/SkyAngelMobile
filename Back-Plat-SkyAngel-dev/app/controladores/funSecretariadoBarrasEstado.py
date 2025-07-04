import json
import pandas as pd
from app.mapper.secretariadoBarrasEstadoMapper import secretariadoBarrasEstadoMapper

class secretariadoBarrasEstadoService():
    
    def __init__(self):
        self.secretariadoBarrasEstado = secretariadoBarrasEstadoMapper()

    def obtenerDatos(self, jsonParametros):
        anios = jsonParametros["años"]
        entidad = jsonParametros["entidad"]
        subtipoDeDelito = jsonParametros["subtipoDeDelito"]
        
        # Obtener los datos del mapper
        responseData, code = self.secretariadoBarrasEstado.selectIncidentes(anios, entidad, subtipoDeDelito)

        if code == 200:
            # Convertir la lista de diccionarios a un DataFrame
            df = pd.DataFrame(responseData['sumDelitos'])
            
            # Seleccionar solo las columnas necesarias: anio, entidad, conteo
            dfSmall = df[["anio", "conteo", "idEntidad", "entidad"]]
            
            # Agrupar los datos por entidad y sumar los crímenes
            dfTotalCrimenes = dfSmall.groupby('entidad')['conteo'].sum().reset_index()
            dfTotalCrimenes = dfTotalCrimenes.sort_values('conteo', ascending=False)
            
            # Crear el JSON con el formato solicitado
            result = []
            for _, row in dfTotalCrimenes.iterrows():
                result.append({
                    "entidad": row['entidad'],  # Estados
                    "crimenes": int(row['conteo'])  # Conteo de crímenes
                })
                
            title = "Delitos por Estado"

            # Agregar todas las configuraciones parametrizadas en 'serie'
            serie = {
                'dataKey': 'crimenes',
                'color': '#ab47bc',
                'fontSize': 14,
                'chartWidth': [850],
                'chartHeight': [700],
                'axisColor': '#000',
                'yAxisWidth': [500],
                'xAxisLabel': 'Número de Crímenes',
                'scaleType': 'band',
                'layout': 'horizontal',
                'grid': { 'vertical': True },
                'margin': { 'top': 10, 'right': 40, 'bottom': 50, 'left': 200 }
            }
            
            return json.dumps({'title': title, 'serie': serie, 'data': result}), 200
  
        
        else:
            return responseData, code
