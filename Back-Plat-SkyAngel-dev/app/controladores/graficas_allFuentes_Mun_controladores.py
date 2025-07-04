import json
import pandas as pd

from app.mapper.graficas_allFuentes_Mun_mapper import barrasAcumMapperAllFuentesMun


class barrasAcumServiceAllFuentesMun():

    def __init__(self):
        self.allFuentesBarrasAcumMun = barrasAcumMapperAllFuentesMun()

    def obtenerDatos(self, jsonParametros):

        try:

            anios = jsonParametros.get("anio", [])
            municipio = jsonParametros.get("id_municipio", [])

            mapper_params = {

            "anio":  anios,
            "id_municipio" :municipio,
            "id_tipo_de_delito": jsonParametros.get("id_tipo_de_delito", []),
            "id_subtipo_de_delito": jsonParametros.get("id_subtipo_de_delito", [])
            }

            responseData = self.allFuentesBarrasAcumMun.selectIncidentesCombinados(mapper_params)
            

            if "Error" in responseData:
                return json.dumps(responseData), 500
            
            # Verificar si hay datos disponibles
            if not responseData or 'data' not in responseData or not responseData['data']:
                # Crear respuesta con datos vacíos pero estructura válida para TRES FUENTES
                organizedData = {
                    "title": "Sin datos disponibles",
                    "series": [
                        {"label": "Secretariado", "data": []},
                        {"label": "Fuente externa", "data": []},
                        {"label": "Sky", "data": []}
                    ],
                    "colors": {
                        "Secretariado": "#FF99D9", 
                        "Feunte externa": "#99C2FF",
                        "Sky": "#ff336b",
                    },
                    "labels": {
                        "yAxisLabel": "Número de crímenes",
                        "yAxisLabelOffset": 30,
                        "legendHidden": False,
                        "yearLabels": []
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

            df = pd.DataFrame(responseData['data'])

            # Verificar si el DataFrame está vacío o no tiene datos
            if df.empty or len(responseData['data']) == 0:
                # Crear respuesta con datos vacíos pero estructura válida para TRES FUENTES
                organizedData = {
                    "title": "Sin datos disponibles",
                    "series": [
                        {"label": "Secretariado", "data": []},
                        {"label": "Fuente Externa", "data": []},
                        {"label": "Sky", "data": []}
                    ],
                    "colors": {
                        "Secretariado": "#FF99D9", 
                        "Fuente Externa": "#99C2FF",
                        "Sky": "#ff336b",
                    },
                    "labels": {
                        "yAxisLabel": "Número de crímenes",
                        "yAxisLabelOffset": 30,
                        "legendHidden": False,
                        "yearLabels": []
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

            # Verificar que existan las columnas necesarias
            required_columns = ['anio', 'conteo_secretariado', 'conteo_anerpv', 'conteo_sky']
            missing_columns = [col for col in required_columns if col not in df.columns]
            
            if missing_columns:
                print(f"Columnas faltantes: {missing_columns}")
                print(f"Columnas disponibles: {df.columns.tolist()}")
                # Crear respuesta con estructura válida
                organizedData = {
                    "title": "Error en estructura de datos",
                    "series": [
                        {"label": "Secretariado", "data": []},
                        {"label": "Fuente Externa", "data": []},
                        {"label": "Sky", "data": []}
                    ],
                    "colors": {
                        "Secretariado": "#FF99D9", 
                        "Fuente Externa": "#99C2FF",
                        "Sky": "#ff336b",
                    },
                    "labels": {
                        "yAxisLabel": "Número de crímenes",
                        "yAxisLabelOffset": 30,
                        "legendHidden": False,
                        "yearLabels": []
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

            dfAnual = df.groupby('anio')[['conteo_secretariado', 'conteo_anerpv', 'conteo_sky']].sum().reset_index()

            crimenesSecretariado = list(dfAnual['conteo_secretariado'].astype(int))
            crimenesAnerpv = list(dfAnual['conteo_anerpv'].astype(int))
            crimenesSky = list(dfAnual['conteo_sky'].astype(int))
            etiquetasAnios = list(dfAnual['anio'].astype(str))

            organizedData = {
                "title": "Robo a transporte por año (Secretariado vs Fuente Externa vs Sky Angel)",
                "series": [
                    {"label": "Secretariado", "data": crimenesSecretariado},
                    {"label": "Fuente Externa", "data": crimenesAnerpv},
                    {"label": "Sky", "data": crimenesSky}
                ],
                "colors": {
                    "Secretariado": "#FF99D9", 
                    "Fuente Externa": "#99C2FF",
                    "Sky": "#ff336b",     
                },
                "labels": {
                    "yAxisLabel": "Número de crímenes",
                    "yAxisLabelOffset" : 30,
                    "legendHidden": False,
                    "yearLabels": etiquetasAnios
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

                print(f"Error in controller: {e}")
                import traceback
                traceback.print_exc()
                return json.dumps({"Error": "Error procesando la solicitud"}), 500