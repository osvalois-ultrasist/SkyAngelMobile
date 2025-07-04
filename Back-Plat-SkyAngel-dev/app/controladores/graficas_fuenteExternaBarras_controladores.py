import pandas as pd
from app.mapper.graficas_fuenteExternaBarras_mapper import fuenteExternaBarrasMapper
from app.controladores.serviciosGraficas_controlador import GenerarColores

class funFuenteExternaBarrasService:
    
    def __init__(self):
        self.fuenteExternaBarras = fuenteExternaBarrasMapper()

    def obtenerDatos(self, jsonParametros):
        anio = jsonParametros.get("anio")
        mes = jsonParametros.get("mes")
        entidad = jsonParametros.get("entidad")
        municipio = jsonParametros.get("municipio")

        if not all([anio, mes, entidad, municipio]):
            raise KeyError("Faltan parámetros obligatorios")

        try:
            responseData, code = self.fuenteExternaBarras.selectIncidentes(anio, mes, entidad, municipio)
        except Exception as e:
            raise Exception(f"Error al obtener datos: {str(e)}")

        if code == 200:
            if 'sumDelitos' not in responseData or not responseData['sumDelitos']:
                return {"error": "Datos vacíos en la respuesta"}, 204

            try:
                df = pd.DataFrame(responseData['sumDelitos'])

                if not {'anio', 'mes', 'mesNombre', 'conteo'}.issubset(df.columns):
                    raise ValueError("Datos con formato inválido")

                anio_mes_totales = (
                    df.groupby(['anio', 'mesNombre'])['conteo']
                    .sum()
                    .unstack(fill_value=0)
                )

                meses_orden = [
                    "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
                    "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
                ]
                anio_mes_totales = anio_mes_totales.reindex(columns=meses_orden, fill_value=0)

                series = [
                    {"label": str(year), "data": row.tolist()}
                    for year, row in anio_mes_totales.iterrows()
                ]

                meses = list(anio_mes_totales.columns)

                return {
                    "series": series,
                    "meses": meses,
                    "height": 300,
                    "colors": GenerarColores(),
                    "titulo": "Delitos por Año y Mes, Nivel Estatal",
                    "maxItems": len(meses),
                    "maxSeries": len(series)
                }

            except Exception as e:
                raise Exception(f"Error procesando datos: {str(e)}")

        else:
            return responseData, code