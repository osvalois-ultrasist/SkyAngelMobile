import pandas as pd
from app.mapper.graficas_reaccionesCentralBarras_mapper import reaccionesBarrasCentralMapper

class funreaccionesCentralBarrasService():

    def __init__(self):
        self.reaccionesBarrasCentral = reaccionesBarrasCentralMapper()

    def obtenerDatos(self, jsonParametros):
        try:
            anios = jsonParametros["años"]
            mes = jsonParametros["meses"]
            entidad = jsonParametros["entidades"]
            municipio = jsonParametros["municipios"]
            categoria = jsonParametros["categoria"]

            if not all([anios, mes, entidad, municipio, categoria]):
                raise ValueError("Todos los parámetros son obligatorios.")

            # Obtener los datos del mapper
            data = self.reaccionesBarrasCentral.selectIncidentes(anios, mes, entidad, municipio, categoria)

            if not data:
                return {"error": "No se encontraron datos con los parámetros proporcionados."}, 404

            # Transformar datos
            result = [
                {
                    "central": row["central"],
                    "crimenes": row["conteo"]
                }
                for row in data
            ]

            # Configuración de la serie
            serie = {
                'dataKey': 'crimenes',
                'valueFormatterText': 'crímenes',
                'color': '#1c57aa',
                'barWidth': 20,
                'barSpacing': 5,
                'fontSize': 10,
                'fontColor': '#0D125B',
                'chartWidth': [700],
                'chartHeight': [300],
                # 'yAxisDataKey': [item["central"] for item in result],
                'yAxisDataKey': "central",
                'yAxisColor': '#0D125B',
                'yAxisWidth': [500],
                'xAxisLabel': 'Número de Crímenes por Central',
                'xAxisColor': '#0D125B',
                'scaleType': 'band',
                'layout': 'horizontal',
                'grid': {'vertical': True},
                'margin': {'top': 20, 'right': 50, 'bottom': 20, 'left': 280}
            }

            return {
                "title": "Total de delitos por central",
                "serie": serie,
                "data": result
            }, 200

        except KeyError as e:
            return {"error": f"Parámetro faltante: {str(e)}"}, 400
        except ValueError as e:
            return {"error": f"Valor inválido: {str(e)}"}, 400
        except Exception as e:
            return {"error": f"Error del servidor: {str(e)}"}, 500
