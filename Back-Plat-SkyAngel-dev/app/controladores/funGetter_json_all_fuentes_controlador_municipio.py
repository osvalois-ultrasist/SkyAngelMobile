import json
import pandas as pd

from app.mapper.getter_json_all_fuentes_municipio_mapper import getterJsonMapperAllMunicipio


class getterJsonAllMunicipio():

    def __init__(self):
        self.getterJsonMapperAll = getterJsonMapperAllMunicipio()

    def obtenerDatos(self, jsonParametros):

        datos_mapper_result = self.getterJsonMapperAll.selectIncidentesCombinados(jsonParametros)
        if "Error" in datos_mapper_result:
            return datos_mapper_result
        
        datos_crudos = datos_mapper_result.get("data", [])
        #print("Esto son los datos crudos:",datos_crudos)
        if not datos_crudos:
            return {}

        # 2. Procesar y transformar los datos con Pandas
        df = pd.DataFrame(datos_crudos)

        # Asegurarse de que 'total' (conteo) es numérico, convertir si es necesario y rellenar NaN con 0
        df['conteo_secretariado'] = pd.to_numeric(df['conteo_secretariado'], errors='coerce').fillna(0)
        df['conteo_anerpv'] = pd.to_numeric(df['conteo_anerpv'], errors='coerce').fillna(0)
        df['conteo_sky'] = pd.to_numeric(df['conteo_sky'], errors='coerce').fillna(0)



        resultado_transformado = {}

        # Agrupar por 'id_entidad'
        for id_entidad, group in df.groupby('id_municipio'):
            entidad_str_key = str(id_entidad)
            resultado_transformado[entidad_str_key] = {}

            # Calcular el total general por cada fuente
            total_secretariado = group['conteo_secretariado'].sum()
            total_anerpv = group['conteo_anerpv'].sum()
            total_sky = group['conteo_sky'].sum()
            
            resultado_transformado[entidad_str_key]['secretariado'] = int(total_secretariado)
            resultado_transformado[entidad_str_key]['anerpv'] = int(total_anerpv)
            resultado_transformado[entidad_str_key]['sky'] = int(total_sky)

            # Total general (suma de las tres fuentes)
            total_general = total_secretariado + total_anerpv + total_sky
            resultado_transformado[entidad_str_key]['total'] = int(total_general)
    
        #print("Este son los datos transformados", resultado_transformado)    
        return resultado_transformado