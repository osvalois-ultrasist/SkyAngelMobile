from psycopg2 import sql
from flask import jsonify
import json
from app.modelos.conexion_bd import Conexion_BD

class secretariadoPieTipoDeDelitoMapper():
    def listToString(self, lista, delimiter=", "):
        stringList = [str(element) for element in lista]
        return delimiter.join(stringList)

    def selectIncidentes(self, anios, tipoDeDelito):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            aniosStr = self.listToString(anios)
            tipoDeDelitoStr = self.listToString(tipoDeDelito)

            query = f"""
        
                SELECT 
                    sdmmv.anio,
                    SUM(sdmmv.conteo) AS total_delitos,
                    sdmmv.id_tipo_de_delito,
                    sdmmv.tipo_de_delito
                FROM 
                    sum_delitos_municipio_mes_vista sdmmv 
                WHERE 
                    sdmmv.anio IN ({aniosStr})
                    AND sdmmv.id_tipo_de_delito in ({tipoDeDelitoStr})
                GROUP BY 
                    sdmmv.anio, sdmmv.id_tipo_de_delito, sdmmv.tipo_de_delito
                ORDER BY 
                    sdmmv.anio

            """

            # Ejecutar la consulta SQL
            cursor.execute(query)
            rows = cursor.fetchall()
            
            # Procesar los resultados
            sumDelitos = [
                {
                    "anio": row[0],
                    "conteo": row[1],
                    "idTipoDeDelito": row[2],
                    "tipoDeDelito": row[3],

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
