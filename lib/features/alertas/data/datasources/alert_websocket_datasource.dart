import 'dart:async';
import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../../core/config/environment.dart';
import '../../../../core/error/app_error.dart';
import '../../../../core/utils/logger.dart';
import '../models/alert_model.dart';

@LazySingleton()
class AlertWebSocketDataSource {
  io.Socket? _socket;
  final StreamController<AlertModel> _newAlertController = StreamController<AlertModel>.broadcast();
  final StreamController<AlertModel> _alertUpdateController = StreamController<AlertModel>.broadcast();
  
  bool _isConnected = false;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 5;
  static const Duration reconnectDelay = Duration(seconds: 3);

  Stream<AlertModel> get newAlertStream => _newAlertController.stream;
  Stream<AlertModel> get alertUpdateStream => _alertUpdateController.stream;
  
  bool get isConnected => _isConnected;

  Future<void> connect() async {
    try {
      if (_isConnected && _socket?.connected == true) {
        AppLogger.info('WebSocket already connected');
        return;
      }

      AppLogger.info('Connecting to WebSocket at ${EnvironmentConfig.baseUrl}');
      
      _socket = io.io(
        EnvironmentConfig.baseUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(maxReconnectAttempts)
            .setReconnectionDelay(reconnectDelay.inMilliseconds)
            .build(),
      );

      _setupEventListeners();
      
      _socket!.connect();
      
    } catch (e) {
      AppLogger.error('Error connecting to WebSocket', error: e);
      _scheduleReconnect();
    }
  }

  void _setupEventListeners() {
    _socket!.onConnect((_) {
      AppLogger.info('WebSocket connected successfully');
      _isConnected = true;
      _reconnectAttempts = 0;
      _reconnectTimer?.cancel();
    });

    _socket!.onDisconnect((_) {
      AppLogger.warning('WebSocket disconnected');
      _isConnected = false;
      _scheduleReconnect();
    });

    _socket!.onConnectError((error) {
      AppLogger.error('WebSocket connection error', error: error);
      _isConnected = false;
      _scheduleReconnect();
    });

    _socket!.onError((error) {
      AppLogger.error('WebSocket error', error: error);
    });

    // Listen for new alerts
    _socket!.on('nueva_alerta', (data) {
      try {
        AppLogger.info('Received new alert via WebSocket');
        
        final alertData = data as Map<String, dynamic>;
        final alert = AlertModel.fromJson({
          ...alertData,
          'coordenadas': '${alertData['lat']},${alertData['lng']}',
          'usuario_id': alertData['usuario_id'] ?? 1,
          'uuid': alertData['uuid'] ?? '',
          'activa': true,
          'estado': 'activa',
        });
        
        _newAlertController.add(alert);
        AppLogger.info('New alert added to stream: ${alert.id}');
      } catch (e) {
        AppLogger.error('Error processing new alert from WebSocket', error: e);
      }
    });

    // Listen for alert updates
    _socket!.on('alerta_actualizada', (data) {
      try {
        AppLogger.info('Received alert update via WebSocket');
        
        final updateData = data as Map<String, dynamic>;
        
        // We need to get the full alert data, for now just log the update
        AppLogger.info('Alert ${updateData['id']} updated to status: ${updateData['estado']}');
        
        // In a real implementation, you might want to fetch the full alert data
        // and emit it through the update stream
      } catch (e) {
        AppLogger.error('Error processing alert update from WebSocket', error: e);
      }
    });
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= maxReconnectAttempts) {
      AppLogger.error('Max reconnection attempts reached, giving up');
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectAttempts++;
    
    AppLogger.info('Scheduling WebSocket reconnection attempt ${_reconnectAttempts}/${maxReconnectAttempts}');
    
    _reconnectTimer = Timer(reconnectDelay, () {
      connect();
    });
  }

  Future<void> disconnect() async {
    try {
      AppLogger.info('Disconnecting WebSocket');
      
      _reconnectTimer?.cancel();
      _socket?.disconnect();
      _socket?.dispose();
      _socket = null;
      _isConnected = false;
      
      AppLogger.info('WebSocket disconnected');
    } catch (e) {
      AppLogger.error('Error disconnecting WebSocket', error: e);
    }
  }

  void dispose() {
    disconnect();
    _newAlertController.close();
    _alertUpdateController.close();
  }
}
