import 'package:socket_io_client/socket_io_client.dart' as IO;

IO.Socket createSocket(String url) {
  // 웹소켓만 사용해 Socket.IO 연결
  IO.Socket socket = IO.io(url,
      IO.OptionBuilder().setTransports(['websocket']).build());
  return socket;
}
