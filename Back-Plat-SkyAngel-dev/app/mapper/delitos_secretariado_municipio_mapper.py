import psycopg2
from flask import jsonify
from app.configuraciones.config import Config
from app.modelos.conexion_bd import Conexion_BD

class Delitos_secretariado_municipio_mapper():
    """
        Clase que mapea objetos Delitos_secretariado_municipio 
        a la tabla DELITOS_SECRETARIADO_MUNICIPIO
    """
 #Recibe como parametro un objeto entidad
    def insert(self,Delitos_secretariado_municipio):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            # Verificar si el id_delito existe
            cursor.execute("SELECT 1 FROM cat_delitos_secretariado WHERE id_delito = %s", (Delitos_secretariado_municipio.id_tipo_de_delito,))
            if cursor.fetchone() is None:
                return {"Error": "id_delito no existe"}, 404

            # Verificar si el cve_municipio existe
            cursor.execute("SELECT 1 FROM catalogo_municipios WHERE cve_municipio = %s", (Delitos_secretariado_municipio.cve_municipio,))
            if cursor.fetchone() is None:
                return {"Error": "cve_municipio no existe"}, 404

            #Proceder con el insert en caso de que exista id_tipo_de_delito
            cursor.execute("insert into delitos_secretariado_municipio (id_tipo_de_delito, cve_municipio) values (%s, %s) RETURNING id_delito_municipio",(Delitos_secretariado_municipio.id_tipo_de_delito, Delitos_secretariado_municipio.cve_municipio))
            last_id = cursor.fetchone()[0]
            conn.commit()
            response = {"insert": True, "id_delito_municipio":last_id}
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

    def update(self,Delitos_secretariado_municipio):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            #Verificar si el id_delito_municipio existe
            cursor.execute("SELECT 1 FROM delitos_secretariado_municipio WHERE id_delito_municipio = %s",(Delitos_secretariado_municipio.id_delito_municipio,))
            if cursor.fetchone() is None:
                return {"Error": "id_delito_municipio no existe"}, 404

            # Verificar si el id_delito existe
            cursor.execute("SELECT 1 FROM cat_delitos_secretariado WHERE id_delito = %s", (Delitos_secretariado_municipio.id_tipo_de_delito,))
            if cursor.fetchone() is None:
                return {"Error": "id_delito no existe"}, 404

            # Verificar si el cve_municipio existe
            cursor.execute("SELECT 1 FROM catalogo_municipios WHERE cve_municipio = %s", (Delitos_secretariado_municipio.cve_municipio,))
            if cursor.fetchone() is None:
                return {"Error": "cve_municipio no existe"}, 404

            #Realizar la actualización
            cursor.execute("UPDATE delitos_secretariado_municipio set id_tipo_de_delito= %s, cve_municipio= %s WHERE id_delito_municipio = %s",
                (Delitos_secretariado_municipio.id_tipo_de_delito, Delitos_secretariado_municipio.cve_municipio, Delitos_secretariado_municipio.id_delito_municipio))

            conn.commit()
            response = {"update": True, "id_delito_municipio": Delitos_secretariado_municipio.id_delito_municipio}
            return response, 200
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexion del servidor"}), 500
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    def delete(self,id_delito_municipio):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            cursor.execute("DELETE FROM delitos_secretariado_municipio WHERE id_delito_municipio = %s RETURNING id_delito_municipio",
                (id_delito_municipio,))

            delete_id = cursor.fetchone()
            if delete_id is None:
                return {"Error": "id_delito_municipio no existe"}, 404

            conn.commit()
            response = {"delete": True, "id_delito_municipio": delete_id[0]}
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
            cursor.execute("select id_delito_municipio, id_tipo_de_delito, cve_municipio from delitos_secretariado_municipio")
            rows = cursor.fetchall()
            del_sec_mun = [{"idDelitoMunicipio": row[0],
            "idTipoDeDelito": row[1],
            "cveMunicipio": row[2]} for row in rows]
            response = {"delitosSecretariadoMunicipio": del_sec_mun}
            return response, 200
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"}), 500
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()