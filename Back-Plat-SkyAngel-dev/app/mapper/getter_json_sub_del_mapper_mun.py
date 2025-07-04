from app.configuraciones.cursor import get_cursor
from app.configuraciones.config import Config
from app.modelos.conexion_bd import Conexion_BD

class SubtipoDelitosTotalMun():

    def selectSubDel(self, jsonParametros):
        try:
            # Extraer parámetros del JSONz
            anio = jsonParametros.get("anio", [])
            municipio = jsonParametros.get("id_municipio", [])
            subTipoDeDelitos = jsonParametros.get("id_subtipo_de_delito", [])
            

            #print(f"jsonParametros recibidos: {jsonParametros}")
            with get_cursor() as cursor:
                query = """
                    SELECT 
                    sdmmv.id_municipio,
                    sdmmv.modalidad,
                    sdmmv.conteo as total
                    from sum_delitos_municipio_mes_vista sdmmv
                """
                
                condiciones = []
                params = []
                
                if anio and 0 not in anio:
                    condiciones.append("sdmmv.anio IN %s")
                    params.append(tuple(anio))

                if subTipoDeDelitos and 0 not in subTipoDeDelitos:
                    condiciones.append("sdmmv.id_subtipo_de_delito IN %s")
                    params.append(tuple(subTipoDeDelitos))
                
                if municipio and 0 not in municipio:
                    condiciones.append("sdmmv.id_municipio IN %s")
                    params.append(tuple(municipio))
                
                if condiciones:
                    query += " WHERE " + " AND ".join(condiciones)
                

                
                # Execute query and process results
                cursor.execute(query, params)
                #print(query, params)
                rows = cursor.fetchall()
                jsonSub = [
                    {
                        "id_municipio": row[0],
                        "modalidad": row[1],
                        "total" : row[2]
                    }
                    for row in rows 
                ]
                #print("el proximo json es", jsonSub)
                return {"data": jsonSub}
                
        except Exception as e:
                print(f"Error: {e}")
        return {"Error": "Error conexión del servidor"}
