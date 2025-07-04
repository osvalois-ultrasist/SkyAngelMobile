import psycopg2
from app.configuraciones.cursor import get_cursor

""" Clase encargada de acceder a la BD y obtener los puntos 
referentes a delitos ferroviarios agrupados por municipios y entidades"""
class Puntos_ferroviarios_mapper():
    """ Función que realiza la consulta a la BD y 
    obtiene los puntos ferroviarios agrupados por municipios y entidades"""
    def obtenerFerroviarios(self):
        try: 
            #
            with get_cursor() as cursor:
                """ -Agrupa por entidad y municipio
                    -Conteo de cantidad de delitos por tipo y periodo
                    -Las coordenadas son asociadas al municipio"""
                query = f"""
                    SELECT
                        cm.latitud_centroide AS latitud, 
                        cm.longitud_centroide AS longitud,  
                        cm.municipio AS "Municipio",  
                        ce.entidad AS "Entidad", 
                        
                        -- Conteo total registros ferroviarios agrupados por periodos de años
                        SUM(CASE WHEN fr.anio BETWEEN 2016 AND 2019 THEN 1 ELSE 0 END) AS "Total año 2016-2019",
                        SUM(CASE WHEN fr.anio BETWEEN 2020 AND 2024 THEN 1 ELSE 0 END) AS "Total año 2020-2024",

                        -- Robo a tren
                        SUM(CASE WHEN fs.id_fer_subdelito = 4 THEN 1 ELSE 0 END) AS "Robo a tren (Combustible)",
                        SUM(CASE WHEN fs.id_fer_subdelito = 12 THEN 1 ELSE 0 END) AS "Robo a tren (Material rodante)",
                        SUM(CASE WHEN fs.id_fer_subdelito = 15 THEN 1 ELSE 0 END) AS "Robo a tren (Producto/carga)",
                        SUM(CASE WHEN fs.id_fer_subdelito = 18 THEN 1 ELSE 0 END) AS "Robo a tren (Robo a material rodante)",
                        SUM(CASE WHEN fs.id_fer_subdelito = 19 THEN 1 ELSE 0 END) AS "Robo a tren (Robo a producto/carga)",
                        
                        -- Robo a vía
                        SUM(CASE WHEN fs.id_fer_subdelito = 6 THEN 1 ELSE 0 END) AS "Robo a vía (Componentes de señales)",
                        SUM(CASE WHEN fs.id_fer_subdelito = 8 THEN 1 ELSE 0 END) AS "Robo a vía (Componentes de vía)",
                        SUM(CASE WHEN fs.id_fer_subdelito = 16 THEN 1 ELSE 0 END) AS "Robo a vía (Robo a componentes de señales)",
                        SUM(CASE WHEN fs.id_fer_subdelito = 17 THEN 1 ELSE 0 END) AS "Robo a vía (Robo a componentes de vía)",
                        
                        -- Vandalismo al tren
                        SUM(CASE WHEN fs.id_fer_subdelito = 2 THEN 1 ELSE 0 END) AS "Vandalismo al tren (Apertura de unidades)",
                        SUM(CASE WHEN fs.id_fer_subdelito = 3 THEN 1 ELSE 0 END) AS "Vandalismo al tren (Cierre de angulares)",
                        SUM(CASE WHEN fs.id_fer_subdelito = 11 THEN 1 ELSE 0 END) AS "Vandalismo al tren (Material rodante)",
                        SUM(CASE WHEN fs.id_fer_subdelito = 14 THEN 1 ELSE 0 END) AS "Vandalismo al tren (Personas ajenas)",
                        SUM(CASE WHEN fs.id_fer_subdelito = 20 THEN 1 ELSE 0 END) AS "Vandalismo al tren (Tren dividido)",
                        
                        -- Vandalismo en vía
                        SUM(CASE WHEN fs.id_fer_subdelito = 1 THEN 1 ELSE 0 END) AS "Vandalismo en vía (Aparatos de vía)",
                        SUM(CASE WHEN fs.id_fer_subdelito = 5 THEN 1 ELSE 0 END) AS "Vandalismo en vía (Componentes de señales)",
                        SUM(CASE WHEN fs.id_fer_subdelito = 7 THEN 1 ELSE 0 END) AS "Vandalismo en vía (Componentes de vía)",
                        SUM(CASE WHEN fs.id_fer_subdelito = 9 THEN 1 ELSE 0 END) AS "Vandalismo en vía (Equipo sobre la vía)",
                        SUM(CASE WHEN fs.id_fer_subdelito = 10 THEN 1 ELSE 0 END) AS "Vandalismo en vía (Manipulación de señales)",
                        SUM(CASE WHEN fs.id_fer_subdelito = 13 THEN 1 ELSE 0 END) AS "Vandalismo en vía (Obstrucción de vía)",
                        SUM(CASE WHEN fs.id_fer_subdelito = 21 THEN 1 ELSE 0 END) AS "Vandalismo en vía (Vandalismo a componentes de señales)"

                    FROM fer_registros fr
                    INNER JOIN fer_delitos_subdelitos fs ON fr.id_fer_delito_subdelito = fs.id_fer_delito_subdelito
                    INNER JOIN catalogo_municipios cm ON fr.cve_municipio = cm.cve_municipio
                    INNER JOIN cat_entidad ce ON cm.id_entidad = ce.id_entidad
                    -- Agrupar por ubicacion geografica y nombre (municipio y entidad)
                    GROUP BY cm.latitud_centroide, cm.longitud_centroide, cm.municipio, ce.entidad
                    -- Ordenar por entidad y municipio
                    ORDER BY ce.entidad, cm.municipio ASC
                """
                # Ejecutar la consulta
                cursor.execute(query)
                # Obtener todas las filas 
                rows = cursor.fetchall()
                # Obtener los nombres de las columnas
                columns = [col[0] for col in cursor.description]
                # Convertir las filas en diccionarios
                data = [dict(zip(columns, row)) for row in rows]
                # Retornar los datos
                return data
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return {"Error": "Error conexión del servidor"}, 500