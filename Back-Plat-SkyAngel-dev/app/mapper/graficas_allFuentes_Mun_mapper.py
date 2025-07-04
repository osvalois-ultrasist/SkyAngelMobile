from app.configuraciones.cursor import get_cursor

class barrasAcumMapperAllFuentesMun():

    def selectIncidentesCombinados(self, jsonParametros):
        try:

            anios = jsonParametros.get("anio", [])
            municipio = jsonParametros.get("id_municipio", [])
            tipoDeDelitos = jsonParametros.get("id_tipo_de_delito", [])
            subtipoDeDelitos = jsonParametros.get("id_subtipo_de_delito", [])

            with get_cursor() as cursor:
                query = """
                SELECT
                    anio,
                    id_municipio,
                    SUM(conteo_secretariado) AS total_conteo_secretariado,
                    SUM(conteo_anerpv) AS total_conteo_anerpv,
                    SUM(conteo_sky) as total_conteo_sky_angel
                FROM (
                    SELECT
                        anio,
                        id_municipio,
                        conteo AS conteo_secretariado,
                        0 AS conteo_anerpv,
                        0 AS conteo_sky
                    FROM sum_delitos_municipio_mes_vista
                    WHERE
                        id_subtipo_de_delito = %s
                        AND id_tipo_de_delito = %s
                """

                condiciones_sec = []
                #Usar valores por defecto si las listas están vacías
                params_sec = [subtipoDeDelitos[0] if subtipoDeDelitos else 41,
                         tipoDeDelitos[0] if tipoDeDelitos else 33]

                if anios and 0 not in anios:
                    condiciones_sec.append("anio IN %s")
                    params_sec.append(tuple(anios))

                if municipio and 0 not in municipio:
                    condiciones_sec.append("id_municipio IN %s")
                    params_sec.append(tuple(municipio))

                if condiciones_sec:
                    query += " AND " + " AND ".join(condiciones_sec)

                query += """
                    UNION ALL
                    -- Parte Anerpv
                    SELECT
                        anio,
                        cve_municipio,
                        0 AS conteo_secretariado,
                        conteo_robo_transportista_acumulado AS conteo_anerpv,
                        0 as conteo_sky
                    FROM sum_delitos_municipio_mes_anerpv_vista
                """

                condiciones_anerpv = []
                params_anerpv = []

                if anios and 0 not in anios:
                    condiciones_anerpv.append("anio IN %s")
                    params_anerpv.append(tuple(anios))

                if municipio and 0 not in municipio:
                    condiciones_anerpv.append("cve_municipio IN %s")
                    params_anerpv.append(tuple(municipio))

                if condiciones_anerpv:
                    query += " WHERE " + " AND ".join(condiciones_anerpv)

                query += """
                union all
                -- parte sky-angel
                select 
                i.anio,
                i.cve_municipio,
                0 as conteo_secretariado,
                0 as conteo_anerpv,
                count(*) as conteo_sky
                from int_inc_delictivas i
                """
                condiciones_sky = []
                params_sky = []


                if anios and 0 not in anios:
                    condiciones_sky.append("i.anio IN %s")
                    params_sky.append(tuple(anios))

                if municipio and 0 not in municipio:
                    condiciones_sky.append("i.cve_municipio IN %s")
                    params_sky.append(tuple(municipio))

                if condiciones_sky:
                    query += " WHERE " + " AND ".join(condiciones_sky)

                query += """
                    GROUP BY i.anio, i.cve_municipio -- Agrupación para Sky Angel
                ) AS datos_combinados
                GROUP BY anio, id_municipio
                ORDER BY anio
                """
                params = params_sec + params_anerpv + params_sky
                #print(query, params)
                cursor.execute(query, params)
                

                rows = cursor.fetchall()
                sumDelitos = [
                    {
                        "anio": row[0],
                        "conteo_secretariado": row[2],
                        "conteo_anerpv": row[3],
                        "conteo_sky": row[4]
                    }
                    for row in rows
                ]
                #print(sumDelitos)
                return {"data": sumDelitos}

        except Exception as e:
                print(f"Error in mapper: {e}")

                return {"Error": "Error en la consulta de datos"}