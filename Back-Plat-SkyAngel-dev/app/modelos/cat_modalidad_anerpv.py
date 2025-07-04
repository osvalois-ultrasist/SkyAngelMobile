class CatModalidadAnerpv():
	"""
	Clase que maneja objetos  CatModalidadAnerpv
	extaídos de la tabla CAT_MODALIDAD_ANERPV
	de la base de datos riesgos_sky_angel
	"""
    #Metodo, donde init es para iniciailzar el objeto
	def __init__(self,id_modalidad_anerpv, modalidad_anerpv):

        #Propiedades del objeto
		self.id_modalidad_anerpv = id_modalidad_anerpv
		self.modalidad_anerpv = modalidad_anerpv
		
    #Método para conversion a string
	def __str__(self):
		return ("id_modalidad_anerpv: "+str(self.id_modalidad_anerpv)+","+
            "modalidad_anerpv: "+str(self.modalidad_anerpv))
            
    #Método para conversion a JSON
	def to_json(self):
		return {"id_modalidad_anerpv" : self.id_modalidad_anerpv,
        "modalidad_anerpv " : self.modalidad_anerpv}