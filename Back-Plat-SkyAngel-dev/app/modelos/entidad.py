
#Es el objeto
class Entidad():
	"""
	Clase que maneja objetos Entidad 
	extaídos de la tabla CAT_ENTIDAD
	de la base de datos riesgos_sky_angel
	"""
    #Metodo, donde init es para iniciailzar el objeto
	def __init__(self,id_entidad, entidad):

        #Propiedades del objeto
		self.id_entidad = id_entidad
		self.entidad = entidad
    
	#Método para conversion a string
	def __str__(self):
		return ("id_entidad: "+str(self.id_entidad)+","+
			"entidad: "+str(self.entidad))
    
	#Método para conversion a JSON
	def to_json(self):
		return {"id_entidad" : self.id_entidad,
			"entidad" : self.entidad}	