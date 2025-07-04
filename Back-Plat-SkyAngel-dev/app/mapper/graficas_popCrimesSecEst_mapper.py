from app.configuraciones.cursor import get_cursor
from app.configuraciones.config import Config
from app.modelos.conexion_bd import Conexion_BD

class secretariadoBarrasAcumMapperDelMun():

    def selectIncidentes(self, jsonParametros):
        try:
            # Extraer parámetros del JSON
            anios = jsonParametros.get("anio", [])
            entidades = jsonParametros.get("id_entidad", [])
            tipoDeDelitos = jsonParametros.get("id_tipo_de_delito", [])
            modalidades = jsonParametros.get("id_modalidad", [])

            with get_cursor() as cursor:
                
                query = """
                SELECT 
                    sdmmvt.anio, 
                    sdmmvt.id_entidad,
                    sdmmvt.id_tipo_de_delito,
                    sdmmvt.id_subtipo_de_delito,
                    sdmmvt.subtipo_de_delito,
                    sdmmvt.id_modalidad,
                    SUM(sdmmvt.conteo) as conteo
                FROM 
                    sum_delitos_municipio_mes_vista sdmmvt
                """
                
                condiciones = []
                params = []
                
                if anios and 0 not in anios:
                    condiciones.append("sdmmvt.anio IN %s")
                    params.append(tuple(anios))
                
                if entidades and 0 not in entidades:
                    condiciones.append("sdmmvt.id_entidad IN %s")
                    params.append(tuple(entidades))
                                    
                if tipoDeDelitos and 0 not in tipoDeDelitos:
                    condiciones.append("sdmmvt.id_tipo_de_delito IN %s")
                    params.append(tuple(tipoDeDelitos))
                
                if modalidades and 0 not in modalidades:
                    condiciones.append("sdmmvt.id_modalidad IN %s")
                    params.append(tuple(modalidades))
                
                if condiciones:
                    query += " WHERE " + " AND ".join(condiciones)
                
                query += """  
                    GROUP BY sdmmvt.anio, sdmmvt.id_entidad, sdmmvt.id_tipo_de_delito, sdmmvt.id_subtipo_de_delito, sdmmvt.id_modalidad, sdmmvt.subtipo_de_delito
                    ORDER BY sdmmvt.anio
                """
                
                # Execute query and process results
                cursor.execute(query, params)
                rows = cursor.fetchall()
                sumDelitos = [
                    {
                        "anio": row[0],
                        "subtipoDeDelito": row[4],
                        "conteo": row[6]
                    }
                    for row in rows 
                ]
                return {"data": sumDelitos}
                
        except Exception as e:
                print(f"Error: {e}")
        return {"Error": "Error conexión del servidor"}
