import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'main.dart';
import 'mainScreen.dart';


String messageTest = '';
String tokenMy;
int connectionStatus = 0;


class newAutorisationPage extends StatefulWidget {

  final String url;

  newAutorisationPage({String url}):url = url;

  @override
  _newAutorisationPageState createState() => _newAutorisationPageState();

}

class _newAutorisationPageState extends State<newAutorisationPage> {


  String _url, _body, _PostLogin, _PostPassword;
  var maskFormatterPhone = new MaskTextInputFormatter(mask: '+7 (###) ###-##-##', filter: { "#": RegExp(r'[0-9]') });

  //для файрбейз
  StreamSubscription iosSubscription;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    _url = 'https://perevozki40.ru/api/login';
    _firebaseMessaging.configure();

    super.initState();

    /*_firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );*/



    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: false));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      //print("Settings registered: $settings");
    });


    _firebaseMessaging.getToken().then((token) {
      assert(token != null);
      setState(() {
        tokenMy = "$token"; // получили токен и отправили его в переменную
      });
      print(tokenMy);
    });

  }


  _sendRequestPost() async {
    setState(() {
      connectionStatus = 1;
    });
    _PostLogin= _PostLogin.replaceAll("+7", "").replaceAll("(", "").replaceAll(")", "").replaceAll("-", "").replaceAll(" ", "");
    var errorMark;
      try {
        var response = await http.post(_url,
            headers: {"Accept": "application/json"},
            body: jsonEncode(<String, dynamic>{"phone": "$_PostLogin", "password": "$_PostPassword", "firebase_id":"$tokenMy"}
              //body: jsonEncode(<String, dynamic>{"phone": "1111111111", "password": "123456", "firebase_id":"1"}
            )
        );

        Map<String, dynamic> user = jsonDecode(response.body);
        _body = user['status'];

        if(_body != 'ERROR'){
          final Directory directory = await getApplicationDocumentsDirectory();
          final File file = File('${directory.path}/profile.txt');
          var profile = jsonEncode(<String, dynamic>{"phone": "$_PostLogin", "password":"$_PostPassword", "autorisationToken" : "${user['token']}", "userid":"${user['userid']}", "firebaseToken" : "$tokenMy"});
          await file.writeAsString(profile);
          userToken = user['token'];
          userId = user['userid'].toString();
          //идем на главный экран
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => mainScreenPage()));
          errorMark = response.body;
        } else {_body = 'ERROR';}
        //print(response.body);
      } catch (error) {
        //print(error);
        //print(errorMark);
      }
      setState(() {});

  }//_sendRequestPost

  callClient(url) async {
    if (await canLaunch('tel://$url')) {
      await launch('tel://$url');
    } else {
      throw 'Невозможно набрать номер $url';
    }
    print('пробуем позвонить');
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
          title: Text('Перевозчик40.RU', style: TextStyle(fontSize: 16.0, color: Colors.white, fontFamily: 'Open Sans',fontWeight: FontWeight.bold )),
          centerTitle: true,
          backgroundColor: Color(0xFF821e82),
          brightness: Brightness.dark,
          actions: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(0,0,10,0),
              child: Material(
                color: Color(0xFF821e82), // button color
                child: InkWell(
                  splashColor: Colors.green, // splash color
                  onTap: () {callClient('+79019955949');}, // button pressed
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.call, size: 18.0, color: Colors.white), // icon
                      Text("Звонок", style: TextStyle(color: Colors.white)), // text
                    ],
                  ),
                ),
              ),
            )
          ]
      ),
      body: SingleChildScrollView(
        physics: ScrollPhysics(),
          child: Column(
            children: <Widget>[
              SizedBox(height: 20.0),
              Center(
                  child:Container(
                    child: Text('ВХОД В ЛИЧНЫЙ КАБИНЕТ', style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.black),textAlign: TextAlign.center,),
                    padding: EdgeInsets.fromLTRB(10,30,10,10),
                    alignment: Alignment(0.0, 0.0),
                  )
              ),
              Container(
                  child: TextFormField(
                      inputFormatters: [maskFormatterPhone],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(hintText: "Номер телефона без +7", focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: BorderSide(
                      color: Color(0xFF821e82),
                    ),
                  ), enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                  ),),
                      onChanged: (value){_PostLogin = value;}, autovalidate: true),
                  padding: EdgeInsets.fromLTRB(40,10,40,5)
              ),
              Container(
                child: TextFormField(decoration: InputDecoration(hintText: "Пароль", focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(
                    color: Color(0xFF821e82),
                  ),
                ), enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),),  onChanged: (value){_PostPassword = value;}, autovalidate: true, obscureText: true,),
                padding: EdgeInsets.fromLTRB(40,10,40,5),
              ),
              SizedBox(height: 10.0),
              RaisedButton.icon(onPressed: _sendRequestPost, icon: Icon(Icons.vpn_key), label: Text("ВХОД"),color: Color(0xFF821e82),
                textColor: Colors.white,
                disabledColor: Colors.grey,
                disabledTextColor: Colors.white,
                padding: EdgeInsets.fromLTRB(50,10,50,10),
                splashColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                ),
              ),
              SizedBox(height: 20.0),
              //Text('Response body', style: TextStyle(fontSize: 20.0,color: Colors.blue)),
          connectionStatus == 1 ? CircularProgressIndicator(backgroundColor: Color(0xFF821e82),valueColor : AlwaysStoppedAnimation(Colors.green),):Container(),
              Text(_body == 'ERROR' ? 'Неверный номер телефона или пароль' : '', style: TextStyle(fontSize: 15.0,color: Colors.redAccent)),
              SizedBox(height: 20.0),
            ],
          )
      ),
    );
  }
}


class LoginProcedure extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: newAutorisationPage(url: 'https://perevozki40.ru/api/login')
    );
  }
}
