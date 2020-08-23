import 'dart:convert';

import 'package:flutter/rendering.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_transport/chat_facitility/chat_bloc.dart';
import 'package:shared_transport/chat_facitility/chat_model.dart';
import 'package:shared_transport/chat_facitility/msg_bloc.dart';
import 'package:shared_transport/models/ride_model.dart';
import 'package:shared_transport/widgets/empty_state.dart';
import 'package:url_launcher/url_launcher.dart';

//var index = 0;
class Chat extends StatefulWidget {
  final ChatModel chat;
  final ChatBloc chatBloc;

  Chat({Key key, @required this.chat, @required this.chatBloc})
      : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  MsgBloc msgBloc;

  TextEditingController textEditingController;
  ScrollController _scrollController;

  String name;
  String email;
  double rating;
  String pic;

  @override
  void initState() {
    super.initState();
    msgBloc = MsgBloc(widget.chat.sender.email);
    textEditingController = TextEditingController();
    _scrollController = ScrollController();

    if (!widget.chat.read) {
      var updateChat = widget.chat;
      updateChat.read = true;
      widget.chatBloc.updateChatIn.add(updateChat);
    }
    _initialiseData();
  }

  @override
  void dispose() {
    super.dispose();
    msgBloc.dispose();
  }

  _initialiseData() async {
    var _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    setState(() {
      name = prefs.getString('name');
      email = prefs.getString('email');
      rating = prefs.getDouble('avgRating');
      pic = prefs.getString('photoUrl');
    });
  }

  sendMessage() {
    
    if (textEditingController.text.trim() == '') return;
    var newMsg = Message(
      sender: User(name: name, email: email, rating: rating, pic: pic),
      data: textEditingController.text,
      date: DateTime.now(),
    );
    // generate new msg request to server
    msgBloc.addMsgIn.add(newMsg);
    widget.chatBloc.channelIn
        .add(json.encode({'msg': newMsg, 'to': widget.chat.sender.email}));
    var updatedChat = widget.chat;
    updatedChat.lastMessage = newMsg.data;
    updatedChat.lastMessageDate = newMsg.date;
    widget.chatBloc.updateChatIn.add(updatedChat);
    textEditingController.text = '';
  }

  Widget _buildInput() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: EdgeInsets.all(15.0),
        height: 61,
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35.0),
            boxShadow: [
              BoxShadow(offset: Offset(0, 3), blurRadius: 5, color: Colors.grey)
            ],
          ),
          child: Row(
            children: [
              IconButton(icon: Icon(Icons.face), onPressed: null),
              Expanded(
                child: TextField(
                  controller: textEditingController,
                  decoration: InputDecoration(
                    hintText: "Type Something...",
                    border: InputBorder.none,
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: sendMessage(),
                ),
              ),
              IconButton(icon: Icon(Icons.send), onPressed: sendMessage),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMsg(List<Message> msgs) {
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: msgs.length,
      itemBuilder: (context, i) {
        msgs.sort((Message a, Message b) => (b.date).compareTo(a.date));

        return Padding(
          padding: const EdgeInsets.all(10),
          child: msgs[i].sender.email == widget.chat.sender.email
              ? _recivedMsg(msgs[i])
              : _sentMsg(msgs[i]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget createBody() {
      return Stack(
        children: <Widget>[
          StreamBuilder<List<Message>>(
            stream: msgBloc.msgOut,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              return snapshot.hasData
                  ? snapshot.data.length == 0
                      ? Center(
                          child: EmptyState(
                            title: 'Say hello',
                            message: 'No message found',
                          ),
                        )
                      : _buildMsg(snapshot.data)
                  : Center(child: CircularProgressIndicator());
            },
          ),
          _buildInput(),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppbar(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: createBody(),
      ),
    );
  }

  _recivedMsg(Message msg) {
    return Row(
      children: [
        _buildCover(),
        SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${msg.sender.name}",
              style: Theme.of(context).textTheme.caption,
            ),
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * .6),
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(25),
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Text(
                "${msg.data}",
                style: Theme.of(context).textTheme.body1.apply(
                      color: Colors.black87,
                    ),
              ),
            ),
          ],
        ),
        SizedBox(width: 15),
        Text(
          '${msg.date.hour.toString().padLeft(2, '0')}:${msg.date.minute.toString().padLeft(2, '0')}',
          style: Theme.of(context).textTheme.body2.apply(color: Colors.grey),
        ),
      ],
    );
  }

  _sentMsg(Message msg) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '${msg.date.hour.toString().padLeft(2, '0')}:${msg.date.minute.toString().padLeft(2, '0')}',
          style: Theme.of(context).textTheme.body2.apply(color: Colors.grey),
        ),
        SizedBox(width: 15),
        Container(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .6),
          padding: const EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            color: Theme.of(context).accentColor.withOpacity(.85),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
              bottomLeft: Radius.circular(25),
            ),
          ),
          child: Text(
            "${msg.data}",
            style: Theme.of(context).textTheme.body1.apply(
                  color: Colors.black87,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppbar() {
    return AppBar(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      elevation: 2,
      titleSpacing: 0,
      title: ListTile(
        onTap: () {},
        leading: _buildCover(),
        title: Text(
          widget.chat.sender.name,
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
          ),
        ),
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: IconButton(
            color: Colors.white,
            icon: Icon(Icons.call),
            onPressed: () {
              var link = 'tel:${widget.chat.sender.phone}';
              launch(link);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCover() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(.3),
              offset: Offset(0, 5),
              blurRadius: 25)
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CircleAvatar(
              backgroundImage: NetworkImage(widget.chat.sender.pic ??
                  'https://images.unsplash.com/photo-1518806118471-f28b20a1d79d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80'),
            ),
          ),
        ],
      ),
    );
  }
}
