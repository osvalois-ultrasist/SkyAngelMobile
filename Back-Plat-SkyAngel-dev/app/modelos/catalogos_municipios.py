
#Es el objeto
class Municipios():
	"""
	Clase que maneja objetos Municipios 
	extaídos de la tabla CAT_MUNICIPIOS
	de la base de datos riesgos_sky_angel
	"""
    #Metodo, donde init es para iniciailzar el objeto
	
	def __init__(self,cve_municipio,municipio,latitud_centroide,longitud_centroide,id_entidad):

        #Propiedades del objeto
		self.cve_municipio = cve_municipio
		self.municipio = municipio
		self.latitud_centroide = latitud_centroide
		self.longitud_centroide = longitud_centroide
		self.id_entidad = id_entidad
    
	#Método para conversion a string
	def __str__(self):
		return ("cve_municipio: "+str(self.cve_municipio)+","+
			"municipio: "+str(self.municipio)+","+
            "latitud_centroide: "+str(self.latitud_centroide)+","+
            "longitud_centroide: "+str(self.longitud_centroide)+","+
            "id_entidad: "+str(self.id_entidad))
    
	#Método para conversion a JSON
	def to_json(self):
		return {"cve_municipio" : self.cve_municipio,
            "municipio" : self.municipio,
            "latitud_centroide" : self.latitud_centroide,
            "longitud_centroide" : self.longitud_centroide,
            "id_entidad" : self.id_entidad}
