import psycopg2
from flask import jsonify
from app.configuraciones.config import Config
from app.modelos.conexion_bd import Conexion_BD

class Cat_delitos_secretariado_mapper():
    """
        Clase que mapea objetos cat_delitos_secretariado 
        a la tabla CAT_DELITOS_SECRETARIADO
    """
 #Recibe como parametro un objeto entidad
    def insert(self,Cat_delitos_secretariado):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            # Verificar si el id_subtipo_de_delito existe
            cursor.execute("SELECT 1 FROM cat_subtipo_de_delito WHERE id_subtipo_de_delito = %s", (Cat_delitos_secretariado.id_subtipo_de_delito,))
            if cursor.fetchone() is None:
                return {"Error": "id_subtipo_de_delito no existe"}, 404

            # Verificar si el id_modalidad existe
            cursor.execute("SELECT 1 FROM cat_modalidad WHERE id_modalidad = %s", (Cat_delitos_secretariado.id_modalidad,))
            if cursor.fetchone() is None:
                return {"Error": "id_modalidad no existe"}, 404

            #Verificar si id_modalidad e id_subtipo_de_delito existen en la base de datos
            cursor.execute("SELECT 1 FROM cat_delitos_secretariado WHERE id_modalidad = %s AND id_subtipo_de_delito = %s", (Cat_delitos_secretariado.id_modalidad,Cat_delitos_secretariado.id_subtipo_de_delito,))
            if cursor.fetchone() is not None:
                return {"Error": "id_subtipo_de_delito y id_modalidad existen"}, 404

            #Proceder con el insert en caso de que exista id_tipo_de_delito
            cursor.execute("insert into cat_delitos_secretariado (id_subtipo_de_delito, id_modalidad) values (%s, %s) RETURNING id_delito",(Cat_delitos_secretariado.id_subtipo_de_delito, Cat_delitos_secretariado.id_modalidad ))
            last_id = cursor.fetchone()[0]
            conn.commit()
            response = {"insert": True, "id_delito":last_id}
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

    def update(self,Cat_delitos_secretariado):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            #Verificar si el id_delito existe
            cursor.execute("SELECT 1 FROM cat_delitos_secretariado WHERE id_delito = %s",(Cat_delitos_secretariado.id_delito,))
            if cursor.fetchone() is None:
                return {"Error": "id_delito no existe"}, 404

            # Verificar si el id_subtipo_de_delito existe
            cursor.execute("SELECT 1 FROM cat_subtipo_de_delito WHERE id_subtipo_de_delito = %s", (Cat_delitos_secretariado.id_subtipo_de_delito,))
            if cursor.fetchone() is None:
                return {"Error": "id_subtipo_de_delito no existe"}, 404

            # Verificar si el id_modalidad existe
            cursor.execute("SELECT 1 FROM cat_modalidad WHERE id_modalidad = %s", (Cat_delitos_secretariado.id_modalidad,))
            if cursor.fetchone() is None:
                return {"Error": "id_modalidad no existe"}, 404

            #Realizar la actualización
            cursor.execute("UPDATE cat_delitos_secretariado set id_subtipo_de_delito= %s, id_modalidad= %s WHERE id_delito = %s",
                (Cat_delitos_secretariado.id_subtipo_de_delito, Cat_delitos_secretariado.id_modalidad, Cat_delitos_secretariado.id_delito))

            conn.commit()
            response = {"update": True, "id_delito": Cat_delitos_secretariado.id_delito}
            return response, 200
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexion del servidor"}), 500
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    def delete(self,id_delito):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            cursor.execute("DELETE FROM cat_delitos_secretariado WHERE id_delito = %s RETURNING id_delito",
                (id_delito,))

            delete_id = cursor.fetchone()
            if delete_id is None:
                return {"Error": "id_delito no existe"}, 404

            conn.commit()
            response = {"delete": True, "id_delito": delete_id[0]}
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
            cursor.execute("select id_delito, id_subtipo_de_delito, id_modalidad from cat_delitos_secretariado")
            rows = cursor.fetchall()
            delitos_sec = [{"idDelito": row[0],
            "idSubtipoDeDelito": row[1],
            "idModalidad": row[2]} for row in rows]
            response = {"catDelitosSecretariado": delitos_sec}
            return response, 200
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"}), 500
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    def select_por_id_subtipo(self, id_subtipo_de_delito):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            cursor.execute(
                """
                    SELECT cds.id_subtipo_de_delito, csdd.subtipo_de_delito, cds.id_modalidad, cm.modalidad
                        FROM cat_delitos_secretariado cds
                    LEFT JOIN cat_subtipo_de_delito csdd ON cds.id_subtipo_de_delito = csdd.id_subtipo_de_delito
                    LEFT JOIN cat_modalidad cm ON cds.id_modalidad = cm.id_modalidad
                        WHERE cds.id_subtipo_de_delito = %s
                    ORDER BY cds.id_subtipo_de_delito ASC, cds.id_modalidad ASC
                """, (id_subtipo_de_delito,))
            rows = cursor.fetchall()
            subtipo_delito = [{"idModalidad": row[2], "modalidad": row[3]} for row in rows]
            response = {"subTipoDeDelito": subtipo_delito}
            return response, 200
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"}), 500
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()