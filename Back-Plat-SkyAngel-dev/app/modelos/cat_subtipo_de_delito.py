class Cat_subtipo_de_delito():
	"""
	Clase que maneja objetos Cat_subtipo_de_delito 
	extaídos de la tabla CAT_SUBTIPO_DE_DELITO
	de la base de datos riesgos_sky_angel
	"""
    #Metodo, donde init es para iniciailzar el objeto
	def __init__(self,id_subtipo_de_delito, id_tipo_de_delito, subtipo_de_delito):

        #Propiedades del objeto
		self.id_subtipo_de_delito = id_subtipo_de_delito
		self.id_tipo_de_delito = id_tipo_de_delito
		self.subtipo_de_delito = subtipo_de_delito
		
    #Método para conversion a string
	def __str__(self):
		return ("id_subtipo_de_delito: "+str(self.id_subtipo_de_delito)+","+
			"id_tipo_de_delito: "+str(self.id_tipo_de_delito)+","+
			"subtipo_de_delito: "+str(self.subtipo_de_delito))
    #Método para conversion a JSON
	def to_json(self):
		return {"id_subtipo_de_delito" : self.id_subtipo_de_delito,
			"id_tipo_de_delito" : self.id_tipo_de_delito,
			"subtipo_de_delito " : self.subtipo_de_delito}