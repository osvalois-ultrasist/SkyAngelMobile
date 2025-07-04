from psycopg2 import sql
from flask import jsonify
import json
from app.modelos.conexion_bd import Conexion_BD

class secretariadoBarrasMunicipioMapper():
    def listToString(self, lista, delimiter=", "):
        stringList = [str(element) for element in lista]
        return delimiter.join(stringList)

    def selectIncidentes(self, anios, municipio, subtipoDeDelito):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            aniosStr = self.listToString(anios)
            municipioStr = self.listToString(municipio)
            subtipoDeDelitoStr = self.listToString(subtipoDeDelito)
            
            query = f"""
            with DELITOS_MUNICIPIOS as(
            select sdmmv.anio,
                sdmmv.entidad,
                sdmmv.id_municipio,
                sdmmv.municipio,
                sdmmv.conteo,
                sdmmv.id_subtipo_de_delito
            FROM 
                sum_delitos_municipio_mes_vista sdmmv
            where sdmmv.id_municipio IN ({municipioStr})
            ),
            delitos_por_tipo as (
            select
                d.anio,
                d.entidad,
                d.id_municipio,
                d.municipio,
                d.conteo
            FROM 
                DELITOS_MUNICIPIOS d
            where d.id_subtipo_de_delito in ({subtipoDeDelitoStr})
            )
            select
                d.anio,
                d.entidad,
                d.id_municipio,
                d.municipio,
                SUM(d.conteo) AS total_crimenes
            FROM 
                DELITOS_MUNICIPIOS d
            where d.anio IN ({aniosStr})
            GROUP BY 
                d.anio, d.entidad ,d.id_municipio , d.municipio 
            """

            # Ejecutar la consulta SQL
            cursor.execute(query)
            rows = cursor.fetchall()
            
            # Procesar los resultados
            sumDelitos = [
                {
                    "anio": row[0],
                    "entidad": row[1],
                    "cveMunicipio": row[2],
                    "municipio": row[3],
                    "conteo": row[4]

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
