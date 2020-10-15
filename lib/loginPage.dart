import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'main.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'chatIndex.dart';

class LoginPage extends StatefulWidget {
  var fireStore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

//------enumeration---------->

enum FormType { login, register }
//--------------------------->

class _LoginPageState extends State<LoginPage> {
  final formKey = new GlobalKey<
      FormState>(); //since the parent "form" is responsible for textformfield, we have to define a global varibale.

  String _email;
  String _password;
  String _name;
  bool status;
  String _id;
  var _contact;

  FormType _formType = FormType.login;

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      print('Valid');
      return true;
    }
    return false;
  }

//----------------------------------------------
//      Validate, Store, Navigate
//----------------------------------------------
  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        if (_formType == FormType.login) {
          UserCredential userCredential;
          try {
            userCredential = await widget._auth
                .signInWithEmailAndPassword(email: _email, password: _password);
            print(_email);
            print(_password);
          } on FirebaseAuthException catch (e) {
            if (e.code == 'user-not-found') {
              print('No user found for that email.');
            } else if (e.code == 'wrong-password') {
              print('Wrong password provided for that user.');
            }
          }
          User user = userCredential.user;

          print('Signed in: ${user.uid}');

          print(user.email);

          if (user != null) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ChatIndex(user)));
          }
        } else {
          dynamic result = await widget._auth.createUserWithEmailAndPassword(
              email: _email, password: _password);
          User user = result.user;

          print("TESSST");
          print(user);

          widget.fireStore.collection("users").add({
            "name": _name,
            "email": _email,
          }).then((value) => null);

          print('Registered user: ${user.uid}');

          if (user != null) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ChatIndex(user)));
          }
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

//---------------------------------------
//        New User Register
//---------------------------------------

  void moveToRegister() {
    formKey.currentState.reset(); //to clear the previous content of the page
    setState(() {
      //setState() triggers build again, hence creating the page
      _formType = FormType.register;
    });
  }

  //--------------------------------------
  //           Login
  //--------------------------------------

  void moveToLogin() {
    setState(() {
      _formType = FormType.login;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text("data"),
      ),
      body: Builder(builder: (BuildContext context) {
        return Center(
          child: Container(
            margin: EdgeInsets.all(20.0),
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: new Form(
                key: formKey, //doubt: what is a key?

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: buildInputs() + buildSubmitButtons(),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

//--------------------------------------------------------------------
//                  Inputs
//--------------------------------------------------------------------
  List<Widget> buildInputs() {
    if (_formType == FormType.login) {
      return [
        TextFormField(
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(labelText: "Email"),
          validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
          onSaved: (value) => _email = value,
        ),
        TextFormField(
          decoration: InputDecoration(labelText: "Password"),
          obscureText: true,
          validator: (value) =>
              value.isEmpty ? 'password can\'t be empty' : null,
          onSaved: (value) => _password = value,
        ),
      ];
    } else {
      return [
        TextFormField(
          decoration: InputDecoration(labelText: "Email"),
          validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
          onSaved: (value) => _email = value,
        ),
        TextFormField(
          decoration: InputDecoration(labelText: "Password"),
          obscureText: true,
          validator: (value) =>
              value.isEmpty ? 'password can\'t be empty' : null,
          onSaved: (value) => _password = value,
        ),
      ];
    }
  }

  //---------------------------------------------------------------------
  //                    Buttons
  //---------------------------------------------------------------------

  List<Widget> buildSubmitButtons() {
    if (_formType == FormType.login) {
      return [
        RaisedButton(
          child: Text("Login"),
          onPressed: validateAndSubmit,
        ),
        FlatButton(
          onPressed: moveToRegister,
          child: Text(
            "New User? Sign up",
            style: TextStyle(fontSize: 15.0),
          ),
        ),
      ];
    } else {
      return [
        RaisedButton(
          child: Text("Sign Up"),
          onPressed: validateAndSubmit,
        ),
        FlatButton(
          onPressed: moveToLogin,
          child: Text(
            "Already an account? Login",
            style: TextStyle(fontSize: 15.0),
          ),
        ),
      ];
    }
  }
}
