import json
import pandas as pd
from app.mapper.graficas_fuenteExternaVelas_mapper import fuenteExternaVelasMapper

class funFuenteExternaVelasService:
    
    def __init__(self):
        self.fuenteExternaVelas = fuenteExternaVelasMapper()

    def obtenerDatos(self, jsonParametros):
        anio = jsonParametros["anio"]
        mes = jsonParametros["mes"]
        entidad = jsonParametros["entidad"]
        municipio = jsonParametros["municipio"]

        # Obtener los datos del mapper
        responseData, code = self.fuenteExternaVelas.selectIncidentes(anio, mes, entidad, municipio)

        if code == 200:
            # Convertir la lista de diccionarios a un DataFrame
            df = pd.DataFrame(responseData['sumDelitos'])

            # Verificar que existan datos
            if df.empty:
                return json.dumps({"error": "No se encontraron datos para los parámetros proporcionados"}), 404

            mes_a_numero = {
                "Enero": 1, "Febrero": 2, "Marzo": 3, "Abril": 4,
                "Mayo": 5, "Junio": 6, "Julio": 7, "Agosto": 8,
                "Septiembre": 9, "Octubre": 10, "Noviembre": 11, "Diciembre": 12
            }

            if df['mes'].dtype == 'object':
                df['mes'] = df['mes'].map(mes_a_numero)

            anio_mes_totales = df.groupby(['anio', 'mes'])['conteo'].agg(
                total='sum',
                high='max',
                low='min',
                open='mean'
            ).reset_index()

            anio_mes_totales['close'] = anio_mes_totales['open'].shift(1)
            anio_mes_totales.loc[0, 'close'] = anio_mes_totales.loc[0, 'open']

            meses = [
                "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", 
                "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
            ]

            result = []
            for _, row in anio_mes_totales.iterrows():
                period = f"{meses[int(row['mes']) - 1]} {int(row['anio'])}"
                result.append({
                    "period": period,
                    "high": row['high'],
                    "low": row['low'],
                    "close": row['close'],
                    "open": row['open'],
                    "volume": row['total']
                })

            # Configuración de la gráfica
            chart_config = {
                "width": "100%",
                "height": 400,
                "margins": {"top": 20, "right": 30, "left": 0, "bottom": 0},
                "grid": {"strokeDasharray": "3 3"},
                "bars": [
                    {
                        "dataKey": "openCloseRange",
                        "stackId": "1",
                        "colors": {"positive": "#4caf50", "negative": "#f80000"}
                    },
                    {"dataKey": "highClose", "stackId": "2", "fill": "#25764b"},
                    {"dataKey": "lowClose", "stackId": "2", "fill": "#ffa920"}
                ]
            }

            response = {
                "titulo": "Gráfico de Velas, Nivel Estatal",
                "datos": result,
                "configuracion": chart_config
            }

            return json.dumps(response), 200
        
        else:
            return responseData, code
