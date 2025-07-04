import json
import pandas as pd

from app.mapper.graficas_popCrimesAllEst_mapper import barrasMapperAllFuentesEntidad


class barrasServiceAllFuentesEntidad():

    def __init__(self):
        self.allFuentesBarrasEntidad = barrasMapperAllFuentesEntidad()

    def obtenerDatos(self, jsonParametros):

        try:

            anios = jsonParametros.get("anio", [])
            entidad = jsonParametros.get("id_entidad", [])

            mapper_params = {

            "anio":  anios,
            "id_entidad" :entidad,
            "id_tipo_de_delito": jsonParametros.get("id_tipo_de_delito", []),
            "id_subtipo_de_delito": jsonParametros.get("id_subtipo_de_delito", [])
            }

            responseData = self.allFuentesBarrasEntidad.selectIncidentesCombinados(mapper_params)
            

            if "Error" in responseData:
                return json.dumps(responseData), 500
            if not responseData or 'data' not in responseData or not responseData['data']:
                 return json.dumps({"message": "No data found for the specified criteria"}), 404


            df = pd.DataFrame(responseData['data'])


            dfAnual = df.groupby('anio')[['conteo_secretariado', 'conteo_anerpv', 'conteo_sky']].sum().reset_index()


            crimenesSecretariado = list(dfAnual['conteo_secretariado'].astype(int))
            crimenesAnerpv = list(dfAnual['conteo_anerpv'].astype(int))
            crimenesSky = list(dfAnual['conteo_sky'].astype(int))
            etiquetasAnios = list(dfAnual['anio'].astype(str))

            organizedData = {
                "title": "Robo a transporte por año (Secretariado vs Fuente externa vs Sky angel)",
                "series": [
                    {"label": "Secretariado", "data": crimenesSecretariado},
                    {"label": "Fuente externa", "data": crimenesAnerpv},
                    {"label": "Sky", "data": crimenesSky}
                ],
                "colors": {
                    "Secretariado": "#FF99D9", 
                    "Fuente externa": "#99C2FF",
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