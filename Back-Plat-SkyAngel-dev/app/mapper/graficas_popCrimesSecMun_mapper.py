from app.configuraciones.cursor import get_cursor
from app.configuraciones.config import Config
from app.modelos.conexion_bd import Conexion_BD

class secretariadoBarrasAcumMapperDelMunSel():

    def selectIncidentes(self, jsonParametros):
        try:
            # Extraer parámetros del JSON
            anios = jsonParametros.get("anio", [])
            municipio = jsonParametros.get("id_municipio", [])
            tipoDeDelitos = jsonParametros.get("id_delito", [])
            subTipoDeDelito = jsonParametros.get("id_subtipo_de_delito", [])
            modalidades = jsonParametros.get("id_modalidad", [])

            #print(f"jsonParametros recibidos: {jsonParametros}")
            with get_cursor() as cursor:
               
                query = """
                SELECT 
                    sdmmvt.anio,
                    sdmmvt.id_mes,
                    cm.mes,
                    sdmmvt.subtipo_de_delito,
                    SUM(sdmmvt.conteo) AS total_conteo	
                FROM 
                    sum_delitos_municipio_mes_vista sdmmvt
                JOIN cat_meses cm
                    ON cm.id_mes = sdmmvt.id_mes   
                """
                
                condiciones = []
                params = []
                
                if anios and 0 not in anios:
                    condiciones.append("sdmmvt.anio IN %s")
                    params.append(tuple(anios))
                
                if municipio and 0 not in municipio:
                    condiciones.append("sdmmvt.id_municipio IN %s")
                    params.append(tuple(municipio))
                                    
                if tipoDeDelitos and 0 not in tipoDeDelitos:
                    condiciones.append("sdmmvt.id_delito IN %s")
                    params.append(tuple(tipoDeDelitos))

                if subTipoDeDelito and 0 not in subTipoDeDelito:
                    condiciones.append("sdmmvt.id_subtipo_de_delito IN %s")
                    params.append(tuple(subTipoDeDelito))
                
                if modalidades and 0 not in modalidades:
                    condiciones.append("sdmmvt.id_modalidad IN %s")
                    params.append(tuple(modalidades))
                
                if condiciones:
                    query += " WHERE " + " AND ".join(condiciones)
                
                query += """  
                    GROUP BY 
                    sdmmvt.anio, 
                    sdmmvt.id_mes,
                    sdmmvt.subtipo_de_delito,
                    cm.mes
                    ORDER BY sdmmvt.anio
                """
                
                
                cursor.execute(query, params)
                #print(query, params)
                rows = cursor.fetchall()
                sumDelitos = [
                    {
                        "anio": row[0],
                        "id_mes": row[1],
                        "mes": row[2],
                        "subtipoDeDelito": row[3],
                        "conteo": row[4]
                    }
                    for row in rows 
                ]
                return {"data": sumDelitos}
                
        except Exception as e:
                print(f"Error: {e}")
        return {"Error": "Error conexión del servidor"}
