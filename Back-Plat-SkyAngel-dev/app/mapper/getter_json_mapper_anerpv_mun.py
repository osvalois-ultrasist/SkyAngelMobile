from app.configuraciones.cursor import get_cursor

class jsonAcumAnerpvMun():


    def selectIncidentes(self, jsonParametros):
        try:
            # Extraer parámetros del JSON
            municipio = jsonParametros.get("id_municipio", [])
            #subTipoDeDelitos = jsonParametros.get("id_subtipo_de_delito", [])
            

            #print(f"jsonParametros recibidos anerpv: {jsonParametros}")
            with get_cursor() as cursor:
                query = """
                        select 
                        sdmma.cve_municipio,
                        sdmma.conteo_robo_transportista_acumulado as total
                        from sum_delitos_municipio_mes_anerpv sdmma 
                """
                
                condiciones = []
                params = []
                
                #if subTipoDeDelitos and 0 not in subTipoDeDelitos:
                 #   condiciones.append("sdmmv.id_subtipo_de_delito IN %s")
                 #   params.append(tuple(subTipoDeDelitos))
                
                if municipio and 0 not in municipio:
                    condiciones.append("sdmma.cve_municipio IN %s")
                    params.append(tuple(municipio))
                
                if condiciones:
                    query += " WHERE " + " AND ".join(condiciones)
                

                
                # Execute query and process results
                cursor.execute(query, params)
                #print(query, params)
                rows = cursor.fetchall()
                jsonSub = [
                    {
                        "cve_municipio": row[0],
                        "total" : row[1]
                    }
                    for row in rows 
                ]
                #print("el proximo json es", jsonSub)
                return {"data": jsonSub}
                
        except Exception as e:
                print(f"Error: {e}")
        return {"Error": "Error conexión del servidor"}
