
from app.mapper.subTipoDel_mapper import Subtipo_delito_mapper
from flask import jsonify

class Subtipo_delito_service():
    def __init__(self):
       self.subtipo_delito_mapper = Subtipo_delito_mapper()

    def get_todos_subtipo(self):
        try:
            response_data = self.subtipo_delito_mapper.select_all()
            
            if 'data' in response_data:
                return jsonify(response_data["data"]), 200
            else:
                return jsonify({"Error": "Formato de datos inesperados en el mapper"}), 500
        except Exception as e:
            print(f"Error en el servicio: {e}")
            return jsonify({"Error": "Error interno del servidor al obtener los subtipos de delito"}), 500
        
        


       
       