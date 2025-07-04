import json
import pandas as pd
from app.mapper.graficas_fuenteExternaBarrasDias_mapper import fuenteExternaBarrasDiasMapper
from app.controladores.serviciosGraficas_controlador import GenerarColores

class funFuenteExternaBarrasDiasService:
    
    def __init__(self):
        self.fuenteExternaBarrasDias = fuenteExternaBarrasDiasMapper()

    def obtenerDatos(self, jsonParametros):
        try:
            anio = jsonParametros.get("anio")
            mes = jsonParametros.get("mes")

            if anio is None or mes is None:
                return {"error": "Parámetro 'anio' o 'mes' faltante"}, 400

            responseData, code = self.fuenteExternaBarrasDias.selectIncidentes(anio, mes)

            if code == 200 and "sumDelitos" in responseData:
                df = pd.DataFrame(responseData['sumDelitos'])
                if df.empty:
                    return {"error": "No se encontraron datos para los parámetros proporcionados"}, 404

                df = df.groupby(['mes']).sum()

                # Crear la estructura de series según los nombres de los días de la semana
                series = [
                    {"label": "Lunes", "data": df['conteoLunes'].tolist()},
                    {"label": "Martes", "data": df['conteoMartes'].tolist()},
                    {"label": "Miércoles", "data": df['conteoMiercoles'].tolist()},
                    {"label": "Jueves", "data": df['conteoJueves'].tolist()},
                    {"label": "Viernes", "data": df['conteoViernes'].tolist()},
                    {"label": "Sábado", "data": df['conteoSabado'].tolist()},
                    {"label": "Domingo", "data": df['conteoDomingo'].tolist()}
                ]

                meses = [
                    "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
                    "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
                ]

                data = {
                    "months": meses,
                    "series": series,
                    "colors": GenerarColores(num_colores=7),
                    "height": 300,
                    "titulo": 'Delitos por Año, Mes y Día de la Semana, Nivel Nacional',
                    "maxItems": 12,
                    "maxSeries": 10
                }

                return data, 200

            else:
                return responseData, code
                
        except KeyError as ke:
            return {"error": f"Parámetro faltante o incorrecto: {str(ke)}"}, 400

        except Exception as e:
            return {"error": f"Error interno: {str(e)}"}, 500