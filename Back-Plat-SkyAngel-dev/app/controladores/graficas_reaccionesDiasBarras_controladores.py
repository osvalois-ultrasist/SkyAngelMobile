import pandas as pd
from app.mapper.graficas_reaccionesDiasBarras_mapper import reaccionesBarrasDiasMapper

class funreaccionesDiasBarrasService():

    def __init__(self):
        self.reaccionesBarrasDias = reaccionesBarrasDiasMapper()

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
            data = self.reaccionesBarrasDias.selectIncidentes(anios, mes, entidad, municipio, categoria)

            if not data:
                return {"error": "No se encontraron datos con los parámetros proporcionados."}, 404

            # Convertir los días de número a nombre
            dias_semana = {
                1: "Lunes", 2: "Martes", 3: "Miércoles", 4: "Jueves",
                5: "Viernes", 6: "Sábado", 7: "Domingo"
            }

            # Transformar datos
            result = [
            {
                "dia": row["dia"],
                "crimenes": row["conteo"]
            }
            for row in data
                    ]
            
            orden_dias = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"]
            # Ordenar el resultado según el orden de la semana
            result = sorted(result,key=lambda x: orden_dias.index(x["dia"]) if x["dia"] in orden_dias else 99)

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
                # 'yAxisDataKey': [item["dia"] for item in result],
                'yAxisDataKey': "dia",
                'yAxisColor': '#0D125B',
                'yAxisWidth': [500],
                'xAxisLabel': 'Número de Crímenes por Día',
                'xAxisColor': '#0D125B',
                'scaleType': 'band',
                'layout': 'horizontal',
                'grid': {'vertical': True},
                'margin': {'top': 20, 'right': 50, 'bottom': 20, 'left': 100}
            }

            return {
                "title": "Total de delitos por día de la semana",
                "serie": serie,
                "data": result
            }, 200

        except KeyError as e:
            return {"error": f"Parámetro faltante: {str(e)}"}, 400
        except ValueError as e:
            return {"error": f"Valor inválido: {str(e)}"}, 400
        except Exception as e:
            return {"error": f"Error del servidor: {str(e)}"}, 500