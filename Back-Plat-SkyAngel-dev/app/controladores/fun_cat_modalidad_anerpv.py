from app.mapper.cat_modalidad_anerpv_mapper import CatModalidadAnerpv_mapper
from app.modelos.cat_modalidad_anerpv import CatModalidadAnerpv

class CatModalidadAnerpv_service():

    def __init__(self):
        self.CatModalidadAnerpv_mapper = CatModalidadAnerpv_mapper()

    def insert(self, json):
        cat_mod =  CatModalidadAnerpv(-1,
            json['modalidad_anerpv']
        )
        return self.CatModalidadAnerpv_mapper.insert(cat_mod)

    def update(self, id_modalidad_anerpv, json):
# Verificar si 'modalidad_anerpv' está en el JSON
        if 'modalidad_anerpv' not in json or not json['modalidad_anerpv'].strip():
            return {"Error": "El campo 'modalidad_anerpv' es obligatorio y no debe estar vacío"}, 400
        cat_mod =  CatModalidadAnerpv(
            id_modalidad_anerpv,
            json['modalidad_anerpv'])
        return self.CatModalidadAnerpv_mapper.update(cat_mod)

    def delete(self, id_modalidad_anerpv):
        return self.CatModalidadAnerpv_mapper.delete(id_modalidad_anerpv)

    def select_all(self):
        return self.CatModalidadAnerpv_mapper.select_all()