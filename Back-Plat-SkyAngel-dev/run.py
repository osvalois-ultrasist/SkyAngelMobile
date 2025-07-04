import eventlet
eventlet.monkey_patch()

from app import create_app, socketio
from app.configuraciones.config import Config
from flask_compress import Compress
from app.controladores.fun_scheduler_alertas import iniciar_scheduler_alertas

app = create_app()
Compress(app)
iniciar_scheduler_alertas()

"""
# Solo iniciar scheduler si no estamos en modo __main__ (i.e., llamado por gunicorn)
if __name__ != "__main__":
    iniciar_scheduler_alertas()

# Defino el modo Degub (True para desarrollo. False para produccion)
if __name__ == "__main__":
    iniciar_scheduler_alertas()
    socketio.run(app,host=Config.HOST,port=Config.PORT,debug=Config.DEBUG)
    """