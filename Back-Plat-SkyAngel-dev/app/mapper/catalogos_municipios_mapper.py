import psycopg2
import traceback
import json
from flask import jsonify
from flask import make_response
from app.configuraciones.cursor import get_cursor
from app.configuraciones.config import Config
from app.modelos.conexion_bd import Conexion_BD

class Municipios_mapper():
    """
        Clase que mapea objetos Catalogos_Municipios 
        a la tabla CATALOGOS_MUNICIPIOS
    """
 #Recibe como parametro un objeto municipio
    def insert(self,municipios):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            cursor.execute("insert into catalogo_municipios (cve_municipio, municipio, latitud_centroide, longitud_centroide, id_entidad) values (%s,%s,%s,%s,%s) RETURNING cve_municipio",(municipios.cve_municipio, municipios.municipio,municipios.latitud_centroide,municipios.longitud_centroide,municipios.id_entidad,))
            last_id = cursor.fetchone()[0]
            conn.commit()
            response = {"insert": True, "cve_municipio":last_id}
            return response, 200
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexion del servidor"}), 500
        finally:
            # Cerrar la conexión y el cursor
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    def update(self,municipios):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            cursor.execute("UPDATE catalogo_municipios set municipio= %s, latitud_centroide= %s, longitud_centroide= %s, id_entidad= %s  WHERE cve_municipio = %s",
                (municipios.municipio,municipios.latitud_centroide,municipios.longitud_centroide,municipios.id_entidad,municipios.cve_municipio))
            conn.commit()
            response = {"update": True, "cve_municipio": municipios.cve_municipio}
            return response, 200
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"}), 500
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    def delete(self,cve_municipio):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            cursor.execute("DELETE FROM catalogo_municipios WHERE cve_municipio = %s RETURNING cve_municipio",
                (cve_municipio,))
            delete_id = cursor.fetchone()
            if delete_id is None:
                return {"Error": "id_entidad no existe"}, 404
            conn.commit()
            response = {"delete": True, "cve_municipio": delete_id[0]}
            return response, 200
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"}), 500
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    def select_all(self):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            cursor.execute("select cve_municipio, municipio, latitud_centroide, longitud_centroide,id_entidad from catalogo_municipios")
            rows = cursor.fetchall()
            mun = [{"value": row[0], "label": row[1]} for row in rows]
            response = {"data": mun}
            return response, 200
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"}), 500
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    def select_por_id_entidad(self, id_entidad):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            cursor.execute("SELECT cve_municipio, municipio FROM catalogo_municipios WHERE id_entidad = %s", (id_entidad,))
            rows = cursor.fetchall()
            municipios = [{"value": row[0], "label": row[1]} for row in rows]
            response = {"data": municipios}
            return response, 200
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"}), 500
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    def select_municipios_por_idEntidad(self, id_entidad):
        try:
            with get_cursor() as cursor:

                query = """
                        SELECT 
                                cm.cve_municipio, 
                                cm.municipio, 
                                ce.abreviatura 
                        FROM catalogo_municipios cm
                        LEFT JOIN cat_entidad ce ON cm.id_entidad = ce.id_entidad                  
                """

                condiciones = []
                params = []  # Aquí incluirás los valores de tus listas concatenadas

                if id_entidad and 0 not in id_entidad:
                    condiciones.append("cm.id_entidad IN %s")
                    params.append(tuple(id_entidad))  # Usa una tupla para IN
                
                if condiciones:
                    query += " WHERE " + " AND ".join(condiciones)

                query += """ 
                            ORDER BY cm.cve_municipio ASC
                        """

                #Ejecutamos la consulta
                cursor.execute(query, params)

                #Obtener los resultados como lista de tuplas
                resultados = cursor.fetchall()

                #Convertir los resultados a una lista para jsonify
                idEntidad = [{"value": row[0], "label": row[1] +", "+ row[2]} for row in resultados]
                response = {"data": idEntidad}
                return response

        except psycopg2.Error as e:
                print(f"Error: {e}")
                return {"Error": "Error conexion del servidor"}


    def concatenarListas(self,lista,conector):
        return conector.join(map(str, lista))