import json
import pandas as pd
from app.controladores.serviciosGraficas_controlador import GenerarColores
from app.mapper.graficas_popCrimesFeMun_mapper import barrasMunMapperAnerpv
from app.modelos.constantes_globales import diccionarioMeses

class barrasAcumServiceMunSelAnerpv():
    
    def __init__(self):
        self.AnerpvBarrasMunAcum = barrasMunMapperAnerpv()

    def obtenerDatos(self, jsonParametros):
        
        try:
            # Extraer parámetros del JSON
            anios = jsonParametros.get("anio", [])
            municipio = jsonParametros.get("cve_municipio", [])

            mapper_params = {
            # Extraer parámetros del JSON
            "anio":  anios,
            "cve_municipio" :municipio,
            }
    
            responseData = self.AnerpvBarrasMunAcum.selectIncidentes(mapper_params)
            
            df = pd.DataFrame(responseData['data'])

            dfSmall = df[["anio", "conteo", "mes", "id_mes"]]
    
            dfAnual = dfSmall.groupby('anio')['conteo'].sum().reset_index()
            dfMensual = dfSmall.groupby(['anio', 'mes', 'id_mes'])['conteo'].sum().reset_index()
            
            crimenesAnuales = list(dfAnual['conteo'].astype(int))
            crimenesPorMes = []
            mes_labels = list(dfMensual['mes'].astype(str).unique())

            for anio in dfMensual['anio'].unique():
                crimenesMensuales = dfMensual[dfMensual['anio'] == anio].sort_values('id_mes')['conteo'].tolist()
                crimenesPorMes.append([int(crimen) for crimen in crimenesMensuales])
            mes_labels = list(dfMensual['mes'].astype(str).unique())
            etiquetasAnios = list(dfAnual['anio'].astype(str))


            organizedData = {
                "title": "Total de delitos por año y mes",
                "series": [
                    {"label": "Crímenes anuales", "data": crimenesAnuales},
                    {"label": "Crímenes por mes", "data": crimenesPorMes}
                ],
                "colors": {
                    "anual": "#0D125B",
                    "meses": GenerarColores(num_colores=12)
                },
                "labels": {
                    "yAxisLabelOffset" : 30,
                    "legendHidden": True,
                    "monthLabels": mes_labels,
                    "yearLabels": etiquetasAnios
                },
                "chartDimensions": {
                    "width": 850,
                    "height": 300
                },
                "chartParams": {
                    "categoryGapRatio": 0.3,
                    "barGapRatio": 0.1,
                    "translateX": "translateX(-10px)",
                    "margin": {"top": 20, "right": 50, "bottom": 20, "left": 50},
                    "width": 500,
                }
            }
            #print(organizedData)
            return json.dumps(organizedData), 200
        except Exception as e:
            print(f"Error en controlador: {e}")
            return {"Error": "Error conexión del servidor"}, 500