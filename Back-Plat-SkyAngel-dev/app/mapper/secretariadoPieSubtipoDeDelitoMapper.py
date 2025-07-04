from psycopg2 import sql
from flask import jsonify
import json
from app.modelos.conexion_bd import Conexion_BD

class secretariadoPieSubtipoDeDelitoMapper():
    def listToString(self, lista, delimiter=", "):
        stringList = [str(element) for element in lista]
        return delimiter.join(stringList)

    def selectIncidentes(self, anios, subtipoDeDelito):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            aniosStr = self.listToString(anios)
            subtipoDeDelitoStr = self.listToString(subtipoDeDelito)

            query = f""" 
                select sdmmv.anio,
                    sdmmv.id_subtipo_de_delito, subtipo_de_delito,
                    SUM(sdmmv.conteo) as total_delitos
                from 
                    sum_delitos_municipio_mes_vista sdmmv 
                where
                    sdmmv.anio IN ({aniosStr})
                and	
                    sdmmv.id_subtipo_de_delito in ({subtipoDeDelitoStr})
                group by 
                    sdmmv.anio , sdmmv.id_subtipo_de_delito , sdmmv.subtipo_de_delito 
                order by
                    sdmmv.anio 
            """

            # Ejecutar la consulta SQL
            cursor.execute(query)
            rows = cursor.fetchall()
            
            # Procesar los resultados
            sumDelitos = [
                {
                    "anio": row[0],
                    "idSubtipoDeDelito": row[1],
                    "subtipoDeDelito": row[2],
                    "conteo": row[3],

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
