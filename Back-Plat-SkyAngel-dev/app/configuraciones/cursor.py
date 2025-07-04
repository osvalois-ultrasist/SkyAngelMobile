import psycopg2
from app.configuraciones.config import Config
from app.modelos.conexion_bd import Conexion_BD
from contextlib import contextmanager

@contextmanager
def get_cursor():
    conn = None
    cursor = None
    try:
        # Obtener la conexion
        conn = Conexion_BD().conexion_bd()
        # Crear el cursor
        cursor = conn.cursor()
        # Devolver el cursor para su uso
        yield cursor
        # Hacer commit si todo salió bien
        conn.commit()
    except psycopg2.Error as e:
        if conn:
            # Hacer rollback si algo falla
            conn.rollback()
        print(f"Error en la base de datos: {e}")
        raise
    finally:
        if cursor:
            # Cerrar el cursor
            cursor.close()
        if conn:
            # Cerrar la conexión
            conn.close()