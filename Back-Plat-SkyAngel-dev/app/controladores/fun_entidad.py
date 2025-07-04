from app.mapper.entidad_mapper import Entidad_mapper
from app.modelos.entidad import Entidad

class Entidad_service():

    def __init__(self):
        self.entidad_mapper = Entidad_mapper()

    def insert(self, json):
        entidad =  Entidad(-1,
            json['entidad']
        )
        return self.entidad_mapper.insert(entidad)

    def update(self, id_entidad, json):
        entidad =  Entidad(
            id_entidad,
            json['entidad'])
        return self.entidad_mapper.update(entidad)

    def delete(self, id_entidad):
        return self.entidad_mapper.delete(id_entidad)

    def select_all(self):
        response = self.entidad_mapper.select_all()
        response["data"].insert(0,{"value": 0, "label": "TODOS"})
        return response, 200