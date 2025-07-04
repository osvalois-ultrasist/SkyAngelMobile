class Delitos_secretariado_municipio():
	"""
	Clase que maneja objetos Delitos_secretariado_municipio 
	extaídos de la tabla DELITOS_SECRETARIADO_MUNICIPIO
	de la base de datos riesgos_sky_angel
	"""
    #Metodo, donde init es para iniciailzar el objeto
	def __init__(self,id_delito_municipio, id_tipo_de_delito, cve_municipio):

        #Propiedades del objeto
		self.id_delito_municipio = id_delito_municipio
		self.id_tipo_de_delito = id_tipo_de_delito
		self.cve_municipio = cve_municipio
		
    #Método para conversion a string
	def __str__(self):
		return ("id_delito_municipio: "+str(self.id_delito_municipio+","+
            "id_tipo_de_delito: "+str(self.id_tipo_de_delito)+","+			
            "cve_municipio: "+str(self.cve_municipio)))
            
    #Método para conversion a JSON
	def to_json(self):
		return {"id_delito_municipio " : self.id_delito_municipio,  "id_tipo_de_delito" : self.id_tipo_de_delito,			
        "cve_municipio" : self.cve_municipio}