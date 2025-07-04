class Alerta:
    def __init__(self, id_alerta, tipo_alerta, incidencia_alerta, fecha_alerta, dia_semana, hora_alerta, comentario_alerta, operador_de_unidad, central, linea_transportista, latitud_alerta, longitud_alerta, id_estatus_alerta):
        self.id_alerta = id_alerta
        self.tipo_alerta = tipo_alerta
        self.incidencia_alerta = incidencia_alerta
        self.fecha_alerta = fecha_alerta
        self.dia_semana = dia_semana
        self.hora_alerta = hora_alerta
        self.comentario_alerta = comentario_alerta
        self.operador_de_unidad = operador_de_unidad
        self.central = central
        self.linea_transportista = linea_transportista
        self.latitud_alerta = latitud_alerta
        self.longitud_alerta = longitud_alerta
        self.id_estatus_alerta = id_estatus_alerta

    def __str__(self):
        return (
            "id_alerta: "+str(self.id_alerta)+","+
            "tipo_alerta: "+str(self.tipo_alerta)+","+
            "incidencia_alerta: "+str(self.incidencia_alerta)+","+
            "fecha_alerta: "+str(self.fecha_alerta)+","+
            "dia_semana: "+str(self.dia_semana)+","+
            "hora_alerta: "+str(self.hora_alerta)+","+
            "comentario_alerta: "+str(self.comentario_alerta)+","+
            "operador_de_unidad: "+str(self.operador_de_unidad)+","+
            "central: "+str(self.central)+","+
            "linea_transportista: "+str(self.linea_transportista)+","+
            "latitud_alerta: "+str(self.latitud_alerta)+","+
            "longitud_alerta: "+str(self.longitud_alerta)+","+
            "id_estatus_alerta: "+str(self.id_estatus_alerta)
        )

    def to_json(self):
        return {
            "id_alerta" : self.id_alerta,
            "tipo_alerta" : self.tipo_alerta,
            "incidencia_alerta" : self.incidencia_alerta,
            "fecha_alerta" : self.fecha_alerta,
            "dia_semana" : self.dia_semana,
            "hora_alerta" : self.hora_alerta,
            "comentario_alerta" : self.comentario_alerta,
            "operador_de_unidad" : self.operador_de_unidad,
            "central" : self.central,
            "linea_transportista" : self.linea_transportista,
            "latitud_alerta" : self.latitud_alerta,
            "longitud_alerta" : self.longitud_alerta,
            "id_estatus_alerta" : self.id_estatus_alerta
        }