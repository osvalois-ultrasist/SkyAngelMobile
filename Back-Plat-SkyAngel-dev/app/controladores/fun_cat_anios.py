from app.mapper.cat_anios_mapper import Anios_mapper

class Cat_anios_service():

    def __init__(self):
        self.cat_anios_mapper = Anios_mapper()
    
    def select_distinct_anios(self):
        response = self.cat_anios_mapper.select_distinct_anios()
        response["data"].insert(0,{"value": 0, "label": "TODOS"})
        return response, 200

    def select_distinct_anios_fe(self):
        response = self.cat_anios_mapper.select_distinct_anios_fe()
        response["data"].insert(0,{"value": 0, "label": "TODOS"})
        return response, 200
    
    def select_distinct_anios_sa(self):
        response = self.cat_anios_mapper.select_distinct_anios_sa()
        response["data"].insert(0,{"value": 0, "label": "TODOS"})
        return response, 200