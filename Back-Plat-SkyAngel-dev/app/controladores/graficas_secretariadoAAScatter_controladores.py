import json
import pandas as pd
from app.modelos.constantes_globales import diccionarioMeses
from app.mapper.graficas_secretariadoAAScatter_mapper import secretariadoScatterAnioAnteriorMapper

class secretariadoScatterAnioAnteriorService():
    
    def __init__(self):
        self.secretariadoScatterAnioAnterior = secretariadoScatterAnioAnteriorMapper()

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
            responseData = self.secretariadoScatterAnioAnterior.selectIncidentes(anios, mes, entidad, municipio, bienJuridicoAfectado, tipoDeDelito, subtipoDeDelito, modalidad)

            if 'data' not in responseData or not responseData['data']:
                            # Crear estructura de datos vacía pero con el formato correcto
                config = {
                "innerRadius": [5, 55, 105, 155],
                "outerRadius": [50, 100, 150, 200],
                "width": 550,
                "height": 550,
                "margin": {'top': 20, 'right': 50, 'bottom': 20, 'left': 50},
                "legendHidden": True,
                "title": 'No se encontraron datos para los parámetros seleccionados'
            }
            
                empty_data = []
                organizedData = {
                    "data1": empty_data,
                    "data2": empty_data,
                    "data3": empty_data,
                    "data4": empty_data,
                    "config": config,
                    "noData": True
                }
                return organizedData, 200


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
                    "width": 850,
                    "height": 300
                },
                
                "chartTitle": "Total de delitos por mes (año actual vs año anterior)"
            }
            
            return json.dumps(organizedData), 200
        except Exception as e:
            return {"Error": f"Error en la base de datos: {str(e)}"}, 500