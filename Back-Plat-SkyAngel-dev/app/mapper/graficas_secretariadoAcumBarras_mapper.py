from psycopg2 import sql
from flask import jsonify
import json
from app.configuraciones.cursor import get_cursor

class secretariadoBarrasAcumMapper():

    def selectIncidentes(self, anios, mes, entidad, municipio, bienJuridicoAfectado, tipoDeDelito, subtipoDeDelito, modalidad):
        try:
            with get_cursor() as cursor:
                query = """
                        SELECT
                            sdmmv.anio,
                            sdmmv.id_mes,
                            cm.mes,
                            SUM(sdmmv.conteo) AS total_crimenes
                        FROM 
                            sum_delitos_municipio_mes_vista sdmmv
                        JOIN cat_meses cm
                            ON cm.id_mes = sdmmv.id_mes
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
                            GROUP BY sdmmv.anio, sdmmv.id_mes, cm.mes
                            ORDER BY sdmmv.anio, sdmmv.id_mes
                        """

                cursor.execute(query, params)
                rows = cursor.fetchall()
                
                sumDelitos = [
                    {
                        "anio": row[0],
                        "idMes": row[1],
                        "mes": row[2],
                        "conteo": row[3]
                    }
                    for row in rows
                ]

                return {"data": sumDelitos}

        except Exception as e:
            print(f"Error: {e}")
            return {"Error": "Error conexión del servidor"}