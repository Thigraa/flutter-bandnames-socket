import 'package:flutter/cupertino.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  late IO.Socket _socket;

  SocketService() {
    this._initConfig();
  }

  void _initConfig() {
    //?Dart client
    _socket = IO.io('http://192.168.1.40:3000/', {
      //192.168.1.40
      'transports': ['websocket'],
      'autoConnect': true
    });
    socket.onConnect((_) {
      print('connect');
      this._serverStatus = ServerStatus.Online;
      notifyListeners();
    });
    socket.onDisconnect((_) {
      print('disconnect');
      this._serverStatus = ServerStatus.Offline;
      notifyListeners();
    });

    // socket.on('nuevo-mensaje', (payload) {
    //   print('nombre:' + payload['nombre']);
    //   print('mensaje:' + payload['mensaje']);
    // });
  }

  ServerStatus get serverStatus => _serverStatus;
  IO.Socket get socket => _socket;
  get emit => _socket.emit;
}
