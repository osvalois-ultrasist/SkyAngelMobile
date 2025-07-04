import json
import pandas as pd
from app.modelos.constantes_globales import diccionarioMeses
from app.mapper.graficas_reaccionesAAScatter_mapper import reaccionesScatterAnioAnteriorMapper

class funreaccionesScatterService():
    
    def __init__(self):
        self.reaccionesScatter = reaccionesScatterAnioAnteriorMapper()

    def obtenerDatos(self, jsonParametros):
        try:
            # Extraer parámetros del JSON
            anios = jsonParametros.get("años", [])
            mes = jsonParametros.get("meses", [])
            entidad = jsonParametros.get("entidades", [])
            municipio = jsonParametros.get("municipios", [])
            categoria = jsonParametros.get("categoria", [])

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
            if not categoria:  # Validación explícita
                errores.append("El parámetro 'categoria' no puede estar vacío.")

            if errores:
                return {"Errores": errores}, 400

            # Obtener los datos del mapper
            responseData, code = self.reaccionesScatter.selectIncidentes(anios, mes, entidad, municipio, categoria)

            # Convertir la lista de diccionarios a un DataFrame
            df = pd.DataFrame(responseData['data'])

            if 0 in anios:
                # Seleccionar el año más reciente y el anterior
                max_anio = df['anio'].max()
                anios = [max_anio, max_anio - 1]

            # Crear un diccionario para organizar los datos por año
            dataDict = {}

            # Iterar por cada año en los datos
            for anio in df['anio'].unique():
                dfAnio = df[df['anio'] == anio].sort_values(by='idMes')
                # Convertir la clave del año a string para evitar el error
                dataDict[str(anio)] = dfAnio['conteo'].tolist()

            # Preparar la lista de años en formato string
            years = [str(anio) for anio in sorted(df['anio'].unique(), reverse=True)]

            # Verificar la presencia de los años en los datos
            anio_actual = str(anios[0])
            anio_anterior = str(anios[1])

            anio_actual_data = dataDict.get(anio_actual, [])
            anio_anterior_data = dataDict.get(anio_anterior, [])

            mes_labels = list(df['mes'].astype(str).unique())
            orden_meses = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', # Lista con el orden correcto
               'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre']
            mes_labels = sorted(mes_labels, key=lambda mes: orden_meses.index(mes)) # Ordenar meses

            # Dentro de organizedData
            organizedData = {
                "years": years,
                "months": mes_labels,
                "data": {
                    "AnioActual": anio_actual_data,
                    "AnioAnterior": anio_anterior_data,
                },
                "colors": {
                    "AnioActual": "#1C57AA",
                    "AnioAnterior": "#0D125B"
                },
                "labels": {
                    "AnioActual": "Año Actual",
                    "AnioAnterior": "Año Anterior"
                },
                "chartDimensions": {
                    "width": 1000,
                    "height": 300
                },
                
                "chartTitle": "Total de delitos por mes (año actual vs año anterior)"
            }
            
            return json.dumps(organizedData), 200
        except Exception as e:
            return {"Error": f"Error en la base de datos: {str(e)}"}, 500
    