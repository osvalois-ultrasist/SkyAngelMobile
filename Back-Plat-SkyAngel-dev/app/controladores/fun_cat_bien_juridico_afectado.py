from app.mapper.cat_bien_juridico_mapper import Cat_bien_juridico_mapper
from app.modelos.cat_bien_juridico_afectado import Cat_bien_juridico

class Cat_bien_juridico_service():

    def __init__(self):
        self.cat_bien_juridico_mapper = Cat_bien_juridico_mapper()

    def insert(self, json):
        cat_bien =  Cat_bien_juridico(-1,
            json['bien_juridico_afectado']
        )
        return self.cat_bien_juridico_mapper.insert(cat_bien)

    def update(self, id_bien_juridico_afectado, json):
        cat_bien =  Cat_bien_juridico(
            id_bien_juridico_afectado,
            json['bien_juridico_afectado'])
        return self.cat_bien_juridico_mapper.update(cat_bien)

    def delete(self, id_bien_juridico_afectado):
        return self.cat_bien_juridico_mapper.delete(id_bien_juridico_afectado)

    def select_all(self):
        response, status = self.cat_bien_juridico_mapper.select_all()  # Desempaquetar el tuple
        if status == 200:
            response["data"].insert(0, {"value": 0, "label": "TODOS"})
        return response, status