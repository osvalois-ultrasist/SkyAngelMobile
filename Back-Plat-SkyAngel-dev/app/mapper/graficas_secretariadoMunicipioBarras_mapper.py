from flask import jsonify
import json
from app.configuraciones.cursor import get_cursor
from psycopg2 import sql

class secretariadoBarrasMunicipioMapper():
    def listToString(self, lista, delimiter=", "):
        return delimiter.join(map(str, lista))

    def selectIncidentes(self, anios, mes, entidad, municipio, bienJuridicoAfectado, tipoDeDelito, subtipoDeDelito, modalidad):
        try:
            with get_cursor() as cursor:
                query = """
                    WITH DELITOS_MUNICIPIOS AS (
                        SELECT 
                            sdmmv.anio, 
                            sdmmv.entidad, 
                            sdmmv.id_municipio, 
                            sdmmv.municipio, 
                            sdmmv.conteo, 
                            sdmmv.id_subtipo_de_delito
                        FROM 
                            sum_delitos_municipio_mes_vista sdmmv 
                        {where_clause}
                    ),
                    delitos_por_tipo AS (
                        SELECT 
                            d.anio, 
                            d.entidad, 
                            d.id_municipio, 
                            d.municipio, 
                            d.conteo
                        FROM DELITOS_MUNICIPIOS d
                    )
                    SELECT 
                        d.anio, 
                        d.entidad, 
                        d.id_municipio, 
                        d.municipio, 
                        SUM(d.conteo) AS total_crimenes
                    FROM DELITOS_MUNICIPIOS d
                    GROUP BY d.anio, d.entidad, d.id_municipio, d.municipio
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
                    where_clause = "WHERE " + " AND ".join(condiciones)
                else:
                    where_clause = ""

                query = query.format(where_clause=where_clause)

                cursor.execute(query, params)
                rows = cursor.fetchall()
                sumDelitos = [{"anio": row[0], "entidad": row[1], "cveMunicipio": row[2],   "municipio": row[3], "conteo": row[4]} for row in rows]

                return {"data": sumDelitos}

        except Exception as e:
            raise Exception(f"Error en la base de datos: {str(e)}")