from app.modelos.conection_bd import Conection_BD

def obtener_datos():
    """ Obtiene los datos de la tabla """
    conBD = Conection_BD()
    query = f"""
        -- Siniestros
        SELECT 
            ce.entidad,
            nm.latitud_centroide,
            nm.longitud_centroide,
            'Siniestros' AS tipo,
            '2018-2020' AS anio_2018_2020,
            SUM(CASE WHEN i.anio BETWEEN 2018 AND 2020 THEN i.siniestros_cuota ELSE 0 END) AS cuota_2018_2020,
            SUM(CASE WHEN i.anio BETWEEN 2018 AND 2020 THEN i.siniestros_libre ELSE 0 END) AS libre_2018_2020,
            SUM(CASE WHEN i.anio BETWEEN 2018 AND 2020 THEN i.siniestros_total ELSE 0 END) AS total_2018_2020,
            '2021-2023' AS anio_2021_2023,
            SUM(CASE WHEN i.anio BETWEEN 2021 AND 2023 THEN i.siniestros_cuota ELSE 0 END) AS cuota_2021_2023,
            SUM(CASE WHEN i.anio BETWEEN 2021 AND 2023 THEN i.siniestros_libre ELSE 0 END) AS libre_2021_2023,
            SUM(CASE WHEN i.anio BETWEEN 2021 AND 2023 THEN i.siniestros_total ELSE 0 END) AS total_2021_2023
        FROM int_accidentes_transito i
        JOIN cat_entidad ce ON i.id_entidad = ce.id_entidad
        JOIN catalogo_municipios nm ON i.id_entidad = nm.id_entidad 
            AND nm.cve_municipio IN (
                1001, 2002, 3003, 4002, 5030, 6002, 7101, 8019, 9015, 10005,
                11015, 12029, 13048, 14039, 15106, 16053, 17007, 18017, 19039,
                20067, 21114, 22014, 23004, 24028, 25006, 26030, 27004, 28041,
                29033, 30087, 31050, 32056
            )
        WHERE i.anio BETWEEN 2018 AND 2023
        GROUP BY ce.entidad, nm.latitud_centroide, nm.longitud_centroide
        UNION ALL
        -- Lesionados
        SELECT 
            ce.entidad,
            nm.latitud_centroide,
            nm.longitud_centroide,
            'Lesionados' AS tipo,
            '2018-2020' AS anio_2018_2020,
            SUM(CASE WHEN i.anio BETWEEN 2018 AND 2020 THEN i.lesionados_cuota ELSE 0 END),
            SUM(CASE WHEN i.anio BETWEEN 2018 AND 2020 THEN i.lesionados_libre ELSE 0 END),
            SUM(CASE WHEN i.anio BETWEEN 2018 AND 2020 THEN i.lesionados_total ELSE 0 END),
            '2021-2023' AS anio_2021_2023,
            SUM(CASE WHEN i.anio BETWEEN 2021 AND 2023 THEN i.lesionados_cuota ELSE 0 END),
            SUM(CASE WHEN i.anio BETWEEN 2021 AND 2023 THEN i.lesionados_libre ELSE 0 END),
            SUM(CASE WHEN i.anio BETWEEN 2021 AND 2023 THEN i.lesionados_total ELSE 0 END)
        FROM int_accidentes_transito i
        JOIN cat_entidad ce ON i.id_entidad = ce.id_entidad
        JOIN catalogo_municipios nm ON i.id_entidad = nm.id_entidad 
            AND nm.cve_municipio IN (
                1001, 2002, 3003, 4002, 5030, 6002, 7101, 8019, 9015, 10005,
                11015, 12029, 13048, 14039, 15106, 16053, 17007, 18017, 19039,
                20067, 21114, 22014, 23004, 24028, 25006, 26030, 27004, 28041,
                29033, 30087, 31050, 32056
            )
        WHERE i.anio BETWEEN 2018 AND 2023
        GROUP BY ce.entidad, nm.latitud_centroide, nm.longitud_centroide
        UNION ALL
        -- Fallecidos
        SELECT 
            ce.entidad,
            nm.latitud_centroide,
            nm.longitud_centroide,
            'Fallecidos' AS tipo,
            '2018-2020' AS anio_2018_2020,
            SUM(CASE WHEN i.anio BETWEEN 2018 AND 2020 THEN i.fallecidos_cuota ELSE 0 END),
            SUM(CASE WHEN i.anio BETWEEN 2018 AND 2020 THEN i.fallecidos_libre ELSE 0 END),
            SUM(CASE WHEN i.anio BETWEEN 2018 AND 2020 THEN i.fallecidos_total ELSE 0 END),
            '2021-2023' AS anio_2021_2023,
            SUM(CASE WHEN i.anio BETWEEN 2021 AND 2023 THEN i.fallecidos_cuota ELSE 0 END),
            SUM(CASE WHEN i.anio BETWEEN 2021 AND 2023 THEN i.fallecidos_libre ELSE 0 END),
            SUM(CASE WHEN i.anio BETWEEN 2021 AND 2023 THEN i.fallecidos_total ELSE 0 END)
        FROM int_accidentes_transito i
        JOIN cat_entidad ce ON i.id_entidad = ce.id_entidad
        JOIN catalogo_municipios nm ON i.id_entidad = nm.id_entidad 
            AND nm.cve_municipio IN (
                1001, 2002, 3003, 4002, 5030, 6002, 7101, 8019, 9015, 10005,
                11015, 12029, 13048, 14039, 15106, 16053, 17007, 18017, 19039,
                20067, 21114, 22014, 23004, 24028, 25006, 26030, 27004, 28041,
                29033, 30087, 31050, 32056
            )
        WHERE i.anio BETWEEN 2018 AND 2023
        GROUP BY ce.entidad, nm.latitud_centroide, nm.longitud_centroide;
    """
    resultado = conBD.Run_query(query)
    
    return resultado