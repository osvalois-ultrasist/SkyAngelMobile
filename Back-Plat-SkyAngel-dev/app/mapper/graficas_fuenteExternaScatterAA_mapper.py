from psycopg2 import sql
from flask import jsonify
from app.modelos.conexion_bd import Conexion_BD
from app.configuraciones.cursor import get_cursor

class fuenteExternaScatterMapper:
    def listToString(self, lista, delimiter=", "):
        stringList = [str(element) for element in lista]
        return delimiter.join(stringList)

    def selectIncidentes(self, anios, mes, entidad, municipio):
        with get_cursor() as cursor:
            try:
                query = """
                        SELECT 
                            sdemav.anio, 
                            sdemav.id_mes, 
                            sdemav.mes, 
                            SUM(sdemav.conteo_robo_transportista) AS total_robos
                        FROM 
                            sum_delitos_entidad_mes_anerpv_vista sdemav
                        JOIN 
                            sum_delitos_municipio_mes_anerpv_vista sdmmav
                        ON 
                            sdemav.id_entidad = sdmmav.id_entidad
                            AND sdemav.anio = sdmmav.anio
                            AND sdemav.id_mes = sdmmav.id_mes
                """
                condiciones = []
                params = []

                if anios and 0 not in anios:
                    condiciones.append("sdemav.anio IN %s")
                    params.append(tuple(anios))

                if mes and 0 not in mes:
                    condiciones.append("sdemav.id_mes IN %s")
                    params.append(tuple(mes))

                if entidad and 0 not in entidad:
                    condiciones.append("sdemav.id_entidad IN %s")
                    params.append(tuple(entidad))

                if municipio and 0 not in municipio:
                    condiciones.append("sdmmav.cve_municipio IN %s")
                    params.append(tuple(municipio))

                if condiciones:
                    query += " WHERE " + " AND ".join(condiciones)

                query += """
                            GROUP BY 
                            sdemav.anio, sdemav.id_mes, sdemav.mes 
                            ORDER BY 
                            sdemav.anio, sdemav.id_mes
                        """
                
                # Asegúrate de usar los parámetros
                cursor.execute(query, params)
                rows = cursor.fetchall()

                sumDelitos = [
                    {
                        "anio": row[0],
                        "idMes": row[1],
                        "mes": row[2],
                        "conteo": row[3]
                    }
                    for row in rows
                ]
                return {"data": sumDelitos}, 200
            except Exception as e:
                print(f"Error: {e}")
                return {"Error": "Error conexión del servidor"}, 500