import json
import boto3
from app.configuraciones.rutas_archivos import BUCKET_NAME, MAPAS
from app.mapper.mapas_mapper import Mapas_mapper

class MapasControlador():

    def __init__(self):
        self.mapasmapper = Mapas_mapper()
    
    def obtener_geojson(self, municipio):
        """
        Obtiene un archivo GeoJSON del bucket S3 dado un ID.
        """
        if int(municipio) == 0:  #Es para el filtro de select_vista y select_vista_con_geojson
            municipio = 3
        try:
            # Conectar con S3
            s3 = boto3.client('s3', region_name='us-east-1')
            
            # Construir el nombre del archivo
            id_formateado = f"{int(municipio):05d}"
            nombre_archivo = f"{id_formateado}.geojson"
            
            # Ruta completa en el bucket
            ruta_archivo = f"{MAPAS}{nombre_archivo}"
            
            # Obtener el objeto desde S3
            archivo = s3.get_object(Bucket=BUCKET_NAME, Key=ruta_archivo)
            
            # Leer y devolver el contenido del archivo
            contenido = archivo['Body'].read().decode("utf-8")
            return json.loads(contenido), None
        except s3.exceptions.NoSuchKey:
            return None, f"Archivo {nombre_archivo} no encontrado en el bucket."
        except ValueError:
            return None, "ID proporcionado no es válido."
        except Exception as e:
            return None, f"Error al obtener el archivo: {str(e)}"
        
    def obtener_geojson_estado(self, estado):
        """
        Obtiene un archivo GeoJSON del bucket S3 dado un ID.
        """
        if int(estado) == 0:
            estado = 2
        try:
            # Conectar con S3
            s3 = boto3.client('s3', region_name='us-east-1')
            
            # Construir el nombre del archivo
            id_formateado = f"{int(estado):05d}"
            nombre_archivo = f"{id_formateado}.geojson"
            
            # Ruta completa en el bucket
            ruta_archivo = f"{MAPAS}{nombre_archivo}"
            
            # Obtener el objeto desde S3
            archivo = s3.get_object(Bucket=BUCKET_NAME, Key=ruta_archivo)
            
            # Leer y devolver el contenido del archivo
            contenido = archivo['Body'].read().decode("utf-8")
            return json.loads(contenido), None
        except s3.exceptions.NoSuchKey:
            return None, f"Archivo {nombre_archivo} no encontrado en el bucket."
        except ValueError:
            return None, "ID proporcionado no es válido."
        except Exception as e:
            return None, f"Error al obtener el archivo: {str(e)}"

    def select_delitos_vista(self, municipios, anios, meses, delitos):
        # Validación de parámetros
        errores = []
        parametros = {
            "municipios": municipios,
            "anios": anios,
            "meses": meses,
            "delitos": delitos,
        }

        for campo, valor in parametros.items():
            if not valor or not isinstance(valor, list):
                errores.append(f"El campo '{campo}' es requerido y debe ser una lista no vacía")

        # Si hay errores, devolverlos
        if errores:
            return {
                "errores": errores,
            }

        # Normalización de valores (manejar 0 como indicador de "todos")
        municipios = None if municipios == [0] else municipios
        anios = None if anios == [0] else anios
        meses = None if meses == [0] else meses
        delitos = None if delitos == [0] else delitos

        # Llamada a la capa de datos (Mapper)
        try:
            return self.mapasmapper.select_delitos_vista(municipios, anios, meses, delitos)
        except Exception as e:
            return {
                "message": "Error al procesar la solicitud en la base de datos.",
                "detalles": str(e),
            }

    def select_vista(self, municipios, anios, meses, subtiposDelitos, modalidades):
        # Validación de parámetros
        errores = []
        parametros = {
            "municipios": municipios,
            "anios": anios,
            "meses": meses,
            "subtiposDelitos": subtiposDelitos,
            "modalidades": modalidades,
        }

        for campo, valor in parametros.items():
            if not valor or not isinstance(valor, list):
                errores.append(f"El campo '{campo}' es requerido y debe ser una lista no vacía")

        # Si hay errores, devolverlos
        if errores:
            return {
                "errores": errores,
            }

        # Normalización de valores (manejar 0 como indicador de "todos")
        municipios = None if municipios == [0] else municipios
        anios = None if anios == [0] else anios
        meses = None if meses == [0] else meses
        subtiposDelitos = None if subtiposDelitos == [0] else subtiposDelitos
        modalidades = None if modalidades == [0] else modalidades

        # Llamada a la capa de datos (Mapper)
        try:
            return self.mapasmapper.select_vista(municipios, anios, meses, subtiposDelitos, modalidades)
        except Exception as e:
            return {
                "message": "Error al procesar la solicitud en la base de datos.",
                "detalles": str(e),
            }

    def select_vista_con_geojson(self, municipios, anios, meses, subtiposDelitos, modalidades):
            # Obtener resultados de `select_vista`.
            resultados = self.select_vista(
                municipios, anios, meses, subtiposDelitos, modalidades
            )
            if "errores" in resultados:
                return resultados  # Devolver errores si los hay.

            # Paso 2: Cargar el archivo GeoJSON y combinarlo con los resultados.
            mapa_final = {
                "type": "FeatureCollection",
                "features": [],
            }

            for municipio in municipios:
                json_data, error = self.obtener_geojson(municipio)
                if error:
                    return {"status": "error", "message": error}

            # Determinar si el archivo es GeoJSON o TopoJSON
            if "type" in json_data and json_data["type"] == "Topology":
                # Manejo de TopoJSON
                mapa_final["type"] = "Topology"
                if "objects" in json_data:
                    for key, value in json_data["objects"].items():
                        # Iterar sobre las geometrías dentro del TopoJSON
                        if "geometries" in value:
                            for geometry in value["geometries"]:
                                cve_geo = geometry.get("properties", {}).get("cveGeo")
                                resultado = next(
                                    (
                                        r
                                        for r in resultados["data"]
                                        if r["cveMunicipio"] == cve_geo
                                    ),
                                    None,
                                )

                                if resultado:
                                    # Añadir propiedades adicionales
                                    geometry["properties"]["cveMunicipio"] = resultado["cveMunicipio"]
                                    geometry["properties"]["descripcionMunicipio"] = resultado["descripcionMunicipio"]
                                    geometry["properties"]["conteoDelitos"] = resultado["conteoDelitos"]
                    # Agregar al resultado final
                    mapa_final["objects"] = json_data["objects"]
            else:
                #Formato GeoJSON
                # Buscar el municipio en los resultados del conteo.
                for feature in json_data["features"]:
                    cve_geo = feature["properties"].get("cveGeo")
                    resultado = next(
                        (
                            r
                            for r in resultados["data"]
                            if r["cveMunicipio"] == cve_geo
                        ),
                        None,
                    )

                    if resultado:
                        # Añadir propiedades adicionales al GeoJSON.
                        feature["properties"]["cveMunicipio"] = resultado["cveMunicipio"]
                        feature["properties"]["descripcionMunicipio"] = resultado["descripcionMunicipio"]
                        feature["properties"]["conteoDelitos"] = resultado["conteoDelitos"]

                        mapa_final["features"].append(feature)
            
            return mapa_final
 
    def select_vista_fe(self, municipios, anios, meses):
        # Validación de parámetros
        errores = []
        parametros = {
            "municipios": municipios,
            "anios": anios,
            "meses": meses,
        }

        for campo, valor in parametros.items():
            if not valor or not isinstance(valor, list):
                errores.append(f"El campo '{campo}' es requerido y debe ser una lista no vacía")

        # Si hay errores, devolverlos
        if errores:
            return {
                "data": [],  # Aseguramos la consistencia
                "errores": errores,
            }

        # Normalización de valores (manejar 0 como indicador de "todos")
        municipios = None if municipios == [0] else municipios
        anios = None if anios == [0] else anios
        meses = None if meses == [0] else meses

        # Llamada a la capa de datos (Mapper)
        try:
            return self.mapasmapper.select_vista_fe(municipios, anios, meses)
        except Exception as e:
            return {
                "message": "Error al procesar la solicitud en la base de datos.",
                "detalles": str(e),
            }

    def select_vista_con_geojson_fe(self, municipios, anios, meses):
            # Obtener resultados de `select_vista_fe`.
            resultados = self.select_vista_fe(
                municipios, anios, meses
            )
            if "errores" in resultados:
                return resultados  # Devolver errores si los hay.

            # Paso 2: Cargar el archivo GeoJSON y combinarlo con los resultados.
            mapa_final = {
                "type": "FeatureCollection",
                "features": [],
            }

            for municipio in municipios:
                json_data, error = self.obtener_geojson(municipio)
                if error:
                    return {"status": "error", "message": error}

            # Determinar si el archivo es GeoJSON o TopoJSON
            if "type" in json_data and json_data["type"] == "Topology":
                # Manejo de TopoJSON
                mapa_final["type"] = "Topology"
                if "objects" in json_data:
                    for key, value in json_data["objects"].items():
                        # Iterar sobre las geometrías dentro del TopoJSON
                        if "geometries" in value:
                            for geometry in value["geometries"]:
                                cve_geo = geometry.get("properties", {}).get("cveGeo")
                                resultado = next(
                                    (
                                        r
                                        for r in resultados["data"]
                                        if r["cveMunicipio"] == cve_geo
                                    ),
                                    None,
                                )

                                if resultado:
                                    # Añadir propiedades adicionales
                                    geometry["properties"]["cveMunicipio"] = resultado["cveMunicipio"]
                                    geometry["properties"]["descripcionMunicipio"] = resultado["descripcionMunicipio"]
                                    geometry["properties"]["conteoDelitos"] = resultado["conteoDelitos"]
                                    geometry["properties"]["idEntidad"] = resultado["idEntidad"]
                                    geometry["properties"]["descripcionEntidad"] = resultado["descripcionEntidad"]
                    # Agregar al resultado final
                    mapa_final["objects"] = json_data["objects"]
            else:
                #Formato GeoJSON
                # Buscar el municipio en los resultados del conteo.
                for feature in json_data["features"]:
                    cve_geo = feature["properties"].get("cveGeo")
                    resultado = next(
                        (
                            r
                            for r in resultados["data"]
                            if r["cveMunicipio"] == cve_geo
                        ),
                        None,
                    )

                    if resultado:
                        # Añadir propiedades adicionales al GeoJSON.
                        feature["properties"]["cveMunicipio"] = resultado["cveMunicipio"]
                        feature["properties"]["descripcionMunicipio"] = resultado["descripcionMunicipio"]
                        feature["properties"]["conteoDelitos"] = resultado["conteoDelitos"]
                        feature["properties"]["idEntidad"] = resultado["idEntidad"]
                        feature["properties"]["descripcionEntidad"] = resultado["descripcionEntidad"]

                        mapa_final["features"].append(feature)
            
            return mapa_final

    def select_vista_fe_en(self, entidades, anios, meses):
        # Validación de parámetros
        errores = []
        parametros = {
            "entidades": entidades,
            "anios": anios,
            "meses": meses,
        }

        for campo, valor in parametros.items():
            if not valor or not isinstance(valor, list):
                errores.append(f"El campo '{campo}' es requerido y debe ser una lista no vacía")

        # Si hay errores, devolverlos
        if errores:
            return {
                "data": [],  # Aseguramos la consistencia
                "errores": errores,
            }

        # Normalización de valores (manejar 0 como indicador de "todos")
        entidades = None if entidades == [0] else entidades
        anios = None if anios == [0] else anios
        meses = None if meses == [0] else meses

        # Llamada a la capa de datos (Mapper)
        try:
            return self.mapasmapper.select_vista_fe_en(entidades, anios, meses)
        except Exception as e:
            return {
                "message": "Error al procesar la solicitud en la base de datos.",
                "detalles": str(e),
            }

    def select_vista_con_geojson_fe_en(self, entidades, anios, meses):
            # Obtener resultados de `select_vista_fe_en`.
            resultados = self.select_vista_fe_en(
                entidades, anios, meses
            )
            # Validar si hay errores en los resultados
            if not resultados.get("data"):
                # Devolver los errores si existen o un mensaje genérico
                return {
                    "status": "error",
                    "message": resultados.get("message", "Error inesperado al obtener los datos.")
        }

            # Paso 2: Cargar el archivo GeoJSON y combinarlo con los resultados.
            mapa_final = {
                "type": "FeatureCollection",
                "features": [],
            }

            for estado in entidades:
                estado_str = str(estado).zfill(5)[:2]
                json_data, error = self.obtener_geojson_estado(estado)
                
                if error:
                    return {"status": "error", "message": error}

                # Determinar si el archivo es GeoJSON o TopoJSON
                if "type" in json_data and json_data["type"] == "Topology":
                    # Manejo de TopoJSON
                    mapa_final["type"] = "Topology"
                    if "objects" in json_data:
                        for key, value in json_data["objects"].items():
                            # Iterar sobre las geometrías dentro del TopoJSON
                            if "geometries" in value:
                                for geometry in value["geometries"]:
                                    cve_ent = geometry.get("properties", {}).get("cveEnt")
                                    if cve_ent == estado_str:
                                        resultado = next(
                                            (
                                                r
                                                for r in resultados["data"]
                                                if str(r["idEntidad"]).zfill(5)[:2] == cve_ent
                                            ),
                                            None,
                                        )

                                        if resultado:
                                            # Añadir propiedades adicionales
                                            geometry["properties"]["idEntidad"] = resultado["idEntidad"]
                                            geometry["properties"]["descripcionEntidad"] = resultado["descripcionEntidad"]
                                            geometry["properties"]["conteoDelitos"] = resultado["conteoDelitos"]
                        # Agregar al resultado final
                        mapa_final["objects"] = json_data["objects"]
                else:
                    #Formato GeoJSON
                    # Buscar el municipio en los resultados del conteo.
                    for feature in json_data["features"]:
                        cve_ent = feature["properties"].get("cveEnt")
                        if cve_ent == estado_str:
                            resultado = next(
                                (
                                    r
                                    for r in resultados["data"]
                                    if str(r["idEntidad"]).zfill(5)[:2] == cve_ent
                                ),
                                None,
                            )

                            if resultado:
                                # Añadir propiedades adicionales al GeoJSON.
                                feature["properties"]["idEntidad"] = resultado["idEntidad"]
                                feature["properties"]["descripcionEntidad"] = resultado["descripcionEntidad"]
                                feature["properties"]["conteoDelitos"] = resultado["conteoDelitos"]

                                mapa_final["features"].append(feature)            
            return mapa_final