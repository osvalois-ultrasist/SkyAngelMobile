import psycopg2
import traceback
from datetime import datetime
from flask import jsonify
from flask import make_response
from app.configuraciones.cursor import get_cursor

class DelitosNacionalAnerpv_mapper():
    """
        Clase que mapea objetos DelitosNacionalAnerpv_mapper 
        a la tabla SUM_DELITOS_NACIONAL_MES_ANERPV
    """
#Recibe como parametro un objeto entidad
    def insert(self,DelitosNacionalAnerpv):
        try:
            with get_cursor() as cursor:
                cursor.execute(
                    "INSERT INTO sum_delitos_nacional_mes_anerpv ( anio, id_mes, conteo_robo_transportista, conteo_robo_transportista_acumulado, conteo_robo_vehiculos_pesados, conteo_robo_vehiculos_ligeros, conteo_robo_vehiculos_privados, conteo_robo_turno_matutino, conteo_robo_turno_madrugada, conteo_robo_turno_vespertino, conteo_robo_turno_nocturno,conteo_robo_lunes,conteo_robo_martes,conteo_robo_miercoles,conteo_robo_jueves,conteo_robo_viernes,conteo_robo_sabado,conteo_robo_domingo) values (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)",
                    (   
                        DelitosNacionalAnerpv.anio, 
                        DelitosNacionalAnerpv.id_mes, 
                        DelitosNacionalAnerpv.conteo_robo_transportista, 
                        DelitosNacionalAnerpv.conteo_robo_transportista_acumulado,
                        DelitosNacionalAnerpv.conteo_robo_vehiculos_pesados,
                        DelitosNacionalAnerpv.conteo_robo_vehiculos_ligeros,
                        DelitosNacionalAnerpv.conteo_robo_vehiculos_privados,
                        DelitosNacionalAnerpv.conteo_robo_turno_matutino,
                        DelitosNacionalAnerpv.conteo_robo_turno_madrugada,
                        DelitosNacionalAnerpv.conteo_robo_turno_vespertino,
                        DelitosNacionalAnerpv.conteo_robo_turno_nocturno,
                        DelitosNacionalAnerpv.conteo_robo_lunes,
                        DelitosNacionalAnerpv.conteo_robo_martes,
                        DelitosNacionalAnerpv.conteo_robo_miercoles,
                        DelitosNacionalAnerpv.conteo_robo_jueves,
                        DelitosNacionalAnerpv.conteo_robo_viernes,
                        DelitosNacionalAnerpv.conteo_robo_sabado,
                        DelitosNacionalAnerpv.conteo_robo_domingo,
                    )
                )
                last_id = cursor.lastrowid
                response = {"insert": True, "delitosNacional":last_id}
                return response, 201
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexion del servidor"}), 500

    ## QUEDA PENDIENTE POR CONFIRMAR PARA LA ACTUALIZACION
    def insert_or_update(self, datos):
        try:
            with get_cursor() as cursor:
                for record in datos:
                    cursor.execute(
                        """
                        INSERT INTO sum_delitos_entidad_mes_modalidad_anerpv (anio, id_mes, id_modalidad_anerpv, conteo_robo_transportista, conteo_robo_transportista_acumulado)
                        VALUES (%s,%s,%s,%s,%s,%s)
                        ON CONFLICT (id_entidad, anio, id_mes, id_modalidad_anerpv)
                        DO UPDATE SET
                        conteo_robo_transportista = EXCLUDED.conteo_robo_transportista
                        conteo_robo_transportista_acumulado = EXCLUDED.conteo_robo_transportista_acumulado;
                        """,
                        (
                            record['id_entidad'], 
                            record['anio'], 
                            record['id_mes'], 
                            record['id_modalidad_anerpv'], 
                            record['conteo_robo_transportista'],
                            record['conteo_robo_transportista_acumulado']
                        )               
                    )
                response = {"insert_or_update": True, "Mensaje": "Registro insertado o actualizado exitosamente"}
                return response, 200
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": f"Error conexion del servidor {e}"}), 500


    def delete(self,DelitosNacionalAnerpv):
        try:
            with get_cursor() as cursor:
                cursor.execute(
                    """
                    DELETE FROM sum_delitos_nacional_mes_anerpv 
                    WHERE anio = %s 
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
                    AND conteo_robo_lunes = %s 
                    AND conteo_robo_martes = %s 
                    AND conteo_robo_miercoles = %s 
                    AND conteo_robo_jueves = %s 
                    AND conteo_robo_viernes = %s 
                    AND conteo_robo_sabado = %s 
                    AND conteo_robo_domingo = %s 
                    RETURNING  anio, id_mes, conteo_robo_transportista, conteo_robo_transportista_acumulado, conteo_robo_vehiculos_pesados, conteo_robo_vehiculos_ligeros, conteo_robo_vehiculos_privados, conteo_robo_turno_matutino, conteo_robo_turno_madrugada, conteo_robo_turno_vespertino, conteo_robo_turno_nocturno,conteo_robo_lunes,conteo_robo_martes,conteo_robo_miercoles,conteo_robo_jueves,conteo_robo_viernes,conteo_robo_sabado,conteo_robo_domingo
                    """,
                    (
                        DelitosNacionalAnerpv.anio, 
                        DelitosNacionalAnerpv.id_mes, 
                        DelitosNacionalAnerpv.conteo_robo_transportista, 
                        DelitosNacionalAnerpv.conteo_robo_transportista_acumulado,
                        DelitosNacionalAnerpv.conteo_robo_vehiculos_pesados,
                        DelitosNacionalAnerpv.conteo_robo_vehiculos_ligeros,
                        DelitosNacionalAnerpv.conteo_robo_vehiculos_privados,
                        DelitosNacionalAnerpv.conteo_robo_turno_matutino,
                        DelitosNacionalAnerpv.conteo_robo_turno_madrugada,
                        DelitosNacionalAnerpv.conteo_robo_turno_vespertino,
                        DelitosNacionalAnerpv.conteo_robo_turno_nocturno,
                        DelitosNacionalAnerpv.conteo_robo_lunes,
                        DelitosNacionalAnerpv.conteo_robo_martes,
                        DelitosNacionalAnerpv.conteo_robo_miercoles,
                        DelitosNacionalAnerpv.conteo_robo_jueves,
                        DelitosNacionalAnerpv.conteo_robo_viernes,
                        DelitosNacionalAnerpv.conteo_robo_sabado,
                        DelitosNacionalAnerpv.conteo_robo_domingo,
                    )
                )
                delete_id = cursor.fetchone()
                if delete_id is None:
                    return {"Error": "El dato que insertó no existe"}, 404

                response = {"delete": True, "delitosNacional": delete_id[0]}
                return response
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"}), 500

    def select_all(self):
        try:
            with get_cursor() as cursor:
                cursor.execute("select anio, id_mes, conteo_robo_transportista, conteo_robo_transportista_acumulado, conteo_robo_vehiculos_pesados, conteo_robo_vehiculos_ligeros, conteo_robo_vehiculos_privados, conteo_robo_turno_matutino, conteo_robo_turno_madrugada, conteo_robo_turno_vespertino, conteo_robo_turno_nocturno, conteo_robo_lunes,conteo_robo_martes,conteo_robo_miercoles,conteo_robo_jueves,conteo_robo_viernes,conteo_robo_sabado,conteo_robo_domingo from sum_delitos_nacional_mes_anerpv")
                rows = cursor.fetchall()
                mod = [{
                    "anio": row[0],
                    "idMes": row[1],
                    "conteoRoboTransportista": row[2],
                    "conteoRoboTransportistaAcumulado": row[3],
                    "conteoRoboVehiculosPesados": row[4],
                    "conteoRoboVehiculosLigeros": row[5],
                    "conteoRoboVehiculosPrivados": row[6],
                    "conteoRoboTurnoMatutino": row[7],
                    "conteoRoboTurnoMadrugada": row[8],
                    "conteoRoboTurnoVespertino": row[9],
                    "conteoRoboTurnoNocturno": row[10],
                    "conteoRoboLunes": row[11],
                    "conteoRoboMartes": row[12],
                    "conteoRoboMiercoles": row[13],
                    "conteoRoboJueves": row[14],
                    "conteoRoboViernes": row[15],
                    "conteoRoboSabado": row[16],
                    "conteoRoboDomingo": row[17],
                    } for row in rows]
                response = {"data": mod}
                return response, 200
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"}), 500

    def concatenarListas(self, lista):
        return ','.join(map(str, lista))

    def select_anio(self,DelitosNacionalAnerpv):    
        try:
            with get_cursor() as cursor:
                query = """
                    SELECT  anio,
                            id_mes ,
                            conteo_robo_transportista ,
                            conteo_robo_transportista_acumulado ,
                            conteo_robo_vehiculos_pesados ,
                            conteo_robo_vehiculos_ligeros ,
                            conteo_robo_vehiculos_privados ,
                            conteo_robo_turno_matutino ,
                            conteo_robo_turno_madrugada ,
                            conteo_robo_turno_vespertino ,
                            conteo_robo_turno_nocturno ,
                            conteo_robo_lunes ,
                            conteo_robo_martes ,
                            conteo_robo_miercoles ,
                            conteo_robo_jueves ,
                            conteo_robo_viernes ,
                            conteo_robo_sabado ,
                            conteo_robo_domingo 
                    from sum_delitos_nacional_mes_anerpv sdnma 

                """
                # Lista de condiciones para WHERE
                condiciones = []

                # Verificamos si anio no es None y agregamos la condición
                if DelitosNacionalAnerpv.anio is not None:
                    condiciones.append(
                        "anio IN ({})".format(self.concatenarListas(DelitosNacionalAnerpv.anio))
                    )

                # Verificamos si id_mes no es None y agregamos la condición
                if DelitosNacionalAnerpv.id_mes is not None:
                    condiciones.append(
                        "id_mes IN ({})".format(self.concatenarListas(DelitosNacionalAnerpv.id_mes))
                    )

                # Si hay condiciones, las agregamos con WHERE o AND
                if condiciones:
                    query += " WHERE " + " AND ".join(condiciones)

                #Ejecutamos la consulta
                cursor.execute(query)

                #Obtener los resultados como lista de tuplas
                resultados = cursor.fetchall()
                
                sum_nac = [{
                        "anio": row[0],
                        "idMes": row[1],
                        "conteoRoboTransportista": row[2],
                        "conteoRoboTransportistaAcumulado": row[3],
                        "conteoRoboVehiculosPesados": row[4],
                        "conteoRoboVehiculosLigeros": row[5],
                        "conteoRoboVehiculosPrivados": row[6],
                        "conteoRoboTurnoMatutino": row[7],
                        "conteoRoboTurnoMadrugada": row[8],
                        "conteoRoboTurnoVespertino": row[9],
                        "conteoRoboTurnoNocturno": row[10],
                        "conteoRoboLunes": row[11],
                        "conteoRoboMartes": row[12],
                        "conteoRoboMiercoles": row[13],
                        "conteoRoboJueves": row[14],
                        "conteoRoboViernes": row[15],
                        "conteoRoboSabado": row[16],
                        "conteoRoboDomingo": row[17],
                     }for row in resultados]
                response = {"data": sum_nac}
                return response, 200
        except psycopg2.Error as e:
                print(f"Error: {e}")
                return jsonify({"Error": "Error conexión del servidor"}), 500

    def select_nacional(self,anio,id_mes): 
        try:
            with get_cursor() as cursor:
                query = """
                        SELECT 
                            SUM(conteo_robo_transportista) conteo
                        FROM sum_delitos_nacional_mes_anerpv
                """
                                # Lista de condiciones para WHERE
                condiciones = []

                # Verificamos si anio no es None y agregamos la condición
                if anio is not None:
                    condiciones.append(
                        "anio IN ({})".format(self.concatenarListas(anio))
                    )

                # Verificamos si id_mes no es None y agregamos la condición
                if id_mes is not None:
                    condiciones.append(
                        "id_mes IN ({})".format(self.concatenarListas(id_mes))
                    )

                # Si hay condiciones, las agregamos con WHERE o AND
                if condiciones:
                    query += " WHERE " + " AND ".join(condiciones)

                 #Ejecutamos la consulta
                cursor.execute(query)

                #Obtener los resultados como lista de tuplas
                resultados = cursor.fetchall()
                
                con_nac = [row[0] for row in resultados]
                response = {"valorNacional": con_nac[0]}
                return response, 200
        except psycopg2.Error as e:
                print(f"Error: {e}")
                return jsonify({"Error": "Error conexión del servidor"}), 500