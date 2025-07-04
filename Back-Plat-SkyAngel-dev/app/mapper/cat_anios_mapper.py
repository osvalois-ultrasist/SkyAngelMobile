import psycopg2
from flask import jsonify
from app.configuraciones.config import Config
from app.modelos.conexion_bd import Conexion_BD
from app.configuraciones.cursor import get_cursor

class Anios_mapper():
    
    def select_distinct_anios(self):
        try:
            with get_cursor() as cursor:

                query = """
                        SELECT DISTINCT anio 
                        FROM sum_delitos_municipio_mes_vista sdmm
                        ORDER BY anio ASC;
                        """
                cursor.execute(query)

                rows = cursor.fetchall()
                
                anios = [{"label": row[0], "value": row[0]} for row in rows]
                response = {"data": anios}
                return response
        except psycopg2.Error as e:
                print(f"Error: {e}")
                return jsonify({"Error": "Error conexión del servidor"})

    def select_distinct_anios_fe(self):
        try:
            with get_cursor() as cursor:
                query = """
                        SELECT DISTINCT sdmmav.anio 
                        FROM sum_delitos_municipio_mes_anerpv_vista sdmmav
                        ORDER BY sdmmav.anio ASC;
                        """
                cursor.execute(query)

                rows = cursor.fetchall()
                
                anios = [{"label": row[0], "value": row[0]} for row in rows]
                response = {"data": anios}
                return response
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"})
        
    def select_distinct_anios_sa(self):
        try:
            with get_cursor() as cursor:

                # Consulta para obtener los años de los puntos de interés de SkyAngel
                query = """
                        SELECT DISTINCT i.anio
                        FROM int_inc_delictivas i
                        UNION
                        SELECT DISTINCT o.anio
                        FROM int_otras_incidencias o
                        UNION
                        SELECT DISTINCT a.anio
                        FROM int_accidentes a
                        UNION
                        SELECT DISTINCT r.anio
                        FROM int_recuperacion r
                        ORDER BY anio ASC;
                        """
                cursor.execute(query)

                rows = cursor.fetchall()

                anios = [{"label": row[0], "value": row[0]} for row in rows]
                response = {"data": anios}
                return response
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"})
