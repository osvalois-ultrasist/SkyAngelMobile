from psycopg2 import sql
from flask import jsonify
import json
from app.modelos.conexion_bd import Conexion_BD

class reaccionesTablaMapper():
    def listToString(self, lista, delimiter=", "):
        stringList = [str(element) for element in lista]
        return delimiter.join(stringList)

    def selectIncidentes2(self, anios, mes, entidad, municipio, categoria):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            aniosStr = self.listToString(anios)
            mesStr = self.listToString(mes)
            entidadStr = self.listToString(entidad)
            municipioStr = self.listToString(municipio)
            categoriaStr = self.listToString(categoria)

            query = f"""
                SELECT 
                    EXTRACT(YEAR FROM i.fecha_incidente) AS anios,
                    i.id_mes,
                    SUBSTRING(CAST(i.cve_municipio AS TEXT) FROM 1 FOR CASE WHEN LENGTH(CAST(i.cve_municipio AS TEXT)) = 4 THEN 1 ELSE 2 END)::INTEGER as id_entidad,
                    COUNT(*) AS conteo
                FROM 
                    incidentes_sky i
                INNER JOIN 
                    cat_categorias c
                ON 
                    i.id_categoria = c.id_categoria    
                where
                EXTRACT(YEAR FROM i.fecha_incidente) in ({aniosStr})
                and i.id_mes in ({mesStr})
                and SUBSTRING(CAST(i.cve_municipio AS TEXT) FROM 1 FOR CASE WHEN LENGTH(CAST(i.cve_municipio AS TEXT)) = 4 THEN 1 ELSE 2 END)::INTEGER in ({entidadStr})
                and i.cve_municipio in ({municipioStr})
                and i.id_categoria in ({categoriaStr})
                GROUP BY 
                    EXTRACT(YEAR FROM i.fecha_incidente), id_mes, id_entidad
                ORDER BY
                    anios
            """
            cursor.execute(query)
            rows = cursor.fetchall()

            sumDelitos = [{"anio": row[0], "idMes": row[1], "idEntidad": row[2], "conteo": row[3]} for row in rows]

            return {"sumDelitos": sumDelitos}, 200

        except Exception as e:
            print(f"Error: {e}")
            return {"Error": "Error conexión del servidor"}, 500

        finally:
            cursor.close()
            conn.close()

    def selectIncidentes(self, anios, mes, entidad, municipio, categoria):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            query = """
            
                SELECT 
                    EXTRACT(YEAR FROM i.fecha_incidente) AS anios,
                    i.id_mes,
                    SUBSTRING(CAST(i.cve_municipio AS TEXT) FROM 1 FOR CASE WHEN LENGTH(CAST(i.cve_municipio AS TEXT)) = 4 THEN 1 ELSE 2 END)::INTEGER as id_entidad,
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
            
            if municipio and municipio !=[0]:
                condiciones.append("i.cve_municipio IN %s")
                params.append(tuple(municipio))
                        
            if categoria and categoria != [0]:
                condiciones.append("i.id_categoria IN %s")
                params.append(tuple(categoria))
            
            if condiciones:
                query += " WHERE " + " AND ".join(condiciones)
            
            query += """  
                GROUP BY 
                    EXTRACT(YEAR FROM i.fecha_incidente), id_mes, id_entidad
                ORDER BY
                    anios
                    """

            cursor.execute(query, params)
            rows = cursor.fetchall()
            
            sumDelitos = [{"anio": row[0], "idMes": row[1], "idEntidad": row[2], "conteo": row[3]} for row in rows]

            return {"sumDelitos": sumDelitos}, 200

        except Exception as e:
            print(f"Error: {e}")
            return {"Error": "Error conexión del servidor"}, 500

        finally:
            cursor.close()
            conn.close()