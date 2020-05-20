import 'dart:convert';
import 'dart:io';

import 'package:shared_transport/chat_facitility/chat_model.dart';
import 'package:shared_transport/chat_facitility/istorage_service.dart';

class MsgService extends IStorageService<List<Message>> {
  final String email;
  MsgService(this.email) : super('$email.json');

  @override
  Future<List<Message>> readFile() async {
    try {
      final file = await localFile;
      List listOfMaps = json.decode(await file.readAsString());

      List chats = listOfMaps.map((map) => Message.fromJson(map)).toList();
      return chats;
    } on FileSystemException catch (_) {
      print(_);
      return [];
    } catch (_) {
      print(_);
      return [];
    }
  }

  Future<File> writeToFile(Message msg) async {
    final file = await localFile;
    List<Message> msgs = await readFile();
    msgs.add(msg);
    return file.writeAsString(json.encode(msgs));
  }

  Future<bool> deleteFile() async {
    final file = await localFile;
    try {
      await file.delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
