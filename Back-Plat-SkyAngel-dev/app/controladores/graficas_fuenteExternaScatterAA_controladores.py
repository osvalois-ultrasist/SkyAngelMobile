import json
import pandas as pd
from app.modelos.constantes_globales import diccionarioMeses
from app.mapper.graficas_fuenteExternaScatterAA_mapper import fuenteExternaScatterMapper

class funFuenteExternaScatterService:
    
    def __init__(self):
        self.fuenteExternaScatter = fuenteExternaScatterMapper()

    def obtenerDatos(self, jsonParametros):
        try:
            # Extraer parámetros del JSON
            anios = jsonParametros.get("años", [])
            mes = jsonParametros.get("mes", [])
            entidad = jsonParametros.get("entidad", [])
            municipio = jsonParametros.get("municipio", [])
            
            
            
            
            
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
            
            
            
            
            
            
            
            
            
            if errores:
                return {"Errores": errores}, 400


            # Obtener los datos del mapper
            responseData, code = self.fuenteExternaScatter.selectIncidentes(anios, mes, entidad, municipio)
        
        
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
                    "width": 1000,
                    "height": 300
                },
                
                "chartTitle": "Total de delitos por mes (año actual vs año anterior)"
            }
        
            return json.dumps(organizedData), 200
        except Exception as e:
            return {"Error": f"Error en la base de datos: {str(e)}"}, 500