import pandas as pd
import psycopg2
from flask import jsonify
from app.configuraciones.config import Config
from app.modelos.conexion_bd import Conexion_BD

class Json_delitos():
    """
        Clase que mostrara JSON completo
        de delitos
    """    
    def select_delitos(self):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            query = """
                SELECT cbja.id_bien_juridico_afectado, cbja.bien_juridico_afectado, ctdd.id_tipo_de_delito, 
                       ctdd.tipo_de_delito, csdd.id_subtipo_de_delito, csdd.subtipo_de_delito, 
                       cm.id_modalidad, cm.modalidad
                FROM cat_delitos_secretariado cds
                LEFT JOIN cat_modalidad cm ON cds.id_modalidad = cm.id_modalidad
                LEFT JOIN cat_subtipo_de_delito csdd ON cds.id_subtipo_de_delito = csdd.id_subtipo_de_delito
                LEFT JOIN cat_tipo_de_delito ctdd ON csdd.id_tipo_de_delito = ctdd.id_tipo_de_delito
                LEFT JOIN cat_bien_juridico_afectado cbja ON ctdd.id_bien_juridico_afectado = cbja.id_bien_juridico_afectado
                ORDER BY cbja.id_bien_juridico_afectado ASC, ctdd.id_tipo_de_delito ASC, csdd.id_subtipo_de_delito ASC
            """
            df = pd.read_sql_query(query, conn)
            conn.close()

            # Transformar el DataFrame a JSON anidado
            return self.transformar_json(df), 200

        except psycopg2.Error as e:
            print(f"Error: {e}")
            return {"Error": "Error conexión del servidor"}, 500

    def transformar_json(self, df):
        nested_dict = {}
        for _, row in df.iterrows():
            bien_id = row['id_bien_juridico_afectado']
            bien_afectado = row['bien_juridico_afectado']
            tipo_id = row['id_tipo_de_delito']
            tipo_delito = row['tipo_de_delito']
            subtipo_id = row['id_subtipo_de_delito']
            subtipo_delito = row['subtipo_de_delito']
            modalidad_id = row['id_modalidad']
            modalidad = row['modalidad']

            if bien_id not in nested_dict:
                nested_dict[bien_id] = {
                    "id": bien_id,
                    "descripcion": bien_afectado,
                    "tipoDeDelito": {}
                }

            if tipo_id not in nested_dict[bien_id]["tipoDeDelito"]:
                nested_dict[bien_id]["tipoDeDelito"][tipo_id] = {
                    "id": tipo_id,
                    "descripcion": tipo_delito,
                    "subtipoDeDelito": {}
                }

            if subtipo_id not in nested_dict[bien_id]["tipoDeDelito"][tipo_id]["subtipoDeDelito"]:
                nested_dict[bien_id]["tipoDeDelito"][tipo_id]["subtipoDeDelito"][subtipo_id] = {
                    "id": subtipo_id,
                    "descripcion": subtipo_delito,
                    "modalidad": []
                }

            nested_dict[bien_id]["tipoDeDelito"][tipo_id]["subtipoDeDelito"][subtipo_id]["modalidad"].append({
                "id": modalidad_id,
                "descripcion": modalidad
            })

        nested_list = list(nested_dict.values())
        return {"bienJuridicoAfectado": nested_list}

