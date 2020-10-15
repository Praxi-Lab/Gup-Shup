import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chatPage.dart';

class ChatIndex extends StatefulWidget {
  ChatIndex(this.user);
  final User user;

  @override
  State<StatefulWidget> createState() => ChatIndexState();
}

class ChatIndexState extends State<ChatIndex> {
  String _chatname;
  final TextEditingController _textController = new TextEditingController();
  bool _isWriting = false;
  String addEmail;

  FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  QuerySnapshot querySnapshot;
  List users = [];
  List openChats = [];

  bool isLoading = false;

  @override
  void initState() {
    getUsers();
    super.initState();
  }

  void getUsers() async {
    querySnapshot = await _fireStore.collection('users').get();
    var list = querySnapshot.docs;
    for (int i = 0; i < list.length; i++) {
      users.add(list[i]['email']);
    }
    print(users);
  }

  Future<void> callback(String email) async {
    List l = [widget.user.email, email];
    DocumentReference reference =
        await _fireStore.collection('chatGroups').add({
      'title': 'Flutter in Action',
    });
    reference.set({'users': l});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GupShup'),
      ),
      body: Builder(
        builder: (ctx) => Container(
          color: Color(0xffecf0f1),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Container(
                  color: Color(0xffecf0f1),
                  alignment: Alignment.topLeft,
                    child: Text(
                      "Chats",
                      style: TextStyle(
                          color: Color(0xff34495e),
                          fontSize: 30,
                          fontFamily: 'SFDisplay',
                          fontWeight: FontWeight.w600),
                    ),
                    margin: EdgeInsets.only(left: 10, top: 15)),
              ),
              Container(
                  color: Color(0xffecf0f1),
                  child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('chatGroups')
                          .snapshots(),
                      builder: (ctx, snapshot) {
                        if (isLoading) {
                          return CircularProgressIndicator();
                        }
                        int count = 0;
                        List<int> indices = [];
                        List<String> ids = [];

                        for (var i = 0; i < snapshot.data.documents.length; i++) {
                          if (snapshot.data.documents[i]['users']
                              .toString()
                              .contains(widget.user.email.toString())) {
                            count++;
                            ids.add(snapshot.data.documents[i].documentID);
                            indices.add(i);
                          }
                        }

                        if (count == 0) {
                          return Stack(
                            children: [
                              Positioned(
                                left: 50,
                                top: 300,
                                child: Container(
                                  alignment: Alignment(0, 0),
                                  child: Text(
                                    'Oh Snap!\nLooks like you have no open chats',
                                    style: TextStyle(
                                        color: Color(0xff7f8c8d),
                                        fontSize: 20,
                                        fontFamily: 'SFDisplay',
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                              Positioned(
                                  top: 600,
                                  left: 180,
                                  child: Container(
                                    child: Text(
                                      'Start a conversation...',
                                      style: TextStyle(
                                          color: Color(0xff7f8c8d),
                                          fontSize: 20,
                                          fontFamily: 'SFDisplay',
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ))
                            ],
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                            itemCount: count,
                            itemBuilder: (ctx, index) {
                              List t = snapshot.data.documents[indices[index]]
                                  .data()['users'];

                              for (var i in t) {
                                if (i != widget.user.email) {
                                  var x = i.toString().split('@')[0];
                                  _chatname = x;
                                  openChats.add(i);
                                }
                              }

                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (ctx) => ChatPage(
                                              widget.user,
                                              snapshot
                                                  .data
                                                  .documents[indices[index]]
                                                  .documentID,
                                              _chatname)));
                                },
                                child: Column(
                                  
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Container(
                                        color: Color(0xfff5f5f5),
                                        alignment: Alignment(-1, 0),
                                        height: 80,
                                        margin: EdgeInsets.only(
                                            top: 20, left: 0, right: 0),
                                        padding: EdgeInsets.only(
                                            top: 25,
                                            bottom: 25,
                                            left: 15,
                                            right: 15),
                                        child: Text(_chatname.toString())),
                                    //Text(users.toString()))
                                    // snapshot.data.documents[indices[index]].documentID.toString())),
                                  ],
                                ),
                              );
                            });
                      })
                  //Text('${snapshot.data.documents[0]['users']}');

                  ),
            ],
          ),
        ),
      ),
      floatingActionButton: Builder(
        builder: (ctx) => new FloatingActionButton(
            onPressed: () => _showMaterialDialog(ctx),
            child: Icon(Icons.add, color: Color(0xfff5f5f5))),
      ),
    );
  }

  _showMaterialDialog(BuildContext c) {
    showDialog(
        context: c,
        builder: (_) => new AlertDialog(
              //title: new Text(z.toString()),
              content: new Container(
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
                      addEmail = txt;
                    });
                  },
                  decoration:
                      new InputDecoration.collapsed(hintText: "Add by email"),
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Add!'),
                  onPressed: () {
                    if (users.contains(addEmail) &&
                        !openChats.contains(addEmail)) {
                      setState(() {
                        isLoading = true;
                      });
                      callback(addEmail);
                      setState(() {
                        isLoading = false;
                      });
                    } else {
                      print("Email doesnt exist");
                      _showToast(c);
                    }
                    _textController.text = "";
                    Navigator.of(context).pop();
                  },
                )
              ],
            ));
  }
}

void _showToast(BuildContext context) {
  final scaffold = Scaffold.of(context);
  scaffold.showSnackBar(
    SnackBar(
      content: const Text('Email does not exist'),
    ),
  );
}
