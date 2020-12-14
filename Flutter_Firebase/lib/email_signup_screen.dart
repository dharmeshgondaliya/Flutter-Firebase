import 'package:Flutter_Firebase/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class email_signup_screen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => Email_Signup();
}

class Email_Signup extends State<email_signup_screen>{
  var emailkey = GlobalKey<FormState>();
  var namecontroller = TextEditingController();
  var emailcontroller = TextEditingController();
  var passwordcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoginBox(),
    );
  }

  Widget LoginBox(){
    return Center(
      child: Padding(
        padding: EdgeInsets.only(left: 25.0,right: 25.0,top: 100.0),
        child: Form(
          key: emailkey,
          child: Column(
            children: <Widget>[
              Text('Register',style: TextStyle(fontSize: 25.0),),

              SizedBox(height: 20.0,),

              TextFormField(
                controller: namecontroller,
                decoration: InputDecoration(
                  labelText: 'Enter Name'
                ),
                validator: (value){
                  if(value.trim().isEmpty){
                    return 'Enter Name';
                  }
                },
              ),

              SizedBox(height: 15.0,),

              TextFormField(
                controller: emailcontroller,
                decoration: InputDecoration(
                  labelText: 'Enter Email'
                ),
                validator: (value){
                  if(value.trim().isEmpty){
                    return 'Enter Email ID';
                  }
                },
              ),

              SizedBox(height: 15.0,),

              TextFormField(
                controller: passwordcontroller,
                decoration: InputDecoration(
                  labelText: 'Enter Password'
                ),
                validator: (value){
                  if(value.trim().isEmpty){
                    return 'Enter Password';
                  }
                  if(value.trim().toString().length < 6){
                    return 'Enter 6 character or more password';
                  }
                },
              ),

              SizedBox(height: 15.0,),

              Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      onPressed: (){
                        if(emailkey.currentState.validate()){
                          DataOperation();
                        }
                      },
                      child: Text('Register',style: TextStyle(color: Colors.white,fontSize: 16.0),),
                      color: Colors.blueAccent,
                    )
                  )
                ],
              ),

              SizedBox(height: 15.0,),

              InkWell(
                child: Text("Already have a account",style: TextStyle(fontSize: 16.0),),
                onTap: (){
                  Navigator.pop(context);
                },
              )
              
            ],
          ),
        ),
      ),
    );
  }

  DataOperation(){
    var name = namecontroller.text.trim().toString();
    var email = emailcontroller.text.trim().toString();
    var password = passwordcontroller.text.trim().toString();
    Firebase.initializeApp();
    try{
      adduser(email, password);
      adduserdata(name, email);
      namecontroller.text = "";
      emailcontroller.text = "";
      passwordcontroller.text = "";

      Navigator.push(context, MaterialPageRoute(builder: (context)=>home_screen()));
    }
    catch(e){
      print(e);
    }
  }

  adduser(email,password) async {
    var user = (await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password)) as FirebaseUser;
  }

  adduserdata(name,email) async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
      await ref.child("Users").child(ref.push().key.toString()).set({
        'name': name,
        'contact': email,
        'contacttype': "email",
        'image': "https://firebasestorage.googleapis.com/v0/b/flutter-crud-app-eea32.appspot.com/o/demo.jpeg?alt=media&token=83ba20c3-d98e-42b6-bb33-80f9aeadf8b7",
        'user': "Register",
      });
  }

}
