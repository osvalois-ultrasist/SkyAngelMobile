from app.modelos.conexion_bd import Conexion_BD

class fuenteExternaBarrasHorarioMapper:

    def listToString(self, lista, delimiter=", "):
        stringList = [str(element) for element in lista]
        resultString = delimiter.join(stringList)
        return resultString

    def selectIncidentes2(self, anio, mes, entidad, municipio):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            anioStr = self.listToString(anio)
            mesStr = self.listToString(mes)
            entidadStr = self.listToString(entidad)
            municipioStr = self.listToString(municipio)

            query = f"""
                        SELECT
                            sdemav.anio,
                            sdemav.id_mes,
                            sdemav.mes,
                            SUM(sdemav.conteo_robo_turno_matutino) AS total_robo_turno_matutino,
                            SUM(sdemav.conteo_robo_turno_madrugada) AS total_robo_turno_madrugada,
                            SUM(sdemav.conteo_robo_turno_vespertino) AS total_robo_turno_vespertino,
                            SUM(sdemav.conteo_robo_turno_nocturno) AS total_robo_turno_nocturno,
                            SUM(
                                sdemav.conteo_robo_turno_matutino +
                                sdemav.conteo_robo_turno_madrugada +
                                sdemav.conteo_robo_turno_vespertino +
                                sdemav.conteo_robo_turno_nocturno
                            ) AS total_robo_vehiculos
                        FROM
                            sum_delitos_entidad_mes_anerpv_vista sdemav
                        JOIN 
                            sum_delitos_municipio_mes_anerpv_vista sdmmav
                            ON sdemav.id_entidad = sdmmav.id_entidad
                        WHERE
                            sdemav.anio IN ({anioStr})
                            AND sdemav.id_mes IN ({mesStr})
                            AND sdemav.id_entidad IN ({entidadStr})
                            AND sdmmav.cve_municipio IN ({municipioStr})
                        GROUP BY
                            sdemav.anio,
                            sdemav.id_mes,
                            sdemav.mes            
    """
            cursor.execute(query)
            rows = cursor.fetchall()

            sumDelitos = [
                {
                    "anio": row[0],
                    "mes": row[1],
                    "mesNombre": row[2],
                    "turnoMatutino": row[3],
                    "turnoMadrugada": row[4],
                    "turnoVespertino": row[5],
                    "turnoNocturno": row[6],
                    "conteo": row[7],
                }
                for row in rows
            ]

            return {"sumDelitos": sumDelitos}, 200

        except Exception as e:
            print(f"Error en la conexión a la base de datos: {e}")
            return {"error": "Error en la conexión a la base de datos"}, 500

        finally:
            cursor.close()
            conn.close()
            
    def selectIncidentes(self, anios, mes, entidad, municipio):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            query = """
                SELECT
                    sdemav.anio,
                    sdemav.id_mes,
                    sdemav.mes,
                    sdemav.conteo_robo_turno_matutino,
                    sdemav.conteo_robo_turno_madrugada,
                    sdemav.conteo_robo_turno_vespertino,
                    sdemav.conteo_robo_turno_nocturno,
                    (sdemav.conteo_robo_turno_matutino + 
                    sdemav.conteo_robo_turno_madrugada + 
                    sdemav.conteo_robo_turno_vespertino + 
                    sdemav.conteo_robo_turno_nocturno) AS total_conteo
                FROM
                    sum_delitos_entidad_mes_anerpv_vista sdemav
                JOIN 
                    sum_delitos_municipio_mes_anerpv_vista sdmmav
                    ON sdemav.id_entidad = sdmmav.id_entidad
            """
            condiciones = []
            params = []

            if anios and anios != [0]:
                condiciones.append("sdemav.anio IN %s")
                params.append(tuple(anios))

            if mes and mes != [0]:
                condiciones.append("sdemav.id_mes IN %s")
                params.append(tuple(mes))

            if entidad and entidad != [0]:
                condiciones.append("sdemav.id_entidad IN %s")
                params.append(tuple(entidad))

            if municipio and municipio != [0]:
                condiciones.append("sdmmav.cve_municipio IN %s")
                params.append(tuple(municipio))

            if condiciones:
                query += " WHERE " + " AND ".join(condiciones)
            
            query += """  
                GROUP BY 
                    sdemav.anio, 
                    sdemav.id_mes, 
                    sdemav.mes, 
                    sdemav.conteo_robo_turno_matutino,
                    sdemav.conteo_robo_turno_madrugada,
                    sdemav.conteo_robo_turno_vespertino,
                    sdemav.conteo_robo_turno_nocturno;
            """

            # Asegúrate de usar los parámetros
            cursor.execute(query, params)
            rows = cursor.fetchall()

            sumDelitos = [
                {
                    "anio": row[0],
                    "mes": row[1],
                    "mesNombre": row[2],
                    "turnoMatutino": row[3],
                    "turnoMadrugada": row[4],
                    "turnoVespertino": row[5],
                    "turnoNocturno": row[6],
                    "conteo": row[7],
                }
                for row in rows
            ]

            return {"sumDelitos": sumDelitos}, 200

        except Exception as e:
            print(f"Error: {e}")
            return {"Error": "Error conexión del servidor"}, 500

        finally:
            cursor.close()
            conn.close()