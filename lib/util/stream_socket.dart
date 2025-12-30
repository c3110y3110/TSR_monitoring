import 'package:socket_io_client/socket_io_client.dart' as IO;

IO.Socket createSocket(String url) {
  IO.Socket socket = IO.io(url,
      IO.OptionBuilder().setTransports(['websocket']).build());
  return socket;
}
