from app.modelos.catalogos_municipios import Municipios
from app.mapper.catalogos_municipios_mapper import Municipios_mapper

class Municipios_service():

    def __init__(self):
        self.municipios_mapper = Municipios_mapper()

    def insert(self, json):
        municipio =  Municipios(
            json['cve_municipio'],
            json['municipio'],
            json['latitud_centroide'],
            json['longitud_centroide'],
            json['id_entidad']
        )
        return self.municipios_mapper.insert(municipio)

    def update(self, cve_municipio, json):
        municipio =  Municipios(
            cve_municipio,
            json['municipio'],
            json['latitud_centroide'],
            json['longitud_centroide'],
            json['id_entidad']
        )
        return self.municipios_mapper.update(municipio)

    def delete(self, cve_municipio):
        return self.municipios_mapper.delete(cve_municipio)

    def select_all(self):
        return self.municipios_mapper.select_all()  

    def select_por_id_entidad(self,id_entidad):
        return self.municipios_mapper.select_por_id_entidad(id_entidad)

    def select_municipios_por_idEntidad(self,id_entidad):
         # Validar si la lista está vacía o es nula
        if not id_entidad:
            return {"Error": "Lista de 'id_entidad' vacia o nula"}, 400
        response = self.municipios_mapper.select_municipios_por_idEntidad(id_entidad)
        response["data"].insert(0,{"value": 0, "label": "TODOS"})
        return response, 200