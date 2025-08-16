import 'package:socket_io_client/socket_io_client.dart' as socket_io;

class SocketService {
  late socket_io.Socket socket;

  void connect() {
    socket = socket_io.io('http://your-backend-server-url', socket_io.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .build());

    socket.connect();

    socket.onConnect((_) {
      print('Connected to WebSocket server');
    });

    socket.on('login_response', (data) {
      print('Login Response: $data');
    });

    socket.on('song_list', (data) {
      print('Song List: $data');
    });

    socket.onDisconnect((_) {
      print('Disconnected from server');
    });
  }

  void emitEvent(String event, dynamic data) {
    socket.emit(event, data);
  }

  void onEvent(String event, Function(dynamic) callback) {
    socket.on(event, callback);
  }

  void disconnect() {
    socket.disconnect();
  }
}
