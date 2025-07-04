from app.mapper.cat_tipo_de_delito_mapper import Cat_tipo_de_delito_mapper
from app.modelos.cat_tipo_de_delito import Cat_tipo_de_delito

class Cat_tipo_de_delito_service():

    def __init__(self):
        self.cat_tipo_de_delito_mapper = Cat_tipo_de_delito_mapper()

    def insert(self, json):
        cat_tipo =  Cat_tipo_de_delito(-1,
            json['tipo_de_delito'],
            json['id_bien_juridico_afectado']
        )
        return self.cat_tipo_de_delito_mapper.insert(cat_tipo)

    def update(self, id_tipo_de_delito, json):
        cat_tipo =  Cat_tipo_de_delito(
            id_tipo_de_delito,
            json['tipo_de_delito'],
            json['id_bien_juridico_afectado']
        )
        return self.cat_tipo_de_delito_mapper.update(cat_tipo)

    def delete(self, id_tipo_de_delito):
        return self.cat_tipo_de_delito_mapper.delete(id_tipo_de_delito)

    def select_all(self):
        response, status = self.cat_tipo_de_delito_mapper.select_all()  # Desempaquetar el tuple
        if status == 200:
            response["data"].insert(0, {"value": 0, "label": "TODOS"})
        return response, status

    def select_por_id_bien(self,id_bien_juridico_afectado):
        return self.cat_tipo_de_delito_mapper.select_por_id_bien(id_bien_juridico_afectado)

    def select_tipoDeDelito_por_idBienJuridico(self,id_bien_juridico_afectado):
         # Validar si la lista está vacía o es nula
        if not id_bien_juridico_afectado:
            return {"Error": "Lista de id bien juridico afectado vacia o nula"}, 400
        
        response = self.cat_tipo_de_delito_mapper.select_tipoDeDelito_por_idBienJuridico(id_bien_juridico_afectado)  # Desempaquetar el tuple
        response["data"].insert(0, {"value": 0, "label": "TODOS"})
        return response, 200