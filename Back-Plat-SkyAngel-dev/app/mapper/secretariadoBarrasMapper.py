import psycopg2
from flask import jsonify
from app.modelos.conexion_bd import Conexion_BD

class muiBarrasMapper():

    def listToString(self, lista, delimiter=", "):
        stringList = [str(element) for element in lista]
        resultString = delimiter.join(stringList)
        return resultString
    

    def selectIncidentesMui(self, anios, mes, incidencias, municipios):
        # Conexión a la base de datos
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            aniosStr = self.listToString(anios)
            mesStr = self.listToString(mes)
            incidenciasStr = self.listToString(incidencias)
            municipiosStr = self.listToString(municipios)

            # Consulta SQL usando las listas convertidas a cadenas
            query = f"""
            select sdmmv.id_mes, sdmmv.id_delito, sdmmv.anio, sdmmv.conteo
            from sum_delitos_municipio_mes_vista sdmmv
            where 
            sdmmv.id_mes IN ({mesStr})
            and sdmmv.id_delito IN ({incidenciasStr})
            and sdmmv.anio IN ({aniosStr})
            and sdmmv.id_municipio IN ({municipiosStr})
            """

            # Ejecutar la consulta SQL
            cursor.execute(query)
            rows = cursor.fetchall()

            # Procesar los resultados
            sumDelitos = [
                {
                    "idMes": row[0],
                    "idDelitoMunicipio": row[1],
                    "anio": row[2],
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
