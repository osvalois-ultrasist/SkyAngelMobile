import json
import pandas as pd
from app.controladores.serviciosGraficas_controlador import GenerarColores
from app.mapper.graficas_popCrimesSecMun_mapper import secretariadoBarrasAcumMapperDelMunSel

class secretariadoBarrasAcumServiceDelMunSel():
    
    def __init__(self):
        self.secretariadoBarrasAcumMunDelSel = secretariadoBarrasAcumMapperDelMunSel()

    def obtenerDatos(self, jsonParametros):
        try:

            # Extraer parámetros del JSON
            anios = jsonParametros.get("anio", [])
            municipios = jsonParametros.get("id_municipio",[])
            #entidades = jsonParametros.get("id_entidad", [])
            subTipoDeDelitos = jsonParametros.get("id_subtipo_de_delito", [])
            modalidades = jsonParametros.get("id_modalidad", [])
            

            mapper_params = {
            # Extraer parámetros del JSON
            "anio":  anios,
            "id_municipio" : municipios,
            #"id_entidad" :entidades,
            "id_subtipo_de_delito" :subTipoDeDelitos,
            "id_modalidad" :modalidades,
            
            }
            

            responseData = self.secretariadoBarrasAcumMunDelSel.selectIncidentes(mapper_params)
            
            df = pd.DataFrame(responseData['data'])
            
            # Verificar si el DataFrame está vacío o no tiene datos
            if df.empty or len(responseData['data']) == 0:
                # Crear respuesta con datos vacíos pero estructura válida
                organizedData = {
                    "title": "Sin datos disponibles",
                    "series": [
                        {"label": "Crímenes anuales", "data": []},
                        {"label": "Crímenes por mes", "data": []}
                    ],
                    "colors": {
                        "anual": "#0D125B",
                        "meses": GenerarColores(num_colores=12)
                    },
                    "labels": {
                        "yAxisLabelOffset": 30,
                        "legendHidden": True,
                        "monthLabels": [],
                        "yearLabels": []
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
                return json.dumps(organizedData), 200
            
            # Verificar que existan las columnas necesarias (ahora incluye mes e id_mes)
            required_columns = ['anio', 'conteo', 'subtipoDeDelito', 'mes', 'id_mes']
            missing_columns = [col for col in required_columns if col not in df.columns]
            
            if missing_columns:
                print(f"Columnas faltantes: {missing_columns}")
                print(f"Columnas disponibles: {df.columns.tolist()}")
                # Crear respuesta con datos vacíos
                organizedData = {
                    "title": "Error en estructura de datos",
                    "series": [
                        {"label": "Crímenes anuales", "data": []},
                        {"label": "Crímenes por mes", "data": []}
                    ],
                    "colors": {
                        "anual": "#0D125B",
                        "meses": GenerarColores(num_colores=12)
                    },
                    "labels": {
                        "yAxisLabelOffset": 30,
                        "legendHidden": True,
                        "monthLabels": [],
                        "yearLabels": []
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
                return json.dumps(organizedData), 200

            # extraemos aquí el nombre real del subtipo desde la data
            if 'subtipoDeDelito' in df.columns and not df['subtipoDeDelito'].empty:
                # Tomamos el primer subtipo no vacío
                name_subtipoDeDelito = df['subtipoDeDelito'].dropna().astype(str).str.strip().iloc[0]
            else:
                name_subtipoDeDelito = "General"

            # Ahora incluimos mes e id_mes en el DataFrame pequeño
            dfSmall = df[["anio", "conteo", "mes", "id_mes"]]
    
            dfAnual = dfSmall.groupby('anio')['conteo'].sum().reset_index()
            dfMensual = dfSmall.groupby(['anio', 'mes', 'id_mes'])['conteo'].sum().reset_index()
            
            crimenesAnuales = list(dfAnual['conteo'].astype(int))
            crimenesPorMes = []
            
            # Procesar datos mensuales por año
            for anio in dfMensual['anio'].unique():
                crimenesMensuales = dfMensual[dfMensual['anio'] == anio].sort_values('id_mes')['conteo'].tolist()
                crimenesPorMes.append([int(crimen) for crimen in crimenesMensuales])
            
            mes_labels = list(dfMensual['mes'].astype(str).unique())
            etiquetasAnios = list(dfAnual['anio'].astype(str))

            organizedData = {
                "title": f"Total de {name_subtipoDeDelito} por año y mes",
                "series": [
                    {"label": "Crímenes anuales", "data": crimenesAnuales},
                    {"label": "Crímenes por mes", "data": crimenesPorMes}
                ],
                "colors": {
                    "anual": "#0D125B",
                    "meses": GenerarColores(num_colores=12)
                },
                "labels": {
                    "yAxisLabelOffset": 30,
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
            return json.dumps(organizedData), 200
        except Exception as e:
            print(f"Error: {e}")
            return {"Error": "Error conexión del servidor"}, 500