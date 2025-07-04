import psycopg2
import json
import traceback
from flask import jsonify
from flask import make_response
from app.configuraciones.config import Config
from app.modelos.conexion_bd import Conexion_BD
from app.configuraciones.cursor import get_cursor

class Cat_modalidad_mapper():
    """
        Clase que mapea objetos cat_bien_juridico_afectado 
        a la tabla CAT_BIEN_JURIDICO_AFECTADO
    """
 #Recibe como parametro un objeto entidad
    def insert(self,cat_modalidad):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            cursor.execute("insert into cat_modalidad (modalidad) values (%s) RETURNING id_modalidad",(cat_modalidad.modalidad,))
            last_id = cursor.fetchone()[0]
            conn.commit()
            response = {"insert": True, "id_modalidad":last_id}
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

    def update(self,cat_modalidad):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            #Verificar si la id_modalidad existe
            cursor.execute("SELECT 1 FROM cat_modalidad WHERE id_modalidad = %s" ,(cat_modalidad.id_modalidad,))
            if cursor.fetchone() is None:
                return {"Error": "id_modalidad no existe"}, 404
            
            #Procede a realizar UPDATE en caso que exista la id_modalidad
            cursor.execute("UPDATE cat_modalidad set modalidad= %s WHERE id_modalidad = %s",
                (cat_modalidad.modalidad, cat_modalidad.id_modalidad))

            conn.commit()
            response = {"update": True, "id_modalidad": cat_modalidad.id_modalidad}
            return response, 200
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"}), 500
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    def delete(self,id_modalidad):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            cursor.execute("DELETE FROM cat_modalidad WHERE id_modalidad = %s RETURNING id_modalidad",
                (id_modalidad,))

            delete_id = cursor.fetchone()
            if delete_id is None:
                return {"Error": "id_modalidad no existe"}, 404

            conn.commit()
            response = {"delete": True, "id_modalidad": delete_id[0]}
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
            cursor.execute("select id_modalidad, modalidad from cat_modalidad")
            rows = cursor.fetchall()
            mod = [{"value": row[0], "label": row[1]} for row in rows]
            response = {"data": mod}
            return response, 200
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"}), 500
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    def select_modalidad_por_idSubtipoDeDelito(self, id_subtipo_de_delito):
        try:

            conn = Conexion_BD().conexion_bd()
            cursor = conn.cursor()

            query = """
                    SELECT cds.id_modalidad, cm.modalidad
                    FROM cat_delitos_secretariado cds
                    LEFT JOIN cat_modalidad cm ON cds.id_modalidad = cm.id_modalidad
                    LEFT JOIN cat_subtipo_de_delito csdd ON cds.id_subtipo_de_delito = csdd.id_subtipo_de_delito
            """

            condiciones = []
            params = []  # Aquí incluirás los valores de tus listas concatenadas

            if id_subtipo_de_delito and 0 not in id_subtipo_de_delito:
                condiciones.append("cds.id_subtipo_de_delito IN %s")
                params.append(tuple(id_subtipo_de_delito))  # Usa una tupla para IN
            
            if condiciones:
                query += " WHERE " + " AND ".join(condiciones)

            query += """ 
                        GROUP BY cds.id_modalidad, cm.modalidad
                        ORDER BY cds.id_modalidad ASC
                    """

            #Ejecutamos la consulta
            cursor.execute(query, params)

            #Obtener los resultados como lista de tuplas
            resultados = cursor.fetchall()

            #Convertir los resultados a una lista para jsonify
            modalidad = [{"value": row[0], "label": row[1]} for row in resultados]
            response_data = {"data": modalidad}
            return response_data
        except psycopg2.Error as e:
            # Imprimir el stack trace completo
            traceback.print_exc()
            print(f"Error: {e}")
            return {"Error": "Error conexion del servidor"}, 500
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    def select_modalidad_delitos_vista(self, subtipoDeDelito):
        try:
            with get_cursor() as cursor:
                query = """
                        SELECT 
                            dv.id_subtipo_de_delito , 
                            dv.subtipo_de_delito, 
                            dv.id_modalidad, 
                            dv.modalidad, 
                            dv.descripcion_delito 
                        FROM delitos_vista dv
                """

                condiciones = []
                params = []  # Aquí incluirás los valores de tus listas concatenadas

                if subtipoDeDelito and 0 not in subtipoDeDelito:
                    condiciones.append("dv.id_subtipo_de_delito IN %s")
                    params.append(tuple(subtipoDeDelito))  # Usa una tupla para IN
                
                if condiciones:
                    query += " WHERE " + " AND ".join(condiciones)

                query += """ 
                            ORDER BY dv.id_modalidad ASC
                        """

                #Ejecutamos la consulta
                cursor.execute(query, params)

                #Obtener los resultados como lista de tuplas
                resultados = cursor.fetchall()

                #Convertir los resultados a una lista para jsonify
                delvista = [{"value": row[2], "label": row[4]} for row in resultados]
                response = {"data": delvista}
                return response
        except psycopg2.Error as e:
                print(f"Error: {e}")
                return {"Error": "Error conexion del servidor"}, 500

    def concatenarListas(self,lista,conector):
        return conector.join(map(str, lista))