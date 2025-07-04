class Sum_delitos_municipio_mes():
	"""
	Clase que maneja objetos Sum_delitos_municipio_mes 
	extaídos de la tabla SUM_DELITOS_MUNICIPIO_MES
	de la base de datos riesgos_sky_angel
	"""
    #Metodo, donde init es para iniciailzar el objeto
	def __init__(self,id_mes, id_delito_municipio, anio, conteo):

        #Propiedades del objeto
		self.id_mes = id_mes
		self.id_delito_municipio = id_delito_municipio
		self.anio = anio
		self.conteo = conteo
		
    #Método para conversion a string
	def __str__(self):
		return ("id_mes: "+str(self.id_mes)+","+
            "id_delito: "+str(self.id_delito)+","+
			"id_municipio: "+str(self.id_municipio)+","+
            "anio: "+str(self.anio)+","+			
            "conteo: "+str(self.conteo))
            
    #Método para conversion a JSON
	def to_json(self):
		return {"id_mes" : self.id_mes,
        "id_delito " : self.id_delito, 
        "id_municipio " : self.id_municipio, 
        "anio" : self.anio,			
        "conteo" : self.conteo}