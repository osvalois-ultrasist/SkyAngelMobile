from flask_socketio import emit

def register_alerta_events(socketio):
# Evento para recibir la alerta desde el front-end
    @socketio.on('connect')
    def handle_connect():
        print('Cliente conectado')


    # Evento para recibir la alerta desde el front-end
    @socketio.on('enviarAlerta')
    def handle_alert(alerta):
        try:

            print(f'Alerta recibida: {alerta}')
            # Emitir la alerta a todos los clientes conectados
            socketio.emit('receiveAlert', alerta)
            print(f'Alerta enviada a todos los clientes conectados: {alerta}')

        except Exception as e:
            print(f'Error al enviar la alerta: {e}')    
            emit('error', {'message': str(e)})