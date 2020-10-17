import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'dart:async';

class ChatPage extends StatefulWidget {
  ChatPage(this.user, this.chatid, this.chatName) : super();
  final user;
  final chatid;
  final chatName;
  //DateTime _date = DateTime.now();

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  final TextEditingController _textController = new TextEditingController();
  ScrollController scrollController = ScrollController();
  bool _isWriting = false;

  // Callback to create a new message
  Future<void> callback(String txt) async {
    DateTime _date = DateTime.now();

    // Creating document with custom ID
    DocumentReference reference = _fireStore
        .collection('chatGroups')
        .doc('${widget.chatid}')
        .collection('messages')
        .doc('$_date${widget.user.email}');

    // Updaing created doc with message details
    reference
        .set({'from': widget.user.email, 'msg': txt, 'time': _date.toString()});
  }

  // Function for alignement of msg to left/right
  _alignment(snapshot, index) {
    if (snapshot.data.documents[index]['from'] == widget.user.email) {
      return CrossAxisAlignment.end;
    } else {
      return CrossAxisAlignment.start;
    }
  }

// Similar function for color of msg box
  _chatColor(snapshot, index) {
    if (snapshot.data.documents[index]['from'] == widget.user.email) {
      return Colors.grey[500];
    } else {
      return Colors.grey[400];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: FloatingActionButton(
            backgroundColor: Color(0xffEAB543),
            elevation: 0,
            child: Icon(Icons.arrow_back, color: Color(0xfff5f5f5)),
            heroTag: "go back",
            onPressed: () => Navigator.pop(context)),
        backgroundColor: Color(0xffEAB543),
        title: Text(
          widget.chatName,
          style: TextStyle(
            color: Color(0xfff5f5f5),
            fontSize: 22,
            fontFamily: 'SFDisplay',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Container(
        color: Color(0xffdfe4ea),
        child: Column(
          children: <Widget>[
            new Flexible(
                child: StreamBuilder(
                    stream: _fireStore
                        .collection('chatGroups')
                        .doc('${widget.chatid}')
                        .collection('messages')
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Something went wrong');
                      }

                      // if (snapshot.connectionState == ConnectionState.waiting) {
                      //   return Text("Loading");
                      // }

                      return ListView.builder(
                          controller: scrollController,
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: (context, index) {
                            // Displaying each message document as a message
                            return Container(
                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                margin: EdgeInsets.only(top: 10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(20),
                                  color: _chatColor(snapshot, index),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      _alignment(snapshot, index),
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 10.0, left: 10),
                                      child: CircleAvatar(
                                        child: Text(
                                          '${snapshot.data.docs[index]['from'].toString().split('@')[0]}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontFamily: 'SFDisplay',
                                            fontWeight: FontWeight.w200,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 10.0,
                                          top: 6,
                                          bottom: 4,
                                          left: 10),
                                      child: Text(
                                        '${snapshot.data.docs[index]['msg']}',
                                        style: TextStyle(
                                          color: Color(0xff34495e),
                                          fontSize: 20,
                                          fontFamily: 'SFDisplay',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 10.0,
                                          top: 6,
                                          bottom: 4,
                                          left: 10),
                                      child: Text(
                                        '${snapshot.data.docs[index]['time'].toString().substring(11, 16)}',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 12,
                                          fontFamily: 'SFDisplay',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ));
                          });
                    })),
            // This will build the textfield and send button
            _buildComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildComposer() {
    return new Container(
      decoration: BoxDecoration(
        //borderRadius: BorderRadius.circular(20),
        color: Colors.transparent,
      ),

      margin: EdgeInsets.symmetric(horizontal: 9.0),
      child: new Row(
        children: <Widget>[
          new Flexible(
            //Input Field
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.only(left: 10, top: 15, bottom: 10),
              child: new TextField(
                controller: _textController,
                onChanged: (String txt) {
                  setState(() {
                    _isWriting = (txt.length > 0);
                  });
                },
                decoration: new InputDecoration.collapsed(
                    hintText: "Write a message..."),
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Container(
                decoration: BoxDecoration(
                  color: Color(0xff3498db),
                  borderRadius: BorderRadius.circular(50),
                ),
                margin: EdgeInsets.symmetric(horizontal: 3.0),
                child: new IconButton(
                    //Send Button
                    icon: Icon(Icons.send, color: Color(0xfff5f5f5)),
                    onPressed: () {
                      if (_isWriting) {
                        _submitMsg(_textController.text);
                        Timer(
                            Duration(milliseconds: 500),
                            () => scrollController.jumpTo(
                                scrollController.position.maxScrollExtent));
                      }
                    }),
              ))
        ],
      ),
      //  ),
    );
  }

  _submitMsg(String txt) {
    //Cleans the textField and changes state
    txt == null ? null : callback(txt);
    _textController.clear();
    setState(() {
      _isWriting = false;
    });
  }
}
