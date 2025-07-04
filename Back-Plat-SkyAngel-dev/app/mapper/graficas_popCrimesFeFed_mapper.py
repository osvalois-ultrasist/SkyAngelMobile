from app.configuraciones.cursor import get_cursor

class barrasAcumMapperAnerpv():

    def selectIncidentes(self, jsonParametros):
        try:
            # Extraer parámetros del JSON
            anios = jsonParametros.get("anio", [])
            entidades = jsonParametros.get("id_entidad", [])

            with get_cursor() as cursor:
                query = """
                        select 
                        anerpv.anio, 
                        anerpv.id_mes,
                        cm.mes,
                        sum(conteo_robo_transportista_acumulado) as conteo
                FROM 
                    sum_delitos_entidad_mes_anerpv_vista anerpv
                JOIN cat_meses cm
                    ON cm.id_mes = anerpv.id_mes  
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
                    GROUP BY anerpv.anio, anerpv.id_mes, cm.mes
                    ORDER BY anerpv.anio
                """
                
                cursor.execute(query, params)
                
                rows = cursor.fetchall()
                sumDelitos = [
                    {
                        "anio": row[0],
                        "id_mes": row[1],
                        "mes" : row[2],
                        "conteo": row[3]
                    }
                    for row in rows 
                ]
                #print("la suma de delitos es:", sumDelitos)
                return {"data": sumDelitos}
                
        except Exception as e:
                print(f"Error: {e}")
        return {"Error": "Error conexión del servidor"}
