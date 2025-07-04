import psycopg2
from collections import OrderedDict
from app.configuraciones.cursor import get_cursor

""" Clase encargada de acceder a la BD y obtener datos 
referentes a los puntos de interes de sus respectivas tablas en la BD"""
class Puntos_interes_mapper():
    def obtenerDatosIncidencias(self, tabla):
        """Obtiene datos de una tabla especifica de la BD
        - tabla: incidencias delictivas, otras incidencias, accidentes, recuperaciones"""
        try:
            with get_cursor() as cursor:
                query = f"""
                    SELECT 
                        i.latitud, 
                        i.longitud,
                        i.dia, 
                        m.mes AS nombre_mes,
                        i.anio, 
                        i.categoria, 
                        i.central, 
                        nm.municipio,  
                        ne.entidad 
                    FROM {tabla} i
                    JOIN cat_meses m ON i.MES = m.id_mes
                    LEFT JOIN catalogo_municipios nm ON i.CVE_MUNICIPIO = nm.cve_municipio
                    LEFT JOIN cat_entidad ne ON i.ID_ENTIDAD = ne.id_entidad
                """
                # Ejecutar la consulta
                cursor.execute(query)
                # Obtener todas las filas de la consulta
                rows = cursor.fetchall()
                # Crear una lista de diccionarios con los resultados
                incidencias = [{"latitud": float(row[0]),"longitud": float(row[1]),"Día de la semana": row[2],"Mes": row[3],"Año": row[4],
                    "Categoria": row[5],"Central": row[6],"Municipio": row[7],"Entidad": row[8]
                } for row in rows]
                # Devolver la lista
                return incidencias
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return {"Error": "Error conexión del servidor"}, 500

    def obtenerDatosCachimbas(self):
        """Obtiene datos de una tabla especifica de la BD
        - tabla: cachimbas, casetas"""
        try:
            with get_cursor() as cursor:
                query = f"""
                    SELECT  
                        ca.latitud, 
                        ca.longitud,
                        ca.int_cachimba,
                        nm.municipio,  
                        ne.entidad 
                    FROM int_cachimbas ca
                    LEFT JOIN catalogo_municipios nm ON ca.CVE_MUNICIPIO = nm.cve_municipio
                    LEFT JOIN cat_entidad ne ON ca.ID_ENTIDAD = ne.id_entidad
                """
                # Ejecutar la consulta
                cursor.execute(query)
                rows = cursor.fetchall()
                resultado = [{"latitud": float(row[0]),"longitud": float(row[1]),"Nombre": row[2],"Municipio": row[3],"Entidad": row[4]} for row in rows]
                return resultado
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return {"Error": "Error conexión del servidor"}, 500
    
    def obtenerDatosCasetas(self):
        """Obtiene datos de una tabla especifica de la BD
        - tabla: cachimbas, casetas"""
        try:
            with get_cursor() as cursor:
                query = f"""
                    SELECT  
                        cas.latitud, 
                        cas.longitud,
                        cas.int_caseta,
                        nm.municipio,  
                        ne.entidad 
                    FROM int_casetas cas
                    LEFT JOIN catalogo_municipios nm ON cas.CVE_MUNICIPIO = nm.cve_municipio
                    LEFT JOIN cat_entidad ne ON cas.ID_ENTIDAD = ne.id_entidad
                """
                # Ejecutar la consulta
                cursor.execute(query)
                rows = cursor.fetchall()
                resultado = [{"latitud": float(row[0]),"longitud": float(row[1]),"Caseta": row[2],"Municipio": row[3],"Entidad": row[4]} for row in rows]
                return resultado
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return {"Error": "Error conexión del servidor"}, 500
        
    def obtenerParaderos(self):
        """Obtiene datos de la tabla paraderos"""
        try:
            with get_cursor() as cursor:
                query = f"""
                    SELECT  
                        p.latitud AS latitud, 
                        p.longitud AS longitud,
                        p.enlace AS "Enlace",
                        p.name AS "Nombre",
                        p._description AS "Descripción",
                        p.enlace1 AS "Enlace1",
                        p.km AS "Km",
                        p.carretera AS "Carretera",
                        p.paradores_recomendados AS "Paraderos recomendados",
                        p.origen AS Origen,
                        p.corredor_seguro AS "Corredor seguro",
                        p.estacion_de_servicios AS "Estación de servicios",
                        p.gasolinera AS Gasolinera,
                        p.banos AS "Baños",
                        p.alimentos AS "Alimentos",
                        p.telefono_publico AS "Teléfono publico",
                        p.servicio_medico AS "Servicio médico",
                        p.mecanico AS "Mecánico",
                        p.mecanico_y_o_vulcanizadora AS "Mecánico y/o vulcanizadora",
                        p.srv_grua AS "Servicio grua",
                        p.taxi AS "Taxi",
                        p.servicio_publico_y_ambulacincia AS "Servicio público y ambulancia",
                        p.tienda_auto_servicio AS "Tienda auto servicio",
                        p.hotel AS "Hotel",
                        p.estacionamiento AS "Estacionamiento",
                        p.estacionamiento1 AS "Estacionamiento1",
                        p.estacionaminto AS "Estacionamieto2",
                        p.retorno AS "Retorno",
                        p.zonna_de_riezgoo_bajo AS "Zona de riesgo bajo",
                        p.zona_de_riesgo_medio AS "Zona de riesgo medio",
                        p.zona_de_estacionamiento AS "Zona de estacionamiento",
                        p.tienda AS "Tienda",
                        p.estacion_gn AS "Estacion gas natural",
                        p.pension AS "Pensión",
                        p.zona_de_servicios AS "Zona de servicios",
                        p.sanitarios AS "Sanitarios",
                        p.vijilancia_iluminada AS "Vijilancia iluminada",
                        p.gasolinera1 AS "Gasolinera1",
                        nm.municipio AS "Municipio",  
                        ne.entidad AS "Entidad" 
                    FROM int_paraderos p
                    LEFT JOIN catalogo_municipios nm ON p.CVE_MUNICIPIO = nm.cve_municipio
                    LEFT JOIN cat_entidad ne ON p.ID_ENTIDAD = ne.id_entidad
                """
                # Ejecutar la consulta
                cursor.execute(query)
                # Obtener todas las filas 
                rows = cursor.fetchall()
                # Obtener los nombres de las columnas
                columns = [col[0] for col in cursor.description]
                # Convertir las filas en diccionarios
                data = [dict(zip(columns, row)) for row in rows]
                # Retornar los datos
                return data
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return {"Error": "Error conexión del servidor"}, 500
        
    def obtenerMinisterios(self):
        """Obtiene los datos de la tabla int_ministerios_publicos"""
        try:
            with get_cursor() as cursor:
                query = f"""
                    SELECT  
                        min.latitud, 
                        min.longitud,
                        min.int_ministerio_publico,
                        min.direccion,
                        min.delegacion,
                        min.enlace,
                        min.telefono,
                        min.correo_electronico,
                        nm.municipio,  
                        ne.entidad 
                    FROM int_ministerios_publicos min
                    LEFT JOIN catalogo_municipios nm ON min.CVE_MUNICIPIO = nm.cve_municipio
                    LEFT JOIN cat_entidad ne ON min.ID_ENTIDAD = ne.id_entidad
                """
                # Ejecutar la consulta
                cursor.execute(query)
                rows = cursor.fetchall()
                ministerios = [{"latitud": float(row[0]),"longitud": float(row[1]),"Ministerio": row[2],"Dirección": row[3],"Delegación": row[4],
                    "Enlace": row[5],"Teléfono": row[6],"Correo": row[7],"Municipio": row[8],"Entidad": row[9]} for row in rows]
                return ministerios
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return {"Error": "Error conexión del servidor"}, 500
        
    def obtenerCorralones(self):
        """Obtiene los datos de la tabla int_corralones"""
        try:
            with get_cursor() as cursor:
                query = f"""
                    SELECT  
                        c.latitud, 
                        c.longitud,
                        c.corralon,
                        c.direccion,
                        c.enlace,
                        c.telefono,
                        c.correo_electronico,
                        nm.municipio,  
                        ne.entidad 
                    FROM int_corralones c
                    LEFT JOIN catalogo_municipios nm ON c.CVE_MUNICIPIO = nm.cve_municipio
                    LEFT JOIN cat_entidad ne ON c.ID_ENTIDAD = ne.id_entidad
                """
                # Ejecutar la consulta
                cursor.execute(query)
                rows = cursor.fetchall()
                corralones = [{"latitud": float(row[0]),"longitud": float(row[1]),"Corralón": row[2],"Dirección": row[3],"Enlace": row[4],
                    "Teléfono": row[5],"Correo": row[6],"Municipio": row[7],"Entidad": row[8]} for row in rows]
                return corralones
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return {"Error": "Error conexión del servidor"}, 500
        
    def obtenerCobertura(self):
        """Obtiene los datos de la tabla int_cobertura"""
        try:
            with get_cursor() as cursor:
                query = f"""
                    SELECT  
                        c.latitud, 
                        c.longitud,
                        c.cobertura_gps_fijo,
                        c.cobertura_gps_movil,
                        c.flujo_terrestre,
                        nm.municipio,  
                        ne.entidad 
                    FROM int_cobertura c
                    LEFT JOIN catalogo_municipios nm ON c.CVE_MUNICIPIO = nm.cve_municipio
                    LEFT JOIN cat_entidad ne ON c.ID_ENTIDAD = ne.id_entidad
                """
                # Ejecutar la consulta
                cursor.execute(query)
                rows = cursor.fetchall() 
                coberturas = [{"latitud": float(row[0]),"longitud": float(row[1]),"CoberturaGpsFijo": round(float(row[2]),2),"CoberturaGpsMovil": round(float(row[3]),2),
                    "FlujoTerrestre": int(row[4]),"Municipio": row[5],"Entidad": row[6]} for row in rows]
                return coberturas
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return {"Error": "Error conexión del servidor"}, 500
            
    def obtenerGuardia(self):
        """Obtiene los datos de la tabla int_guardia_nacional"""        
        try:
            with get_cursor() as cursor:
                query = f"""
                    SELECT
                        g.latitud, 
                        g.longitud,
                        g.enlace,
                        g.zona,
                        g.instalacion,
                        g.estacion,
                        g.direccion,
                        nm.municipio,  
                        ne.entidad 
                    FROM int_guardia_nacional g
                    LEFT JOIN catalogo_municipios nm ON g.CVE_MUNICIPIO = nm.cve_municipio
                    LEFT JOIN cat_entidad ne ON g.ID_ENTIDAD = ne.id_entidad
                """
                # Ejecutar la consulta
                cursor.execute(query)
                rows = cursor.fetchall()
                guardias = [{"latitud": float(row[0]),"longitud": float(row[1]),"Enlace": row[2],"Zona": row[3],"Instalación": row[4],
                    "Estación": row[5],"Dirección": row[6],"Municipio": row[7],"Entidad": row[8]} for row in rows]
                return guardias
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return {"Error": "Error conexión del servidor"}, 500
        
    def obtenerPensiones(self):
        """Obtiene los datos de la tabla int_pensiones"""
        try:
            with get_cursor() as cursor:
                query = f"""
                    SELECT  
                        pe.latitud, 
                        pe.longitud,
                        pe.int_pension,
                        pe.autorizada,
                        nm.municipio,  
                        ne.entidad 
                    FROM int_pensiones pe
                    LEFT JOIN catalogo_municipios nm ON pe.CVE_MUNICIPIO = nm.cve_municipio
                    LEFT JOIN cat_entidad ne ON pe.ID_ENTIDAD = ne.id_entidad
                """
                # Ejecutar la consulta
                cursor.execute(query)
                rows = cursor.fetchall()
                pensiones = [{"latitud": float(row[0]),"longitud": float(row[1]),"Pensión": row[2],"Autorizada": row[3],"Municipio": row[4],"Entidad": row[5]} for row in rows]
                return pensiones
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return {"Error": "Error conexión del servidor"}, 500
    
