import 'package:flutter/material.dart';
import 'package:shared_transport/chat_facitility/chat.dart';
import 'package:shared_transport/chat_facitility/chat_bloc.dart';
import 'package:shared_transport/chat_facitility/chat_model.dart';

class ChatCard extends StatelessWidget {
  final ChatModel chat;
  final ChatBloc chatBloc;

  ChatCard({this.chat, this.chatBloc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: .5),
      child: MaterialButton(
        elevation: .5,
        color: Colors.white,
        padding: EdgeInsets.all(8),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Chat(chat: chat, chatBloc: chatBloc)),
        ),
        child: _buildCard(context: context),
      ),
    );
  }

  Widget _buildCard({BuildContext context}) {
    return ListTile(
      leading: _buildCover(),
      title: Text(chat.sender.name),
      subtitle: _buildLastMsg(),
      trailing: _buildTime(),
    );
  }

  Widget _buildCover() {
    return Container(
      width: 50,
      height: 50,
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
              backgroundImage: NetworkImage(chat.sender.pic ??
                  'https://images.unsplash.com/photo-1518806118471-f28b20a1d79d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastMsg() {
    return chat.read == true
        ? Text(
            chat.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
          )
        : Text(
            chat.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
          );
  }

  Widget _buildTime() {
    return Container(
      width: 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              chat.read
                  ? Icon(
                      Icons.check,
                      size: 15,
                    )
                  : Container(height: 15, width: 15),
              Text(
                  '${chat.lastMessageDate.hour}:${chat.lastMessageDate.minute}')
            ],
          ),
          SizedBox(height: 15.0),
          !chat.read
              ? Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                )
              : Container(height: 10, width: 10),
        ],
      ),
    );
  }
}
