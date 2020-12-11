import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket socket;

  createSocketConnection() {
    socket = IO.io('http://192.168.0.6:59520', <String, dynamic>{
      'transports': ['websocket'],
    });

    this.socket.on('connect', (_) => print('Connected'));
    this.socket.on('disconnect', (_) => print('Disconnected'));
  }

  emit(String event, dynamic data) {
    this.socket.emit(event, data);
  }

}