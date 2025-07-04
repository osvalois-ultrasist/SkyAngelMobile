import json
import pandas as pd
from app.controladores.serviciosGraficas_controlador import GenerarColores
from app.mapper.graficas_popCrimesSecEst_mapper import secretariadoBarrasAcumMapperDelMun

class secretariadoBarrasAcumServiceDelMun():
    
    def __init__(self):
        self.secretariadoBarrasAcumMunDel = secretariadoBarrasAcumMapperDelMun()

    def obtenerDatos(self, jsonParametros):
        try:

            # Extraer parámetros del JSON
            anios = jsonParametros.get("anio", [])
            #municipios = jsonParametros.get("id_municipio",[])
            entidades = jsonParametros.get("id_entidad", [])
            tipoDeDelitos = jsonParametros.get("id_tipo_de_delito", [])
            modalidades = jsonParametros.get("id_modalidad", [])

            name_subtipoDeDelito = jsonParametros.get("subtipoDeDelito", [])

            
            mapper_params = {
            # Extraer parámetros del JSON
            "anio":  anios,
            #"id_municipio" : municipios,
            "id_entidad" :entidades,
            "id_tipo_de_delito" :tipoDeDelitos,
            "id_modalidad" :modalidades,
            
            }
            #print("El subtipo es:", name_subtipoDeDelito)

            #if anios == [0]:
            #   anios = []  # Mapper tratará el caso como "todos los años

            responseData = self.secretariadoBarrasAcumMunDel.selectIncidentes(mapper_params)
            df = pd.DataFrame(responseData['data'])

            # extraemos aquí el nombre real del subtipo desde la data
            if not df.empty and 'subtipoDeDelito' in df.columns:
                # Tomamos el primer subtipo no vacío
                name_subtipoDeDelito = df['subtipoDeDelito'].dropna().astype(str).str.strip().iloc[0]
            else:
                name_subtipoDeDelito = "General"

            dfSmall = df[["anio", "conteo"]]
    
            dfAnual = dfSmall.groupby('anio')['conteo'].sum().reset_index()
            
            crimenesAnuales = list(dfAnual['conteo'].astype(int))
            etiquetasAnios = list(dfAnual['anio'].astype(str))

            organizedData = {

                "title": f"Total de crímenes tipo de {name_subtipoDeDelito}",

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
        except Exception as e:
            print(f"Error: {e}")
            return {"Error": "Error conexión del servidor"}, 500