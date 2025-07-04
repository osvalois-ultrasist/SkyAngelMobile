import pandas as pd
from app.mapper.graficas_secretariadoMunicipioBarras_mapper import secretariadoBarrasMunicipioMapper

class secretariadoBarrasMunicipioService():
    
    def __init__(self):
        self.secretariadoBarrasMunicipio = secretariadoBarrasMunicipioMapper()

    def obtenerDatos(self, jsonParametros):
        try:            
            # Extraer parámetros del JSON
            anios = jsonParametros.get("años", [])
            mes = jsonParametros.get("mes", [])
            subtipoDeDelito = jsonParametros.get("subtipoDeDelito", [])
            entidad = jsonParametros.get("entidad", [])
            municipio = jsonParametros.get("municipio", [])
            bienJuridicoAfectado = jsonParametros.get("bienJuridicoAfectado", [])
            tipoDeDelito = jsonParametros.get("tipoDeDelito", [])
            modalidad = jsonParametros.get("modalidad", [])

            errores = []

            # Validar parámetros requeridos
            if not anios:  # Validación explícita
                errores.append("El parámetro 'anios' no puede estar vacío.")
            if not mes:  # Validación explícita
                errores.append("El parámetro 'mes' no puede estar vacío.")
            if not entidad:  # Validación explícita
                errores.append("El parámetro 'entidad' no puede estar vacío.")
            if not municipio:  # Validación explícita
                errores.append("El parámetro 'municipio' no puede estar vacío.")
            if not bienJuridicoAfectado:  # Validación explícita
                errores.append("El parámetro 'bienJuridicoAfectado' no puede estar vacío.")
            if not tipoDeDelito:  # Validación explícita
                errores.append("El parámetro 'tipoDeDelito' no puede estar vacío.")
            if not subtipoDeDelito:  # Validación explícita
                errores.append("El parámetro 'subtipoDeDelito' no puede estar vacío.")
            if not modalidad:  # Validación explícita
                errores.append("El parámetro 'modalidad' no puede estar vacío.")

            if errores:
                return {"Errores": errores}, 400

            # Obtener los datos del mapper
            data = self.secretariadoBarrasMunicipio.selectIncidentes(anios, mes, entidad, municipio, bienJuridicoAfectado, tipoDeDelito, subtipoDeDelito, modalidad)

            df = pd.DataFrame(data['data'])
            dfSmall = df[["anio", "conteo", "entidad", "cveMunicipio", "municipio"]]
            dfTotalCrimenes = dfSmall.groupby(['municipio', 'entidad'])['conteo'].sum().reset_index()
            dfTotalCrimenes = dfTotalCrimenes.sort_values('conteo', ascending=False).head(20)

            result = [
                {
                    "municipio": f"{row['municipio']}, {row['entidad']}",
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
                    'fontSize': 10,
                    'fontColor': '#0D125B',
                    'chartWidth': [850],
                    'chartHeight': [300],
                    'yAxisDataKey': 'municipio',
                    'yAxisColor': '#0D125B',
                    'yAxisWidth': [500],
                    'xAxisLabel': 'Número de Crímenes',
                    'xAxisColor': '#0D125B',
                    'scaleType': 'band',
                    'layout': 'horizontal',
                    'grid': {'vertical': True },
                    'margin': { 'top': 20, 'right': 50, 'bottom': 20, 'left': 270 }
                }

            return {
                'title': 'Delitos en los 20 municipios con mayor siniestralidad',
                'serie': serie,
                'data': result
                }, 200

        except Exception as e:
            return {"Error": f"Error del servidor: {str(e)}"}, 500