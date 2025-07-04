import json
from flask import jsonify
from app.mapper.graficasFuentesExternas_mapper import FuentesExternasMapper

class GraficasFuentesExternasService():
    """Esta clase obtiene información de la base de datos 
    sobre las fuentes externas de la plataforma de riesgos 
    y genera archivos json con los parámetros necesarios 
    para realizar diferentes gráficas en la vista."""
    
    def __init__(self,parametros):
        self.parametrosValidados = self.validarParametrosEntrada(parametros)
        self.fuentesExternasMapper = FuentesExternasMapper()
        self.diccionarioMeses = self.fuentesExternasMapper.diccionarioMeses
        self.cveMunEntidades = self.fuentesExternasMapper.cveMunEntidades

    def validarParametrosEntrada(self,parametros):
        """Los parámetros de entrada para realizar la búsqueda 
        provenientes de los filtros definidos en la vista deben ser:
        anios:lista de enteros
        meses:lista de identificadores enteros
        entidades:lista de identificadores enteros
        municipios:lista de identificadores enteros"""
        parametrosValidados = {}
        try:
            for key, value in parametros.items():
                parametrosValidados[key] = self.validarListaEnteros(value)
                if parametrosValidados[key] == []:
                    parametrosValidados['validación'] = "Parámetros inválidos: {}".format(value) 
                    return parametrosValidados
                parametrosValidados['validación'] = "Parámetros correctos"
            return parametrosValidados
        except Exception as e:
            parametrosValidados['validación'] = "Parámetros inválidos: "+str(e)
            return parametrosValidados
    
    def validarListaEnteros(self,lista):
        """Valida si todos los elementos en la lista son enteros
        y si no devuelve una lista vacía"""
        if not lista:
            return []
        if not all(isinstance(i, int) for i in lista):
            return []
        return lista

    def obtenerDatosDelitosPorEntidadBarras(self,
                                            title ='Delitos por entidad',
                                            xAxisDataKey = 'entidades',
                                            yAxisLabel = 'Cantidad de delitos',
                                            width = [1200],
                                            height = [400],
                                            fontSize = 20,
                                            fontFamily = 'Verdana',
                                            color = ['#00ffff']):
        """Este método obtiene los datos de la base de datos
        y los transforma en un archivo json con la estructura
        necesaria para generar una gráfica de barras
        que muestra el conteo de delitos por entidad
        registrados en las fuentes externas 
        """
        data = {'title': title,
                    'xAxisParam' : {'scaleType': 'band', 'dataKey': xAxisDataKey},
                    'yAxisParam': {'label': yAxisLabel},
                    'mesNombre': str(self.diccionarioMeses),
                    'data': {},
                    'width': width,
                    'height': height,
                    'color': color,
                    'fontSize': fontSize,
                    'fontFamily': fontFamily
                    }
        # Validación de parámetros
        if self.parametrosValidados['validación'] == "Parámetros correctos":
            # Obtener los datos del mapper
            responseData, code = self.fuentesExternasMapper.selectDelitosPorEntidad(
                self.parametrosValidados['anios'], 
                self.parametrosValidados['meses'], 
                self.parametrosValidados['entidades'])
            data['data'] = responseData
            #data['status_code'] = code
            return json.dumps(data,ensure_ascii=False).encode('utf8'), code
        else:
            response = {"respuesta": 'Error con los parámetros: '+
            self.parametrosValidados['validación'],"status_code":400}
            return json.dumps(response,ensure_ascii=False).encode('utf8'), 400
    
    def obtenerDatosDelitosPorMunicipioBarras(self,
                                              title ='Delitos por municipio',
                                              xAxisDataKey = 'municipios',
                                              yAxisLabel = 'Cantidad de delitos',
                                              width = [1200],
                                              height = [400],
                                              fontSize = 20,
                                              fontFamily = 'Verdana',
                                              color = ['#00ffff']):
        """Este método obtiene los datos de la base de datos
        y los transforma en un archivo json con la estructura
        necesaria para generar una gráfica de barras
        que muestra el conteo de delitos por municipio 
        registrados en las fuentes externas 
        """
        data = {'title': title,
            'xAxisParam' : {'scaleType': 'band', 'dataKey': xAxisDataKey},
            'yAxisParam': {'label': yAxisLabel},
            'mesNombre': self.diccionarioMeses,
            'data': {},
            'width': width,
            'height': height,
            'color': color,
            'fontSize': fontSize,
            'fontFamily': fontFamily
            }
        # Validación de parámetros
        if self.parametrosValidados['validación'] == "Parámetros correctos":
            # Obtener los datos del mapper
            responseData, code = self.fuentesExternasMapper.selectDelitosPorMunicipio(
                self.parametrosValidados['anios'], 
                self.parametrosValidados['meses'], 
                self.parametrosValidados['municipios'])
            if code == 200:
                data['data'] = responseData
                return json.dumps(data,ensure_ascii=False).encode('utf8'), 200
            else:
                return responseData, code
        else:
            response = {"respuesta": 'Error con los parámetros: '+
            self.parametrosValidados['validación'],"status_code":400}
            return json.dumps(response,ensure_ascii=False).encode('utf8'), 400
        
    def obtenerDatosDelitosPorMunicipioTopBarras(self,
                                                 max_resultados=20,
                                                 title ='Delitos en los 20 municipios más peligrosos',
                                                 xAxisDataKey = 'municipios',
                                                 yAxisLabel = 'Cantidad de delitos',
                                                 width = [1200],
                                                 height = [400],
                                                 fontSize = 20,
                                                 fontFamily = 'Verdana',
                                                 color = ['#00ffff']):
        """Este método obtiene los datos de la base de datos
        y los transforma en un archivo json con la estructura
        necesaria para generar una gráfica de barras
        que muestra el conteo de delitos por municipio
        para los 20 municipios con mayor cantidad
        registrados en las fuentes externas 
        """
        data = {'title': title,
            'xAxisParam' : {'scaleType': 'band', 'dataKey': xAxisDataKey},
            'yAxisParam': {'label': yAxisLabel},
            'mesNombre': self.diccionarioMeses,
            'data': {},
            'width': width,
            'height': height,
            'color': color,
            'fontSize': fontSize,
            'fontFamily': fontFamily
            }
        # Validación de parámetros
        if self.parametrosValidados['validación'] == "Parámetros correctos":
            # Obtener los datos del mapper
            responseData, code = self.fuentesExternasMapper.selectDelitosPorMunicipioTop(
                self.parametrosValidados['anios'], 
                self.parametrosValidados['meses'], 
                self.parametrosValidados['municipios'],
                max_resultados)
            if code == 200:
                data['data'] = responseData
                return json.dumps(data,ensure_ascii=False).encode('utf8'), 200
            else:
                return responseData, code
        else:
            response = {"respuesta": 'Error con los parámetros: '+
            self.parametrosValidados['validación'],"status_code":400}
            return json.dumps(response,ensure_ascii=False).encode('utf8'), 400
