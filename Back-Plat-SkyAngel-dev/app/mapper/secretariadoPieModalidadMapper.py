from psycopg2 import sql
from flask import jsonify
import json
from app.modelos.conexion_bd import Conexion_BD

class secretariadoPieModalidadMapper():
    def listToString(self, lista, delimiter=", "):
        stringList = [str(element) for element in lista]
        return delimiter.join(stringList)

    def selectIncidentes(self, anios, subtipoDeDelito, modalidad):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            aniosStr = self.listToString(anios)
            subtipoDeDelitoStr = self.listToString(subtipoDeDelito)
            modalidadStr = self.listToString(modalidad)

            query = f""" 
            select sdmmv.anio,
                sdmmv.id_modalidad , modalidad ,
                SUM(sdmmv.conteo) as total_delitos
            from 
                sum_delitos_municipio_mes_vista sdmmv
            where
                sdmmv.anio in ({aniosStr})
                and sdmmv.id_subtipo_de_delito in ({subtipoDeDelitoStr})
                and	sdmmv.id_modalidad  in ({modalidadStr})
            group by 
                sdmmv.anio , sdmmv.id_modalidad, sdmmv.modalidad 
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
                    "idModalidad": row[1],
                    "modalidad": row[2],
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
