from psycopg2 import sql
from flask import jsonify
import json
from app.configuraciones.cursor import get_cursor

class secretariadoBarrasEstadoMapper():
    def listToString(self, lista, delimiter=", "):
        return delimiter.join(map(str, lista))

    def selectIncidentes2(self, anios, mes, entidad, municipio, bienJuridicoAfectado, tipoDeDelito, subtipoDeDelito, modalidad):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            aniosStr = self.listToString(anios)
            mesStr = self.listToString(mes)
            entidadStr = self.listToString(entidad)
            municipioStr = self.listToString(municipio)
            bienJuridicoAfectadoStr = self.listToString(bienJuridicoAfectado)
            tipoDeDelitoStr = self.listToString(tipoDeDelito)
            subtipoDeDelitoStr = self.listToString(subtipoDeDelito)
            modalidadStr = self.listToString(modalidad)


            query = f"""
                SELECT sdmmv.anio, sdmmv.id_entidad, sdmmv.entidad, SUM(sdmmv.conteo) AS total_crimenes
                FROM sum_delitos_municipio_mes_vista sdmmv
                    WHERE sdmmv.anio IN ({aniosStr})
                    AND sdmmv.id_mes IN ({mesStr})
                    and sdmmv.id_entidad in ({entidadStr})
                    and sdmmv.id_municipio in ({municipioStr})
                    and sdmmv.id_bien_juridico_afectado in ({bienJuridicoAfectadoStr})
                    and sdmmv.id_tipo_de_delito  in ({tipoDeDelitoStr})
                    AND sdmmv.id_subtipo_de_delito IN ({subtipoDeDelitoStr})
                    AND sdmmv.id_modalidad IN ({modalidadStr})

                GROUP BY sdmmv.anio, sdmmv.id_entidad, sdmmv.entidad
                ORDER BY sdmmv.anio, sdmmv.id_entidad
            """

            cursor.execute(query)
            rows = cursor.fetchall()

            if not rows:
                raise ValueError("No se encontraron datos con los parámetros proporcionados.")

            return [{"anio": row[0], "idEntidad": row[1], "entidad": row[2], "conteo": row[3]} for row in rows]

        except Exception as e:
            raise Exception(f"Error en la base de datos: {str(e)}")
        finally:
            cursor.close()
            conn.close()
            
    def selectIncidentes(self, anios, mes, entidad, municipio, bienJuridicoAfectado, tipoDeDelito, subtipoDeDelito, modalidad):
        try:
            with get_cursor() as cursor:
                query = """
                    SELECT 
                        sdmmv.anio, 
                        sdmmv.id_entidad, 
                        sdmmv.entidad, 
                        SUM(sdmmv.conteo) AS total_crimenes
                    FROM sum_delitos_municipio_mes_vista sdmmv
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
                            GROUP BY sdmmv.anio, sdmmv.id_entidad, sdmmv.entidad
                            ORDER BY sdmmv.anio, sdmmv.id_entidad
                        """

                cursor.execute(query, params)
                rows = cursor.fetchall()
                delitos = [{
                        "anio": row[0], 
                        "idEntidad": row[1], 
                        "entidad": row[2], 
                        "conteo": row[3]
                    } 
                    for row in rows
                ]
                return {"data": delitos}
        except Exception as e:
            raise Exception(f"Error en la base de datos: {str(e)}")
