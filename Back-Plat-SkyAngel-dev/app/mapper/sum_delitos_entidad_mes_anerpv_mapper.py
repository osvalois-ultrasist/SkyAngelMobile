import psycopg2
import traceback
from datetime import datetime
from flask import jsonify
from flask import make_response
from app.configuraciones.cursor import get_cursor

class DelitosEntidadAnerpv_mapper():
    """
        Clase que mapea objetos EntidadMesModalidadAnerpv_mapper 
        a la tabla SUM_DELITOS_ENTIDAD_MES_MODALIDAD_ANERPV
    """
#Recibe como parametro un objeto entidad
    def insert(self,DelitosEntidadAnerpv):
        try:
            with get_cursor() as cursor:
                cursor.execute(
                    "INSERT INTO sum_delitos_entidad_mes_anerpv (id_entidad, anio, id_mes, conteo_robo_transportista, conteo_robo_transportista_acumulado, conteo_robo_vehiculos_pesados, conteo_robo_vehiculos_ligeros, conteo_robo_vehiculos_privados, conteo_robo_turno_matutino, conteo_robo_turno_madrugada, conteo_robo_turno_vespertino, conteo_robo_turno_nocturno) values (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)",
                    (   
                        DelitosEntidadAnerpv.id_entidad, 
                        DelitosEntidadAnerpv.anio, 
                        DelitosEntidadAnerpv.id_mes, 
                        DelitosEntidadAnerpv.conteo_robo_transportista, 
                        DelitosEntidadAnerpv.conteo_robo_transportista_acumulado,
                        DelitosEntidadAnerpv.conteo_robo_vehiculos_pesados,
                        DelitosEntidadAnerpv.conteo_robo_vehiculos_ligeros,
                        DelitosEntidadAnerpv.conteo_robo_vehiculos_privados,
                        DelitosEntidadAnerpv.conteo_robo_turno_matutino,
                        DelitosEntidadAnerpv.conteo_robo_turno_madrugada,
                        DelitosEntidadAnerpv.conteo_robo_turno_vespertino,
                        DelitosEntidadAnerpv.conteo_robo_turno_nocturno,
                    )
                )
                last_id = cursor.lastrowid
                response = {"insert": True, "idEntidad":last_id}
                return response, 201
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexion del servidor"}), 500

    def delete(self,id_entidad, anio, id_mes, conteo_robo_transportista, conteo_robo_transportista_acumulado, conteo_robo_vehiculos_pesados, conteo_robo_vehiculos_ligeros, conteo_robo_vehiculos_privados, conteo_robo_turno_matutino, conteo_robo_turno_madrugada, conteo_robo_turno_vespertino, conteo_robo_turno_nocturno):
        try:
            with get_cursor() as cursor:
                cursor.execute(
                    """
                    DELETE FROM sum_delitos_entidad_mes_anerpv 
                    WHERE id_entidad = %s 
                    AND anio = %s   
                    AND id_mes = %s 
                    AND conteo_robo_transportista = %s 
                    AND conteo_robo_transportista_acumulado = %s 
                    AND conteo_robo_vehiculos_pesados = %s 
                    AND conteo_robo_vehiculos_ligeros = %s 
                    AND conteo_robo_vehiculos_privados = %s 
                    AND conteo_robo_turno_matutino = %s 
                    AND conteo_robo_turno_madrugada = %s 
                    AND conteo_robo_turno_vespertino = %s 
                    AND conteo_robo_turno_nocturno = %s 
                    RETURNING id_entidad, anio, id_mes, conteo_robo_transportista, conteo_robo_transportista_acumulado, conteo_robo_vehiculos_pesados, conteo_robo_vehiculos_ligeros, conteo_robo_vehiculos_privados, conteo_robo_turno_matutino, conteo_robo_turno_madrugada, conteo_robo_turno_vespertino, conteo_robo_turno_nocturno
                    """,
                    (
                        id_entidad, 
                        anio, 
                        id_mes, 
                        conteo_robo_transportista, 
                        conteo_robo_transportista_acumulado,
                        conteo_robo_vehiculos_pesados,
                        conteo_robo_vehiculos_ligeros,
                        conteo_robo_vehiculos_privados,
                        conteo_robo_turno_matutino,
                        conteo_robo_turno_madrugada,
                        conteo_robo_turno_vespertino,
                        conteo_robo_turno_nocturno,
                    )
                )
                delete_id = cursor.fetchone()
                if delete_id is None:
                    return {"Error": "El dato que insertó no existe"}, 404

                response = {"delete": True, "idEntidadDelitosAnerpv": delete_id[0]}
                return response
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"}), 500

    def select_all(self):
        try:
            with get_cursor() as cursor:
                cursor.execute("select id_entidad, anio, id_mes, conteo_robo_transportista, conteo_robo_transportista_acumulado, conteo_robo_vehiculos_pesados, conteo_robo_vehiculos_ligeros, conteo_robo_vehiculos_privados, conteo_robo_turno_matutino, conteo_robo_turno_madrugada, conteo_robo_turno_vespertino, conteo_robo_turno_nocturno from sum_delitos_entidad_mes_anerpv")
                rows = cursor.fetchall()
                mod = [{
                    "idEntidad": row[0], 
                    "anio": row[1],
                    "idMes": row[2],
                    "conteoRoboTransportista": row[3],
                    "conteoRoboTransportistaAcumulado": row[4],
                    "conteoRoboVehiculosPesados": row[5],
                    "conteoRoboVehiculosLigeros": row[6],
                    "conteoRoboVehiculosPrivados": row[7],
                    "conteoRoboTurnoMatutino": row[8],
                    "conteoRoboTurnoMadrugada": row[9],
                    "conteoRoboTurnoVespertino": row[10],
                    "conteoRoboTurnoNocturno": row[11],
                    } for row in rows]
                response = {"data": mod}
                return response, 200
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"}), 500

    def select_distinct_entidades(self):
        try:
            with get_cursor() as cursor:
                cursor.execute("select distinct id_entidad, entidad from sum_delitos_entidad_mes_anerpv_vista")
                rows = cursor.fetchall()
                mod = [{
                    "value": row[0], 
                    "label": row[1]
                    } for row in rows]
                response = {"data": mod}
                return response
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"}), 500

    def select_vista(self,DelitosEntidadAnerpv):    
        try:
            with get_cursor() as cursor:    

                query = """
                        SELECT  sdemav.id_entidad,
                                sdemav.entidad,
                                SUM(sdemav.conteo_robo_transportista) as total_conteo
                        FROM sum_delitos_entidad_mes_anerpv_vista sdemav                   
                        
                """
                # Lista de condiciones para WHERE
                condiciones = []

                # Verificamos si anio no es None y agregamos la condición
                if DelitosEntidadAnerpv.anio is not None:
                    condiciones.append(
                        "anio IN ({})".format(self.concatenarListas(DelitosEntidadAnerpv.anio))
                    )

                # Verificamos si id_mes no es None y agregamos la condición
                if DelitosEntidadAnerpv.id_mes is not None:
                    condiciones.append(
                        "id_mes IN ({})".format(self.concatenarListas(DelitosEntidadAnerpv.id_mes))
                    )
                
                # Verificamos si id_entidad no es None y agregamos la condición
                if DelitosEntidadAnerpv.id_entidad is not None:
                    condiciones.append(
                        "id_entidad IN ({})".format(self.concatenarListas(DelitosEntidadAnerpv.id_entidad))
                    )                

                # Si hay condiciones, las agregamos con WHERE o AND
                if condiciones:
                    query += " WHERE " + " AND ".join(condiciones)
                
                query += "GROUP BY sdemav.id_entidad, sdemav.entidad;"
                
                #Ejecutamos la consulta
                cursor.execute(query)

                #Obtener los resultados como lista de tuplas
                resultados = cursor.fetchall()
                
                sum_del_ent_anerpv = {str(row[0]): int(row[2]) for row in resultados}
                response = {"data": sum_del_ent_anerpv}
                return response, 200
        except psycopg2.Error as e:
                print(f"Error: {e}")
                return jsonify({"Error": "Error conexión del servidor"}), 500

    def concatenarListas(self, lista):
        return ','.join(map(str, lista))