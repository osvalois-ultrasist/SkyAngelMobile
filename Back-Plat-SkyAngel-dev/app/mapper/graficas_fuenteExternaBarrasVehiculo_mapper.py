from psycopg2 import sql
from flask import jsonify
import json
from app.modelos.conexion_bd import Conexion_BD

class fuenteExternaBarrasVehiculoMapper:

    def listToString(self, lista, delimiter=", "):
        return delimiter.join([str(element) for element in lista])

    def selectIncidentes2(self, anio, mes, entidad, municipio):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            anioStr = self.listToString(anio)
            mesStr = self.listToString(mes)
            entidadStr = self.listToString(entidad)
            municipioStr = self.listToString(municipio)

            query = f"""
            SELECT
                sdemav.anio,
                sdemav.id_mes,
                sdemav.mes,
                SUM(sdemav.conteo_robo_vehiculos_pesados) AS total_robo_vehiculos_pesados,
                SUM(sdemav.conteo_robo_vehiculos_ligeros) AS total_robo_vehiculos_ligeros,
                SUM(sdemav.conteo_robo_vehiculos_privados) AS total_robo_vehiculos_privados,
                SUM(sdemav.conteo_robo_vehiculos_pesados + conteo_robo_vehiculos_ligeros + conteo_robo_vehiculos_privados) AS total_robo_vehiculos
				FROM
				    sum_delitos_entidad_mes_anerpv_vista sdemav
				JOIN 
				    sum_delitos_municipio_mes_anerpv_vista sdmmav
				    ON sdemav.id_entidad = sdmmav.id_entidad
				WHERE
				    sdemav.anio IN ({anioStr})
				    AND sdemav.id_mes IN ({mesStr})
				    AND sdemav.id_entidad IN ({entidadStr})
				    AND sdmmav.cve_municipio IN ({municipioStr})
				GROUP BY
				    sdemav.anio,
				    sdemav.id_mes,
				    sdemav.mes
        """
            cursor.execute(query)
            rows = cursor.fetchall()

            sumDelitos = [
                {
                    "anio": row[0],
                    "mes": row[1],
                    "mesNombre": row[2],
                    "vehiculosPesados": row[3],
                    "vehiculosLigeros": row[4],
                    "vehiculosPrivados": row[5],
                    "conteo": row[6],
                }
                for row in rows
            ]

            return {"sumDelitos": sumDelitos}, 200

        except Exception as e:
            return {"error": "Error conexión del servidor"}, 500

        finally:
            cursor.close()
            conn.close()
    
    
    def selectIncidentes(self, anios, mes, entidad, municipio):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            query = """
            SELECT
                sdemav.anio,
                sdemav.id_mes,
                sdemav.mes,
                sdemav.conteo_robo_vehiculos_pesados,
                sdemav.conteo_robo_vehiculos_ligeros,
                sdemav.conteo_robo_vehiculos_privados,
                (sdemav.conteo_robo_vehiculos_pesados + conteo_robo_vehiculos_ligeros + conteo_robo_vehiculos_privados) AS total_robo_vehiculos
				FROM
				    sum_delitos_entidad_mes_anerpv_vista sdemav
				JOIN 
				    sum_delitos_municipio_mes_anerpv_vista sdmmav
				    ON sdemav.id_entidad = sdmmav.id_entidad
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
            
            query += """  
				GROUP BY
				    sdemav.anio,
				    sdemav.id_mes,
				    sdemav.mes,
				    sdemav.conteo_robo_vehiculos_pesados,
				    sdemav.conteo_robo_vehiculos_ligeros,
				    sdemav.conteo_robo_vehiculos_privados
            """

            # Asegúrate de usar los parámetros
            cursor.execute(query, params)
            rows = cursor.fetchall()

            sumDelitos = [
                {
                    "anio": row[0],
                    "mes": row[1],
                    "mesNombre": row[2],
                    "vehiculosPesados": row[3],
                    "vehiculosLigeros": row[4],
                    "vehiculosPrivados": row[5],
                    "conteo": row[6],
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