import pandas as pd
from app.mapper.graficas_secretariadoEstadoBarras_mapper import secretariadoBarrasEstadoMapper

class secretariadoBarrasEstadoService():
    
    def __init__(self):
        self.secretariadoBarrasEstado = secretariadoBarrasEstadoMapper()

    def obtenerDatos(self, jsonParametros):
        try:
            # Extraer parámetros del JSON
            anios = jsonParametros.get("años", [])
            mes = jsonParametros.get("mes", [])
            entidad = jsonParametros.get("entidad", [])
            municipio = jsonParametros.get("municipio", [])
            bienJuridicoAfectado = jsonParametros.get("bienJuridicoAfectado", [])
            tipoDeDelito = jsonParametros.get("tipoDeDelito", [])
            subtipoDeDelito = jsonParametros.get("subtipoDeDelito", [])
            modalidad = jsonParametros.get("modalidad", [])

            # Inicializar lista de errores
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
            data = self.secretariadoBarrasEstado.selectIncidentes(anios, mes, entidad, municipio, bienJuridicoAfectado, tipoDeDelito, subtipoDeDelito, modalidad)
            
            df = pd.DataFrame(data['data'])
            dfSmall = df[["anio", "idEntidad", "entidad", "conteo"]]    
            dfTotalCrimenes = dfSmall.groupby('entidad')['conteo'].sum().reset_index()
            dfTotalCrimenes = dfTotalCrimenes.sort_values('conteo', ascending=False)

            result = [
                {
                    "entidad": row['entidad'],
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
                'chartHeight': [300],
                'yAxisDataKey': 'entidad',
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
                'title': "Total de delitos por Entidad Federativa", 
                'serie': serie, 
                'data': result
                }, 200
        except Exception as e:
            return {"Error": f"Error del servidor: {str(e)}"}, 500