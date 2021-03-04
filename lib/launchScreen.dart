import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'main.dart';
import 'mainScreen.dart';
import 'newAutorisation.dart';

String Uphone, Upass, UfromFile;

class launchScreen extends StatefulWidget {

  @override
  _LaunchScreenState createState() => _LaunchScreenState();
}


class _LaunchScreenState extends State<launchScreen> {
  String _url, _body;

  @override
  void initState() {
    _url = 'https://perevozki40.ru/api/login';
    super.initState();
    readProfile();
  }//initState



  readProfile() async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File fileL = File('${directory.path}/profile.txt');

      UfromFile = await fileL.readAsString();
      var nameUs = json.decode(UfromFile);
      if (nameUs['phone'].length > 0) {
          Uphone = nameUs['phone'];
          Upass = nameUs['password'];
          userToken = nameUs['autorisationToken'];
          userId = nameUs['userid'];
          tokenMy = nameUs['firebaseToken'];

          try {
            var response = await http.post(_url,
                headers: {"Accept": "application/json"},
                body: jsonEncode(<String, dynamic>{
                  "phone": Uphone,
                  "password": Upass,
                  "firebase_id": "$tokenMy"
                }
                  //body: jsonEncode(<String, dynamic>{"phone": "1111111111", "password": "123456", "firebase_id":"1"}
                )
            );
            Map<String, dynamic> user = jsonDecode(response.body);
            _body = user['status'];

            if (_body != 'ERROR') {
              userToken = user['token'];
              userId = user['userid'];
            }
            _body = response.body;
            print(response.body);
          } catch (error) {
            _body = error.toString();
          }
          setState(() {});
          //идем на главный экран
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => mainScreenPage()));
    } else {
        Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => LoginProcedure()));}
    } catch (error) {
      //редиректимся на страницу проверки номера телефона
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => LoginProcedure()));    }

  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return Scaffold(
      backgroundColor: Color(0xFFffffff),
      body:Container(
        height: MediaQuery.of(context).size.height, width: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Color.fromRGBO(229, 229, 229, 1),),

        child:Column(
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).size.height / 2 - 120, width: MediaQuery.of(context).size.width,

              ),
              Center(
                child:Text('Перевозчик40.RU\n', style: TextStyle(fontSize: 20.0, color: Colors.grey, fontFamily: 'Open Sans',fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
            ),
            Center(
              child: Container(
                height: 100, width: 100,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("images/icon.png"),
                        fit:BoxFit.fitHeight, alignment: Alignment(0.1, 0.0)
                    ),
                  ),
                ),),
              SizedBox(height:20, width: MediaQuery.of(context).size.width,

              ),
              Center(
                child:Text('Версия: 1.0.0\n', style: TextStyle(fontSize: 15.0, color: Colors.grey, fontFamily: 'Open Sans'),textAlign: TextAlign.center,),
              ),
              Center(
                child:Container(
                    width: 15.0,
                    height: 15.0,
                    margin: EdgeInsets.fromLTRB(10,0,0,0),
                    child:CircularProgressIndicator(strokeWidth: 2.0,
                      valueColor : AlwaysStoppedAnimation(Colors.black),)),
              ),
            ]),
      ),
    );
  }



  updateProfile() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/profile.txt');
    var profile = jsonEncode(<String, dynamic>{"phone": "$Uphone", "pass":"$Upass"});
    await file.writeAsString(profile);
  }

}




