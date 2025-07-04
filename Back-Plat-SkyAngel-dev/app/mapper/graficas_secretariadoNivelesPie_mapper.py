from psycopg2 import sql
from app.configuraciones.cursor import get_cursor

class secretariadoPieNivelesMapper():
    def listToString(self, lista, delimiter=", "):
        stringList = [str(element) for element in lista]
        return delimiter.join(stringList)

    def selectIncidentes2(self, anios, mes, entidad, municipio, bienJuridicoAfectado, tipoDeDelito, subtipoDeDelito, modalidad):
        try:
            conn = Conexion_BD().conexion_bd()
            cursor = conn.cursor()
            aniosStr = self.listToString(anios)
            mesStr = self.listToString(mes)
            entidadStr = self.listToString(entidad)
            municipioStr = self.listToString(municipio)
            bienJuridicoAfectadoStr = self.listToString(bienJuridicoAfectado)
            tipoDeDelitoStr = self.listToString(tipoDeDelito)
            subtipoDeDelitoStr = self.listToString(subtipoDeDelito)
            modalidadStr = self.listToString(modalidad)

            query = f"""
                select
                    sdmmv.anio,
                    sdmmv.id_bien_juridico_afectado, sdmmv.bien_juridico_afectado,
                    sdmmv.id_tipo_de_delito, sdmmv.tipo_de_delito,
                    sdmmv.id_subtipo_de_delito, sdmmv.subtipo_de_delito,
                    sdmmv.id_modalidad, sdmmv.modalidad,
                    SUM(sdmmv.conteo) as total_delitos
                from 
                sum_delitos_municipio_mes_vista sdmmv
                    WHERE sdmmv.anio IN ({aniosStr})
                    AND sdmmv.id_mes IN ({mesStr})
                    and sdmmv.id_entidad in ({entidadStr})
                    and sdmmv.id_municipio in ({municipioStr})
                    and sdmmv.id_bien_juridico_afectado in ({bienJuridicoAfectadoStr})
                    and sdmmv.id_tipo_de_delito  in ({tipoDeDelitoStr})
                    AND sdmmv.id_subtipo_de_delito IN ({subtipoDeDelitoStr})
                    AND sdmmv.id_modalidad IN ({modalidadStr})
                group by 
                    sdmmv.anio
                    ,sdmmv.id_bien_juridico_afectado, sdmmv.bien_juridico_afectado 
                    ,sdmmv.id_tipo_de_delito, sdmmv.tipo_de_delito 
                    ,sdmmv.id_subtipo_de_delito, sdmmv.subtipo_de_delito
                    ,sdmmv.id_modalidad, sdmmv.modalidad
                order by
                    sdmmv.anio            
            """
            cursor.execute(query)
            rows = cursor.fetchall()
            
            sumDelitos = [
                {
                    "anio": row[0],
                    "idBienJuridicoAfectado": row[1],
                    "bienJuridicoAfectado": row[2],
                    "idTipoDeDelito": row[3],
                    "tipoDeDelito": row[4],
                    "idSubtipoDeDelito": row[5],
                    "subtipoDeDelito": row[6],
                    "idModalidad": row[7],
                    "modalidad": row[8],
                    "conteo": row[9],
                }
                for row in rows
            ]

            cursor.close()
            conn.close()
            return {"sumDelitos": sumDelitos}, 200

        except Exception as e:
            return {"error": str(e)}, 500

        
    def selectIncidentes(self, anios, mes, entidad, municipio, bienJuridicoAfectado, tipoDeDelito, subtipoDeDelito, modalidad):
        try:
            with get_cursor() as cursor:
                query = """
                    select
                        sdmmv.anio,
                        sdmmv.id_bien_juridico_afectado, sdmmv.bien_juridico_afectado,
                        sdmmv.id_tipo_de_delito, sdmmv.tipo_de_delito,
                        sdmmv.id_subtipo_de_delito, sdmmv.subtipo_de_delito,
                        sdmmv.id_modalidad, sdmmv.modalidad,
                        SUM(sdmmv.conteo) as total_delitos
                    from 
                    sum_delitos_municipio_mes_vista sdmmv

                """
                condiciones = []
                params = []
                
                if anios and 0 not in anios:
                    condiciones.append("sdmmv.anio IN %s")
                    params.append(tuple(anios))
                
                if mes and 0 not in mes:
                    condiciones.append("sdmmv.id_mes IN %s")
                    params.append(tuple(mes))
                
                if entidad and 0 not in entidad:
                    condiciones.append("sdmmv.id_entidad IN %s")
                    params.append(tuple(entidad))
                
                if municipio and 0 not in municipio:
                    condiciones.append("sdmmv.id_municipio IN %s")
                    params.append(tuple(municipio))
                
                if bienJuridicoAfectado and 0 not in bienJuridicoAfectado:
                    condiciones.append("sdmmv.id_bien_juridico_afectado IN %s")
                    params.append(tuple(bienJuridicoAfectado))
                
                if tipoDeDelito and 0 not in tipoDeDelito:
                    condiciones.append("sdmmv.id_tipo_de_delito IN %s")
                    params.append(tuple(tipoDeDelito))
                
                if subtipoDeDelito and 0 not in subtipoDeDelito:
                    condiciones.append("sdmmv.id_subtipo_de_delito IN %s")
                    params.append(tuple(subtipoDeDelito))
                
                if modalidad and 0 not in modalidad:
                    condiciones.append("sdmmv.id_modalidad IN %s")
                    params.append(tuple(modalidad))
                
                if condiciones:
                    query += " WHERE " + " AND ".join(condiciones)
                
                query += """  
                    group by 
                        sdmmv.anio
                        ,sdmmv.id_bien_juridico_afectado, sdmmv.bien_juridico_afectado 
                        ,sdmmv.id_tipo_de_delito, sdmmv.tipo_de_delito 
                        ,sdmmv.id_subtipo_de_delito, sdmmv.subtipo_de_delito
                        ,sdmmv.id_modalidad, sdmmv.modalidad
                    order by
                        sdmmv.anio            
                        """

                cursor.execute(query, params)
                rows = cursor.fetchall()

                sumDelitos = [
                    {
                        "anio": row[0],
                        "idBienJuridicoAfectado": row[1],
                        "bienJuridicoAfectado": row[2],
                        "idTipoDeDelito": row[3],
                        "tipoDeDelito": row[4],
                        "idSubtipoDeDelito": row[5],
                        "subtipoDeDelito": row[6],
                        "idModalidad": row[7],
                        "modalidad": row[8],
                        "conteo": row[9],
                    }
                    for row in rows
                ]

                return {"data": sumDelitos}

        except Exception as e:
            print(f"Error: {e}")
            return {"Error": "Error conexión del servidor"}