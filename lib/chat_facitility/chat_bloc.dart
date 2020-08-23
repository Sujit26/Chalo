import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_transport/chat_facitility/chat_model.dart';
import 'package:shared_transport/chat_facitility/chat_service.dart';
import 'package:shared_transport/chat_facitility/msg_bloc.dart';
import 'package:shared_transport/config/keys.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatBloc {
  /// Keeps track of the all the chats to a sender
  List<ChatModel> _storageChat = new List();

  /// The [PublishSubject] is a [StreamController] but fom the rxDart library
  PublishSubject<ChatModel> _addChatController = new PublishSubject();

  /// The [Sink] is the input to add a new chat to the [_storageChat]
  Sink<ChatModel> get addChatIn => _addChatController.sink;

  /// The [PublishSubject] is a [StreamController] but fom the rxDart library
  PublishSubject<ChatModel> _deleteChatController = new PublishSubject();

  /// The [Sink] is the input to delete a chat to the [_storageChat]
  Sink<ChatModel> get deleteChatIn => _deleteChatController.sink;

  /// The [PublishSubject] is a [StreamController] but fom the rxDart library
  PublishSubject<ChatModel> _updateChatController = new PublishSubject();

  /// The [Sink] is the input to update a chat to the [_storageChat]
  Sink<ChatModel> get updateChatIn => _updateChatController.sink;

  /// The [BehaviorSubject] is a [StreamController]
  /// The controller has the chats of the user
  BehaviorSubject<List<ChatModel>> _chatController = new BehaviorSubject();

  /// The [Sink] is the input for the [_chatController]
  Sink<List<ChatModel>> get chatIn => _chatController.sink;

  /// The [Stream] is the output for the [_chatController]
  Stream<List<ChatModel>> get chatOut => _chatController.stream;

  final ChatService _storageService = new ChatService();

  WebSocketChannel _channel;

  Sink get channelIn => _channel.sink;

  ChatBloc() {
    getStorageChat();
    _setUpChannel();

    _addChatController.listen(_handleNewChat);
    _deleteChatController.listen(_handleDeleteChat);
    _updateChatController.listen(_handleUpdateChat);
  }

  _setUpChannel() async {
    WidgetsFlutterBinding.ensureInitialized();
    var _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    var data = {
      'email': prefs.getString('email'),
      'token': prefs.getString('token'),
    };
    try {
      _channel = IOWebSocketChannel.connect(
          Keys.chatSocket + '?data=${jsonEncode(data)}');
    } catch (e) {
      print(e);
    }
    _channel.stream.listen((onData) {
      onData = jsonDecode(onData);
      print('Socket Says: ' + onData.toString());
      Message msg = Message.fromJson(onData);
      _chatExist(msg);
    });
  }

  void dispose() {
    _addChatController.close();
    _deleteChatController.close();
    _chatController.close();
    _updateChatController.close();
    _channel.sink.close();
  }

  void getStorageChat() async {
    _storageChat = await _storageService.readFile();

    chatIn.add(_storageChat);
  }

  void _handleNewChat(ChatModel chat) async {
    await _storageService.writeToFile(chat);

    getStorageChat();
  }

  void _handleDeleteChat(ChatModel chat) async {
    await _storageService.removeFromFile(chat);

    getStorageChat();
  }

  void _handleUpdateChat(ChatModel chat) async {
    await _storageService.updateFromFile(chat);

    getStorageChat();
  }

  void _chatExist(Message msg) async {
    try {
      var res = _storageChat
          .firstWhere((chat) => chat.sender.email == msg.sender.email);
      res.lastMessage = msg.data;
      res.lastMessageDate = msg.date;
      res.read = false;
      updateChatIn.add(res);
    } catch (e) {
      addChatIn.add(ChatModel(msg.sender, msg.data, false, msg.date));
    }
    MsgBloc msgBloc = MsgBloc(msg.sender.email);
    msgBloc.addMsgIn.add(msg);
  }
}
