from psycopg2 import sql
from flask import jsonify
import json
from app.modelos.conexion_bd import Conexion_BD

class fuenteExternaBarrasMapper():

    def listToString(self, lista, delimiter=", "):
        stringList = [str(element) for element in lista]
        resultString = delimiter.join(stringList)
        return resultString    

    def selectIncidentes(self, anios, mes, entidad, municipio):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            query = """
                SELECT 
                sdemav.anio, 
                sdemav.id_mes, 
                sdemav.mes, 
                sdemav.id_entidad, 
                sdemav.entidad, 
                sdemav.conteo_robo_transportista
                FROM 
                sum_delitos_entidad_mes_anerpv_vista sdemav
                JOIN 
                sum_delitos_municipio_mes_anerpv_vista sdmmav
                ON 
                sdemav.id_entidad = sdmmav.id_entidad
                and
                sdemav.anio = sdmmav.anio
                and
                sdemav.id_mes = sdmmav.id_mes
                and
                sdemav.conteo_robo_transportista = sdmmav.conteo_robo_transportista
            """
            condiciones = []
            params = []

            if anios and anios != [0]:
                condiciones.append("sdemav.anio IN %s")
                params.append(tuple(anios))

            if mes and mes != [0]:
                condiciones.append("sdemav.id_mes IN %s")
                params.append(tuple(mes))

            if entidad and entidad != [0]:
                condiciones.append("sdemav.id_entidad IN %s")
                params.append(tuple(entidad))

            if municipio and municipio != [0]:
                condiciones.append("sdmmav.cve_municipio IN %s")
                params.append(tuple(municipio))

            if condiciones:
                query += " WHERE " + " AND ".join(condiciones)

            # Asegúrate de usar los parámetros
            cursor.execute(query, params)
            rows = cursor.fetchall()

            sumDelitos = [
                {
                    "anio": row[0],
                    "mes": row[1],
                    "mesNombre": row[2],
                    "idEntidad": row[3],
                    "entidad": row[4],
                    "conteo": row[5]
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
