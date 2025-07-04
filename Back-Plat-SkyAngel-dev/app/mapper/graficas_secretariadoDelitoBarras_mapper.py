from psycopg2 import sql
from flask import jsonify
import json
from app.modelos.conexion_bd import Conexion_BD

class secretariadoBarrasDelitoMapper():
    def listToString(self, lista, delimiter=", "):
        return delimiter.join(map(str, lista))

    def selectIncidentes(self, anios, mes, entidad, municipio, bienJuridicoAfectado, tipoDeDelito, subtipoDeDelito, modalidad):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            query = """
            SELECT
                sdmmv.anio,
                sdmmv.id_mes,
                sdmmv.id_municipio,
                sdmmv.municipio,
                sdmmv.id_tipo_de_delito,
                sdmmv.tipo_de_delito,
                SUM(sdmmv.conteo) AS total_crimenes
            FROM
                sum_delitos_municipio_mes_vista sdmmv
            """
            
            condiciones = []
            params = []
            
            if anios and anios != [0]:
                condiciones.append("sdmmv.anio IN %s")
                params.append(tuple(anios))

            if mes and mes != [0]:
                condiciones.append("sdmmv.id_mes IN %s")
                params.append(tuple(mes))
            
            if entidad and entidad != [0]:
                condiciones.append("sdmmv.id_entidad IN %s")
                params.append(tuple(entidad))
            
            if municipio and municipio != [0]:
                condiciones.append("sdmmv.id_municipio IN %s")
                params.append(tuple(municipio))
            
            if bienJuridicoAfectado and bienJuridicoAfectado != [0]:
                condiciones.append("sdmmv.id_bien_juridico_afectado IN %s")
                params.append(tuple(bienJuridicoAfectado))
            
            if tipoDeDelito and tipoDeDelito != [0]:
                condiciones.append("sdmmv.id_tipo_de_delito IN %s")
                params.append(tuple(tipoDeDelito))
            
            if subtipoDeDelito and subtipoDeDelito != [0]:
                condiciones.append("sdmmv.id_subtipo_de_delito IN %s")
                params.append(tuple(subtipoDeDelito))
            
            if modalidad and modalidad != [0]:
                condiciones.append("sdmmv.id_modalidad IN %s")
                params.append(tuple(modalidad))
            
            if condiciones and len(condiciones) > 0:
                query += " WHERE " + " AND ".join(condiciones)

            query += """
            GROUP BY
                sdmmv.anio,
                sdmmv.id_mes,
                sdmmv.id_municipio,
                sdmmv.municipio,
                sdmmv.id_tipo_de_delito,
                sdmmv.tipo_de_delito
            ORDER BY
                sdmmv.anio,
                sdmmv.id_municipio,
                sdmmv.id_mes
                    """

            cursor.execute(query, params)

            rows = cursor.fetchall()

            return [
                {
                "anio": row[0],
                "idMES":row[1],
                "idMunicipio": row[2],
                "municipio": row[3],
                "idTipoDelito": row[4],
                "tipoDelito": row[5],
                "conteo": row[6]
                }
                for row in rows]

        except Exception as e:
            raise Exception(f"Error en la base de datos: {str(e)}")
        finally:
            cursor.close()
            conn.close()
