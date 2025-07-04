from flask import Response
import json
from flask import jsonify
from app.mapper.conteo_reacciones_mapper import ConteoReacciones_mapper

class ConteoReacciones_service():
    def __init__(self):
        self.mapper = ConteoReacciones_mapper()

    def _formatear_respuesta(self, resultado):
        """Formatea la respuesta manteniendo el orden del GeoJSON"""
        if isinstance(resultado, tuple) and len(resultado) == 2:
            data, status_code = resultado
            if status_code != 200:
                return data, status_code
        else:
            data = resultado

        return data

    def select_incidencias(self, anio=None, mes=None, municipio=None, entidad=None):
        return self._formatear_respuesta(self.mapper.select_incidencias(anio, mes, municipio, entidad))

    def select_otras_incidencias(self, anio=None, mes=None, municipio=None, entidad=None):
        return self._formatear_respuesta(self.mapper.select_otras_incidencias(anio, mes, municipio, entidad))

    def select_accidentes(self, anio=None, mes=None, municipio=None, entidad=None):
        return self._formatear_respuesta(self.mapper.select_accidentes(anio, mes, municipio, entidad))

    def select_recuperaciones(self, anio=None, mes=None, municipio=None, entidad=None):
        return self._formatear_respuesta(self.mapper.select_recuperaciones(anio, mes, municipio, entidad))
