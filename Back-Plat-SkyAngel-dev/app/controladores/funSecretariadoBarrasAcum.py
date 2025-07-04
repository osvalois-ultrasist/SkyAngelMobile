import json
import pandas as pd
from app.mapper.secretariadoBarrasAcumMapper import secretariadoBarrasAcumMapper

class secretariadoBarrasAcumService():
    
    def __init__(self):
        self.secretariadoBarrasAcum = secretariadoBarrasAcumMapper()

    def obtenerDatos(self, jsonParametros):
        anios = jsonParametros["años"]
        mes = jsonParametros["mes"]
        subtipoDeDelito = jsonParametros["subtipoDeDelito"]
        
        # Obtener los datos del mapper
        responseData, code = self.secretariadoBarrasAcum.selectIncidentes(anios, mes, subtipoDeDelito)

        if code == 200:
            # Convertir la lista de diccionarios a un DataFrame
            df = pd.DataFrame(responseData['sumDelitos'])
            
            # Seleccionar solo las columnas necesarias: anio, conteo, idMes, mes
            dfSmall = df[["anio", "conteo", "idMes", "mes"]]
            
            # Agrupar los datos por año y sumar los crímenes
            dfAnual = dfSmall.groupby('anio')['conteo'].sum().reset_index()
            
            # Agrupar los datos por mes dentro de cada año
            dfMensual = dfSmall.groupby(['anio', 'mes', 'idMes'])['conteo'].sum().reset_index()
            
            # Formatear los datos de crímenes anuales
            crimenesAnuales = list(dfAnual['conteo'].astype(int))
            
            # Formatear los datos de crímenes por mes (agrupados por año)
            crimenesPorMes = []
            for anio in dfMensual['anio'].unique():
                # Obtener los crímenes por mes para ese año
                crimenesMensuales = dfMensual[dfMensual['anio'] == anio].sort_values('idMes')['conteo'].tolist()
                crimenesPorMes.append([int(crimen) for crimen in crimenesMensuales])
            
            # Crear el JSON de salida con las dos series
            result = {
                "series": [
                    {
                        "label": "Crímenes anuales",
                        "data": crimenesAnuales
                    },
                    {
                        "label": "Crímenes por mes",
                        "data": crimenesPorMes
                    }
                ]
            }
                        
            organizedData = {
                    "title": "Total de Delitos por Año", 
                    "series": [
                        {
                            "label": "Crímenes anuales",
                            "data": crimenesAnuales
                        },
                        {
                            "label": "Crímenes por mes",
                            "data": crimenesPorMes
                        }
                    ],
                    "colors": {
                        "anual": "#ab47bc",  # Morado
                        "meses": ["#ff6384", "#36a2eb", "#cc65fe", "#ffce56", "#ff6384", "#36a2eb", "#cc65fe", "#ffce56", "#ff6384", "#36a2eb", "#cc65fe", "#ffce56"]
                    },
                    "labels": {
                        "yAxisLabel": "Número de crímenes",
                        "monthLabels": ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]
                    },
                    "chartDimensions": {
                        "width": 1400,
                        "height": 400
                    },
                    "chartParams": {
                    "categoryGapRatio": 0.3,
                    "barGapRatio": 0.1,
                    "translateX": -20,
                    "width": '100%',
                }
                }

            return json.dumps(organizedData), 200
        else:
            return responseData, code
