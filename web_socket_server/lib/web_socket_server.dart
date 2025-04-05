import 'dart:io';

final List<WebSocket> clients = [];

void runServer() async {
  final server = await HttpServer.bind('localhost', 8080);
  print('WebSocket server started on port 8080');

  server.listen((request) async {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      final webSocket = await WebSocketTransformer.upgrade(request);
      print('Client connected');
      clients.add(webSocket);

      webSocket.listen(
        (message) {
          print('Received message: $message');

          // Broadcast to all other clients
          for (var client in clients) {
            if (client.readyState == WebSocket.open) {
              client.add(message);
            }
          }
        },
        onDone: () {
          print('Client disconnected');
          clients.remove(webSocket);
        },
        onError: (error) {
          print('Error: $error');
          clients.remove(webSocket);
        },
      );
    }
  });
}
