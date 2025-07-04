import psycopg2
import traceback
import json
from datetime import datetime
from flask import jsonify
from flask import make_response
from app.configuraciones.cursor import get_cursor

class DelitosMunicipiosAnerpv_mapper():
    """
        Clase que mapea objetos MunicipiosDelitosAnerpv_mapper 
        a la tabla SUM_DELITOS_MUNICIPIO_MES_ANERPV
    """
#Recibe como parametro un objeto entidad
    def insert(self,DelitosMunicipiosAnerpv):
        try:
            with get_cursor() as cursor:
                cursor.execute(
                    "INSERT INTO sum_delitos_municipio_mes_anerpv (cve_municipio, anio, id_mes, conteo_robo_transportista, conteo_robo_transportista_acumulado) values (%s,%s,%s,%s,%s)",
                    (   
                        DelitosMunicipiosAnerpv.cve_municipio, 
                        DelitosMunicipiosAnerpv.anio, 
                        DelitosMunicipiosAnerpv.id_mes,
                        DelitosMunicipiosAnerpv.conteo_robo_transportista, 
                        DelitosMunicipiosAnerpv.conteo_robo_transportista_acumulado,
                    )
                )
                last_id = cursor.lastrowid
                response = {"insert": True, "MunicipiosDelitos":last_id}
                return response, 201
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexion del servidor"}), 500

    def delete(self,cve_municipio, anio, id_mes):
        try:
            with get_cursor() as cursor:
                cursor.execute(
                    """
                    DELETE FROM sum_delitos_municipio_mes_anerpv 
                    WHERE cve_municipio = %s 
                    AND anio = %s 
                    AND id_mes = %s 
                    RETURNING cve_municipio, anio, id_mes
                    """,
                    (
                        cve_municipio, 
                        anio, 
                        id_mes,  
                    )
                )
                delete_id = cursor.fetchone()
                if delete_id is None:
                    return {"Error": "El dato que insertó no existe"}, 404

                response = {"delete": True, "DelitosMunicipiosAnerpv": delete_id[0]}
                return response
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"}), 500

    def select_all(self):
        try:
            with get_cursor() as cursor:
                cursor.execute("select cve_municipio, anio, id_mes, conteo_robo_transportista, conteo_robo_transportista_acumulado from sum_delitos_municipio_mes_anerpv")
                rows = cursor.fetchall()
                mod = [{
                    "cveMunicipio": row[0], 
                    "anio": row[1],
                    "idMes": row[2],
                    "conteoRoboTransportista": row[3],
                    "conteoRoboTransportistaAcumulado": row[4],
                    } for row in rows]
                response = {"data": mod}
                return response, 200
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"}), 500
 
    def select_municipios_por_id_entidad(self, id_entidad):
            try:
                with get_cursor() as cursor:
                    query = """
                            SELECT sdmmav.cve_municipio, 
                                    sdmmav.municipio,
                                    sdmmav.abreviatura
                            FROM sum_delitos_municipio_mes_anerpv_vista sdmmav
                    """
                    condiciones = []
                    params = []  # Aquí incluirás los valores de tus listas concatenadas

                    if id_entidad and 0 not in id_entidad:
                        condiciones.append("sdmmav.id_entidad IN %s")
                        params.append(tuple(id_entidad))  # Usa una tupla para IN
                   
                    if condiciones:
                        query += " WHERE " + " AND ".join(condiciones)

                    query += """ 
                                GROUP BY sdmmav.cve_municipio, sdmmav.municipio, sdmmav.abreviatura
                                ORDER BY sdmmav.cve_municipio ASC
                            """

                    cursor.execute(query, params)

                    #Obtener los resultados como lista de tuplas
                    resultados = cursor.fetchall()

                    #Convertir los resultados a una lista para jsonify
                    idEntidad = [{"value": row[0], "label": row[1]+", " + row[2]} for row in resultados]
                    response = {"data": idEntidad}
                    return response
            except psycopg2.Error as e:
                    # Imprimir el stack trace completo
                    traceback.print_exc()
                    print(f"Error: {e}")
                    return {"Error": "Error conexion del servidor"}, 500

    def select_distinct_municipios(self):
        try:
            with get_cursor() as cursor:
                cursor.execute(
                        "SELECT distinct cve_municipio, municipio FROM sum_delitos_municipio_mes_anerpv_vista"
                )
                rows = cursor.fetchall()
                ent = [{
                    "value": row[0],
                    "label": row[1],
                    } for row in rows]
                response = {"data": ent}
                return response
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"}), 500

    def select_municipios_entidad(self):
        try:
            with get_cursor() as cursor:
                cursor.execute(
                        "SELECT distinct id_entidad, entidad FROM sum_delitos_municipio_mes_anerpv_vista"
                )
                rows = cursor.fetchall()
                ent = [{
                    "value": row[0],
                    "label": row[1],
                    } for row in rows]
                response = {"data": ent}
                return response
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"}), 500


    def select_vista(self,json):    
        try:
            # Extraer los parámetros del diccionario json
            anio = json.get('anio')
            id_mes = json.get('id_mes')
            cve_municipio = json.get('cve_municipio')
            id_entidad = json.get('id_entidad')

            with get_cursor() as cursor:    

                query = """
                        SELECT  sdmmav.cve_municipio,
                                sdmmav.municipio,
                                SUM(sdmmav.conteo_robo_transportista) as total_conteo
                        FROM sum_delitos_municipio_mes_anerpv_vista sdmmav                   
                        
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
                
                # Verificamos si cve_municipio no es None y agregamos la condición
                if cve_municipio is not None:
                    condiciones.append(
                        "cve_municipio IN ({})".format(self.concatenarListas(cve_municipio))
                    )                

                # Verificamos si cve_municipio no es None y agregamos la condición
                if id_entidad is not None:
                    condiciones.append(
                        "id_entidad IN ({})".format(self.concatenarListas(id_entidad))
                    )                

                # Si hay condiciones, las agregamos con WHERE o AND
                if condiciones:
                    query += " WHERE " + " AND ".join(condiciones)
                
                query += "GROUP BY sdmmav.cve_municipio, sdmmav.municipio;"
                
                #Ejecutamos la consulta
                cursor.execute(query)

                #Obtener los resultados como lista de tuplas
                resultados = cursor.fetchall()
                
                sum_del_mun_anerpv = {str(row[0]): int(row[2]) for row in resultados}
                response = {"data": sum_del_mun_anerpv}
                return response, 200
        except psycopg2.Error as e:
                print(f"Error: {e}")
                return jsonify({"Error": "Error conexión del servidor"}), 500

    def concatenarListas(self, lista):
        return ','.join(map(str, lista))