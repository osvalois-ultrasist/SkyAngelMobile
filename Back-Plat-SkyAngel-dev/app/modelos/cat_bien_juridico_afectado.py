class Cat_bien_juridico():
	"""
	Clase que maneja objetos Cat_bien_juridico 
	extaídos de la tabla CAT_BIEN_JURIDICO_AFECTADO
	de la base de datos riesgos_sky_angel
	"""
    #Metodo, donde init es para iniciailzar el objeto
	def __init__(self,id_bien_juridico_afectado, bien_juridico_afectado):

        #Propiedades del objeto
		self.id_bien_juridico_afectado = id_bien_juridico_afectado
		self.bien_juridico_afectado = bien_juridico_afectado
    #Método para conversion a string
	def __str__(self):
		return ("id_bien_juridico_afectado: "+str(self.id_bien_juridico_afectado)+","+
			"bien_juridico_afectado: "+str(self.bien_juridico_afectado))
    #Método para conversion a JSON
	def to_json(self):
		return {"id_bien_juridico_afectado" : self.id_bien_juridico_afectado,
			"bien_juridico_afectado" : self.bien_juridico_afectado}