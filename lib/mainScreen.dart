import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'main.dart';
import 'newAutorisation.dart';

Map<String, dynamic> orders;
String orderType = 'new';
int selectedIndex = 0;
bool ordersReady = false;
//для файрбейз
//FirebaseMessaging _fcm = FirebaseMessaging();

class mainScreenPage extends StatefulWidget {

  @override
  _mainScreenPageState createState() => _mainScreenPageState();

}

class _mainScreenPageState extends State<mainScreenPage> {


  /*StreamSubscription iosSubscription;*/

  @override
  void initState() {
    /*if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        // save the token  OR subscribe to a topic here
        const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: false);
      });
      _fcm.requestNotificationPermissions(IosNotificationSettings());
      _fcm.configure();
    }*/
    super.initState();
    _sendRequestPost();
  }

  _sendRequestPost() async {
    try {
      var response = await http.post("https://perevozki40.ru/api/orders",
          headers: {"Accept": "application/json", "Authorization": "Bearer $userToken"},
          body: jsonEncode(<String, dynamic>{"userid": "$userId"}
          )
      );
      orders = jsonDecode(response.body);
      print(response.body);
      print(response.body);
    } catch (error) {
      print(error);
    }
    ordersReady = true;
    setState(() {}); //reBuildWidget
    //}
  }//_sendRequestPost

  callClient(url) async {
    if (await canLaunch('tel://$url')) {
      await launch('tel://$url');
    } else {
      throw 'Невозможно набрать номер $url';
    }
    print('пробуем позвонить');
  }

  goToSite(url) async {
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
          leading: Container(
            margin: EdgeInsets.fromLTRB(0,0,0,0),
            //padding: EdgeInsets.fromLTRB(5,5,5,5),
            child: Material(
              color: Color(0xFF821e82), // button color
              child: InkWell(
                splashColor: Colors.green, // splash color
                onTap: () {
                  logoutProcedure();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => LoginProcedure()));
                }, // button pressed
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.logout, size: 18.0, color: Colors.white), // icon
                    Text("Выход", style: TextStyle(color: Colors.white)), // text
                  ],
                ),
              ),
            ),
          ),
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
              SizedBox(height: 10.0),
          Container(
            margin: EdgeInsets.fromLTRB(20,10,20,20),
            padding: EdgeInsets.fromLTRB(10,10,10,10),
              child: Text('Ваши заказы в статусе: ${orderType == 'new' ? 'Новые' : orderType == 'completed' ? 'Завершенные' : 'В процессе'}',style: TextStyle(fontSize: 18.0, color: Color(0xFF444444), /*decoration: TextDecoration.underline, decorationColor: Color(0xFF444444), decorationThickness: 2,*/ fontFamily: 'Open Sans'),textAlign: TextAlign.center,),
          ),
            SizedBox(height: 10.0),
              ordersReady == true ? orders['$orderType'] != null ? ListView.builder(
              physics: ScrollPhysics(),
              shrinkWrap: true,
              itemCount: orders['$orderType'].length, //подставляем тип заказа
              itemBuilder: (BuildContext context, int index) {
                return orders['$orderType'][0] != null ? Container(
                  margin: EdgeInsets.fromLTRB(20,10,20,20),
                  padding: EdgeInsets.fromLTRB(10,10,10,10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Color(0xFFFFFFFF),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: Offset(0, 0), // changes position of shadow
                        ),
                      ],),

                      child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text('Номер заказа: ${orders['$orderType'][index]['id']}'),
                          Text(' | '),
                          Text('Дата: ${orders['$orderType'][index]['date']}')
                        ],
                      ),
                      SizedBox(height: 5.0),
                      Container(
                        child: Text('Клиент: ${orders['$orderType'][index]['client']}'),
                      ),
                      SizedBox(height: 5.0),
                      Container(
                        child: Text('Маршрут: ${orders['$orderType'][index]['info']}'),
                      ),
                      SizedBox(height: 5.0),
                      Container(
                        child: Text('Данные автомобиля и водителя: ${orders['$orderType'][index]['vehicle']}'),
                      ),
                      SizedBox(height: 10.0),
                      Container(
                        child: Text('Дополнительная информация: ${orders['$orderType'][index]['route']}'),
                      ),
                      SizedBox(height: 5.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text('Тариф: ${orders['$orderType'][index]['rate'] == null ? 'Не указан' : orders['$orderType'][index]['rate']}'),
                          Text(' | '),
                          Text('${orders['$orderType'][index]['type_payment']}')
                        ],
                      ),
                      GestureDetector(
                      onTap: () {
                        goToSite('${orders['$orderType'][index]['url']}');
                        },
                        child:
                      Text('${orders['$orderType'][index]['url'] == null ? 'Ссылка на заказ:' : ''}'),
                      ),
                      //SizedBox(height: 20.0),
                    ],
                  ),
                ) : Container(child: Text('У вас еще нет заказов'));
              })  : Container(
                  margin: EdgeInsets.fromLTRB(20,10,20,20),
                  padding: EdgeInsets.fromLTRB(10,10,10,10),
                  child: Text('У вас нет заказов в этой категории ')) : Container(
                  margin: EdgeInsets.fromLTRB(0,MediaQuery.of(context).size.height/3,0,0),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  Text('Загружаем историю заказов')
                ],
              )),

            ],
          )
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.fiber_new),
            label: 'Новые',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.av_timer_rounded ),
            label: 'В процессе',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.archive),
            label: 'Выполненые',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Color(0xFF821e82),
        onTap: _onItemTapped,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: new FloatingActionButton(

        onPressed:(){
          setState(() {
            ordersReady = false;
          });

          _sendRequestPost();//обновить заказы
        },
        tooltip: 'Increment',
        child: new Icon(Icons.autorenew_rounded , size: 50,color:Color(0xFF6A6A6A),), //cчитаем вниз, потом меняем на направление вверх и считаем вверх
        backgroundColor: Color(0xFFFFFFFF),
      ),

    );
  }

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
    if(selectedIndex == 0) {
      setState(() {
        orderType = 'new';
      });
    }
    if(selectedIndex == 1){
      setState(() {
        orderType = 'in_process';
      });
    }
    if(selectedIndex == 2){
      setState(() {
        orderType = 'completed';
      });
    }
  }
}




logoutProcedure()async{
  final Directory directory = await getApplicationDocumentsDirectory();
  final File file = File('${directory.path}/profile.txt');
  var profile = "";
  await file.writeAsString(profile);

  try {
    var response = await http.post("https://perevozki40.ru/api/logout",
        headers: {"Accept": "application/json", "Authorization": "Bearer $userToken"},
        body: jsonEncode(<String, dynamic>{"userid": "$userId", "firebase_id" : "$tokenMy"}
        )
    );}
    catch(e){}
}
