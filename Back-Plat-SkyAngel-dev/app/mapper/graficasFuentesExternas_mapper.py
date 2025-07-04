import psycopg2
from flask import jsonify
from app.configuraciones.config import Config
from app.modelos.conexion_bd import Conexion_BD
from app.modelos.constantes_globales import diccionarioMeses, cveMunEntidades

class FuentesExternasMapper():
    """Esta clase obtiene información de la base de datos 
    sobre las fuentes externas de la plataforma de riesgos 
    y genera archivos json con los parámetros necesarios 
    para realizar diferentes gráficas en la vista."""
    
    def __init__(self):
        self.diccionarioMeses = diccionarioMeses
        self.cveMunEntidades = cveMunEntidades
    
    def concatenarListas(self, lista):
        return ','.join(map(str, lista))
    
    def validarListaEnteros(self,lista):
        """Valida si todos los elementos en la lista son enteros
        y si no devuelve una lista vacía"""
        if not lista:
            return [0]
        if not all(isinstance(i, int) for i in lista):
            return [0]
        return lista

    def selectDelitosPorEntidad(self,anios, meses, entidades):    
        try:
            conn = Conexion_BD().conexion_bd()
            cursor = conn.cursor()

            #Validar listas de parámetros
            anios = self.validarListaEnteros(anios)
            meses = self.validarListaEnteros(meses)
            entidades = self.validarListaEnteros(entidades)

            query = """ 
            WITH 
            nacional as (
            SELECT 0 as id_entidad, 'Nacional' as entidad,
            sum(sumnac.conteo_robo_transportista) as total_conteo
            from sum_delitos_nacional_mes_anerpv sumnac
            WHERE sumnac.anio IN ({0})
            AND sumnac.id_mes IN ({1})
            )
            SELECT 
            sdemav.id_entidad, sdemav.entidad, 
            sum(sdemav.conteo_robo_transportista) AS total_conteo
            FROM sum_delitos_entidad_mes_anerpv_vista sdemav
            WHERE sdemav.anio IN ({0})
            AND sdemav.id_mes IN ({1})
            AND sdemav.id_entidad IN ({2})
            GROUP BY sdemav.id_entidad, sdemav.entidad
            UNION
            SELECT id_entidad, entidad, total_conteo
            FROM nacional""".format(
                self.concatenarListas(anios),
                self.concatenarListas(meses),
                self.concatenarListas(entidades)
            )
            #Ejecutamos la consulta
            cursor.execute(query)

            #Obtener los resultados como lista de tuplas
            resultados = cursor.fetchall()
            result_data = {str(row[1]): int(row[2]) for row in resultados}
            response = {"data": result_data}
            return response, 200
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor: "+str(e)}), 500
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    def selectDelitosPorMunicipio(self,anios, meses, municipios):    
        try:
            conn = Conexion_BD().conexion_bd()
            cursor = conn.cursor()

            #Validar listas de parámetros
            anios = self.validarListaEnteros(anios)
            meses = self.validarListaEnteros(meses)
            municipios = self.validarListaEnteros(municipios)

            query = """
            WITH
            nacional as (
            SELECT 0 as cve_municipio, 'Nacional' as municipio, 'Nacional' as entidad,
            sum(sumnac.conteo_robo_transportista) as total_conteo
            FROM sum_delitos_nacional_mes_anerpv sumnac
            WHERE sumnac.anio IN ({0})
            AND sumnac.id_mes IN ({1})
            )
            SELECT 
            sdmmtv.cve_municipio, sdmmtv.municipio, sdmmtv.entidad,
            sum(sdmmtv.conteo_robo_transportista) AS total_conteo
            FROM sum_delitos_municipio_mes_anerpv_vista sdmmtv
            WHERE sdmmtv.anio IN ({0})
            AND sdmmtv.id_mes IN ({1})
            AND sdmmtv.cve_municipio IN ({2})
            GROUP BY sdmmtv.cve_municipio, sdmmtv.municipio, sdmmtv.entidad
            UNION
            SELECT cve_municipio, municipio, entidad, total_conteo
            FROM nacional
            """.format(
                self.concatenarListas(anios),
                self.concatenarListas(meses),
                self.concatenarListas(municipios)
            )
            #Ejecutamos la consulta
            cursor.execute(query)
            #Obtener los resultados como lista de tuplas
            resultados = cursor.fetchall()
            result_data = {str(row[1])+','+str(row[2]): int(row[3]) for row in resultados}
            response = {"data": result_data}
            return response, 200
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"}), 500
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    def selectDelitosPorMunicipioTop(self,anios, meses, municipios, max_resultados):    
        try:
            conn = Conexion_BD().conexion_bd()
            cursor = conn.cursor()

            #Validar listas de parámetros
            anios = self.validarListaEnteros(anios)
            meses = self.validarListaEnteros(meses)
            municipios = self.validarListaEnteros(municipios)
            munEntidades = self.validarListaEnteros(self.cveMunEntidades)
            try:
                max_resultados = int(max_resultados)+1
            except:
                max_resultados = 0
            
            query = """
            WITH
            nacional as (
            SELECT 0 as cve_municipio, 'Nacional' as municipio, 'Nacional' as entidad,
            sum(sumnac.conteo_robo_transportista) as total_conteo
            FROM sum_delitos_nacional_mes_anerpv sumnac
            WHERE sumnac.anio IN ({0})
            AND sumnac.id_mes IN ({1})
            ),
            municipios as (
            SELECT sdmmtv.cve_municipio, sdmmtv.municipio, sdmmtv.entidad,
            sdmmtv.conteo_robo_transportista
            FROM sum_delitos_municipio_mes_anerpv_vista sdmmtv
            WHERE sdmmtv.anio IN ({0})
            AND sdmmtv.id_mes IN ({1})
            AND sdmmtv.cve_municipio not IN ({2})
            AND sdmmtv.cve_municipio IN ({3})
            )
            SELECT
            m.cve_municipio, m.municipio, m.entidad,
            sum(m.conteo_robo_transportista) AS total_conteo
            FROM municipios m
            GROUP BY m.cve_municipio, m.municipio, m.entidad
            UNION
            SELECT cve_municipio, municipio, entidad, total_conteo
            FROM nacional
            ORDER BY total_conteo desc
            LIMIT {4}""".format(
                self.concatenarListas(anios),
                self.concatenarListas(meses),
                self.concatenarListas(munEntidades),
                self.concatenarListas(municipios),
                max_resultados
            )
            #Ejecutamos la consulta
            cursor.execute(query)

            #Obtener los resultados como lista de tuplas
            resultados = cursor.fetchall()
            result_data = {str(row[1])+','+str(row[2]): int(row[3]) for row in resultados}
            response = {"data": result_data}
            return response, 200
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexión del servidor"}), 500
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()