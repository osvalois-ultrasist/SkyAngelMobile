import psycopg2
import traceback
import json
from flask import jsonify
from flask import make_response
from app.configuraciones.config import Config
from app.modelos.conexion_bd import Conexion_BD

class Cat_tipo_de_delito_mapper():
    """
        Clase que mapea objetos cat_tipo_de_delito 
        a la tabla CAT_TIPO_DE_DELITO
    """
 #Recibe como parametro un objeto entidad
    def insert(self,Cat_tipo_de_delito):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            cursor.execute("insert into cat_tipo_de_delito (tipo_de_delito, id_bien_juridico_afectado) values (%s, %s) RETURNING id_tipo_de_delito",(Cat_tipo_de_delito.tipo_de_delito, Cat_tipo_de_delito.id_bien_juridico_afectado ))
            last_id = cursor.fetchone()[0]
            conn.commit()
            response = {"insert": True, "id_tipo_de_delito":last_id}
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

    def update(self,Cat_tipo_de_delito):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            # Verificar si el id_tipo_de_delito existe
            cursor.execute("SELECT 1 FROM cat_tipo_de_delito WHERE id_tipo_de_delito = %s", (Cat_tipo_de_delito.id_tipo_de_delito,))
            if cursor.fetchone() is None:
                return {"Error": "id_tipo_de_delito no existe"}, 404

            #Realizar la actualización
            cursor.execute("UPDATE cat_tipo_de_delito set tipo_de_delito= %s, id_bien_juridico_afectado= %s WHERE id_tipo_de_delito = %s",
                (Cat_tipo_de_delito.tipo_de_delito, Cat_tipo_de_delito.id_bien_juridico_afectado, Cat_tipo_de_delito.id_tipo_de_delito))

            conn.commit()
            response = {"update": True, "id_tipo_de_delito": Cat_tipo_de_delito.id_tipo_de_delito}
            return response, 200
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexion del servidor"}), 500
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    def delete(self,id_tipo_de_delito):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            cursor.execute("DELETE FROM cat_tipo_de_delito WHERE id_tipo_de_delito = %s RETURNING id_tipo_de_delito",
                (id_tipo_de_delito,))
            delete_id = cursor.fetchone()
            if delete_id is None:
                return {"Error": "id_tipo_de_delito no existe"}, 404
            conn.commit()
            response = {"delete": True, "id_tipo_de_delito": delete_id[0]}
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
            cursor.execute("select id_tipo_de_delito, tipo_de_delito, id_bien_juridico_afectado from cat_tipo_de_delito")
            rows = cursor.fetchall()
            tipo = [{"value": row[0],
            "label": row[1]} for row in rows]
            response = {"data": tipo}
            return response, 200
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"}), 500
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    def select_por_id_bien(self, id_bien_juridico_afectado):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            cursor.execute("SELECT id_tipo_de_delito, tipo_de_delito FROM cat_tipo_de_delito WHERE id_bien_juridico_afectado = %s", (id_bien_juridico_afectado,))
            rows = cursor.fetchall()
            tipo_delito = [{"value": row[0], "label": row[1]} for row in rows]
            response = {"data": tipo_delito}
            return response, 200
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"}), 500
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    def select_tipoDeDelito_por_idBienJuridico(self, id_bien_juridico_afectado):
        try:

            conn = Conexion_BD().conexion_bd()
            cursor = conn.cursor()

            query = """
                    SELECT ctdd.id_tipo_de_delito, ctdd.tipo_de_delito
                    FROM cat_tipo_de_delito ctdd          
            """
            condiciones = []
            params = []  # Aquí incluirás los valores de tus listas concatenadas

            if id_bien_juridico_afectado and 0 not in id_bien_juridico_afectado:
                condiciones.append("ctdd.id_bien_juridico_afectado IN %s")
                params.append(tuple(id_bien_juridico_afectado))  # Usa una tupla para IN
            
            if condiciones:
                query += " WHERE " + " AND ".join(condiciones)

            query += """ 
                    ORDER BY ctdd.id_tipo_de_delito ASC
                """

            #Ejecutamos la consulta
            cursor.execute(query, params)

            #Obtener los resultados como lista de tuplas
            resultados = cursor.fetchall()

            #Convertir los resultados a una lista
            tipoDeDelitos = [{"value": row[0], "label": row[1]} for row in resultados]
            response_data = {"data": tipoDeDelitos}

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

    def concatenarListas(self,lista,conector):
        return conector.join(map(str, lista))
