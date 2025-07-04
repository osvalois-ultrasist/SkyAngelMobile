import pandas as pd
from app.mapper.graficas_fuenteExternaTabla_mapper import fuenteExternaTablaMapper
from app.modelos.constantes_globales import diccionarioMeses

class funFuenteExternaTablaService():

    def __init__(self):
        self.fuenteExternaTabla = fuenteExternaTablaMapper()

    def obtenerDatos(self, jsonParametros):
        try:
            # Extraer parámetros
            anio = jsonParametros["anio"]
            mes = jsonParametros["mes"]
            entidad = jsonParametros["entidad"]
            municipio = jsonParametros["municipio"]

            # Se realiza el reemplazo para todos los meses, para que
            # en el aplicativo, la tabla se despliegue mes por mes y no con "TODOS"
            if mes == [0]:
                mes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]

            # Si el usuario intenta filtrar por municipios, se ajustan las listas para que
            # unicamente filtre por la entidad. Asi la tabla se despliega por entidad
            if municipio != [0]:
                entidad = self.obtner_lista_entidades(municipio)
                municipio = [0] # Se forza a 0 para evitar errores en la tabla

            # Obtener los datos del mapper
            responseData, code = self.fuenteExternaTabla.selectIncidentes(anio, mes, entidad, municipio)

            if code == 200:
                # Convertir la lista de diccionarios a un DataFrame
                df = pd.DataFrame(responseData['sumDelitos'])

                # Mapear los nombres de los meses usando el diccionario
                df["mesNombre"] = df["mes"].astype(str).map(diccionarioMeses)

                # Agrupar los datos por 'entidad' y 'mes', y sumar el 'conteo'
                entidad_mes_totales = df.groupby(['entidad', 'anio', 'mesNombre'])['conteo'].sum().unstack(fill_value=0)

                # Añadir el acumulado para cada entidad
                entidad_mes_totales['acumulado'] = entidad_mes_totales.sum(axis=1)

                # Convertir el índice a columnas para facilitar el manejo
                entidad_mes_totales.reset_index(inplace=True)

                # Reorganizar los datos para incluir los meses como un subobjeto
                data = []
                for _, row in entidad_mes_totales.iterrows():
                    meses_individuales = {
                        mes: row.get(mes, 0) for mes in entidad_mes_totales.columns if mes not in ['entidad', 'anio', 'acumulado']
                    }
                    data.append({
                        "entidad": row["entidad"],
                        "anio": row["anio"],
                        "meses": meses_individuales,
                        "acumulado": row["acumulado"]
                    })

                # Crear la configuración de estilo para el frontend
                configuracion = {
                    "colorEncabezado": "#0D125B",
                    "colorTextoEncabezado": "white",
                    "titulo": "Delitos por Mes y por Estado, Año anterior y Año Actual",
                    "maxWidth": 500,
                    "margin": "auto",
                    "marginTop": 4,
                    "meses": [diccionarioMeses[str(i)] for i in mes]
                }

                # Combinar los datos y la configuración en un solo JSON
                response = {
                    "data": data,
                    "configuracion": configuracion
                }

                return response, 200

            else:
                # Si el código no es 200, retorna el mensaje de error del mapper
                return responseData, code

        except KeyError as e:
            # Si falta algún parámetro en la solicitud
            return {"error": f"Falta el parámetro: {str(e)}"}, 400
        except Exception as e:
            # Manejo de cualquier otro error general
            return {"error": f"Error interno: {str(e)}"}, 500
        
    # Las entidades estan definidas del numero 1000 (Aguascalientes) a 32000 (Zacatecas)
    # Se guardan las entidades correspondientes de los municipios elegidos
    def obtner_lista_entidades(self, lista):
        resultado = set()

        for numero in lista:
            str_num = str(numero)
            if len(str_num) == 4:
                resultado.add(int(str_num[0]))     
            elif len(str_num) >= 5:
                resultado.add(int(str_num[:2]))   

        return sorted(resultado)