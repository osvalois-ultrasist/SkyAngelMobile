from app.mapper.cat_subtipo_de_delito_mapper import Cat_subtipo_de_delito_mapper
from app.modelos.cat_subtipo_de_delito import Cat_subtipo_de_delito

class Cat_subtipo_de_delito_service():

    def __init__(self):
        self.cat_subtipo_de_delito_mapper = Cat_subtipo_de_delito_mapper()

    def insert(self, json):
        cat_subtipo =  Cat_subtipo_de_delito(-1,
            json['id_tipo_de_delito'],
            json['subtipo_de_delito']
        )
        return self.cat_subtipo_de_delito_mapper.insert(cat_subtipo)

    def update(self, id_subtipo_de_delito, json):
        cat_subtipo =  Cat_subtipo_de_delito(
            id_subtipo_de_delito,
            json['id_tipo_de_delito'],
            json['subtipo_de_delito']
        )
        return self.cat_subtipo_de_delito_mapper.update(cat_subtipo)

    def delete(self, id_subtipo_de_delito):
        return self.cat_subtipo_de_delito_mapper.delete(id_subtipo_de_delito)

    def select_all(self):
        return self.cat_subtipo_de_delito_mapper.select_all()

    def select_por_id_tipo(self,id_tipo_de_delito):
        return self.cat_subtipo_de_delito_mapper.select_por_id_tipo(id_tipo_de_delito)

    def select_subtipoDeDelito_por_idTipoDeDelito(self,id_tipo_de_delito):
         # Validar si la lista está vacía o es nula
        if not id_tipo_de_delito:
            return {"Error": "Lista de id tipo de delito vacia o nula"}, 400

        response = self.cat_subtipo_de_delito_mapper.select_subtipoDeDelito_por_idTipoDeDelito(id_tipo_de_delito)  # Desempaquetar el tuple
        response["data"].insert(0, {"value": 0, "label": "TODOS"})
        return response, 200