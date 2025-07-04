from app.mapper.delitos_secretariado_municipio_mapper import Delitos_secretariado_municipio_mapper
from app.modelos.delitos_secretariado_municipio import Delitos_secretariado_municipio

class Delitos_secretariado_municipio_service():

    def __init__(self):
        self.delitos_secretariado_municipio = Delitos_secretariado_municipio_mapper()

    def insert(self, json):
        del_sec_mun =  Delitos_secretariado_municipio(-1,
            json['id_tipo_de_delito'],
            json['cve_municipio']
        )
        return self.delitos_secretariado_municipio.insert(del_sec_mun)

    def update(self, id_delito_municipio, json):
        del_sec_mun =  Delitos_secretariado_municipio(
            id_delito_municipio,
            json['id_tipo_de_delito'],
            json['cve_municipio']
        )
        return self.delitos_secretariado_municipio.update(del_sec_mun)

    def delete(self, id_delito_municipio):
        return self.delitos_secretariado_municipio.delete(id_delito_municipio)

    def select_all(self):
        return self.delitos_secretariado_municipio.select_all()