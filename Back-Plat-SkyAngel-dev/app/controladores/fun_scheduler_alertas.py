from apscheduler.schedulers.background import BackgroundScheduler
from app.controladores.fun_alerta import AlertaService
import atexit
from app.configuraciones.config import TIEMPO_ALERTA_ACTIVA

'''Función que inicia el scheduler de alertas en segundo plano
que se ejecuta periodicamente para actualizar el status de las alertas''' 
def iniciar_scheduler_alertas():
    # Crear instancia scheduler en segundo plano
    scheduler = BackgroundScheduler()
    # Agregar tarea al scheduler que se ejecutara cada TIEMPO_ALERTA_ACTIVA (horas)
    scheduler.add_job(AlertaService().actualizar_estatus_alerta, 'interval', hours=TIEMPO_ALERTA_ACTIVA)
    #Agregar tarea al scheduler
    scheduler.start()
    # Registrar apagado del scheduler al cerrar la app
    atexit.register(lambda: scheduler.shutdown())
