import psycopg2
import traceback
from datetime import datetime
from flask import jsonify
from flask import make_response
from app.configuraciones.cursor import get_cursor

class DelitosModalidadAnerpv_mapper():
    """
        Clase que mapea objetos DelitosModalidadAnerpv_mapper 
        a la tabla SUM_DELITOS_ENTIDAD_MES_MODALIDAD_ANERPV
    """
#Recibe como parametro un objeto entidad
    def insert(self,DelitosModalidadAnerpv):
        try:
            with get_cursor() as cursor:
                cursor.execute(
                    "INSERT INTO sum_delitos_entidad_mes_modalidad_anerpv (id_entidad, anio, id_mes, id_modalidad_anerpv, conteo_robo_transportista, conteo_robo_transportista_acumulado) values (%s,%s,%s,%s,%s,%s)",
                    (   
                        DelitosModalidadAnerpv.id_entidad, 
                        DelitosModalidadAnerpv.anio, 
                        DelitosModalidadAnerpv.id_mes, 
                        DelitosModalidadAnerpv.id_modalidad_anerpv, 
                        DelitosModalidadAnerpv.conteo_robo_transportista, 
                        DelitosModalidadAnerpv.conteo_robo_transportista_acumulado,
                    )
                )
                last_id = cursor.lastrowid
                response = {"insert": True, "idEntidad":last_id}
                return response, 201
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexion del servidor"}), 500

    def delete(self,id_entidad, anio, id_mes, id_modalidad_anerpv):
        try:
            with get_cursor() as cursor:
                cursor.execute(
                    """
                    DELETE FROM sum_delitos_entidad_mes_modalidad_anerpv 
                    WHERE id_entidad = %s 
                    AND anio = %s 
                    AND id_mes = %s 
                    AND id_modalidad_anerpv = %s 
                    RETURNING id_entidad, anio, id_mes, id_modalidad_anerpv
                    """,
                    (
                        id_entidad, 
                        anio, 
                        id_mes, 
                        id_modalidad_anerpv, 
                    )
                )
                delete_id = cursor.fetchone()
                if delete_id is None:
                    return {"Error": "El dato que insertó no existe"}, 404

                response = {"delete": True, "idEntidadModalidadAnerpv": delete_id[0]}
                return response
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"}), 500

    def select_all(self):
        try:
            with get_cursor() as cursor:
                cursor.execute("select id_entidad, anio, id_mes, id_modalidad_anerpv, conteo_robo_transportista, conteo_robo_transportista_acumulado from sum_delitos_entidad_mes_modalidad_anerpv")
                rows = cursor.fetchall()
                mod = [{
                    "idEntidad": row[0], 
                    "anio": row[1],
                    "idMes": row[2],
                    "idModalidadAnerpv": row[3],
                    "conteoRoboTransportista": row[4],
                    "conteoRoboTransportistaAcumulado": row[5],
                    } for row in rows]
                response = {"data": mod}
                return response, 200
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"}), 500