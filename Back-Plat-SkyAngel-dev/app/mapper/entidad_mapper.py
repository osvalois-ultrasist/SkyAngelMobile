import psycopg2
from flask import jsonify
# from app.modelos.entidad import Entidad
from app.configuraciones.config import Config
from app.modelos.conexion_bd import Conexion_BD

class Entidad_mapper():
    """
        Clase que mapea objetos Entidad 
        a la tabla CAT_ENTIDAD
    """
 #Recibe como parametro un objeto entidad
    def insert(self,entidad):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            cursor.execute("insert into cat_entidad (entidad) values (%s) RETURNING id_entidad",(entidad.entidad,))
            last_id = cursor.fetchone()[0]
            conn.commit()
            response = {"insert": True, "id_entidad":last_id}
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

    def update(self,entidad):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            cursor.execute("UPDATE cat_entidad set entidad= %s WHERE id_entidad = %s",
                (entidad.entidad, entidad.id_entidad))
            conn.commit()
            response = {"update": True, "id_entidad": entidad.id_entidad}
            return response, 200
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"}), 500
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    def delete(self,id_entidad):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            cursor.execute("DELETE FROM cat_entidad WHERE id_entidad = %s RETURNING id_entidad",
                (id_entidad,))
            delete_id = cursor.fetchone()
            if delete_id is None:
                return {"Error": "id_entidad no existe"}, 404
            conn.commit()
            response = {"delete": True, "id_entidad": delete_id[0]}
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
            cursor.execute("select id_entidad, entidad from cat_entidad")
            rows = cursor.fetchall()
            entidades = [{"value": row[0], "label": row[1]} for row in rows]
            response = {"data": entidades}
            return response
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"}), 500
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()