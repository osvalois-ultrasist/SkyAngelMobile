import psycopg2
from flask import jsonify
from app.configuraciones.config import Config
from app.modelos.conexion_bd import Conexion_BD

class Cat_bien_juridico_mapper():
    """
        Clase que mapea objetos cat_bien_juridico_afectado 
        a la tabla CAT_BIEN_JURIDICO_AFECTADO
    """
    #Recibe como parametro un objeto entidad
    #INSERT
    def insert(self,cat_bien_juridico_afectado):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            cursor.execute("insert into cat_bien_juridico_afectado (bien_juridico_afectado) values (%s) RETURNING id_bien_juridico_afectado",(cat_bien_juridico_afectado.bien_juridico_afectado,))
            last_id = cursor.fetchone()[0]
            conn.commit()
            response = {"insert": True, "id_bien_juridico_afectado":last_id}
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
    #UPDATE
    def update(self,cat_bien_juridico_afectado):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            cursor.execute("UPDATE cat_bien_juridico_afectado set bien_juridico_afectado= %s WHERE id_bien_juridico_afectado = %s",
                (cat_bien_juridico_afectado.bien_juridico_afectado, cat_bien_juridico_afectado.id_bien_juridico_afectado))
            conn.commit()
            response = {"update": True, "id_bien_juridico_afectado": cat_bien_juridico_afectado.id_bien_juridico_afectado}
            return response, 200
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"}), 500
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()
    #DELETE
    def delete(self,id_bien_juridico_afectado):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            cursor.execute("DELETE FROM cat_bien_juridico_afectado WHERE id_bien_juridico_afectado = %s RETURNING id_bien_juridico_afectado",
                (id_bien_juridico_afectado,))
            delete_id = cursor.fetchone()
            if delete_id is None:
                return {"Error": "id_bien_juridico_afectado no existe"}, 404
            conn.commit()
            response = {"delete": True, "id_bien_juridico_afectado": delete_id[0]}
            return response, 200
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"}), 500
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()
    
    #SELECT ALL
    def select_all(self):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            cursor.execute("select id_bien_juridico_afectado, bien_juridico_afectado from cat_bien_juridico_afectado")
            rows = cursor.fetchall()
            bien = [{"value": row[0], "label": row[1]} for row in rows]
            response = {"data": bien}
            return response, 200
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"}), 500
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()