import psycopg2
import traceback
from datetime import datetime
from flask import jsonify
from flask import make_response
from app.configuraciones.cursor import get_cursor
from app.configuraciones.config import Config
from app.modelos.conexion_bd import Conexion_BD

class Sum_delitos_municipio_mes_mapper():
    """
        Clase que mapea objetos Sum_delitos_municipio_mes_mapper 
        a la tabla SUM_DELITOS_MUNICIPIO_MES_MAPPER
    """

    def insert_or_update(self, datos):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            for record in datos:
                cursor.execute(
                    """
                    INSERT INTO sum_delitos_municipio_mes (id_delito, id_municipio, id_mes, anio, conteo)
                    VALUES (%s, %s, %s, %s)
                    ON CONFLICT (id_delito, id_municipio, id_mes,  anio)
                    DO UPDATE SET conteo = EXCLUDED.conteo
                    """,
                    (
                        record['id_mes'], 
                        record['id_delito'], 
                        record['id_municipio'], 
                        record['anio'], 
                        record['conteo']
                    )               
                )
            conn.commit()
            response = {"insert_or_update": True, "Mensaje": "Registro insertado o actualizado exitosamente"}
            return response, 200
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": f"Error conexion del servidor {e}"}), 500
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    def delete(self,Sum_delitos_municipio_mes):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            cursor.execute("DELETE FROM sum_delitos_municipio_mes WHERE id_mes = %s AND id_delito_municipio = %s AND anio = %s AND conteo = %s RETURNING id_mes, id_delito_municipio, anio, conteo",
                (Sum_delitos_municipio_mes.id_mes, Sum_delitos_municipio_mes.id_delito_municipio, Sum_delitos_municipio_mes.anio, Sum_delitos_municipio_mes.conteo,))

            if cursor.rowcount == 0:
                return {"Error": "Registro no existe"}, 404

            conn.commit()
            response = {"delete": True}
            return response, 200
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexion del servidor"}), 500
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    def select_all(self):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            cursor.execute("select id_delito, id_municipio, id_mes, anio, conteo from sum_delitos_municipio_mes")
            rows = cursor.fetchall()
            sum_del_mun = [{"idDelito": row[0],"idMunicipio": row[1],
            "idMes": row[2],
            "anio": row[3],
            "conteo": row[4]} for row in rows]
            response = {"data": sum_del_mun}
            return response, 200
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"}), 500
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()


    def validar_enteros(self,lista, nombre_lista):
        """Valida si todos los elementos en la lista son enteros."""
        if not lista:  # Verificar si la lista está vacía
            return {"Error": f"'{nombre_lista}' no puede estar vacío"}, 400

        if not all(isinstance(i, int) for i in lista):
            return {"Error": f"Todos los valores en '{nombre_lista}' deben ser enteros"}, 400
        return None

    def select_vista2(self, modalidades, subtiposDelitos, anios, meses, municipios):    
        # Validar que todos los elementos de las listas sean enteros
        for lista, nombre in [(modalidades, 'modalidades'), (subtiposDelitos, 'subtiposDelitos'), (anios, 'anios'), (meses, 'meses'), (municipios, 'municipios')]:
            error = self.validar_enteros(lista, nombre)
            if error:
                return error
        try:
            conn = Conexion_BD().conexion_bd()
            cursor = conn.cursor()

            query = """
                    SELECT id_municipio ,
                            municipio,
                            SUM(conteo) AS total_conteo	   
                    FROM sum_delitos_municipio_mes_vista sdmmv
                    WHERE id_modalidad IN ({})
                    AND id_subtipo_de_delito IN ({})
                    AND anio IN ({})
                    AND id_mes IN ({})
                    AND id_municipio IN ({})
                    GROUP BY id_municipio, municipio
            """.format(
                self.concatenarListas(modalidades),
                self.concatenarListas(subtiposDelitos),
                self.concatenarListas(anios),
                self.concatenarListas(meses),
                self.concatenarListas(municipios)
            )
            
            #Ejecutamos la consulta
            cursor.execute(query)

            #Obtener los resultados como lista de tuplas
            resultados = cursor.fetchall()
            
            # sum_del_mun = [{row[0], row[2]} for row in resultados]
            sum_del_mun = {str(row[0]): int(row[2]) for row in resultados}
            response = {"data": sum_del_mun}
            return response, 200
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"}), 500
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()
#Si no se encuentra nada en la base de datos, en vez de regrear un null regresa un 0
    def select_vista(self, modalidades, subtiposDelitos, anios, entidades, meses, municipios):    
        try:
            
            with get_cursor() as cursor:
                query = """
                        SELECT cm.cve_municipio AS id_municipio,
                                cm.municipio,
                                COALESCE(SUM(sdmmv.conteo), 0) AS total_conteo	   
                        FROM catalogo_municipios cm
                        LEFT JOIN sum_delitos_municipio_mes_vista sdmmv
                            ON cm.cve_municipio = sdmmv.id_municipio
                            AND cm.id_entidad = sdmmv.id_entidad
                """
                join_conditions = []
                where_conditions = []
                params = []  

                
                if anios and 0 not in anios:
                    join_conditions.append("sdmmv.anio IN %s")
                    params.append(tuple(anios))

                if meses and 0 not in meses:
                    join_conditions.append("sdmmv.id_mes IN %s")
                    params.append(tuple(meses))

                if subtiposDelitos and 0 not in subtiposDelitos:
                    join_conditions.append("sdmmv.id_subtipo_de_delito IN %s")
                    params.append(tuple(subtiposDelitos))

                if modalidades and 0 not in modalidades: 
                    join_conditions.append("sdmmv.id_modalidad IN %s")
                    params.append(tuple(modalidades))

                
                if municipios and 0 not in municipios:
                    sub_condicion = []
                    mun_entidades = []
                    
                    for mun in municipios.copy():  
                        if mun % 1000 == 0:
                            municipios.remove(mun)
                            mun_entidades.append(int(mun / 1000))
                    
                    if municipios:
                        sub_condicion.append("cm.cve_municipio IN %s")
                        params.append(tuple(municipios))

                    if mun_entidades:
                        sub_condicion.append("cm.id_entidad IN %s")
                        params.append(tuple(mun_entidades))
                    
                    if sub_condicion:
                        where_conditions.append('(' + ' OR '.join(sub_condicion) + ')')

                
                if entidades and 0 not in entidades and (not municipios or 0 in municipios):
                    where_conditions.append("cm.id_entidad IN %s")
                    params.append(tuple(entidades))

                
                if join_conditions:
                    query += " AND " + " AND ".join(join_conditions)

                
                if where_conditions:
                    query += " WHERE " + " AND ".join(where_conditions)

                query += " GROUP BY cm.cve_municipio, cm.municipio"

                # Execute the query
                cursor.execute(query, params)

                # Get results as a list of tuples
                resultados = cursor.fetchall()
                
                sum_del_mun = {str(row[0]): int(row[2]) for row in resultados}
                response = {"data": sum_del_mun}
                return response
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"})

    def concatenarListas(self, lista):
        return ','.join(map(str, lista))
