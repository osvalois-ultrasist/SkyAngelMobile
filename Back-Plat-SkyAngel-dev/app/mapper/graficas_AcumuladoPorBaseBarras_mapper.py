from psycopg2 import sql
from flask import jsonify
import json
from app.configuraciones.cursor import get_cursor

class AcumuladoBarrasPorBaseMapper():
    def listToString(self, lista, delimiter=", "):
        return delimiter.join(map(str, lista))
            
    def selectIncidentes(self, anios, mes, entidad, municipio):
        try:
            with get_cursor() as cursor:
                query = """
                            WITH 
                            secretariado AS (
                                SELECT 
                                    sdmmv.anio,
                                    sdmmv.id_entidad,
                                    sdmmv.entidad,
                                    SUM(sdmmv.conteo) AS crimenes_secretariado
                                FROM sum_delitos_municipio_mes_vista sdmmv
                                WHERE 1=1
                """
                params = []
                condiciones_secretariado = []
                
                if anios and 0 not in anios:
                    condiciones_secretariado.append("sdmmv.anio IN %s")
                    params.append(tuple(anios))
                
                if mes and 0 not in mes:
                    condiciones_secretariado.append("sdmmv.id_mes IN %s")
                    params.append(tuple(mes))
                
                if entidad and 0 not in entidad:
                    condiciones_secretariado.append("sdmmv.id_entidad IN %s")
                    params.append(tuple(entidad))
                
                if municipio and 0 not in municipio:
                    condiciones_secretariado.append("sdmmv.id_municipio IN %s")
                    params.append(tuple(municipio))
                
                if condiciones_secretariado:
                    query += " AND " + " AND ".join(condiciones_secretariado)
                
                query += """
                                GROUP BY sdmmv.anio, sdmmv.id_entidad, sdmmv.entidad
                            ),
                            anerpv AS (
                                SELECT 
                                    sdemav.anio,
                                    sdemav.id_entidad,
                                    sdemav.entidad,
                                    SUM(sdemav.conteo_robo_transportista) AS crimenes_anerpv
                                FROM sum_delitos_entidad_mes_anerpv_vista sdemav
                                GROUP BY sdemav.anio, sdemav.id_entidad, sdemav.entidad
                            ),
                            sky AS (
                                SELECT 
                                    EXTRACT(YEAR FROM i.fecha_incidente) AS anio,
                                    SUBSTRING(CAST(i.cve_municipio AS TEXT) FROM 1 FOR CASE WHEN LENGTH(CAST(i.cve_municipio AS TEXT)) = 4 THEN 1 ELSE 2 END)::INTEGER AS id_entidad,
                                    COUNT(*) AS crimenes_sky
                                FROM incidentes_sky i
                                INNER JOIN cat_categorias c ON i.id_categoria = c.id_categoria    
                                GROUP BY anio, id_entidad
                            ),
                            unidos AS (
                                SELECT 
                                    COALESCE(s.anio, a.anio, sk.anio) AS anio,
                                    COALESCE(s.id_entidad, a.id_entidad, sk.id_entidad) AS id_entidad,
                                    COALESCE(s.entidad, a.entidad, 'SIN ENTIDAD') AS entidad,
                                    COALESCE(s.crimenes_secretariado, 0) AS crimenes_secretariado,
                                    COALESCE(a.crimenes_anerpv, 0) AS crimenes_anerpv,
                                    COALESCE(sk.crimenes_sky, 0) AS crimenes_sky
                                FROM secretariado s
                                FULL OUTER JOIN anerpv a 
                                    ON s.anio = a.anio AND s.id_entidad = a.id_entidad
                                FULL OUTER JOIN sky sk
                                    ON COALESCE(s.anio, a.anio) = sk.anio AND COALESCE(s.id_entidad, a.id_entidad) = sk.id_entidad
                            )
                            SELECT 
                                anio,
                                id_entidad,
                                entidad,
                                crimenes_secretariado,
                                crimenes_anerpv,
                                crimenes_sky,
                                (crimenes_secretariado + crimenes_anerpv + crimenes_sky) AS total_crimenes
                            FROM unidos
                            ORDER BY anio, id_entidad
                        """
                cursor.execute(query, params)
                rows = cursor.fetchall()
                delitos = [{
                        "anio": row[0], 
                        "idEntidad": row[1],
                        "entidad": row[2],
                        "crimenes_secretariado": row[3], 
                        "crimenes_anerpv": row[4],
                        "crimenes_sky": row[5],
                        "total_crimenes": row[6]
                    } 
                    for row in rows
                ]
                return {"data": delitos}
        except Exception as e:
            raise Exception(f"Error en la base de datos: {str(e)}")