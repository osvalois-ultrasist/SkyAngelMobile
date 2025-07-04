from psycopg2 import sql
from flask import jsonify
import json
from app.modelos.conexion_bd import Conexion_BD

class secretariadoBarrasEstadoMapper():
    def listToString(self, lista, delimiter=", "):
        stringList = [str(element) for element in lista]
        return delimiter.join(stringList)

    def selectIncidentes(self, anios, entidad, subtipoDeDelito):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            aniosStr = self.listToString(anios)
            entidadStr = self.listToString(entidad)
            subtipoDeDelitoStr = self.listToString(subtipoDeDelito)

            query = f"""
            
                select
                        sdmmv.anio,
                        sdmmv.id_entidad,
                        sdmmv.entidad,
                        SUM(sdmmv.conteo) AS total_crimenes
                FROM 
                    sum_delitos_municipio_mes_vista sdmmv
                where sdmmv.anio IN ({aniosStr})
                and sdmmv.id_entidad IN ({entidadStr})
                and sdmmv.id_subtipo_de_delito IN ({subtipoDeDelitoStr})
                GROUP BY 
                    sdmmv.anio, sdmmv.id_entidad, sdmmv.entidad
                ORDER BY 
                    sdmmv.anio, sdmmv.id_entidad

            """

            # Ejecutar la consulta SQL
            cursor.execute(query)
            rows = cursor.fetchall()
            
            # Procesar los resultados
            sumDelitos = [
                {
                    "anio": row[0],
                    "idEntidad": row[1],
                    "entidad": row[2],
                    "conteo": row[3]

                }
                for row in rows
            ]

            # Devolver la respuesta en formato JSON usando jsonify
            return {"sumDelitos": sumDelitos}, 200

        except Exception as e:
            print(f"Error: {e}")
            return {"Error": "Error conexión del servidor"}, 500

        finally:
            cursor.close()
            conn.close()
