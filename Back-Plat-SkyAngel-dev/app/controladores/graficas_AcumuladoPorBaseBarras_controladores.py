import json
import pandas as pd
from app.controladores.serviciosGraficas_controlador import GenerarColores
from app.mapper.graficas_AcumuladoPorBaseBarras_mapper import AcumuladoBarrasPorBaseMapper
from app.modelos.constantes_globales import diccionarioMeses

class AcumuladoBarrasPorBaseService():
    
    def __init__(self):
        self.AcumuladoBarrasPorBase = AcumuladoBarrasPorBaseMapper()

    def obtenerDatos(self, jsonParametros):
        try:
            # Extracción de los parámetros del JSON
            anios = jsonParametros.get("años", [])
            mes = jsonParametros.get("mes", [])
            entidad = jsonParametros.get("entidad", [])
            municipio = jsonParametros.get("municipio", [])

            # Llamar al mapper para obtener los datos de incidentes
            responseData = self.AcumuladoBarrasPorBase.selectIncidentes(anios, mes, entidad, municipio)

            # Transformar los datos en un DataFrame de pandas
            df = pd.DataFrame(responseData['data'])

            # Agrupar los datos por entidad (idEntidad y entidad)
            dfEntidad = df.groupby(['idEntidad', 'entidad']).agg({
                'crimenes_secretariado': 'sum',
                'crimenes_anerpv': 'sum',
                'crimenes_sky': 'sum',
                'total_crimenes': 'sum'
            }).reset_index()

            # Datos de la serie: total de crímenes por entidad
            totales = dfEntidad['total_crimenes'].astype(int).tolist()

            # Datos para la barra apilada por base (secretariado, anerpv, sky)
            bases = ['crimenes_secretariado', 'crimenes_anerpv', 'crimenes_sky']
            por_base = [dfEntidad[base].astype(int).tolist() for base in bases]

            # Etiquetas de las entidades (para el eje X)
            entidades = dfEntidad['entidad'].tolist()

            # Construcción del JSON de salida con la estructura esperada
            organizedData = {
                "title": "Total de delitos por entidad y base",
                "series": [
                    {"label": "Crímenes totales por entidad", "data": totales},
                    {"label": "Crímenes por base", "data": por_base}
                ],
                "colors": {
                    "anual": "#0D125B",
                    "meses": ["#0d125b", "#0e1862", "#101f69"]
                },
                "labels": {
                    "yAxisLabel": "Número de crímenes",
                    "yAxisLabelOffset": 30,
                    "legendHidden": True,
                    "bases": ["sky", "anerpv", "secretariado"],
                    "yearLabels": entidades
                },
                "chartDimensions": {
                    "width": 650,
                    "height": 400
                },
                "chartParams": {
                    "categoryGapRatio": 0.3,
                    "barGapRatio": 0.1,
                    "translateX": "translateX(-10px)",
                    "margin": {"top": 20, "right": 50, "bottom": 20, "left": 50},
                    "width": 500
                }
            }

            # Retorno de los datos organizados con el código de respuesta 200
            return organizedData, 200
        except Exception as e:
            # Si ocurre un error, se retorna un mensaje con código 500
            return {"Error": f"Error del servidor: {str(e)}"}, 500
