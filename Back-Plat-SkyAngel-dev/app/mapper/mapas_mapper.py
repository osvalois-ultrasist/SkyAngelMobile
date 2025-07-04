import psycopg2
import traceback
from datetime import datetime
from flask import jsonify
from flask import make_response
from app.configuraciones.config import Config
from app.configuraciones.cursor import get_cursor    
   
   
class Mapas_mapper():

    def select_delitos_vista(self, municipios, anios, meses, delitos):    
        try:
            with get_cursor() as cursor:
                query = """
                        select 
                                sdmmv.id_municipio,
                                sdmmv.municipio,
                                dv.id_delito, 
                                dv.descripcion_delito,
                                SUM(conteo) AS total_conteo
                        from delitos_vista dv
                        left join sum_delitos_municipio_mes_vista sdmmv on dv.id_modalidad = sdmmv.id_modalidad and dv.id_subtipo_de_delito = sdmmv.id_subtipo_de_delito
                """
                condiciones = []
                params = []  # Aquí incluirás los valores de tus listas concatenadas

                if anios is not None:
                    condiciones.append("sdmmv.anio IN %s")
                    params.append(tuple(anios))  # Usa una tupla para IN

                if meses is not None:
                    condiciones.append("sdmmv.id_mes IN %s")
                    params.append(tuple(meses))

                if municipios is not None:
                    condiciones.append("sdmmv.id_municipio IN %s")
                    params.append(tuple(municipios))

                if delitos is not None:
                    condiciones.append("dv.id_delito IN %s")
                    params.append(tuple(delitos))

                if condiciones:
                    query += " WHERE " + " AND ".join(condiciones)

                query += " GROUP BY sdmmv.id_municipio, sdmmv.municipio, dv.id_delito, dv.descripcion_delito"

                cursor.execute(query, params)

                #Obtener los resultados como lista de tuplas
                resultados = cursor.fetchall()
                
                mapas = [{"cveMunicipio": f"{row[0]:05d}",
                "descripcionMunicipio": f"{row[1]},{self.obtener_abreviatura_estado(row[0])}",
                "idDelito":row[2], 
                "descripcionDelito":row[3], 
                "conteoDelitos": row[4]} for row in resultados]
                response = {"data": mapas}
                return response
        except psycopg2.Error as e:
                print(f"Error: {e}")
                return jsonify({"Error": "Error conexión del servidor"})


    def obtener_abreviatura_estado(self, cve_municipio):
        # Normalizar clave de municipio a 5 dígitos
        cve_municipio_str = str(cve_municipio).zfill(5)
        clave_estado = cve_municipio_str[:2]  # Extraer los primeros dos dígitos
        estados_abreviaturas = {
            "01": "AGS", "02": "BC", "03": "BCS", "04": "CAMP", "05": "COAH", "06": "COL",
            "07": "CHIS", "08": "CHIH", "09": "CDMX", "10": "DGO", "11": "GTO", "12": "GRO",
            "13": "HGO", "14": "JAL", "15": "MEX", "16": "MICH", "17": "MOR", "18": "NAY",
            "19": "NL", "20": "OAX", "21": "PUE", "22": "QRO", "23": "QROO", "24": "SLP",
            "25": "SIN", "26": "SON", "27": "TAB", "28": "TAMPS", "29": "TLAX", "30": "VER",
            "31": "YUC", "32": "ZAC",
        }
        return estados_abreviaturas.get(clave_estado, "N/A")  # Formatea clave a 2 dígitos

    def select_vista(self, municipios, anios, meses, subtiposDelitos, modalidades):    
        try:
            with get_cursor() as cursor:
                query = """
                    SELECT id_municipio ,
                            municipio,
                            SUM(conteo) AS total_conteo	   
                    FROM sum_delitos_municipio_mes_vista sdmmv
                """
                condiciones = []
                params = []  # Aquí incluirás los valores de tus listas concatenadas

                if anios and 0 not in anios:
                    condiciones.append("sdmmv.anio IN %s")
                    params.append(tuple(anios))  # Usa una tupla para IN

                if meses and 0 not in meses:
                    condiciones.append("sdmmv.id_mes IN %s")
                    params.append(tuple(meses))

                if municipios and 0 not in municipios:
                    # Normaliza las claves a 5 dígitos
                    municipios = [str(m).zfill(5) for m in municipios]  
                    condiciones.append("sdmmv.id_municipio IN %s")
                    params.append(tuple(municipios))

                if subtiposDelitos and 0 not in subtiposDelitos:
                    condiciones.append("sdmmv.id_subtipo_de_delito IN %s")
                    params.append(tuple(subtiposDelitos))

                if modalidades and 0 not in modalidades: 
                    condiciones.append("sdmmv.id_modalidad IN %s")
                    params.append(tuple(modalidades))

                if condiciones:
                    query += " WHERE " + " AND ".join(condiciones)

                query += " GROUP BY sdmmv.id_municipio, sdmmv.municipio"

                cursor.execute(query, params)

                #Obtener los resultados como lista de tuplas
                resultados = cursor.fetchall()
                
                mapas = [
                    {
                        "cveMunicipio": f"{str(row[0]).zfill(5)}",
                        "descripcionMunicipio": f"{row[1]}, {self.obtener_abreviatura_estado(str(row[0]).zfill(5))}",
                        "conteoDelitos": row[2]
                    } 
                    for row in resultados
                ]
                response = {"data": mapas}
                return response
        except psycopg2.Error as e:
                print(f"Error: {e}")
                return jsonify({"Error": "Error conexión del servidor"})

    def select_vista_fe(self, municipios, anios, meses):    
        try:
            with get_cursor() as cursor:    

                query = """
                        SELECT  sdmmav.cve_municipio,
                                sdmmav.municipio,
                                sdmmav.id_entidad,
                                sdmmav.entidad,
                                SUM(sdmmav.conteo_robo_transportista) as total_conteo
                        FROM sum_delitos_municipio_mes_anerpv_vista sdmmav                   
                        
                """
                # Lista de condiciones para WHERE
                condiciones = []
                params = []  # Aquí incluirás los valores de tus listas concatenadas

                # Verificamos si anios no es None y agregamos la condición
                if anios and 0 not in anios:
                    condiciones.append("sdmmav.anio IN %s")
                    params.append(tuple(anios))  # Usa una tupla para IN

                # Verificamos si meses no es None y agregamos la condición
                if meses and 0 not in meses:
                    condiciones.append("sdmmav.id_mes IN %s")
                    params.append(tuple(meses))  # Usa una tupla para IN

                # Verificamos si municipios no es None y agregamos la condición
                if municipios and 0 not in municipios:
                    # Normaliza las claves a 5 dígitos
                    municipios = [str(m).zfill(5) for m in municipios]
                    condiciones.append("sdmmav.cve_municipio IN %s")
                    params.append(tuple(municipios))  # Usa una tupla para IN
                
                # Si hay condiciones, las agregamos con WHERE o AND
                if condiciones:
                    query += " WHERE " + " AND ".join(condiciones)

                query += " GROUP BY sdmmav.cve_municipio, sdmmav.municipio, sdmmav.id_entidad, sdmmav.entidad"
                
                
                #Ejecutamos la consulta
                cursor.execute(query, params)
                #Obtener los resultados como lista de tuplas
                resultados = cursor.fetchall()

                if not resultados:  # Si no se encuentran resultados
                    return {"status": "error", "message": "No se encontraron datos para los filtros proporcionados."}

                mapasfe = [
                    {
                        "cveMunicipio": f"{str(row[0]).zfill(5)}",
                        "descripcionMunicipio": f"{row[1]}, {self.obtener_abreviatura_estado(str(row[0]).zfill(5))}",
                        "idEntidad": row[2],
                        "descripcionEntidad": row[3],
                        "conteoDelitos": row[4]
                    }
                    for row in resultados
                ]
                response = {"data": mapasfe}
                return response
        except psycopg2.Error as e:
                print(f"Error: {e}")
                return {"Error": "Error conexión del servidor"}

    def select_vista_fe_en(self, entidades, anios, meses):    
        try:
            with get_cursor() as cursor:    

                query = """
                        SELECT 
                            sdemav.id_entidad , 
                            sdemav.entidad , 
                            SUM(sdemav.conteo_robo_transportista) as total_delitos
                        FROM sum_delitos_entidad_mes_anerpv_vista sdemav                 
                        
                """
                # Lista de condiciones para WHERE
                condiciones = []
                params = []  # Aquí incluirás los valores de tus listas concatenadas

                # Verificamos si anios no es None y agregamos la condición
                if anios and 0 not in anios:
                    condiciones.append("sdemav.anio IN %s")
                    params.append(tuple(anios))  # Usa una tupla para IN

                # Verificamos si meses no es None y agregamos la condición
                if meses and 0 not in meses:
                    condiciones.append("sdemav.id_mes IN %s")
                    params.append(tuple(meses))  # Usa una tupla para IN

                # Verificamos si municipios no es None y agregamos la condición
                if entidades and 0 not in entidades:
                    # Normaliza las claves a 5 dígitos
                    entidades = [str(m).zfill(5)[:2] for m in entidades]
                    condiciones.append("sdemav.id_entidad IN %s")
                    params.append(tuple(entidades))  # Usa una tupla para IN
                
                # Si hay condiciones, las agregamos con WHERE o AND
                if condiciones:
                    query += " WHERE " + " AND ".join(condiciones)

                query += " GROUP BY sdemav.id_entidad , sdemav.entidad"
                
                
                #Ejecutamos la consulta
                cursor.execute(query, params)

                #Obtener los resultados como lista de tuplas
                resultados = cursor.fetchall()
                if not resultados:  # Si no se encuentran resultados
                    return {"status": "error", "message": "No se encontraron datos para los filtros proporcionados."}

                mapasfeen = [
                    {
                        "idEntidad": f"{str(row[0]).zfill(2)}{'0' * 3}",
                        "descripcionEntidad": row[1],
                        "conteoDelitos": row[2]
                    }
                    for row in resultados
                ]
                response = {"data": mapasfeen}
                return response
        except psycopg2.Error as e:
                print(f"Error: {e}")
                return {"Error": "Error conexión del servidor"}