import pandas as pd
from app.modelos.constantes_globales import diccionarioMeses, diccionarioEstados
from app.mapper.graficas_reaccionesTabla_mapper import reaccionesTablaMapper

class funreaccionesTablaService():
    def __init__(self):
        self.reaccionesTabla = reaccionesTablaMapper()

    def obtenerDatos(self, jsonParametros):
        try:
            # Extraer parámetros
            anios = jsonParametros["años"]
            mes = jsonParametros["meses"]
            entidad = jsonParametros["entidades"]
            municipio = jsonParametros["municipios"]
            categoria = jsonParametros["categoria"]

            # Se realiza el reemplazo para todos los meses, para que
            # en el aplicativo, la tabla se despliegue mes por mes y no con "TODOS"
            if mes == [0]:
                mes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]

            # Obtener los datos del mapper
            responseData, code = self.reaccionesTabla.selectIncidentes(anios, mes, entidad, municipio, categoria)

            if code == 200:
                # Convertir la lista de diccionarios a un DataFrame
                df = pd.DataFrame(responseData['sumDelitos'])

                # Validar si el DataFrame está vacío
                if df.empty:
                    return {"data": [], "configuracion": {}}, 200

                # Mapear los nombres de los meses y entidades usando los diccionarios
                df["mesNombre"] = df["idMes"].astype(str).map(diccionarioMeses)
                df["entidadNombre"] = df["idEntidad"].astype(str).map(diccionarioEstados)

                # Agrupar los datos por 'entidad', 'anio' y 'mes', y sumar el 'conteo'
                entidad_mes_totales = df.groupby(['entidadNombre', 'anio', 'mesNombre'])['conteo'].sum().unstack(fill_value=0)

                # Añadir el acumulado para cada entidad
                entidad_mes_totales['acumulado'] = entidad_mes_totales.sum(axis=1)

                # Convertir el índice a columnas para facilitar el manejo
                entidad_mes_totales.reset_index(inplace=True)

                # Reorganizar los datos para incluir los meses como un subobjeto
                data = []
                for _, row in entidad_mes_totales.iterrows():
                    meses_individuales = {
                        mes: row.get(mes, 0) for mes in diccionarioMeses.values() if mes not in ['Todos']
                    }
                    data.append({
                        "entidad": row["entidadNombre"],
                        "anio": row["anio"],
                        "meses": meses_individuales,
                        "acumulado": row["acumulado"]
                    })

                # Crear la configuración de estilo para el frontend
                configuracion = {
                    "colorEncabezado": "#0D125B",
                    "colorTextoEncabezado": "white",
                    "titulo": "Delitos por Mes y por Estado, Año anterior y Año Actual",
                    "maxWidth": "100%",
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
