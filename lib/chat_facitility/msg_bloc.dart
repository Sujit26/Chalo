import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:shared_transport/chat_facitility/chat_model.dart';
import 'package:shared_transport/chat_facitility/msg_service.dart';

class MsgBloc {
  /// Keeps track of the all the chats to a sender
  List<Message> _storageMsg = new List();

  /// The [PublishSubject] is a [StreamController] but fom the rxDart library
  PublishSubject<Message> _addMsgController = new PublishSubject();

  /// The [Sink] is the input to add a new chat to the [_storageMsg]
  Sink<Message> get addMsgIn => _addMsgController.sink;

  /// The [PublishSubject] is a [StreamController] but fom the rxDart library
  PublishSubject<void> _deleteMsgController = new PublishSubject();

  /// The [Sink] is the input to delete a chat to the [_storageMsg]
  Sink<void> get deleteMsgIn => _deleteMsgController.sink;

  /// The [BehaviorSubject] is a [StreamController]
  /// The controller has the chats of the user
  BehaviorSubject<List<Message>> _msgController = new BehaviorSubject();

  /// The [Sink] is the input for the [_msgController]
  Sink<List<Message>> get msgIn => _msgController.sink;

  /// The [Stream] is the output for the [_msgController]
  Stream<List<Message>> get msgOut => _msgController.stream;

  MsgService _storageService;

  MsgBloc(email) {
    _storageService = new MsgService(email);

    getStorageMsg();

    _addMsgController.listen(_handleNewMsg);
    _deleteMsgController.listen(_handleDeleteMsg);
  }

  void dispose() {
    _addMsgController.close();
    _deleteMsgController.close();
    _msgController.close();
  }

  void getStorageMsg() async {
    _storageMsg = await _storageService.readFile();

    msgIn.add(_storageMsg);
  }

  void _handleNewMsg(Message chat) async {
    await _storageService.writeToFile(chat);

    getStorageMsg();
  }

  void _handleDeleteMsg(void c) async {
    await _storageService.deleteFile();
  }
}
