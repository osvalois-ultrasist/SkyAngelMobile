import psycopg2
from collections import OrderedDict
from app.configuraciones.cursor import get_cursor

class ConteoReacciones_mapper():
    def _crear_feature(self, row):
        """Crea una feature GeoJSON ordenada con el orden específico"""
        return OrderedDict([  # Mantiene la misma estructura
            ("type", "Feature"),
            ("geometry", OrderedDict([
                ("type", "Point"),
                ("coordinates", [float(row[4]), float(row[3])])  # [longitud, latitud]
            ])),
            ("properties", OrderedDict([         
                ("Mes", row[0]),         
                ("Año", int(row[1])),     
                ("Categoria", row[2]),    
                ("Municipio", row[5]),    # Nombre del municipio
                ("Entidad", row[6]),      # Nombre de la entidad
                ("Conteo_total", int(row[7])),  # Conteo total de reacciones
                ("Conteo_categoria", int(row[8]))  # Conteo de reacciones por categoría
            ]))
        ])

    def convertir_a_geojson(self, rows):
        """Convierte los datos en un GeoJSON"""
        features = [self._crear_feature(row) for row in rows]
        return OrderedDict([
            ("type", "FeatureCollection"),
            ("features", features)
        ])

    def select_reacciones_conteo(self, tabla, anios, meses, municipios, entidades):
        """Obtiene los datos de la tabla especificada y los convierte a GeoJSON"""
        try:
            with get_cursor() as cursor:
                query = f"""
                    SELECT 
                        m.mes AS nombre_mes,
                        i.anio, 
                        i.categoria, 
                        i.latitud, 
                        i.longitud,
                        nm.municipio,  
                        ne.entidad,
                        COUNT(*) OVER (PARTITION BY nm.municipio) AS conteo_total,
                        COUNT(*) OVER (PARTITION BY nm.municipio, i.categoria) AS conteo_categoria
                    FROM {tabla} i
                    JOIN cat_meses m ON i.mes = m.id_mes
                    LEFT JOIN catalogo_municipios nm ON i.cve_municipio = nm.cve_municipio
                    LEFT JOIN cat_entidad ne ON i.id_entidad = ne.id_entidad
                """
                condiciones = []
                params = []

                # Filtrar por año si se proporciona
                if anios and 0 not in anios:
                    condiciones.append("i.anio IN %s")
                    params.append(tuple(anios))

                # Filtrar por mes si se proporciona
                if meses and 0 not in meses:
                    condiciones.append("i.mes IN %s")
                    params.append(tuple(meses))

                if municipios and 0 not in municipios:
                    condiciones.append("i.cve_municipio IN %s")
                    params.append(tuple(municipios))

                # Filtrar por entidades si se proporciona
                if entidades and 0 not in entidades:
                    condiciones.append("i.id_entidad IN %s")
                    params.append(tuple(entidades))

                # Añadir condiciones al query
                if condiciones:
                    query += " WHERE " + " AND ".join(condiciones)

                # Ejecutar la consulta
                cursor.execute(query, params)
                return self.convertir_a_geojson(cursor.fetchall())

        except psycopg2.Error as e:
            print(f"Error: {e}")
            return {"error": str(e)}, 500

    def select_incidencias(self, anios, meses, municipios, entidades):
        return self.select_reacciones_conteo("INT_INC_DELICTIVAS", anios, meses, municipios, entidades)

    def select_otras_incidencias(self, anios, meses, municipios, entidades):
        return self.select_reacciones_conteo("INT_OTRAS_INCIDENCIAS", anios, meses, municipios, entidades)

    def select_accidentes(self, anios, meses, municipios, entidades):
        return self.select_reacciones_conteo("INT_ACCIDENTES", anios, meses, municipios, entidades)

    def select_recuperaciones(self, anios, meses, municipios, entidades):
        return self.select_reacciones_conteo("INT_RECUPERACION", anios, meses, municipios, entidades)

    
