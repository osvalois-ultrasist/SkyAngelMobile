import json
import pandas as pd
from app.controladores.serviciosGraficas_controlador import GenerarColores
from app.mapper.graficas_secretariadoAcumBarras_mapper import secretariadoBarrasAcumMapper
from app.modelos.constantes_globales import diccionarioMeses

class secretariadoBarrasAcumService():
    
    def __init__(self):
        self.secretariadoBarrasAcum = secretariadoBarrasAcumMapper()

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

            # Preparar años (remover 0 si está presente)
            if anios == [0]:
                anios = []  # Mapper tratará el caso como "todos los años"

            responseData = self.secretariadoBarrasAcum.selectIncidentes(anios, mes, entidad, municipio, bienJuridicoAfectado, tipoDeDelito, subtipoDeDelito, modalidad)

            df = pd.DataFrame(responseData['data'])
            dfSmall = df[["anio", "conteo", "idMes", "mes"]]
    
            dfAnual = dfSmall.groupby('anio')['conteo'].sum().reset_index()
            dfMensual = dfSmall.groupby(['anio', 'mes', 'idMes'])['conteo'].sum().reset_index()

            crimenesAnuales = list(dfAnual['conteo'].astype(int))
            crimenesPorMes = []
            for anio in dfMensual['anio'].unique():
                crimenesMensuales = dfMensual[dfMensual['anio'] == anio].sort_values('idMes')['conteo'].tolist()
                crimenesPorMes.append([int(crimen) for crimen in crimenesMensuales])

            # Generar etiquetas de meses sin incluir '0'
            mes_labels = list(dfMensual['mes'].astype(str).unique())
            orden_meses = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', # Lista con el orden correcto
               'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre']
            mes_labels = sorted(mes_labels, key=lambda mes: orden_meses.index(mes)) # Ordenar meses
            etiquetasAnios = list(dfAnual['anio'].astype(str))

            organizedData = {
                "title": "Total de delitos por año y mes",
                "series": [
                    {"label": "Crímenes anuales", "data": crimenesAnuales},
                    {"label": "Crímenes por mes", "data": crimenesPorMes}
                ],
                "colors": {
                    "anual": "#0D125B",
                    "meses": GenerarColores(num_colores=12)
                },
                "labels": {
                    "yAxisLabelOffset" : 30,
                    "legendHidden": True,
                    "monthLabels": mes_labels,
                    "yearLabels": etiquetasAnios
                },
                "chartDimensions": {
                    "width": 850,
                    "height": 300
                },
                "chartParams": {
                    "categoryGapRatio": 0.3,
                    "barGapRatio": 0.1,
                    "translateX": "translateX(-10px)",
                    "margin": {"top": 20, "right": 50, "bottom": 20, "left": 50},
                    "width": 500,
                }
            }

            return json.dumps(organizedData), 200
        except Exception as e:
            print(f"Error: {e}")
            return {"Error": "Error conexión del servidor"}, 500