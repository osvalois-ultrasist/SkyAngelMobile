from app.configuraciones.cursor import get_cursor

class jsonAcumSkyMun():


    def selectIncidentes(self, jsonParametros):
        try:
            # Extraer parámetros del JSON
            municipio = jsonParametros.get("id_municipio", [])
            anio = jsonParametros.get("anio", [])
            

            #print(f"jsonParametros recibidos anerpv: {jsonParametros}")
            with get_cursor() as cursor:
                query = """
                    SELECT 
                        nm.cve_municipio,
                        COUNT(i.cve_municipio) as conteo_total_sky
                    FROM catalogo_municipios nm
                    LEFT JOIN int_inc_delictivas i ON nm.cve_municipio = i.cve_municipio 
                """
                
                condiciones = []
                params = []
                
                if anio and 0 not in anio:
                    condiciones.append("i.anio IN %s")
                    params.append(tuple(anio))
                
                if municipio and 0 not in municipio:
                    condiciones.append("i.cve_municipio IN %s")
                    params.append(tuple(municipio))
                
                if condiciones:
                    query += " WHERE " + " AND ".join(condiciones)
                
                    
                query += """  
                    GROUP BY nm.cve_municipio, nm.municipio
                    ORDER BY nm.cve_municipio;
                """
                
                # Execute query and process results
                cursor.execute(query, params)
                
                rows = cursor.fetchall()
                
                # Crear diccionario con los resultados de la base de datos
                resultados_db = {row[0]: row[1] for row in rows}
                
                # Si se especificaron municipios específicos, incluir todos con valor 0 si no existen
                if municipio and 0 not in municipio:
                    jsonSub = [
                        {
                            "cve_municipio": int(mun),
                            "total": resultados_db.get(int(mun), 0)
                        }
                        for mun in municipio
                    ]
                    # Ordenar por cve_municipio
                    jsonSub.sort(key=lambda x: x["cve_municipio"])
                else:
                    # Si no se especificaron municipios, devolver solo los que tienen datos
                    jsonSub = [
                        {
                            "cve_municipio": row[0],
                            "total": row[1]
                        }
                        for row in rows 
                    ]
                
                
                return {"data": jsonSub}
                
        except Exception as e:
                print(f"Error: {e}")
        return {"Error": "Error conexión del servidor"}
