from psycopg2 import sql
from flask import jsonify
import json
from app.modelos.conexion_bd import Conexion_BD

class reaccionesBarrasCentralMapper():
    def listToString(self, lista, delimiter=", "):
        return delimiter.join(map(str, lista))
            
    def selectIncidentes(self, anios, mes, entidad, municipio, categoria):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            query = """
                            SELECT
                            central,
                            COUNT(*) AS total
                            FROM 
                            int_inc_delictivas ir
                            INNER JOIN cat_categorias cc 
                            ON cc.categorias = IR.categoria
                    """
            condiciones = []
            params = []
            
            if anios and anios != [0]:
                condiciones.append("ir.anio IN %s")
                params.append(tuple(anios))
            
            if mes and mes != [0]:
                condiciones.append("ir.mes IN %s")
                params.append(tuple(mes))
            
            if entidad and entidad != [0]:
                condiciones.append("ir.id_entidad IN %s")
                params.append(tuple(entidad))
            
            if municipio and municipio != [0]:
                condiciones.append("ir.cve_municipio IN %s")
                params.append(tuple(municipio))
                        
            if categoria and categoria != [0]:
                condiciones.append("cc.id_categoria IN %s")
                params.append(tuple(categoria))
                            
            if condiciones:
                query += " WHERE " + " AND ".join(condiciones)
            
            query += """  
                        GROUP BY 
                        central
                        ORDER BY 
                        central
                    """
            cursor.execute(query, params)
            rows = cursor.fetchall()
            
            return [{"central": row[0], "conteo": row[1]} for row in rows]

        except Exception as e:
            raise Exception(f"Error en la base de datos: {str(e)}")
        finally:
            cursor.close()
            conn.close()