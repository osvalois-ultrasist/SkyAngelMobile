from app.mapper.cat_delitos_secretariado_mapper import Cat_delitos_secretariado_mapper
from app.modelos.cat_delitos_secretariado import Cat_delitos_secretariado

class Cat_modalidad_service():

    def __init__(self):
        self.cat_delitos_secretariado = Cat_delitos_secretariado_mapper()

    def insert(self, json):
        cat_delsec =  Cat_delitos_secretariado(-1,
            json['id_subtipo_de_delito'],
            json['id_modalidad']
        )
        return self.cat_delitos_secretariado.insert(cat_delsec)

    def update(self, id_delito, json):
        cat_delsec =  Cat_delitos_secretariado(
            id_delito,
            json['id_subtipo_de_delito'],
            json['id_modalidad']
        )
        return self.cat_delitos_secretariado.update(cat_delsec)

    def delete(self, id_delito):
        return self.cat_delitos_secretariado.delete(id_delito)

    def select_all(self):
        return self.cat_delitos_secretariado.select_all()

    def select_por_id_subtipo(self,id_subtipo_de_delito):
        return self.cat_delitos_secretariado.select_por_id_subtipo(id_subtipo_de_delito)