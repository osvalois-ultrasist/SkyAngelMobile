import json
class Tipos_de_delito():

    def __init__(self):
        self.tipos_de_delito=''
        
    def grafica(self, ruta_archivo):
        # Leer el archivo
        with open(ruta_archivo, 'r') as archivo:
            contenido = json.load(archivo)
        contenido_json = json.dumps(self.process_crime_data(contenido), indent=4)
        return contenido_json

    def process_crime_data(self, json_data):
        data_by_year = {}

        # Iterar sobre cada ubicación
        for location, years in json_data.items():
            # Iterar sobre cada año
            for year, months in years.items():
                if year not in data_by_year:
                    data_by_year[year] = {}

                # Iterar sobre cada mes
                for month, crimes in months.items():
                    total_crimes = sum(crimes.values())  # Sumar todos los delitos en el mes

                    if month not in data_by_year[year]:
                        data_by_year[year][month] = total_crimes
                    else:
                        data_by_year[year][month] += total_crimes

        return data_by_year