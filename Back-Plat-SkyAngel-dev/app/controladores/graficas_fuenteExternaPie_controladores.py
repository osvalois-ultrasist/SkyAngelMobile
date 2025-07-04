import pandas as pd
from app.mapper.graficas_fuenteExternaPie_mapper import fuenteExternaPieMapper
from app.controladores.serviciosGraficas_controlador import GenerarColores

class funFuenteExternaPieService:

    def __init__(self):
        self.fuenteExternaPie = fuenteExternaPieMapper()

    def obtenerDatos(self, jsonParametros):
        anio = jsonParametros.get("anio", [])
        mes = jsonParametros.get("mes", [])
        entidad = jsonParametros.get("entidad", [])
        municipio = jsonParametros.get("municipio", [])

        # Obtener los datos del mapper
        responseData, code = self.fuenteExternaPie.selectIncidentes(anio, mes, entidad, municipio)

        if code == 200:
            # Convertir la lista de diccionarios a un DataFrame
            df = pd.DataFrame(responseData['sumDelitos'])

            # Verificar si el DataFrame está vacío
            if df.empty:
                return {"Error": "No se encontraron datos"}, 404

            colores = GenerarColores()

            # Agrupación y generación de datos
            def generar_json_agrupado(df, col_group, columnas_suma, colores):
                agrupados = df.groupby(col_group).sum()[columnas_suma].reset_index()
                total = agrupados[columnas_suma].sum().sum()
                result = [
                    {
                        "label": f"{row[col_group]} - {round((row[columnas_suma].sum() / total) * 100, 2)}% ({row[columnas_suma].sum()})",
                        "value": round((row[columnas_suma].sum() / total) * 100, 2),
                        "color": colores[i % len(colores)]
                    }
                    for i, row in agrupados.iterrows()
                ]
                return result

            # Calcular el total para tipos de vehículos
            vehiculos_totales = df[["conteo_robo_vehiculos_pesados", "conteo_robo_vehiculos_ligeros", "conteo_robo_vehiculos_privados"]].sum()
            total_vehiculos = vehiculos_totales.sum()
            vehiculos_json = [
                {
                    "label": f"vehiculos_pesados - {round((vehiculos_totales['conteo_robo_vehiculos_pesados'] / total_vehiculos) * 100, 2)}% ({vehiculos_totales['conteo_robo_vehiculos_pesados']})",
                    "value": round((vehiculos_totales['conteo_robo_vehiculos_pesados'] / total_vehiculos) * 100, 2),
                    "color": colores[0]
                },
                {
                    "label": f"vehiculos_ligeros - {round((vehiculos_totales['conteo_robo_vehiculos_ligeros'] / total_vehiculos) * 100, 2)}% ({vehiculos_totales['conteo_robo_vehiculos_ligeros']})",
                    "value": round((vehiculos_totales['conteo_robo_vehiculos_ligeros'] / total_vehiculos) * 100, 2),
                    "color": colores[5]
                },
                {
                    "label": f"vehiculos_privados - {round((vehiculos_totales['conteo_robo_vehiculos_privados'] / total_vehiculos) * 100, 2)}% ({vehiculos_totales['conteo_robo_vehiculos_privados']})",
                    "value": round((vehiculos_totales['conteo_robo_vehiculos_privados'] / total_vehiculos) * 100, 2),
                    "color": colores[9]
                }
            ]

            # Calcular el total para turnos de horario
            horario_totales = df[["conteo_robo_turno_matutino", "conteo_robo_turno_madrugada", "conteo_robo_turno_vespertino", "conteo_robo_turno_nocturno"]].sum()
            total_horarios = horario_totales.sum()
            horario_json = [
                {
                    "label": f"turno_matutino - {round((horario_totales['conteo_robo_turno_matutino'] / total_horarios) * 100, 2)}% ({horario_totales['conteo_robo_turno_matutino']})",
                    "value": round((horario_totales['conteo_robo_turno_matutino'] / total_horarios) * 100, 2),
                    "color": colores[0]
                },
                {
                    "label": f"turno_madrugada - {round((horario_totales['conteo_robo_turno_madrugada'] / total_horarios) * 100, 2)}% ({horario_totales['conteo_robo_turno_madrugada']})",
                    "value": round((horario_totales['conteo_robo_turno_madrugada'] / total_horarios) * 100, 2),
                    "color": colores[3]
                },
                {
                    "label": f"turno_vespertino - {round((horario_totales['conteo_robo_turno_vespertino'] / total_horarios) * 100, 2)}% ({horario_totales['conteo_robo_turno_vespertino']})",
                    "value": round((horario_totales['conteo_robo_turno_vespertino'] / total_horarios) * 100, 2),
                    "color": colores[6]
                },
                {
                    "label": f"turno_nocturno - {round((horario_totales['conteo_robo_turno_nocturno'] / total_horarios) * 100, 2)}% ({horario_totales['conteo_robo_turno_nocturno']})",
                    "value": round((horario_totales['conteo_robo_turno_nocturno'] / total_horarios) * 100, 2),
                    "color": colores[9]
                }
            ]

            # Configuración de respuesta
            result = {
                "data": {
                    "anio": generar_json_agrupado(df, 'anio', ['conteo_robo_transportista'], colores),
                    "mes": generar_json_agrupado(df, 'mes', ['conteo_robo_transportista'], colores),
                    "vehiculos": vehiculos_json,
                    "horario": horario_json
                },
                "configuracion": {
                    "radius": 50,
                    "itemNb": 98,
                    "skipAnimation": False,
                    "titulo": "Porcentaje de Distribución de Incidentes (Año, Mes, Horario y Tipo de Vehículo), Nivel Estatal",
                    "height": 500,
                    "arcLabelMinAngle": 20,
                },
            }

            return result, 200

        return responseData, code
