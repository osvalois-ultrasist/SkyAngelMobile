from app.mapper.cat_modalidad_mapper import Cat_modalidad_mapper
from app.modelos.cat_modalidad import Cat_modalidad

class Cat_modalidad_service():

    def __init__(self):
        self.cat_modalidad_mapper = Cat_modalidad_mapper()

    def insert(self, json):
        cat_mod =  Cat_modalidad(-1,
            json['modalidad']
        )
        return self.cat_modalidad_mapper.insert(cat_mod)

    def update(self, id_modalidad, json):
        cat_mod =  Cat_modalidad(
            id_modalidad,
            json['modalidad'])
        return self.cat_modalidad_mapper.update(cat_mod)

    def delete(self, id_modalidad):
        return self.cat_modalidad_mapper.delete(id_modalidad)

    def select_all(self):
        return self.cat_modalidad_mapper.select_all()

    def select_modalidad_por_idSubtipoDeDelito(self,id_subtipo_de_delito):
         # Validar si la lista está vacía o es nula
        if not id_subtipo_de_delito:
            return {"Error": "Lista de 'id_subtipo_de_delito' vacia o nula"}, 400

        response = self.cat_modalidad_mapper.select_modalidad_por_idSubtipoDeDelito(id_subtipo_de_delito)  # Desempaquetar el tuple
        response["data"].insert(0, {"value": 0, "label": "TODOS"})
        return response, 200

    def select_modalidad_delitos_vista(self,subtipoDeDelito):
         # Validar si la lista está vacía o es nula
        if not subtipoDeDelito:
            return {"Error": "Lista de 'id_subtipo_de_delito' vacia o nula"}, 400

        response = self.cat_modalidad_mapper.select_modalidad_delitos_vista(subtipoDeDelito)  # Desempaquetar el tuple
        response["data"].insert(0, {"value": 0, "label": "TODOS"})
        return response, 200