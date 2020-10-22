import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chatPage.dart';
import 'package:location/location.dart';
import 'showLocation.dart';

class ChatIndex extends StatefulWidget {
  ChatIndex(this.user);
  final User user;

  @override
  State<StatefulWidget> createState() => ChatIndexState();
}

// This Page will show the user all their chats
class ChatIndexState extends State<ChatIndex> {
  final TextEditingController _textController = new TextEditingController();
  bool _isWriting = false;
  String addEmail;

  FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  QuerySnapshot querySnapshot;

  // We will need these 2 lists while defining _addNewChat() function
  List users = []; // list of all users on the app
  List openChats = []; // list of chats of user

  bool isLoading = false;

  //LOCATION

  Location location = new Location();

  @override
  void initState() {
    getUsers();
    super.initState();
  }

  // Gets list of all users (needed to start a new chat)
  void getUsers() async {
    querySnapshot = await _fireStore.collection('users').get();
    var list = querySnapshot.docs;
    for (int i = 0; i < list.length; i++) {
      users.add(list[i]['email']);
    }
    print(users);
  }

  // Function to create a new chat
  Future<void> addChat(String email) async {
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
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(70),
            child: GestureDetector(
              onTap: () {
                print("Map");
                Navigator.push(context,
                    MaterialPageRoute(builder: (ctx) => ShowLocation()));
              },
              child: Container(
                alignment: Alignment.center,
                child: Text("OPEN GOOGLE MAPS"),
                height: 50,
                width: 300,
                decoration: BoxDecoration(color: Colors.blueAccent),
              ),
            )),
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
                  // This streamBuilder will show all chats
                  // We can also use a Future Builder for this
                  child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('chatGroups')
                          .snapshots(),
                      builder: (ctx, snapshot) {
                        if (isLoading) {
                          return CircularProgressIndicator();
                        }

                        // These variables will hold
                        int count = 0; // no of chats
                        List<int> indices =
                            []; // index of each chat in the snapshot
                        List<String> ids = []; //  document ID of each chat

                        // Why do we need these variables?
                        // 1. We need count to display the chatnames
                        // 2. We need indices to get the groupChat document from
                        //    the snapshot for which we'll need their indices
                        // 3. We need document IDs to be able to update the
                        //    message collection inside the doc when sending
                        //    messages.

                        // Finds all chatGroups where user is present and
                        // 1. stores all their indices in indices
                        // 2. Stores the number of these chatGroups in count
                        // 3. Stores their ids in ids
                        for (var i = 0;
                            i < snapshot.data.documents.length;
                            i++) {
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
                              String _chatname;

                              // Using List<int> indices where we stored indices of
                              // required chatGroups
                              List t = snapshot.data.documents[indices[index]]
                                  .data()['users'];

                              // Getting chatname from email
                              // and adding email to List openChats
                              for (var i in t) {
                                if (i != widget.user.email) {
                                  var x = i.toString().split('@')[0];
                                  _chatname = x;
                                  openChats.add(i);
                                }
                              }

                              // The next part just displayes/passes the information
                              // we created so far
                              // Using inkwell to navigate to chatPage
                              // And displaying _chatName
                              return InkWell(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (ctx) => ChatPage(
                                            widget.user,
                                            snapshot
                                                .data
                                                .documents[indices[index]]
                                                .documentID,
                                            _chatname))),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
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

      // Button to start a new chat (add a new user)
      floatingActionButton: Builder(
        builder: (ctx) => new FloatingActionButton(
            onPressed: () => _addNewChat(ctx),
            child: Icon(Icons.add, color: Color(0xfff5f5f5))),
      ),
    );
  }

// Creates toast asking email to start a new chat
  _addNewChat(BuildContext c) {
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
                      addChat(addEmail);
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
      content: const Text(
          'Given email does not exist on GupShup. Please ask your friend to signup on our app.'),
    ),
  );
}
