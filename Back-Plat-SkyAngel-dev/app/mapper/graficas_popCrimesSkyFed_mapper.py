from app.configuraciones.cursor import get_cursor

class skyaAngelBarrasMapper():

    def selectIncidentes(self, jsonParametros):
        try:
            # Extraer parámetros del JSON
            anios = jsonParametros.get("anio", [])
            entidades = jsonParametros.get("id_entidad", [])

            with get_cursor() as cursor:

                query = """
                    SELECT 
                        i.anio,
                        i.mes as id_mes,
                        cm.mes ,
                        COUNT(*) as conteo
                    FROM int_inc_delictivas i
		            JOIN cat_meses cm
		                ON cm.id_mes = i.mes
                """
                
                condiciones = []
                params = []
                
                if anios and 0 not in anios:
                    condiciones.append("i.anio IN %s")
                    params.append(tuple(anios))
                
                if entidades and 0 not in entidades:
                    condiciones.append("i.id_entidad IN %s")
                    params.append(tuple(entidades))
                
                if condiciones:
                    query += " WHERE " + " AND ".join(condiciones)
                
                query += """  
	                    GROUP BY i.anio,
	                    i.id_entidad,
	                    i.mes,
	                    cm.mes
	                    ORDER BY i.anio
                """
                cursor.execute(query, params)
                
                rows = cursor.fetchall()
                sumDelitos = [
                    {
                        "anio": row[0],
                        "id_mes": row[1],
                        "mes": row[2],
                        "conteo": row[3]
                    }
                    for row in rows 
                ]
                return {"data": sumDelitos}
                
        except Exception as e:
                print(f"Error: {e}")
        return {"Error": "Error conexión del servidor"}
