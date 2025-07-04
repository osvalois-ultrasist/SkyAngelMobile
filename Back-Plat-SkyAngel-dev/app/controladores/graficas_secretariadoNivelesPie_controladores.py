import json
import pandas as pd
from itertools import cycle
from app.controladores.serviciosGraficas_controlador import GenerarColores
from app.mapper.graficas_secretariadoNivelesPie_mapper import secretariadoPieNivelesMapper

class secretariadoPieNivelesService():
    
    def __init__(self):
        self.secretariadoPieNiveles = secretariadoPieNivelesMapper()

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
            responseData = self.secretariadoPieNiveles.selectIncidentes(anios, mes, entidad, municipio, bienJuridicoAfectado, tipoDeDelito, subtipoDeDelito, modalidad)

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


            # Procesar datos si no hay errores
            df = pd.DataFrame(responseData['data'])

            #Se genera una ciclo para asignar un gradiente de colores
            ciclo_colores = cycle(GenerarColores())

            df_data1 = df.groupby('bienJuridicoAfectado')['conteo'].sum().reset_index()
            df_data1.columns = ['label', 'value']
            df_data1['color'] = [next(ciclo_colores) for _ in range(len(df_data1))]

            df_data2 = df.groupby('tipoDeDelito')['conteo'].sum().reset_index()
            df_data2.columns = ['label', 'value']
            df_data2['color'] = [next(ciclo_colores) for _ in range(len(df_data2))]

            df_data3 = df.groupby('subtipoDeDelito')['conteo'].sum().reset_index()
            df_data3.columns = ['label', 'value']
            df_data3['color'] = [next(ciclo_colores) for _ in range(len(df_data3))]

            df_data4 = df.groupby('modalidad')['conteo'].sum().reset_index()
            df_data4.columns = ['label', 'value']
            df_data4['color'] = [next(ciclo_colores) for _ in range(len(df_data4))]

            data1 = df_data1.to_dict(orient='records')
            data2 = df_data2.to_dict(orient='records')
            data3 = df_data3.to_dict(orient='records')
            data4 = df_data4.to_dict(orient='records')

            config = {
                "innerRadius": [5, 55, 105, 155],
                "outerRadius": [50, 100, 150, 200],
                "width": 700,
                "height": 700,
                "margin": {'top': 20, 'right': 150, 'bottom': 20, 'left': 150},
                "legendHidden": True,
                "title": 'Delitos según el Bien Jurídico Afectado, Tipo de Delito, Subtipo de Delito y Modalidad'
            }

            organizedData = {
                "data1": data1,
                "data2": data2,
                "data3": data3,
                "data4": data4,
                "config": config
            }
            
            return organizedData, 200

        except Exception as e:
            print(f"Error: {e}")
            return {"Error": f"Error conexión del servidor, {e}"}, 500