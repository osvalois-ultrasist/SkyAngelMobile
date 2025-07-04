import json
import pandas as pd
from app.mapper.graficas_fuenteExternaBarrasHorario_mapper import fuenteExternaBarrasHorarioMapper
from app.controladores.serviciosGraficas_controlador import GenerarColores

class funFuenteExternaBarrasHorarioService:
    
    def __init__(self):
        self.fuenteExternaBarrasHorario = fuenteExternaBarrasHorarioMapper()

    def obtenerDatos(self, jsonParametros):
        try:
            # Validar parámetros de entrada
            anio = jsonParametros.get("anio")
            mes = jsonParametros.get("mes")
            entidad = jsonParametros.get("entidad")
            municipio = jsonParametros.get("municipio")

            if not anio or not mes:
                return {"error": "Faltan parámetros obligatorios: 'anio', 'mes', 'entidad' o 'municipio'"}, 400

            # Llamar al mapper para obtener los datos
            responseData, code = self.fuenteExternaBarrasHorario.selectIncidentes(anio, mes, entidad, municipio)

            if code != 200:
                return responseData, code

            if not responseData.get("sumDelitos"):
                return {"error": "No se encontraron datos en 'sumDelitos'"}, 404

            df = pd.DataFrame(responseData['sumDelitos'])

            # Comprobar que las columnas requeridas existen en el DataFrame
            required_columns = {'mesNombre', 'turnoMatutino', 'turnoMadrugada', 'turnoVespertino', 'turnoNocturno'}
            if not required_columns.issubset(df.columns):
                return {"error": "Faltan columnas requeridas en los datos"}, 422

            # Ordenar cronológicamente los meses y agrupar
            meses_orden = [
                "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
                "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
            ]
            df['mesNombre'] = pd.Categorical(df['mesNombre'], categories=meses_orden, ordered=True)
            #df_agrupado = df.groupby('mesNombre').sum().sort_index()
            df_agrupado = df.groupby('mesNombre', observed=False).sum().sort_index()


            # Crear la estructura de series
            series = [
                {"label": "MATUTINO", "data": df_agrupado['turnoMatutino'].tolist()},
                {"label": "MADRUGADA", "data": df_agrupado['turnoMadrugada'].tolist()},
                {"label": "VESPERTINO", "data": df_agrupado['turnoVespertino'].tolist()},
                {"label": "NOCTURNO", "data": df_agrupado['turnoNocturno'].tolist()}
            ]

            # Construir la respuesta JSON
            data = {
                "months": meses_orden,
                "series": series,
                "colors": GenerarColores(num_colores=4),
                "height": 300,
                "titulo": 'Delitos por Mes y Horario de ocurrencia, Nivel Estatal',
                "maxItems": 12,
                "maxSeries": 10
            }

            return data, 200

        except KeyError as ke:
            return {"error": f"Parámetro faltante o incorrecto: {str(ke)}"}, 400

        except Exception as e:
            return {"error": f"Error interno: {str(e)}"}, 500