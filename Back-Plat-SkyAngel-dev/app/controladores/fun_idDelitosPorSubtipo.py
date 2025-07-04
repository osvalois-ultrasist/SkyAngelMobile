from app.mapper.idDelitosPorSubtipo_mapper import IdDelitosPorSubtipo_mapper


class IdDelitosPorSubtipo_service():

    def __init__(self):
        self.IdDelitosPorSubtipo_mapper = IdDelitosPorSubtipo_mapper()

    def selectDelitoPorSubtipoMapper(self, subTipos):
        # Validar si la lista está vacía o es nula
        if not subTipos or all(tipo == 0 for tipo in subTipos):
            return {"Error": "Lista de subtipos vacia o nula"}, 400
        return self.IdDelitosPorSubtipo_mapper.selectDelitoPorSubtipo(subTipos)   