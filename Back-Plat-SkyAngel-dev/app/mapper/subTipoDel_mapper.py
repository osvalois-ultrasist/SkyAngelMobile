from app.configuraciones.cursor import get_cursor
import psycopg2


class Subtipo_delito_mapper():
    def select_all(self):
        try:
            with get_cursor() as cursor:
                query =  "select id_subtipo_de_delito,id_tipo_de_delito,subtipo_de_delito from cat_subtipo_de_delito"
                cursor.execute(query)
                rows = cursor.fetchall()
                subtipoDeDelitos = [{"value": row[0], "value1": row[1], "label": row[2]} for row in rows]
                response_data = {"data": subtipoDeDelitos}
                #print("La data es: ", response_data)
                return response_data
        except psycopg2.Error as e:
            # Imprimir el stack trace completo
            print(f"Error: {e}")
            return {"Error": "Error conexion del servidor"}, 500            
                

