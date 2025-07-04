class DelitosMunicipiosAnerpv():
	"""
	Clase que maneja objetos  DelitosMunicipiosAnerpv
	extaídos de la tabla SUM_DELITOS_MUNICIPIO_MES_ANERPV
	de la base de datos riesgos_sky_angel
	"""
    #Metodo, donde init es para iniciailzar el objeto
	def __init__(self,cve_municipio, anio, id_mes, conteo_robo_transportista, conteo_robo_transportista_acumulado):

        #Propiedades del objeto
		self.cve_municipio = cve_municipio
		self.anio = anio
		self.id_mes = id_mes
		self.conteo_robo_transportista = conteo_robo_transportista
		self.conteo_robo_transportista_acumulado = conteo_robo_transportista_acumulado
		
    #Método para conversion a string
	def __str__(self):
		return (
            "cve_municipio: "+str(self.cve_municipio)+","+
            "anio: "+str(self.anio)+","+
            "id_mes: "+str(self.id_mes)+","+
            "conteo_robo_transportista: "+str(self.conteo_robo_transportista)+","+
            "conteo_robo_transportista_acumulado: "+str(self.conteo_robo_transportista_acumulado)
        )
            
    #Método para conversion a JSON
	def to_json(self):
		return {
            "cve_municipio" : self.cve_municipio,
            "anio" : self.anio,
            "id_mes" : self.id_mes,
            "conteo_robo_transportista" : self.conteo_robo_transportista,
            "conteo_robo_transportista_acumulado" : self.conteo_robo_transportista_acumulado
        }