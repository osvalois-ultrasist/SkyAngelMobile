# Mapper ajustado
from psycopg2 import sql
from app.modelos.conexion_bd import Conexion_BD

class fuenteExternaPieMapper:

    def listToString(self, lista, delimiter=", "):
        return delimiter.join(map(str, lista))

    def selectIncidentes(self, anios, mes, entidad, municipio, tipo_vehiculo=None, horario=None):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            query = """
                SELECT
                    sdemav.anio, sdemav.id_mes, sdemav.mes, sdemav.id_entidad, sdemav.entidad,
                    sdemav.conteo_robo_vehiculos_pesados, sdemav.conteo_robo_vehiculos_ligeros,
                    sdemav.conteo_robo_vehiculos_privados, sdemav.conteo_robo_turno_matutino,
                    sdemav.conteo_robo_turno_madrugada, sdemav.conteo_robo_turno_vespertino,
                    sdemav.conteo_robo_turno_nocturno, sdemav.conteo_robo_transportista
                FROM
                    sum_delitos_entidad_mes_anerpv_vista sdemav
                JOIN 
                    sum_delitos_municipio_mes_anerpv_vista sdmmav
                    ON sdemav.id_entidad = sdmmav.id_entidad
                    AND
		            sdemav.anio = sdmmav.anio
		            AND
		            sdemav.id_mes = sdmmav.id_mes
		            AND
		            sdemav.conteo_robo_transportista = sdmmav.conteo_robo_transportista

            """
            condiciones = []
            params = []

            if anios:
                condiciones.append("sdemav.anio IN %s")
                params.append(tuple(anios))

            if mes and mes != [0]:
                condiciones.append("sdemav.id_mes IN %s")
                params.append(tuple(mes))

            if entidad:
                condiciones.append("sdemav.id_entidad IN %s")
                params.append(tuple(entidad))

            if municipio:
                condiciones.append("sdmmav.cve_municipio IN %s")
                params.append(tuple(municipio))

            if tipo_vehiculo:
                condiciones.append(f"sdemav.conteo_robo_{tipo_vehiculo} > 0")  # Validar el campo esperado.

            if horario:
                condiciones.append(f"sdemav.conteo_robo_turno_{horario} > 0")  # Validar el campo esperado.

            if condiciones:
                query += " WHERE " + " AND ".join(condiciones)

            cursor.execute(query, params)
            rows = cursor.fetchall()

            sumDelitos = [
                {
                    "anio": row[0],
                    "idMes": row[1],
                    "mes": row[2],
                    "idEntidad": row[3],
                    "entidad": row[4],
                    "conteo_robo_vehiculos_pesados": row[5],
                    "conteo_robo_vehiculos_ligeros": row[6],
                    "conteo_robo_vehiculos_privados": row[7],
                    "conteo_robo_turno_matutino": row[8],
                    "conteo_robo_turno_madrugada": row[9],
                    "conteo_robo_turno_vespertino": row[10],
                    "conteo_robo_turno_nocturno": row[11],
                    "conteo_robo_transportista": row[12],
                }
                for row in rows
            ]

            return {"sumDelitos": sumDelitos}, 200

        except Exception as e:
            print(f"Error: {e}")
            return {"Error": "Error conexión del servidor"}, 500

        finally:
            cursor.close()
            conn.close()
