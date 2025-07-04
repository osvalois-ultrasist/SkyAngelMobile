import pandas as pd
from app.mapper.graficas_reaccionesEstadoBarras_mapper import reaccionesBarrasEstadoMapper
from app.modelos.constantes_globales import diccionarioEstados

class funreaccionesBarrasService():

    def __init__(self):
        self.reaccionesBarrasEstado = reaccionesBarrasEstadoMapper()

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
            data = self.reaccionesBarrasEstado.selectIncidentes(anios, mes, entidad, municipio, categoria)

            if not data:
                return {"error": "No se encontraron datos con los parámetros proporcionados."}, 404

            # Crear un DataFrame con los datos obtenidos
            df = pd.DataFrame(data)

            # Agrupar los datos por entidad y calcular el total de crímenes
            df_small = df[["anio", "conteo", "idEntidad"]]
            df_total_crimenes = df_small.groupby('idEntidad')['conteo'].sum().reset_index()
            df_total_crimenes = df_total_crimenes.sort_values('conteo', ascending=False)

            # Formatear los resultados reemplazando IDs con nombres de entidades
            result = [
                {
                    "entidad": diccionarioEstados.get(str(row['idEntidad']), "Desconocida"),
                    "crimenes": int(row['conteo'])
                }
                for _, row in df_total_crimenes.iterrows()
            ]

            # Formatear la configuración del gráfico
            serie = {
                'dataKey': 'crimenes',
                'valueFormatterText': 'crímenes',
                'color': '#1c57aa',
                'barWidth': 20,
                'barSpacing': 5,
                'fontSize': 10,
                'fontColor': '#0D125B',
                'chartWidth': [700],
                'chartHeight': [500], 
                # 'yAxisDataKey': [diccionarioEstados.get(str(i), "Desconocida") for i in entidad],
                'yAxisDataKey': "entidad",
                'yAxisColor': '#0D125B',
                'yAxisWidth': [500],
                'xAxisLabel': 'Número de Crímenes',
                'xAxisColor': '#0D125B',
                'scaleType': 'band',
                'layout': 'horizontal',
                'grid': {'vertical': True},
                'margin': {'top': 20, 'right': 50, 'bottom': 20, 'left': 280}
            }

            # Retornar la respuesta con los datos procesados
            return {
                'title': "Total de delitos por Entidad Federativa",
                'serie': serie,
                'data': result
            }, 200

        except KeyError as e:
            return {"error": f"Parámetro faltante: {str(e)}"}, 400
        except ValueError as e:
            return {"error": f"Valor inválido: {str(e)}"}, 400
        except Exception as e:
            return {"error": f"Error del servidor: {str(e)}"}, 500
