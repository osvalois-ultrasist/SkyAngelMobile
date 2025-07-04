from psycopg2 import sql
from flask import jsonify
import json
from app.modelos.conexion_bd import Conexion_BD

class secretariadoBarrasAcumMapper():
    def listToString(self, lista, delimiter=", "):
        stringList = [str(element) for element in lista]
        return delimiter.join(stringList)

    def selectIncidentes(self, anios, mes, subtipoDeDelito):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            aniosStr = self.listToString(anios)
            mesStr = self.listToString(mes)
            subtipoDeDelitoStr = self.listToString(subtipoDeDelito)

            query = f"""
                    select
                                sdmmv.anio,
                                sdmmv.id_mes,
                                cm.mes,
                                SUM(sdmmv.conteo) AS total_crimenes
                        FROM 
                            sum_delitos_municipio_mes_vista sdmmv
                        join cat_meses cm
                            on cm.id_mes = sdmmv.id_mes 
                        where sdmmv.anio IN ({aniosStr})
                        and sdmmv.id_mes IN ({mesStr})
                        and sdmmv.id_subtipo_de_delito IN ({subtipoDeDelitoStr})
                        GROUP BY 
                            sdmmv.anio, sdmmv.id_mes, cm.mes
                        ORDER BY 
                            sdmmv.anio, sdmmv.id_mes

            """

            # Ejecutar la consulta SQL
            cursor.execute(query)
            rows = cursor.fetchall()
            
            # Procesar los resultados
            sumDelitos = [
                {
                    "anio": row[0],
                    "idMes": row[1],
                    "mes": row[2],
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
