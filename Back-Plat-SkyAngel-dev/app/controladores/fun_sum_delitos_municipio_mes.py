import pandas as pd
from app.mapper.sum_delitos_municipios_mapper import Sum_delitos_municipio_mes_mapper
from app.modelos.sum_delitos_municipio_mes import Sum_delitos_municipio_mes
from app.configuraciones.rutas_archivos import archivo_delitos, archivo_delitos_secretariado

class Sum_delitos_municipio_mes_service():

    def __init__(self):
        self.sum_delitos_municipio_mes = Sum_delitos_municipio_mes_mapper()

    def procesar_csv(self, file):
        try:

            # Leer ambos archivos Excel
            delitos_df = pd.read_excel(archivo_delitos)
            datos = pd.read_excel(file)

            # Concatenar varias columnas en una nueva columna en ambos DataFrames
            columnas_concatenar = ['Bien jurídico afectado', 'Tipo de delito', 'Subtipo de delito', 'Modalidad']
            delitos_df['columna_concatenada'] = delitos_df[columnas_concatenar].apply(lambda x: '-'.join(x.astype(str)), axis=1)
            datos['columna_concatenada'] = datos[columnas_concatenar].apply(lambda x: '-'.join(x.astype(str)), axis=1)

            # Crear diccionarios para mapear descripciones a IDs en delitos_df
            mapas = {
                'ID': dict(zip(delitos_df['columna_concatenada'], delitos_df['ID'])),
                'id_tipo_delito': dict(zip(delitos_df['Tipo de delito'], delitos_df['id_tipo_delito'])),
                'id_subtipo': dict(zip(delitos_df['Subtipo de delito'], delitos_df['id_subtipo'])),
                'id_modalidad': dict(zip(delitos_df['Modalidad'], delitos_df['id_modalidad']))
            }

            # Aplicar el mapeo para asignar IDs en datos
            for columna, mapa in mapas.items():
                datos[columna] = datos['columna_concatenada'].map(mapa)

            # Diccionario para mapear los nombres de los meses a números
            meses_dict = {
                'Diciembre': 12, 'Noviembre': 11, 'Octubre': 10, 'Septiembre': 9, 
                'Agosto': 8, 'Julio': 7, 'Junio': 6, 'Mayo': 5, 'Abril': 4, 
                'Marzo': 3, 'Febrero': 2, 'Enero': 1
            }

            # Buscar el primer mes con datos
            for mes, num in meses_dict.items():
                if datos[mes].notna().any():
                    df_filtrado = datos[['ID', 'Año', 'Cve. Municipio', mes]].copy()
                    df_filtrado.rename(columns={
                        'Año': 'anio',
                        'Cve. Municipio': 'cve_municipio',
                        mes: 'conteo'
                    }, inplace=True)
                    df_filtrado['id_mes'] = num
                    break
            else:
                return {"Error": "No se encontraron datos en ningún mes."}, 400

            # Crear columna concatenada para comparar con DELITOS_SECRETARIADO_MUNICIPIO
            df_filtrado['columna_concatenada'] = df_filtrado['ID'].astype(str) + '-' + df_filtrado['cve_municipio'].astype(str)

            # Leer el archivo CSV de DELITOS_SECRETARIADO_MUNICIPIO
            datos_csv = pd.read_csv(archivo_delitos_secretariado)

            # Crear columna concatenada en datos_csv
            datos_csv['columna_concatenada'] = datos_csv['ID_TIPO_DE_DELITO'].astype(str) + '-' + datos_csv['CVE_MUNICIPIO'].astype(str)

            # Crear diccionario para mapear las IDs
            mapa_delito_mun = dict(zip(datos_csv['columna_concatenada'], datos_csv['ID_DELITO_MUNICIPIO']))

            # Asignar IDs en df_filtrado
            df_filtrado['id_delito_municipio'] = df_filtrado['columna_concatenada'].map(mapa_delito_mun)
            df_filtrado['CVE_MUNICIPIO'] = df_filtrado['cve_municipio'].map(datos_csv['CVE_MUNICIPIO'])

            # Exportar el resultado a un nuevo archivo Excel
            datos_expo = df_filtrado[['id_delito_municipio', 'cve_municipio', 'id_mes', 'anio', 'conteo']].to_dict(orient='records')

            return self.sum_delitos_municipio_mes.insert_or_update(datos_expo)
        except Exception as e:
            return {"Error": f"Error procesando el archivo: {e}"}, 500

    def delete(self, json):
        sum_del_mun_mes =  Sum_delitos_municipio_mes(
            json['id_mes'],
            json['id_delito_municipio'],
            json['anio'],
            json['conteo']
        )
        return self.sum_delitos_municipio_mes.delete(sum_del_mun_mes)

    def select_all(self):
        return self.sum_delitos_municipio_mes.select_all()

    def select_vista(self, modalidades, subtiposDelitos, anios, entidades, meses, municipios):
         # Validar si la lista está vacía o es nula
        errores = []

        if not modalidades:
            errores.append("El campo 'modalidades' es obligatorio.")
        if not subtiposDelitos:
            errores.append("El campo 'subtipos de delitos' es obligatorio.")
        if not anios:
            errores.append("El campo 'años' es obligatorio.")
        if not meses:
            errores.append("El campo 'meses' es obligatorio.")
        if not municipios:
            errores.append("El campo 'municipios' es obligatorio.")
        
        if errores:
            return {"Errores": errores}, 400
        
        # Llamar a la función de consulta si la validación pasa
        response = self.sum_delitos_municipio_mes.select_vista(modalidades, subtiposDelitos, anios, entidades, meses, municipios)
        return response, 200