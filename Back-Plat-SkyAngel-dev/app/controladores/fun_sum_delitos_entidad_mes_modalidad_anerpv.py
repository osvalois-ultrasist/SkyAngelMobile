from app.mapper.sum_delitos_entidad_mes_modalidad_anerpv_mapper import DelitosModalidadAnerpv_mapper
from app.modelos.sum_delitos_entidad_mes_modalidad_anerpv import DelitosModalidadAnerpv

class DelitosModalidadAnerpv_service():

    def __init__(self):
        self.delitosmodalidadanerpv_mapper = DelitosModalidadAnerpv_mapper()

    def insert(self, json):
        ent_mod =  DelitosModalidadAnerpv(
            json['id_entidad'],
            json['anio'],
            json['id_mes'],
            json['id_modalidad_anerpv'],
            json['conteo_robo_transportista'],
            json['conteo_robo_transportista_acumulado'],
        )
        return self.delitosmodalidadanerpv_mapper.insert(ent_mod)

    ## PENDIENTE POR REVISAR PARA EL UPDATE
    def update(self, id_modalidad_anerpv, json):
        # Verificar si los datos 'entidad_modalidad_anerpv' está en el JSON
        if 'modalidad_anerpv' not in json or not json['modalidad_anerpv'].strip():
            return {"Error": "El campo 'modalidad_anerpv' es obligatorio y no debe estar vacío"}, 400
        ent_mod =  DelitosModalidadAnerpv(
            id_modalidad_anerpv,
            json['modalidad_anerpv'])
        return self.delitosmodalidadanerpv_mapper.update(ent_mod)

    def delete(self, json):
        id_entidad = json['id_entidad'],
        anio = json['anio'],
        id_mes = json['id_mes'],
        id_modalidad_anerpv = json['id_modalidad_anerpv']
        return self.delitosmodalidadanerpv_mapper.delete(id_entidad, anio, id_mes, id_modalidad_anerpv)

    def select_all(self):
        return self.delitosmodalidadanerpv_mapper.select_all()