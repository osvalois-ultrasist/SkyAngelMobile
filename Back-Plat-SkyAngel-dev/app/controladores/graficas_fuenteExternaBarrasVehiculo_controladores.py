import json
import pandas as pd
from app.mapper.graficas_fuenteExternaBarrasVehiculo_mapper import fuenteExternaBarrasVehiculoMapper
from app.controladores.serviciosGraficas_controlador import GenerarColores

class funFuenteExternaBarrasVehiculoService:
    
    def __init__(self):
        self.fuenteExternaBarrasVehiculo = fuenteExternaBarrasVehiculoMapper()

    def obtenerDatos(self, jsonParametros):
        try:
            anio = jsonParametros.get("anio")
            mes = jsonParametros.get("mes")
            entidad = jsonParametros.get("entidad")
            municipio = jsonParametros.get("municipio")

            if not anio or not mes:
                return {"error": "Faltan parámetros obligatorios: 'anio', 'mes', 'entidad' o 'municipio'"}, 400

            responseData, code = self.fuenteExternaBarrasVehiculo.selectIncidentes(anio, mes, entidad, municipio)

            if code != 200:
                return responseData, code

            if 'sumDelitos' not in responseData or not responseData['sumDelitos']:
                return {"error": "No se encontraron datos en 'sumDelitos'"}, 404

            df = pd.DataFrame(responseData['sumDelitos'])

            required_columns = {'mes', 'mesNombre', 'vehiculosPesados', 'vehiculosLigeros', 'vehiculosPrivados'}
            if not required_columns.issubset(df.columns):
                return {"error": "Faltan columnas requeridas en los datos"}, 422

            meses_orden = [
                "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
                "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
            ]
            df['mes'] = pd.Categorical(df['mesNombre'], categories=meses_orden, ordered=True)

            #df_agrupado = df.groupby('mes').sum().sort_index()
            df_agrupado = df.groupby('mes', observed=False).sum().sort_index()


            series = [
                {"label": "PESADOS", "data": df_agrupado['vehiculosPesados'].tolist()},
                {"label": "LIGEROS", "data": df_agrupado['vehiculosLigeros'].tolist()},
                {"label": "PARTICULARES Y OTROS", "data": df_agrupado['vehiculosPrivados'].tolist()}
            ]

            data = {
                "months": meses_orden,
                "series": series,
                "colors": GenerarColores(num_colores=3),
                "height": 300,
                "titulo": "Delitos por Mes y Tipo de Vehículo, Nivel Estatal",
                "maxItems": 12,
                "maxSeries": 10
            }

            return data, 200

        except KeyError as ke:
            return {"error": f"Parámetro faltante o incorrecto: {str(ke)}"}, 400

        except Exception as e:
            return {"error": f"Error interno: {str(e)}"}, 500