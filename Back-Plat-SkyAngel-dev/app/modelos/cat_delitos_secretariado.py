class Cat_delitos_secretariado():
	"""
	Clase que maneja objetos Cat_delitos_secretariado 
	extaídos de la tabla CAT_DELITOS_SECRETARIADO
	de la base de datos riesgos_sky_angel
	"""
    #Metodo, donde init es para iniciailzar el objeto
	def __init__(self,id_delito, id_subtipo_de_delito, id_modalidad):

        #Propiedades del objeto
		self.id_delito = id_delito
		self.id_subtipo_de_delito = id_subtipo_de_delito
		self.id_modalidad = id_modalidad
		
    #Método para conversion a string
	def __str__(self):
		return ("id_delito: "+str(self.id_delito)+","+
			"id_subtipo_de_delito: "+str(self.id_subtipo_de_delito+","+
			"id_modalidad: "+str(self.id_modalidad)))
            
    #Método para conversion a JSON
	def to_json(self):
		return {"id_delito" : self.id_delito,
			"id_subtipo_de_delito " : self.id_subtipo_de_delito,
			"id_modalidad" : self.id_modalidad}