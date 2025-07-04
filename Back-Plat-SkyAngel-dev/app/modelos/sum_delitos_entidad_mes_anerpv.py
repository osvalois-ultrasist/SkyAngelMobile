class DelitosEntidadAnerpv():
	"""
	Clase que maneja objetos  DelitosEntidadAnerpv
	extaídos de la tabla SUM_DELITOS_ENTIDAD_MES_ANERPV
	de la base de datos riesgos_sky_angel
	"""
    #Metodo, donde init es para iniciailzar el objeto
	def __init__(self,id_entidad, anio, id_mes, conteo_robo_transportista, conteo_robo_transportista_acumulado, conteo_robo_vehiculos_pesados, conteo_robo_vehiculos_ligeros, conteo_robo_vehiculos_privados, conteo_robo_turno_matutino, conteo_robo_turno_madrugada, conteo_robo_turno_vespertino, conteo_robo_turno_nocturno):

        #Propiedades del objeto
		self.id_entidad = id_entidad
		self.anio = anio
		self.id_mes = id_mes
		self.conteo_robo_transportista = conteo_robo_transportista
		self.conteo_robo_transportista_acumulado = conteo_robo_transportista_acumulado
		self.conteo_robo_vehiculos_pesados = conteo_robo_vehiculos_pesados
		self.conteo_robo_vehiculos_ligeros = conteo_robo_vehiculos_ligeros
		self.conteo_robo_vehiculos_privados = conteo_robo_vehiculos_privados
		self.conteo_robo_turno_matutino = conteo_robo_turno_matutino
		self.conteo_robo_turno_madrugada = conteo_robo_turno_madrugada
		self.conteo_robo_turno_vespertino = conteo_robo_turno_vespertino
		self.conteo_robo_turno_nocturno = conteo_robo_turno_nocturno
		
    #Método para conversion a string
	def __str__(self):
		return (
            "id_entidad: "+str(self.id_entidad)+","+
            "anio: "+str(self.anio)+","+
            "id_mes: "+str(self.id_mes)+","+
            "conteo_robo_transportista: "+str(self.conteo_robo_transportista)+","+
            "conteo_robo_transportista_acumulado: "+str(self.conteo_robo_transportista_acumulado)+","+
            "conteo_robo_vehiculos_pesados: "+str(self.conteo_robo_vehiculos_pesados)+","+
            "conteo_robo_vehiculos_ligeros: "+str(self.conteo_robo_vehiculos_ligeros)+","+
            "conteo_robo_vehiculos_privados: "+str(self.conteo_robo_vehiculos_privados)+","+
            "conteo_robo_turno_matutino: "+str(self.conteo_robo_turno_matutino)+","+
            "conteo_robo_turno_madrugada: "+str(self.conteo_robo_turno_madrugada)+","+
            "conteo_robo_turno_vespertino: "+str(self.conteo_robo_turno_vespertino)+","+
            "conteo_robo_turno_nocturno: "+str(self.conteo_robo_turno_nocturno)
        )
            
    #Método para conversion a JSON
	def to_json(self):
		return {
            "id_entidad" : self.id_entidad,
            "anio" : self.anio,
            "id_mes" : self.id_mes,
            "conteo_robo_transportista" : self.conteo_robo_transportista,
            "conteo_robo_transportista_acumulado " : self.conteo_robo_transportista_acumulado,
            "conteo_robo_vehiculos_pesados " : self.conteo_robo_vehiculos_pesados,
            "conteo_robo_vehiculos_ligeros " : self.conteo_robo_vehiculos_ligeros,
            "conteo_robo_vehiculos_privados " : self.conteo_robo_vehiculos_privados,
            "conteo_robo_turno_matutino " : self.conteo_robo_turno_matutino,
            "conteo_robo_turno_madrugada " : self.conteo_robo_turno_madrugada,
            "conteo_robo_turno_vespertino " : self.conteo_robo_turno_vespertino,
            "conteo_robo_turno_nocturno " : self.conteo_robo_turno_nocturno
        }