import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_transport/chat_facitility/chat_bloc.dart';
import 'package:shared_transport/chat_facitility/chat_card.dart';
import 'package:shared_transport/chat_facitility/chat_model.dart';
import 'package:shared_transport/chat_facitility/msg_bloc.dart';
import 'package:shared_transport/utils/localizations.dart';
import 'package:shared_transport/widgets/empty_state.dart';

class MyChatPage extends StatefulWidget {
  @override
  _MyChatPage createState() => _MyChatPage();
}

class _MyChatPage extends State<MyChatPage> {
  final ChatBloc chatBloc = ChatBloc();

  @override
  void dispose() {
    super.dispose();
    chatBloc.dispose();
  }

  Widget _buildMessages(List<ChatModel> chatData) {
    chatData.sort((ChatModel a, ChatModel b) =>
        (b.lastMessageDate).compareTo(a.lastMessageDate));

    return Material(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: chatData.length,
        itemBuilder: (context, index) => Dismissible(
          key: UniqueKey(),
          background: Container(
            color: Colors.blue[700],
            padding: EdgeInsets.symmetric(horizontal: 20),
            alignment: AlignmentDirectional.centerStart,
            child: Icon(
              Icons.done,
              color: Colors.white,
            ),
          ),
          secondaryBackground: Container(
            color: Colors.red,
            padding: EdgeInsets.symmetric(horizontal: 20),
            alignment: AlignmentDirectional.centerEnd,
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart)
              return await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Delete'),
                    content: Text('Are you sure you want to delete the chat?'),
                    actions: <Widget>[
                      FlatButton(
                        textColor: Colors.red,
                        onPressed: () {
                          chatBloc.deleteChatIn.add(chatData[index]);
                          MsgBloc(chatData[index].sender.email)
                              .deleteMsgIn
                              .add(chatData[index]);
                          Navigator.pop(context, true);
                        },
                        child: Text('Delete'),
                      ),
                      FlatButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('Cancel'),
                      ),
                    ],
                  );
                },
              );
            else {
              setState(() => chatData[index].read = !chatData[index].read);
              return false;
            }
          },
          onDismissed: (direction) {
            chatData.removeAt(index);
          },
          child: ChatCard(chat: chatData[index], chatBloc: chatBloc),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        elevation: 2,
        titleSpacing: 0,
        centerTitle: true,
        title: Text(AppLocalizations.of(context).localisedText['chat']),
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.search),
          ),
        ],
      ),
      body: StreamBuilder<List<ChatModel>>(
        stream: chatBloc.chatOut,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? snapshot.data.length == 0
                  ? Center(
                      child: EmptyState(
                        title: 'Oops',
                        message: 'No Chats found',
                      ),
                    )
                  : _buildMessages(snapshot.data)
              : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
