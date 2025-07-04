import json
import pandas as pd
from app.controladores.serviciosGraficas_controlador import GenerarColores
from app.mapper.graficas_secretariadoAcumBarras_mapper_TAT import secretariadoBarrasAcumMapperTaT
from app.modelos.constantes_globales import diccionarioMeses

class secretariadoBarrasAcumServiceTaT():
    
    def __init__(self):
        self.secretariadoBarrasAcum = secretariadoBarrasAcumMapperTaT()

    def obtenerDatos(self, jsonParametros):
        
        try:
            # Extraer parámetros del JSON
            anios = jsonParametros.get("anio", [])
            entidades = jsonParametros.get("id_entidad", [])
            tipoDeDelitos = jsonParametros.get("id_tipo_de_delito", [])
            subtipoDeDelitos = jsonParametros.get("id_subtipo_de_delito", [])
            modalidades = jsonParametros.get("id_modalidad", [])

            mapper_params = {
            # Extraer parámetros del JSON
            "anio":  anios,
            "id_entidad" :entidades,
            "id_tipo_de_delito" :tipoDeDelitos,
            "id_modalidad" :modalidades,
            "id_subtipo_de_delito" : subtipoDeDelitos
            }

            if 17 in tipoDeDelitos: #Para feminicidio
                    
                responseData = self.secretariadoBarrasAcum.selectIncidentes(mapper_params)
                
                df = pd.DataFrame(responseData['data'])

                dfSmall = df[["anio", "conteo"]]
        
                dfAnual = dfSmall.groupby('anio')['conteo'].sum().reset_index()
                
                crimenesAnuales = list(dfAnual['conteo'].astype(int))
                etiquetasAnios = list(dfAnual['anio'].astype(str))

                organizedData = {
                    "title": "Total de feminicidios por año",
                    "series": [
                        {"label": "Crímenes anuales", "data": crimenesAnuales},
                    ],
                    "colors": {
                        "anual": "#FF99D9",
                    },
                    "labels": {
                        "yAxisLabel": "Número de crímenes",
                        "yAxisLabelOffset" : 30,
                        "legendHidden": True,
                        "yearLabels": etiquetasAnios  # Usar etiquetas correctas de años
                    },
                    "chartDimensions": {
                        "width": 550,
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
                return json.dumps(organizedData), 200
            
            elif 19 in tipoDeDelitos: #Para homicidios
                    
                responseData = self.secretariadoBarrasAcum.selectIncidentes(mapper_params)
                
                df = pd.DataFrame(responseData['data'])

                dfSmall = df[["anio", "conteo"]]
        
                dfAnual = dfSmall.groupby('anio')['conteo'].sum().reset_index()
                
                crimenesAnuales = list(dfAnual['conteo'].astype(int))
                etiquetasAnios = list(dfAnual['anio'].astype(str))

                organizedData = {
                    "title": "Total de Homicidios por año",
                    "series": [
                        {"label": "Crímenes anuales", "data": crimenesAnuales},
                    ],
                    "colors": {
                        "anual": "#ff5733",
                    },
                    "labels": {
                        "yAxisLabel": "Número de crímenes",
                        "yAxisLabelOffset" : 30,
                        "legendHidden": True,
                        "yearLabels": etiquetasAnios  # Usar etiquetas correctas de años
                    },
                    "chartDimensions": {
                        "width": 550,
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
                return json.dumps(organizedData), 200
            
            elif 33 in tipoDeDelitos: #Para robo a transporte
                    
                responseData = self.secretariadoBarrasAcum.selectIncidentes(mapper_params)
                
                df = pd.DataFrame(responseData['data'])

                dfSmall = df[["anio", "conteo"]]
        
                dfAnual = dfSmall.groupby('anio')['conteo'].sum().reset_index()
                
                crimenesAnuales = list(dfAnual['conteo'].astype(int))
                etiquetasAnios = list(dfAnual['anio'].astype(str))

                organizedData = {
                    "title": "Total de robo a transportista por año",
                    "series": [
                        {"label": "Crímenes anuales", "data": crimenesAnuales},
                    ],
                    "colors": {
                        "anual": "#33c4ff",
                    },
                    "labels": {
                        "yAxisLabel": "Número de crímenes",
                        "yAxisLabelOffset" : 30,
                        "legendHidden": True,
                        "yearLabels": etiquetasAnios  # Usar etiquetas correctas de años
                    },
                    "chartDimensions": {
                        "width": 550,
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
                return json.dumps(organizedData), 200
        except Exception as e:
            print(f"Error: {e}")
            return {"Error": "Error conexión del servidor"}, 500