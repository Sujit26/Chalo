import 'package:shared_transport/models/ride_model.dart';

class ChatModel {
  User sender;
  String lastMessage;
  bool read;
  DateTime lastMessageDate;

  ChatModel(
    this.sender,
    this.lastMessage,
    this.read,
    this.lastMessageDate,
  );
  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      User(
        name: json['sender']['name'] as String,
        email: json['sender']['email'] as String,
        rating: json['sender']['rating'] as double,
        pic: json['sender']['pic'] as String,
      ),
      json['lastMessage'] as String,
      json['read'] as bool,
      DateTime.parse(json['lastMessageDate']),
    );
  }
  Map toJson() => {
        'sender': sender.toJson(),
        'lastMessage': lastMessage,
        'read': read,
        'lastMessageDate': lastMessageDate.toString(),
      };
}

class Message {
  String data;
  DateTime date;
  User sender;

  Message({
    this.data,
    this.date,
    this.sender,
  });
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      data: json['data'] as String,
      date: DateTime.parse(json['date']),
      sender: User(
        name: json['sender']['name'] as String,
        email: json['sender']['email'] as String,
        rating: json['sender']['rating'] * 1.0 as double,
        pic: json['sender']['pic'] as String,
      ),
    );
  }
  Map toJson() => {
        'data': data,
        'date': date.toString(),
        'sender': sender,
      };
}

var msgs = {
  'Sender1Email': [
    Message(
      data: "HELLo 0",
      date: DateTime.parse("2019-11-25 01:00:00.000"),
      sender:
          User(name: 'Sender1', email: 'Sender1Email', rating: 5.0, pic: null),
    ),
    Message(
      data: "HELOO DRIVER 1",
      date: DateTime.parse("2019-11-25 00:00:01.000"),
      sender: User(
          name: 'my name',
          email: '2017csb1115@iitrpr.ac.in',
          rating: 5.0,
          pic: null),
    ),
    Message(
      data:
          "aur ni to kya  dashjasbhsaashh  h id hd  ahdsudas     assad dahf ggfa sfshsa ahashaashg  ",
      date: DateTime.parse("2019-11-25 00:00:06.000"),
      sender:
          User(name: 'Sender1', email: 'Sender1Email', rating: 5.0, pic: null),
    ),
    Message(
      data: "Kuch bhi mat bol bhai 5",
      date: DateTime.parse("2019-11-25 00:00:05.000"),
      sender: User(
          name: 'my name',
          email: '2017csb1115@iitrpr.ac.in',
          rating: 5.0,
          pic: null),
    ),
    Message(
      data: "bolo bhi ab 3",
      date: DateTime.parse("2019-11-25 00:00:03.000"),
      sender: User(
          name: 'my name',
          email: '2017csb1115@iitrpr.ac.in',
          rating: 5.0,
          pic: null),
    ),
    Message(
      data: "kya hai 4",
      date: DateTime.parse("2019-11-25 00:00:04.000"),
      sender:
          User(name: 'Sender1', email: 'Sender1Email', rating: 5.0, pic: null),
    ),
  ],
  'Sender2Email': [
    Message(
      data: "HELLo",
      date: DateTime.parse("2019-11-25 00:00:00.000"),
      sender:
          User(name: 'Sender2', email: 'Sender2Email', rating: 5.0, pic: null),
    ),
    Message(
      data: "HELOO DRIVER1",
      date: DateTime.parse("2019-11-25 00:00:01.000"),
      sender: User(
          name: 'my name',
          email: '2017csb1115@iitrpr.ac.in',
          rating: 5.0,
          pic: null),
    ),
    Message(
      data: "aur ni to kya ",
      date: DateTime.parse("2019-11-25 00:00:06.000"),
      sender:
          User(name: 'Sender2', email: 'Sender2Email', rating: 5.0, pic: null),
    ),
    Message(
      data: "Kuch bhi mat bol bhai",
      date: DateTime.parse("2019-11-25 00:00:05.000"),
      sender: User(
          name: 'my name',
          email: '2017csb1115@iitrpr.ac.in',
          rating: 5.0,
          pic: null),
    ),
    Message(
      data: "bolo bhi ab",
      date: DateTime.parse("2019-11-25 00:00:03.000"),
      sender: User(
          name: 'my name',
          email: '2017csb1115@iitrpr.ac.in',
          rating: 5.0,
          pic: null),
    ),
    Message(
      data: "kya hai",
      date: DateTime.parse("2019-11-25 00:00:04.000"),
      sender:
          User(name: 'Sender2', email: 'Sender2Email', rating: 5.0, pic: null),
    ),
  ],
  'Sender3Email': [
    Message(
      data: "HELLo",
      date: DateTime.parse("2019-11-25 00:00:00.000"),
      sender:
          User(name: 'Sender3', email: 'Sender3Email', rating: 5.0, pic: null),
    ),
    Message(
      data: "HELOO DRIVER1",
      date: DateTime.parse("2019-11-25 00:00:01.000"),
      sender: User(
          name: '2017csb1115@iitrpr.ac.in',
          email: '2017csb1115@iitrpr.ac.in',
          rating: 5.0,
          pic: null),
    ),
    Message(
      data: "aur ni to kya ",
      date: DateTime.parse("2019-11-25 00:00:06.000"),
      sender:
          User(name: 'Sender3', email: 'Sender3Email', rating: 5.0, pic: null),
    ),
    Message(
      data: "Kuch bhi mat bol bhai",
      date: DateTime.parse("2019-11-25 00:00:05.000"),
      sender: User(
          name: '2017csb1115@iitrpr.ac.in',
          email: '2017csb1115@iitrpr.ac.in',
          rating: 5.0,
          pic: null),
    ),
    Message(
      data: "bolo bhi ab",
      date: DateTime.parse("2019-11-25 00:00:03.000"),
      sender: User(
          name: '2017csb1115@iitrpr.ac.in',
          email: '2017csb1115@iitrpr.ac.in',
          rating: 5.0,
          pic: null),
    ),
    Message(
      data: "kya hai",
      date: DateTime.parse("2019-11-25 00:00:04.000"),
      sender:
          User(name: 'Sender3', email: 'Sender3Email', rating: 5.0, pic: null),
    ),
  ],
  'Sender4Email': [
    Message(
      data: "HELLo",
      date: DateTime.parse("2019-11-25 00:00:00.000"),
      sender:
          User(name: 'Sender4', email: 'Sender4Email', rating: 5.0, pic: null),
    ),
    Message(
      data: "HELOO DRIVER1",
      date: DateTime.parse("2019-11-25 00:00:01.000"),
      sender: User(
          name: '2017csb1115@iitrpr.ac.in',
          email: '2017csb1115@iitrpr.ac.in',
          rating: 5.0,
          pic: null),
    ),
    Message(
      data: "aur ni to kya ",
      date: DateTime.parse("2019-11-25 00:00:06.000"),
      sender:
          User(name: 'Sender4', email: 'Sender4Email', rating: 5.0, pic: null),
    ),
    Message(
      data: "Kuch bhi mat bol bhai",
      date: DateTime.parse("2019-11-25 00:00:05.000"),
      sender: User(
          name: '2017csb1115@iitrpr.ac.in',
          email: '2017csb1115@iitrpr.ac.in',
          rating: 5.0,
          pic: null),
    ),
    Message(
      data: "bolo bhi ab",
      date: DateTime.parse("2019-11-25 00:00:03.000"),
      sender: User(
          name: '2017csb1115@iitrpr.ac.in',
          email: '2017csb1115@iitrpr.ac.in',
          rating: 5.0,
          pic: null),
    ),
    Message(
      data: "kya hai",
      date: DateTime.parse("2019-11-25 00:00:04.000"),
      sender:
          User(name: 'Sender4', email: 'Sender4Email', rating: 5.0, pic: null),
    ),
  ],
  'Sender5Email': [
    Message(
      data: "HELLo",
      date: DateTime.parse("2019-11-25 00:00:00.000"),
      sender:
          User(name: 'Sender5', email: 'Sender5Email', rating: 5.0, pic: null),
    ),
    Message(
      data: "HELOO DRIVER1",
      date: DateTime.parse("2019-11-25 00:00:01.000"),
      sender: User(
          name: '2017csb1115@iitrpr.ac.in',
          email: '2017csb1115@iitrpr.ac.in',
          rating: 5.0,
          pic: null),
    ),
    Message(
      data: "aur ni to kya  dashjasbhsaashh  h id hd  ahdsudas     assad ",
      date: DateTime.parse("2019-11-25 00:00:06.000"),
      sender:
          User(name: 'Sender5', email: 'Sender5Email', rating: 5.0, pic: null),
    ),
    Message(
      data: "Kuch bhi mat bol bhai",
      date: DateTime.parse("2019-11-25 00:00:05.000"),
      sender: User(
          name: '2017csb1115@iitrpr.ac.in',
          email: '2017csb1115@iitrpr.ac.in',
          rating: 5.0,
          pic: null),
    ),
    Message(
      data: "bolo bhi ab",
      date: DateTime.parse("2019-11-25 00:00:03.000"),
      sender: User(
          name: '2017csb1115@iitrpr.ac.in',
          email: '2017csb1115@iitrpr.ac.in',
          rating: 5.0,
          pic: null),
    ),
    Message(
      data: "kya hai",
      date: DateTime.parse("2019-11-25 00:00:04.000"),
      sender:
          User(name: 'Sender5', email: 'Sender5Email', rating: 5.0, pic: null),
    ),
  ],
};

List<ChatModel> chatData = [
  ChatModel(
    User(name: 'Sender1', email: 'Sender1Email', rating: 5.0, pic: null),
    "Last Mesaage",
    true,
    DateTime.now(),
  ),
  ChatModel(
    User(name: 'Sender2', email: 'Sender2Email', rating: 5.0, pic: null),
    "Last Mesaage",
    false,
    DateTime.now(),
  ),
  ChatModel(
    User(name: 'Sender3', email: 'Sender3Email', rating: 5.0, pic: null),
    "Last Mesaage",
    true,
    DateTime.now(),
  ),
  ChatModel(
    User(name: 'Sender4', email: 'Sender4Email', rating: 5.0, pic: null),
    "Last Mesaage",
    false,
    DateTime.now(),
  ),
  ChatModel(
    User(name: 'Sender5', email: 'Sender5Email', rating: 5.0, pic: null),
    "Last Mesaage",
    true,
    DateTime.now(),
  ),
];
