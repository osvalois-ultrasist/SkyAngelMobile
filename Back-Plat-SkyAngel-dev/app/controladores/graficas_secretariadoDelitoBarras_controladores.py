import pandas as pd
from app.mapper.graficas_secretariadoDelitoBarras_mapper import secretariadoBarrasDelitoMapper

class secretariadoBarrasDelitoService(): 
    
    def __init__(self):
        self.secretariadoBarrasDelito = secretariadoBarrasDelitoMapper()

    def obtenerDatos(self, jsonParametros):
        try:
            anios = jsonParametros["años"]
            mes = jsonParametros["mes"]
            entidad = jsonParametros["entidad"]
            municipio = jsonParametros["municipio"]
            bienJuridicoAfectado = jsonParametros["bienJuridicoAfectado"]
            tipoDeDelito = jsonParametros["tipoDeDelito"]
            subtipoDeDelito = jsonParametros["subtipoDeDelito"]
            modalidad = jsonParametros["modalidad"]

            # Obtener los datos del mapper
            data = self.secretariadoBarrasDelito.selectIncidentes(anios, mes, entidad, municipio, bienJuridicoAfectado, tipoDeDelito, subtipoDeDelito, modalidad)
            
            df = pd.DataFrame(data)
            dfSmall = df[["anio", "conteo", "idTipoDelito", "tipoDelito"]]
            dfTotalCrimenes = dfSmall.groupby('tipoDelito')['conteo'].sum().reset_index()
            dfTotalCrimenes = dfTotalCrimenes.sort_values('conteo', ascending=False)

            result = [
                {
                    "tipoDeDelito": row['tipoDelito'],
                    "crimenes": int(row['conteo'])
                } 
                for _, row in dfTotalCrimenes.iterrows()
                ]

            serie = {
                'dataKey': 'crimenes',
                'valueFormatterText': 'crímenes',
                'color': '#1C57AA',
                'barWidth': 20,
                'barSpacing': 5,
                'fontSize': 14,
                'fontColor': '#0D125B',
                'chartWidth': [850],
                'chartHeight': [700],
                'yAxisDataKey': 'tipoDeDelito',
                'yAxisColor': '#0D125B',
                'yAxisWidth': [500],
                'xAxisLabel': 'Número de Crímenes',
                'xAxisColor': '#0D125B',
                'scaleType': 'band',
                'layout': 'horizontal',
                'grid': {'vertical': True},
                'margin': {'top': 20, 'right': 50, 'bottom': 20, 'left': 150}
            }

            return {
                'title': "Tipos de Delito por Municipio", 
                'serie': serie, 
                'data': result
                }
        
        except KeyError as e:
            raise KeyError(f"Parámetro faltante: {str(e)}")
        except ValueError as e:
            raise ValueError(f"Valor inválido: {str(e)}")
        except Exception as e:
            raise Exception(f"Error del servidor: {str(e)}")