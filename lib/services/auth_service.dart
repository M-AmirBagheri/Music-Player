import 'package:socket_io_client/socket_io_client.dart' as socket_io;

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  late socket_io.Socket socket;
  bool _loggedIn = false;

  bool get isLoggedIn => _loggedIn;

  void connect() {
    socket = socket_io.io('http://your-backend-server-url', socket_io.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .build());

    socket.connect();

    socket.onConnect((_) {
      print('Connected to WebSocket server');
    });

    socket.onDisconnect((_) {
      print('Disconnected from WebSocket server');
    });
  }

  void login(String username, String password) {
    socket.emit('login', {
      'username': username,
      'password': password,
    });

    socket.on('login_response', (data) {
      if (data['status'] == 'success') {
        _loggedIn = true;
        print('Login successful');
      } else {
        _loggedIn = false;
        print('Login failed: ${data['message']}');
      }
    });
  }

  void logout() {
    socket.emit('logout', {});
    _loggedIn = false;
    print('Logged out');
  }

  void onEvent(String event, Function(dynamic) callback) {
    socket.on(event, callback);
  }

  void disconnect() {
    socket.disconnect();
  }
}
