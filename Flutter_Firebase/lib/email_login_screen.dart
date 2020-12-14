import 'package:Flutter_Firebase/email_signup_screen.dart';
import 'package:Flutter_Firebase/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class email_login_screen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => Email_Login();
}

class Email_Login extends State<email_login_screen>{
  var emailkey = GlobalKey<FormState>();
  var emailcontroller = TextEditingController();
  var passwordcontroller = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.check();
  }

  check() async{
    await Firebase.initializeApp();
    if(FirebaseAuth.instance.currentUser.uid != null){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>home_screen()));
    }
  }

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
              Text('Login',style: TextStyle(fontSize: 25.0),),

              SizedBox(height: 20.0,),

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
                      child: Text('Login',style: TextStyle(color: Colors.white,fontSize: 16.0),),
                      color: Colors.blueAccent,
                    )
                  )
                ],
              ),

              SizedBox(height: 15.0,),

              InkWell(
                child: Text("Don't have a account",style: TextStyle(fontSize: 16.0),),
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>email_signup_screen()));
                },
              )

            ],
          ),
        ),
      ),
    );
  }

  DataOperation() async {
    var email = emailcontroller.text.trim().toString();
    var password = passwordcontroller.text.trim().toString();
    Firebase.initializeApp();
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password).whenComplete((){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>home_screen()));
      });
      
      emailcontroller.text = "";
      passwordcontroller.text = "";

    }catch(e){
      print(e.toString());
    }

  }

}
