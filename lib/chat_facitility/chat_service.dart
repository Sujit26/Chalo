import 'dart:convert';
import 'dart:io';

import 'package:shared_transport/chat_facitility/chat_model.dart';
import 'package:shared_transport/chat_facitility/istorage_service.dart';

class ChatService extends IStorageService<List<ChatModel>> {
  ChatService() : super('chats.json');

  @override
  Future<List<ChatModel>> readFile() async {
    try {
      final file = await localFile;
      List listOfMaps = json.decode(await file.readAsString());

      List chats = listOfMaps.map((map) => ChatModel.fromJson(map)).toList();
      return chats;
    } on FileSystemException catch (_) {
      print(_);
      return [];
    } catch (_) {
      print(_);
      return [];
    }
  }

  Future<File> writeToFile(ChatModel chat) async {
    final file = await localFile;
    List<ChatModel> chats = await readFile();
    chats.add(chat);
    return file.writeAsString(json.encode(chats));
  }

  Future<File> removeFromFile(ChatModel chat) async {
    final file = await localFile;
    List<ChatModel> chats = await readFile();
    chats.removeWhere(
        (chatFromStorage) => chatFromStorage.sender.email == chat.sender.email);
    return file.writeAsString(json.encode(chats));
  }

  Future<File> updateFromFile(ChatModel chat) async {
    final file = await localFile;
    List<ChatModel> chats = await readFile();
    chats.removeWhere(
        (chatFromStorage) => chatFromStorage.sender.email == chat.sender.email);
    chats.add(chat);
    return file.writeAsString(json.encode(chats));
  }
}
