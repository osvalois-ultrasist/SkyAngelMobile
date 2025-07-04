class Cat_modalidad():
	"""
	Clase que maneja objetos Cat_modalidad 
	extaídos de la tabla CAT_MODALIDAD
	de la base de datos riesgos_sky_angel
	"""
    #Metodo, donde init es para iniciailzar el objeto
	def __init__(self,id_modalidad, modalidad):

        #Propiedades del objeto
		self.id_modalidad = id_modalidad
		self.modalidad = modalidad
    
	#Método para conversion a string
	def __str__(self):
		return ("id_modalidad: "+str(self.id_modalidad)+","+
			"modalidad: "+str(self.modalidad))
   
    #Método para conversion a JSON
	def to_json(self):
		return {"id_modalidad" : self.id_modalidad,
			"modalidad" : self.modalidad}