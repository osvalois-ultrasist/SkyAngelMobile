from psycopg2 import sql
from flask import jsonify
import json
from app.modelos.conexion_bd import Conexion_BD

class reaccionesBarrasDelitoMapper():
    def listToString(self, lista, delimiter=", "):
        return delimiter.join(map(str, lista))
            
    def selectIncidentes(self, anios, mes, entidad, municipio, categoria):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            query = """
                SELECT 
                    EXTRACT(YEAR FROM i.fecha_incidente) AS anios,
                    i.id_mes, 
                    i.cve_municipio,
                    SUBSTRING(CAST(i.cve_municipio AS TEXT) FROM 1 FOR CASE WHEN LENGTH(CAST(i.cve_municipio AS TEXT)) = 4 THEN 1 ELSE 2 END)::INTEGER AS id_entidad,
                    i.id_categoria,
                    c.categorias,
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
            
            # Agregar condiciones dinámicas
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
            
            # Agregar condiciones al query
            if condiciones:
                query += " WHERE " + " AND ".join(condiciones)
            
            query += """
                GROUP BY 
                    EXTRACT(YEAR FROM i.fecha_incidente), i.id_mes, i.cve_municipio, id_entidad, i.id_categoria, c.categorias
                ORDER BY
                    anios, id_mes, cve_municipio
            """
            
            # Ejecutar la consulta
            cursor.execute(query, params)
            rows = cursor.fetchall()
            
            # Formatear resultados
            return [
                {
                    "anio": row[0],
                    "idMES": row[1],
                    "cveMunicipio": row[2], 
                    "idEntidad": row[3],
                    "idCategoria": row[4],
                    "categoria": row[5],
                    "conteo": row[6]
                } 
                for row in rows
            ]

        except Exception as e:
            raise Exception(f"Error en la base de datos: {str(e)}")
        finally:
            cursor.close()
            conn.close()
