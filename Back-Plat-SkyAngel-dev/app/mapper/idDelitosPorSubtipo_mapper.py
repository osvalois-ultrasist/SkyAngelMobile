import pandas as pd
import psycopg2
from flask import jsonify
from app.configuraciones.config import Config
from app.modelos.conexion_bd import Conexion_BD

class IdDelitosPorSubtipo_mapper():
    def selectDelitoPorSubtipo(self, subTipos):
        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            # Añadir un AND id_modalidad IN ({})
            query = """
                    SELECT id_delito
                    FROM cat_delitos_secretariado
                    WHERE id_subtipo_de_delito IN ({})  
                    ORDER BY id_delito ASC;
            """.format(self.concatenarListas(subTipos,','))
            
            #Ejecutamos la consulta
            cursor.execute(query)

            #Obtener los resultados como lista de tuplas
            resultados = cursor.fetchall()

            #Cerrar la conexion
            conn.close()

            #Convertir los resultados a una lista para jsonify
            delitos = [row[0] for row in resultados]

            return jsonify({"idDelitos": delitos}), 200
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return {"Error": "Error conexión del servidor"}, 500

    def concatenarListas(self,lista,conector):
        return conector.join(map(str, lista))