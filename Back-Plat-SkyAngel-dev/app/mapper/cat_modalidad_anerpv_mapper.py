import psycopg2
import traceback
from datetime import datetime
from flask import jsonify
from flask import make_response
from app.configuraciones.cursor import get_cursor

class CatModalidadAnerpv_mapper():
    """
        Clase que mapea objetos CatModalidadAnerpv_mapper 
        a la tabla CAT_MODALIDAD_ANERPV
    """
#Recibe como parametro un objeto entidad
    def insert(self,modalidad_anerpv):
        try:
            with get_cursor() as cursor:
                cursor.execute("insert into cat_modalidad_anerpv (modalidad_anerpv) values (%s) RETURNING id_modalidad_anerpv",(modalidad_anerpv.modalidad_anerpv,))
                last_id = cursor.fetchone()[0]
                response = {"insert": True, "idModalidad":last_id}
                return response, 201
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexion del servidor"}), 500

    def update(self,modalidad_anerpv):
        try:
            with get_cursor() as cursor:
                #Procede a realizar UPDATE en caso que exista la id_modalidad
                cursor.execute("UPDATE cat_modalidad_anerpv set modalidad_anerpv = %s WHERE id_modalidad_anerpv = %s",
                    (modalidad_anerpv.modalidad_anerpv, modalidad_anerpv.id_modalidad_anerpv))
                response = {"update": True, "idModalidadAnerpv": modalidad_anerpv.id_modalidad_anerpv}
                return response, 200
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"}), 500

    def delete(self,id_modalidad_anerpv):
        try:
            with get_cursor() as cursor:
                cursor.execute("DELETE FROM cat_modalidad_anerpv WHERE id_modalidad_anerpv = %s RETURNING id_modalidad_anerpv",
                    (id_modalidad_anerpv,))

                delete_id = cursor.fetchone()
                if delete_id is None:
                    return {"Error": "idModalidadAnerpv no existe"}, 404

                response = {"delete": True, "idModalidadAnerpv": delete_id[0]}
                return response, 200
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"}), 500

    def select_all(self):
        try:
            with get_cursor() as cursor:
                cursor.execute("select id_modalidad_anerpv, modalidad_anerpv from cat_modalidad_anerpv")
                rows = cursor.fetchall()
                mod = [{"value": row[0], "label": row[1]} for row in rows]
                response = {"data": mod}
                return response, 200
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"}), 500