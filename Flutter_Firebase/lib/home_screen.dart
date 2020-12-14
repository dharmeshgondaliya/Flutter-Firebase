import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class home_screen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => Home();
}

class Home extends State<home_screen>{

  List<datamodel> users = [];
  var namecontroller = TextEditingController();
  var emailcontroller = TextEditingController();
  var key = GlobalKey<FormState>();
  var refreshkey = GlobalKey<RefreshIndicatorState>();
  var usertypelist = ["All","Register","Not register"];
  String selecttype = "All";
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.getusers();
  }

  Future<Null> getusers() async {
    var query = FirebaseDatabase.instance.reference().child("Users");
    refreshkey.currentState?.show();
    await Future.delayed(Duration(seconds: 3));
    await query.once().then((DataSnapshot snapshot){
      setState(() {
        var keys = snapshot.value.keys;
        var values = snapshot.value;
        users.clear();
        for(var k in keys){
          datamodel user = datamodel(values[k]['name'].toString(),values[k]['contact'].toString(),values[k]['contacttype'].toString(),values[k]['image'].toString(),values[k]['user'].toString(),k);
          if(selecttype == usertypelist[0]){
            users.add(user);
          }  
          else{
            if(selecttype == usertypelist[1] && values[k]['user'] == selecttype){
              users.add(user);
            }
            else if(selecttype == usertypelist[2] && values[k]['user'] == "Dummy"){
              users.add(user);
            }
          }
        }
      });  
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: Text('Firebase Users')),
                  DropdownButton(
                  items: usertypelist.map((String item){
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item,textAlign: TextAlign.right,),
                    );
                  }).toList(), 
                  onChanged: (selectedvalue){
                    setState(() {
                      selecttype = selectedvalue;
                      getusers();
                    });
                  },value: selecttype,
                )
              ],
            )
          ],
        ),
      ),
      body: RefreshIndicator(
        key: refreshkey,child: ListView.builder(
          itemCount: users.length,itemBuilder: (context,index){
        
          if(users[index].user.toString() == "Dummy"){
            return Dismissible(
              key: Key(users[index].key), 
              child: getCard(users[index]),
              onDismissed: (deirection){
                removeuser(users[index]);
              }
            );
          }
          return getCard(users[index]);
        }), 
        onRefresh: getusers,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          ShowDialogBox("New");
        },
        child: Icon(Icons.add,color: Colors.white,),
      ),
    );
  }

  ShowDialogBox(String open,[user]){
    var dialogtitle;
    var btn;
    if(open == "New"){
      dialogtitle = "Add User";
      btn = "Create";
    }
    else{
      dialogtitle = "Update User Data";
      btn = "Update";
    }
    showDialog(
      context: context,
      builder: (context) =>  AlertDialog(
        title: Text(dialogtitle,textAlign: TextAlign.center,),
        content: Form(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
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
              TextFormField(
                controller: emailcontroller,
                decoration: InputDecoration(
                  labelText: 'Enter Email'
                ),
                validator: (value){
                  if(value.trim().isEmpty){
                    return 'Enter Email';
                  }
                },
              )
            ],
          ), 
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: (){
              namecontroller.text = "";
              emailcontroller.text = "";
              Navigator.pop(context);
            }, 
            child: Text('Cancel'),
          ),
          FlatButton(
            onPressed: (){
              if(key.currentState.validate()){
                if(btn == "Create")
                  userAdd(); 
                else
                  userupdate(user);
              }
            }, 
            child: Text(btn),
          )
        ],
      )
    );
  }

  Widget getCard(datamodel user){
    var icon;
    if(user.contacttype.toString() == "email"){
      icon = Icon(Icons.email);
    }else{
      icon = Icon(Icons.phone);
    }
    return Card(
      child: ListTile(
        leading: getImageBox(user),
        title: Text(user.name),
        subtitle: Text(user.contact),
        trailing: icon,
        onLongPress: (){
          if(user.user == "Dummy"){
            setState(() {
              namecontroller.text = user.name;
              emailcontroller.text = user.contact;
              ShowDialogBox("Update",user);
            });
          }
        },
      ),
      color: Colors.lightBlue[50],
    );
  }

  Widget getImageBox(user){
    if(user.user.toString() == "Register"){
      return Container(
          width: 50,height: 50,
          decoration: BoxDecoration(
            image: DecorationImage(image: NetworkImage(user.image),fit: BoxFit.cover)
          ),
        );
    }else{
      return Icon(Icons.person,color: Colors.blueAccent,size: 50,);
    }
  }

  removeuser(user) async {
    await FirebaseDatabase.instance.reference().child("Users").child(user.key).remove();
  }

  userAdd() async {
    var name = namecontroller.text.trim().toString();
    var email = emailcontroller.text.trim().toString();

    var db = FirebaseDatabase.instance.reference();
    await db.child("Users").child(db.push().key.toString()).set({
      'name': name,
      'contact': email,
      'contacttype': "email",
      'image': "https://firebasestorage.googleapis.com/v0/b/flutter-crud-app-eea32.appspot.com/o/demo.jpeg?alt=media&token=83ba20c3-d98e-42b6-bb33-80f9aeadf8b7",
      'user': "Dummy",
    }).then((value) { 
      Navigator.pop(context); 
      namecontroller.text = "";
      emailcontroller.text = "";
    });   
  }

  userupdate(user) async {
    await FirebaseDatabase.instance.reference().child("Users").child(user.key).set({
      'name': namecontroller.text.trim().toString(),
      'contact': emailcontroller.text.trim().toString(),
      'contacttype': "email",
      'image': "https://firebasestorage.googleapis.com/v0/b/flutter-crud-app-eea32.appspot.com/o/demo.jpeg?alt=media&token=83ba20c3-d98e-42b6-bb33-80f9aeadf8b7",
      'user': "Dummy",
    }).then((value){
      Navigator.pop(context); 
      namecontroller.text = "";
      emailcontroller.text = "";
      getusers();
    });
  }

}

class datamodel{
  String name,contact,contacttype,image,user,key;
  datamodel(this.name,this.contact,this.contacttype,this.image,this.user,this.key);
}