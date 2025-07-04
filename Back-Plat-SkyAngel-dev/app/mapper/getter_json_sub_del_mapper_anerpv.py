from app.configuraciones.cursor import get_cursor

class jsonAcumAnerpv():

    def selectIncidentes(self, jsonParametros):
        try:
            # Extraer parámetros del JSON
            anios = jsonParametros.get("anio", [])
            entidades = jsonParametros.get("id_entidad", [])

            with get_cursor() as cursor:
                query = """
                        select 
                        anerpv.id_entidad,
                        sum(conteo_robo_transportista_acumulado) as total
                FROM 
                    sum_delitos_entidad_mes_anerpv_vista anerpv
                """
                
                condiciones = []
                params = []
                
                if anios and 0 not in anios:
                    condiciones.append("anerpv.anio IN %s")
                    params.append(tuple(anios))
                
                if entidades and 0 not in entidades:
                    condiciones.append("anerpv.id_entidad IN %s")
                    params.append(tuple(entidades))
                
                if condiciones:
                    query += " WHERE " + " AND ".join(condiciones)
                
                query += """  
                    GROUP BY anerpv.id_entidad
                """
                
                cursor.execute(query, params)
                
                rows = cursor.fetchall()
                sumDelitos = [
                    {
                        "id_entidad": row[0],
                        "total": row[1]
                    }
                    for row in rows 
                ]
                #print("la suma de delitos es:", sumDelitos)
                return {"data": sumDelitos}
                
        except Exception as e:
                print(f"Error: {e}")
        return {"Error": "Error conexión del servidor"}
