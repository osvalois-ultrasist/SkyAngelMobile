import psycopg2
from flask import jsonify
from app.configuraciones.cursor import get_cursor

class Alerta_mapper():
    """
        Clase que mapea objetos alerta
        a la tabla alertas_sky
    """
    # Funcion para insertar una alerta a la base de datos
    def insert(self, alerta):
        try:
            with get_cursor() as cursor:
                cursor.execute(
                    "INSERT INTO alertas_sky (tipo_alerta, incidencia_alerta, fecha_alerta, dia_semana, hora_alerta, comentario_alerta, operador_de_unidad, central, linea_transportista, latitud_alerta, longitud_alerta, id_estatus_alerta) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s) RETURNING id_alerta",
                    (alerta.tipo_alerta, 
                     alerta.incidencia_alerta, 
                     alerta.fecha_alerta, 
                     alerta.dia_semana, 
                     alerta.hora_alerta,
                     alerta.comentario_alerta,
                     alerta.operador_de_unidad,
                     alerta.central, 
                     alerta.linea_transportista, 
                     alerta.latitud_alerta, 
                     alerta.longitud_alerta, 
                     alerta.id_estatus_alerta,
                    )
                )
                last_id = cursor.fetchone()[0]
                response = {"insert": True, "id_alerta":last_id}
                return response
        except psycopg2.Error as e:
            print(f"Error: {e}")
            raise Exception({"Error": "Error conexión del servidor"})
    # Funcion que consulta BD para obtener todas las alertas activas
    def get_alertas (self):
        try:
            with get_cursor() as cursor:
                query = """
                    SELECT
                        al.latitud_alerta,
                        al.longitud_alerta,
                        al.tipo_alerta,
                        al.incidencia_alerta,
                        al.fecha_alerta,
                        al.dia_semana,
                        al.hora_alerta,
                        al.comentario_alerta,
                        e.estatus_alerta as estatus
                    FROM alertas_sky al
                    INNER JOIN cat_estatus_alerta e ON al.id_estatus_alerta = e.id_estatus_alerta
                    WHERE al.id_estatus_alerta = 1
                """
                cursor.execute(query)
                rows = cursor.fetchall()
                alertas= [{
                    "latitud": float(row[0]),
                    "longitud": float(row[1]),
                    "Tipo": row[2],
                    "Incidencia": row[3],
                    "Fecha": row[4].strftime("%d/%m/%Y"),
                    "Día_semana": row[5],
                    "Hora": row[6].strftime("%H:%M"),
                    "Comentario": row[7],
                    "Estatus": row[8]
                }for row in rows]
                return alertas
        except psycopg2.Error as e:
            print(f"Error: {e}")
            raise Exception({"Error": "Error conexión del servidor"})

    def update_estatus(self):
        try:
            with get_cursor() as cursor:
                cursor.execute("""
                               UPDATE alertas_sky
                               SET id_estatus_alerta = 2
                               WHERE id_estatus_alerta = 1
                               AND (fecha_alerta + hora_alerta) < (CURRENT_TIMESTAMP - INTERVAL '2 hours')
                               """)
                filas_actualizadas = cursor.rowcount
                return {"desactivadas":filas_actualizadas}
        except psycopg2.Error as e:
            print(f"Error: {e}")
            raise Exception({"Error": "Error conexión del servidor"})

    # Funcion que consulta BD para obtener las subcategorias (subtipo de incidencia)
    def obtener_subcategorias (self):
        try:
            # Lista para almacenar las subcategorias
            subcategorias = []

            # Definir las fuentes de datos (tabla relacionada - categoria)
            fuentes= [
                {"tabla":"int_inc_delictivas", "categoria": "Incidencias delictivas"},
                {"tabla":"int_otras_incidencias", "categoria": "Otras incidencias en ruta"},
                {"tabla":"int_accidentes", "categoria": "Accidentes"},
                {"tabla":"int_recuperacion", "categoria": "Recuperaciones"},
            ]

            with get_cursor() as cursor:
                for fuente in fuentes:
                    # Consulta para obtener las subcategorias unicas
                    query = f"SELECT DISTINCT categoria FROM {fuente['tabla']} WHERE categoria IS NOT NULL"
                    cursor.execute(query)
                    resultados = cursor.fetchall()
                    for row in resultados:
                        subcategorias.append({
                            "categoria": fuente["categoria"], # Tipo de incidencia
                            "nombre": row[0] # Subtipo de incidencia 
                            })

                return subcategorias
            
        except psycopg2.Error as e:
            print(f"Error: {e}")
            raise Exception({"Error": "Error conexión del servidor"})


