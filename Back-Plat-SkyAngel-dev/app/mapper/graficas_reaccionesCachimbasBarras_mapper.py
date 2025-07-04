from psycopg2 import sql
from flask import jsonify
import json
from app.modelos.conexion_bd import Conexion_BD

class reaccionesBarrasCachimbasMapper():
    def listToString(self, lista, delimiter=", "):
        return delimiter.join(map(str, lista))
            
    def selectIncidentes(self, anios, mes, entidad, municipio, categoria):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            query = """
                SELECT 
                    ic.int_cachimba,
                    COUNT(*) AS total
                FROM int_cachimbas ic
                INNER JOIN incidentes_sky i ON i.cve_municipio = ic.cve_municipio
                INNER JOIN cat_categorias cc ON cc.id_categoria = i.id_categoria
            """
            condiciones = []
            params = []
            
            if anios and anios != [0]:
                condiciones.append("EXTRACT(YEAR FROM i.fecha_incidente) IN %s")
                params.append(tuple(anios))
            
            if mes and mes != [0]:
                condiciones.append("EXTRACT(MONTH FROM i.fecha_incidente) IN %s")
                params.append(tuple(mes))
            
            if entidad and entidad != [0]:
                # Extraer id_entidad de cve_municipio (primeros 2 dígitos si tiene 5, primer dígito si tiene 4)
                condiciones.append("""
                    CASE 
                        WHEN LENGTH(i.cve_municipio::text) = 5 THEN LEFT(i.cve_municipio::text, 2)::integer
                        WHEN LENGTH(i.cve_municipio::text) = 4 THEN LEFT(i.cve_municipio::text, 1)::integer
                    END IN %s
                """)
                params.append(tuple(entidad))
            
            if municipio and municipio != [0]:
                condiciones.append("i.cve_municipio IN %s")
                params.append(tuple(municipio))
                        
            if categoria and categoria != [0]:
                condiciones.append("cc.id_categoria IN %s")
                params.append(tuple(categoria))
                            
            if condiciones:
                query += " WHERE " + " AND ".join(condiciones)
            
            query += """  
                GROUP BY 
                    ic.int_cachimba
                ORDER BY 
                    ic.int_cachimba
            """
            cursor.execute(query, params)
            rows = cursor.fetchall()
            
            return [{"cachimbas": row[0], "conteo": row[1]} for row in rows]

        except Exception as e:
            raise Exception(f"Error en la base de datos: {str(e)}")
        finally:
            cursor.close()
            conn.close()