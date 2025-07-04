from app.mapper.json_delitos_mapper import Json_delitos

class Json_delitos_service():

    def __init__(self):
        self.json_delitos_mapper = Json_delitos()

    def select_json(self):
        return self.json_delitos_mapper.select_delitos()   

