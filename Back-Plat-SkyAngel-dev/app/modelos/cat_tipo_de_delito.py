class Cat_tipo_de_delito():
	"""
	Clase que maneja objetos Cat_tipo_de_delito 
	extaídos de la tabla CAT_TIPO_DE_DELITO
	de la base de datos riesgos_sky_angel
	"""
    #Metodo, donde init es para iniciailzar el objeto
	def __init__(self,id_tipo_de_delito, tipo_de_delito, id_bien_juridico_afectado):

        #Propiedades del objeto
		self.id_tipo_de_delito = id_tipo_de_delito
		self.tipo_de_delito = tipo_de_delito
		self.id_bien_juridico_afectado = id_bien_juridico_afectado
		
    #Método para conversion a string
	def __str__(self):
		return ("id_tipo_de_delito: "+str(self.id_tipo_de_delito)+","+
			"tipo_de_delito: "+str(self.tipo_de_delito)+","+
			"id_bien_juridico_afectado: "+str(self.id_bien_juridico_afectado))
    
	#Método para conversion a JSON
	def to_json(self):
		return {"id_tipo_de_delito" : self.id_tipo_de_delito,
			"tipo_de_delito" : self.tipo_de_delito,
			"id_bien_juridico_afectado " : self.id_bien_juridico_afectado}