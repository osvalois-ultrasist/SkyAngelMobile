import psycopg2
from flask import jsonify
from app.modelos.conexion_bd import Conexion_BD

class Incidencias_por_anio_mapper():
    """
    Clase que mapea objetos Sum_delitos_municipio_mes_mapper 
    a la tabla SUM_DELITOS_MUNICIPIO_MES_MAPPER
    """

    def list_to_string(self, lista, delimiter=", "):
        string_list = [str(element) for element in lista]
        result_string = delimiter.join(string_list)
        return result_string


    def select_incidentes(self, anios, mes, incidencias, municipios):
        # Conexión a la base de datos
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:

            anios_str = self.list_to_string(anios)
            mes_str = self.list_to_string(mes)
            incidencias_str = self.list_to_string(incidencias)
            municipios_str = self.list_to_string(municipios)

            # Consulta SQL usando las listas convertidas a cadenas
            query = f"""
                with delitos as 
                (select id_delito_municipio from delitos_secretariado_municipio
                where id_tipo_de_delito in ({incidencias_str})
                and cve_municipio in ({municipios_str}))
                SELECT s.id_mes, s.id_delito_municipio, s.anio, s.conteo
                FROM sum_delitos_municipio_mes s 
                right join delitos d
                on d.id_delito_municipio = s.id_delito_municipio
                WHERE s.anio IN ({anios_str})
                AND s.id_mes IN ({mes_str})
            """

            # Ejecutar la consulta SQL
            cursor.execute(query)
            rows = cursor.fetchall()

            # Procesar los resultados
            sum_del_mun = [
                {
                    "id_mes": row[0],
                    "id_delito_municipio": row[1],
                    "anio": row[2],
                    "conteo": row[3]
                }
                for row in rows
            ]

            # Devolver la respuesta en formato JSON
            response = {"sum_delitos": sum_del_mun}
            return response, 200

        except Exception as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"}), 500

        finally:
            cursor.close()
            conn.close()