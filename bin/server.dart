library dartpong;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:http_server/http_server.dart' as http_server;
import 'package:route/server.dart' show Router;

import 'package:dartpong/game_core.dart';

const int PORT = 8080;

void main(){
  GameServer gameServer = new GameServer();

  var webPath = Platform.script.resolve('../web').toFilePath();
  if(!new Directory(webPath).existsSync()){
    print('error! web directory not found');
  }

  HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, PORT).then((server){
    print('server running on ${server.address.address}:$PORT');
    var router = new Router(server);

    //upgrade websocket requests to /ws
    router.serve('/ws')
          .transform(new WebSocketTransformer())
          .listen(gameServer.handleNewConnection);
    
    //set up default handler to serve web files
    var virDir = new http_server.VirtualDirectory(webPath);
    virDir.jailRoot = false;
    virDir.allowDirectoryListing = true;
    virDir.directoryHandler = (dir, req){
      //redirect directory requests to index.html files
      var indexUri = new Uri.file(dir.path).resolve('index.html');
      virDir.serveFile(new File(indexUri.toFilePath()), req);
    };

    //add an error page handler
    virDir.errorPageHandler = (HttpRequest req){
      print('resource not found: ${req.uri.path}');
      req.response.statusCode = HttpStatus.NOT_FOUND;
      req.response.close();
    };

    //serve everything else not routed through the virtual directory
    virDir.serve(router.defaultStream);
  });
}

class GameServer{
  Map<WebSocket, Client> clients;
  List<GameInstance> games;

  GameServer(){
    clients = new Map();
    games = new List();
  }

  void handleNewConnection(WebSocket socket){
    print('adding new client');
    clients[socket] = new Client(socket);
    socket.listen((data) => handleMessage(socket, data));
  }

  void handleMessage(WebSocket socket, data){
    Uint16List packetReceived = new Uint16List.view(data.buffer, 6);
  }
}

class Client{
  WebSocket socket;

  Client(WebSocket socket){
    this.socket = socket;
  }
}
