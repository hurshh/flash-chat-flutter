import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _fireStore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final messageTextEditingController = TextEditingController();
  User loggedInUser ;
  Future<void> getCurrentUser() async {
    final user = await _auth.currentUser;
    try{
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    }
    catch(e){
      print(e);
    }
  }

  // Future<void> getMessages() async {
  //   final messages =  await _fireStore.collection('messages').get();
  //   for(var message in messages.docs){
  //     print(message.data());
  //   }
  // }
  void messagesStream() async{
    await for(var snaps in _fireStore.collection('messages').snapshots()){
     for(var messages in snaps.docs){
       print(messages.data());
     }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }
  @override
  Widget build(BuildContext context) {
    String message;
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                // getMessages();
                messagesStream();
                //Implement logout functionality
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(builder: (context,snapshot){
              if(snapshot.hasData){
                final messages = snapshot.data.docs;
                List<messageBubble> messageWidgets = [];
                for(var message in messages){
                  final messageText = message.get('text');
                  final messageSender = message.get('sender');
                  final MessageBubble = messageBubble(sender: messageSender,text: messageText,);
                  messageWidgets.add(MessageBubble);
                }
                return Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
                    children: messageWidgets,
                  ),
                );
              }
            },stream: _fireStore.collection('messages').snapshots(),
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextEditingController,
                      onChanged: (value) {
                        //Do something with the user input.
                        message = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () async {
                      messageTextEditingController.clear();
                      //Implement send functionality.
                      _fireStore.collection('messages').add({
                        'sender' : loggedInUser.email,
                        'text' : message,
                      });

                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class messageBubble extends StatelessWidget {

  final String sender,text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('$sender',style: TextStyle(fontSize: 14,color: Colors.black45),),
          Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(30),
            color: Colors.blueAccent,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
              child: Text(
                '$text',style: TextStyle(fontSize: 20,color: Colors.white),
              ),
            )
        ),],
      ),
    );
  }

  messageBubble({this.sender, this.text});
}

