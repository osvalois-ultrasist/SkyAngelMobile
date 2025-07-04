import pandas as pd
from app.mapper.graficas_reaccionesDelitoBarras_mapper import reaccionesBarrasDelitoMapper

class reaccionesBarrasDelitoService():
    
    def __init__(self):
        self.reaccionesBarrasDelito = reaccionesBarrasDelitoMapper()

    def obtenerDatos(self, jsonParametros):
        try:
            anios = jsonParametros["años"]
            mes = jsonParametros["meses"]
            entidad = jsonParametros["entidades"]
            municipio = jsonParametros["municipios"]
            idCategoria = jsonParametros["idCategoria"]

            # Obtener los datos del mapper
            data = self.reaccionesBarrasDelito.selectIncidentes(anios, mes, entidad, municipio, idCategoria)
            
            if not data:
                return {
                    'title': "Número de Crímenes por Categoría", 
                    'serie': {}, 
                    'data': []
                }
            
            df = pd.DataFrame(data)
            dfSmall = df[["categoria", "conteo"]]  # Solo necesitamos estas columnas
            dfTotalCrimenes = dfSmall.groupby('categoria')['conteo'].sum().reset_index()
            dfTotalCrimenes = dfTotalCrimenes.sort_values('conteo', ascending=False)

            result = [
                {
                    "categoria": row['categoria'],
                    "crimenes": int(row['conteo'])
                } 
                for _, row in dfTotalCrimenes.iterrows()
            ]

            serie = {
                'dataKey': 'crimenes',
                'valueFormatterText': 'crímenes',
                'color': '#1c57aa',
                'barWidth': 20,
                'barSpacing': 5,
                'fontSize': 7,
                'fontColor': '#0D125B',
                'chartWidth': [700],
                'chartHeight': [700],
                'yAxisDataKey': 'categoria',
                'yAxisColor': '#0D125B',
                'yAxisWidth': [500],
                'xAxisLabel': 'Número de Crímenes por Categoría',
                'xAxisColor': '#0D125B',
                'scaleType': 'band',
                'layout': 'horizontal',
                'grid': {'vertical': True},
                'margin': {'top': 20, 'right': 50, 'bottom': 20, 'left': 280}
            }

            return {
                'title': "Número de Crímenes por Categoría", 
                'serie': serie, 
                'data': result
            }
        
        except KeyError as e:
            raise KeyError(f"Parámetro faltante: {str(e)}")
        except ValueError as e:
            raise ValueError(f"Valor inválido: {str(e)}")
        except Exception as e:
            raise Exception(f"Error del servidor: {str(e)}")