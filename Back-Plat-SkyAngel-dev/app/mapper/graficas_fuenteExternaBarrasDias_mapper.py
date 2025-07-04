from psycopg2 import sql
from app.modelos.conexion_bd import Conexion_BD

class fuenteExternaBarrasDiasMapper:

    def listToString(self, lista, delimiter=", "):
        stringList = [str(element) for element in lista]
        resultString = delimiter.join(stringList)
        return resultString

    def selectIncidentes2(self, anio, mes):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            anioStr = self.listToString(anio)
            mesStr = self.listToString(mes)

            query = f"""
            SELECT
                anio,
                id_mes,
                conteo_robo_lunes,
                conteo_robo_martes,
                conteo_robo_miercoles,
                conteo_robo_jueves,
                conteo_robo_viernes,
                conteo_robo_sabado,
                conteo_robo_domingo,
                conteo_robo_transportista
            FROM sum_delitos_nacional_mes_anerpv sdnma
            WHERE anio IN ({anioStr})
              AND id_mes IN ({mesStr})
            """
            cursor.execute(query)
            rows = cursor.fetchall()

            sumDelitos = [
                {
                    "anio": row[0],
                    "mes": row[1],
                    "conteoLunes": row[2],
                    "conteoMartes": row[3],
                    "conteoMiercoles": row[4],
                    "conteoJueves": row[5],
                    "conteoViernes": row[6],
                    "conteoSabado": row[7],
                    "conteoDomingo": row[8],
                    "conteo": row[9],
                }
                for row in rows
            ]
            return {"sumDelitos": sumDelitos}, 200

        except Exception as e:
            return {"error": "Error de conexión con la base de datos", "details": str(e)}, 500

        finally:
            cursor.close()
            conn.close()
            
    def selectIncidentes(self, anios, mes):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            query = """
            SELECT
                anio,
                id_mes,
                conteo_robo_lunes,
                conteo_robo_martes,
                conteo_robo_miercoles,
                conteo_robo_jueves,
                conteo_robo_viernes,
                conteo_robo_sabado,
                conteo_robo_domingo,
                conteo_robo_transportista
            FROM sum_delitos_nacional_mes_anerpv sdnma
            """
            condiciones = []
            params = []

            if anios and anios != [0]:
                condiciones.append("sdnma.anio IN %s")
                params.append(tuple(anios))

            if mes and mes != [0]:
                condiciones.append("sdnma.id_mes IN %s")
                params.append(tuple(mes))

            if condiciones:
                query += " WHERE " + " AND ".join(condiciones)

            # Asegúrate de usar los parámetros
            cursor.execute(query, params)
            rows = cursor.fetchall()

            sumDelitos = [
                {
                    "anio": row[0],
                    "mes": row[1],
                    "conteoLunes": row[2],
                    "conteoMartes": row[3],
                    "conteoMiercoles": row[4],
                    "conteoJueves": row[5],
                    "conteoViernes": row[6],
                    "conteoSabado": row[7],
                    "conteoDomingo": row[8],
                    "conteo": row[9],
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
