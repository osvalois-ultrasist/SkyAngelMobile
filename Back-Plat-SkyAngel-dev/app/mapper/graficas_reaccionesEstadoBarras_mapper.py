from psycopg2 import sql
from flask import jsonify
import json
from app.modelos.conexion_bd import Conexion_BD

class reaccionesBarrasEstadoMapper():
    def listToString(self, lista, delimiter=", "):
        return delimiter.join(map(str, lista))
            
    def selectIncidentes(self, anios, mes, entidad, municipio, categoria):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            query = """
                SELECT 
                    EXTRACT(YEAR FROM i.fecha_incidente) AS anios,
                    SUBSTRING(CAST(i.cve_municipio AS TEXT) FROM 1 FOR CASE WHEN LENGTH(CAST(i.cve_municipio AS TEXT)) = 4 THEN 1 ELSE 2 END)::INTEGER AS id_entidad,
                    COUNT(*) AS conteo
                FROM 
                    incidentes_sky i
                INNER JOIN 
                    cat_categorias c
                ON 
                    i.id_categoria = c.id_categoria    
            """
            condiciones = []
            params = []
            
            if anios and anios != [0]:
                condiciones.append("EXTRACT(YEAR FROM i.fecha_incidente) IN %s")
                params.append(tuple(anios))
            
            if mes and mes != [0]:
                condiciones.append("i.id_mes IN %s")
                params.append(tuple(mes))
            
            if entidad and entidad != [0]:
                condiciones.append("""
                    SUBSTRING(CAST(i.cve_municipio AS TEXT) FROM 1 FOR 
                    CASE WHEN LENGTH(CAST(i.cve_municipio AS TEXT)) = 4 THEN 1 ELSE 2 END)::INTEGER IN %s
                """)
                params.append(tuple(entidad))
            
            if municipio and municipio != [0]:
                condiciones.append("i.cve_municipio IN %s")
                params.append(tuple(municipio))
                        
            if categoria and categoria != [0]:
                condiciones.append("i.id_categoria IN %s")
                params.append(tuple(categoria))
            
            if condiciones:
                query += " WHERE " + " AND ".join(condiciones)
            
            query += """  
                GROUP BY 
                    EXTRACT(YEAR FROM i.fecha_incidente), id_entidad
                ORDER BY
                    anios
                    """

            cursor.execute(query, params)
            rows = cursor.fetchall()
            
            return [{"anio": row[0], "idEntidad": row[1], "conteo": row[2]} for row in rows]

        except Exception as e:
            raise Exception(f"Error en la base de datos: {str(e)}")
        finally:
            cursor.close()
            conn.close()