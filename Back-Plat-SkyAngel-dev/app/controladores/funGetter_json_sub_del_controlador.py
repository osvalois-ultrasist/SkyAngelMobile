import json
import pandas as pd
from app.mapper.getter_json_sub_del_mapper import SubtipoDelitosTotalEstado


# Función auxiliar para formatear los nombres de modalidad a claves camelCase
# Ejemplo: "Arma Blanca" -> "armaBlanca", "Aborto" -> "aborto"
def _format_modalidad_key(modalidad_name: str) -> str:
    if not modalidad_name:
        return "desconocida"
    
    parts = [part for part in modalidad_name.split(' ') if part]
    if not parts:
        return "desconocida"
    
    key = parts[0].lower()
    if len(parts) > 1:
        for part in parts[1:]:
            key += part.capitalize()
    return key

class GetJsonSubtipoEntidadService():

    def __init__(self):
        self.subtipo_delitos_mapper = SubtipoDelitosTotalEstado()
        

    def obtenerDatos(self, jsonParametros):
        # 1. Obtener los datos usando el mapper
        datos_mapper_result = self.subtipo_delitos_mapper.selectSubDel(jsonParametros)

        if "Error" in datos_mapper_result:
            return datos_mapper_result
        
        datos_crudos = datos_mapper_result.get("data", [])
        #print("Esto son los datos crudos:",datos_crudos)
        if not datos_crudos:
            return {}

        # 2. Procesar y transformar los datos con Pandas
        df = pd.DataFrame(datos_crudos)

        # Asegurarse de que 'total' (conteo) es numérico, convertir si es necesario y rellenar NaN con 0
        if 'total' in df.columns:
            df['total'] = pd.to_numeric(df['total'], errors='coerce').fillna(0)
        else: # Si no hay columna 'total', no se puede procesar
            return {"Error": "La columna 'total' no se encuentra en los datos del mapper."}


        resultado_transformado = {}

        # Agrupar por 'id_entidad'
        for id_entidad, group in df.groupby('id_entidad'):
            entidad_str_key = str(id_entidad)
            resultado_transformado[entidad_str_key] = {}

            # Calcular el total general para la entidad
            total_general_entidad = group['total'].sum()
            resultado_transformado[entidad_str_key]['total'] = int(total_general_entidad) # Convertir a int si es necesario

            # Contar las modalidades únicas y sus sumas
            modalidades_unicas = group['modalidad'].nunique()
            
            if modalidades_unicas > 1:
                # Si hay más de una modalidad, agrupar por modalidad y sumar los totales
                modalidades_sum = group.groupby('modalidad')['total'].sum()
                for modalidad_nombre, suma_modalidad in modalidades_sum.items():
                    clave_modalidad_formateada = _format_modalidad_key(modalidad_nombre)
                    resultado_transformado[entidad_str_key][clave_modalidad_formateada] = int(suma_modalidad)
            # Si solo hay una modalidad (o ninguna, aunque el total general ya está),
            # no se añaden claves de modalidad específicas, solo se mantiene el "total" general.
        #print("Este son los datos transformados", resultado_transformado)    
        return resultado_transformado
