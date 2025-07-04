class DelitosModalidadAnerpv():
	"""
	Clase que maneja objetos  DelitosModalidadAnerpv
	extaídos de la tabla SUM_DELITOS_ENTIDAD_MES_MODALIDAD_ANERPV
	de la base de datos riesgos_sky_angel
	"""
    #Metodo, donde init es para iniciailzar el objeto
	def __init__(self,id_entidad, anio, id_mes, id_modalidad_anerpv, conteo_robo_transportista, conteo_robo_transportista_acumulado):

        #Propiedades del objeto
		self.id_entidad = id_entidad
		self.anio = anio
		self.id_mes = id_mes
		self.id_modalidad_anerpv = id_modalidad_anerpv
		self.conteo_robo_transportista = conteo_robo_transportista
		self.conteo_robo_transportista_acumulado = conteo_robo_transportista_acumulado
		
    #Método para conversion a string
	def __str__(self):
		return (
            "id_entidad: "+str(self.id_entidad)+","+
            "anio: "+str(self.anio)+","+
            "id_mes: "+str(self.id_mes)+","+
            "id_modalidad_anerpv: "+str(self.id_modalidad_anerpv)+","+
            "conteo_robo_transportista: "+str(self.conteo_robo_transportista)+","+
            "conteo_robo_transportista_acumulado: "+str(self.conteo_robo_transportista_acumulado)
        )
            
    #Método para conversion a JSON
	def to_json(self):
		return {
            "id_entidad" : self.id_entidad,
            "anio" : self.anio,
            "id_mes" : self.id_mes,
            "id_modalidad_anerpv" : self.id_modalidad_anerpv,
            "conteo_robo_transportista" : self.conteo_robo_transportista,
            "conteo_robo_transportista_acumulado " : self.conteo_robo_transportista_acumulado
        }