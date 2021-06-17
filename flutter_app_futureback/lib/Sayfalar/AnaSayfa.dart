import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app_futureback/model/Kullanici.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import 'GirisEkran.dart';
import 'hesapOlusturmaSayfasi.dart';

final GoogleSignIn googlegiris = GoogleSignIn(
  scopes: [
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);
final kullaniciRef = FirebaseFirestore.instance.collection("Kullanicilar");
final bildirimRef = FirebaseFirestore.instance.collection("Bildirimler");
final yorumRef = FirebaseFirestore.instance.collection("Yorumlar");
final takipciRef = FirebaseFirestore.instance.collection("Takipçiler");
final takipEdilenRef = FirebaseFirestore.instance.collection("Takip Edilenler");
final gonderiRef = FirebaseFirestore.instance.collection("Gonderilenler");
final akisRef = FirebaseFirestore.instance.collection("Ana Akis");
final kartlarRef = FirebaseFirestore.instance.collection("Kartlar");
final scaffoldKey = GlobalKey<ScaffoldState>();
final FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseMessaging messaging = FirebaseMessaging.instance;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final DateTime timestamp = DateTime.now();
Kullanici anlikKullanici;

/// Create a [AndroidNotificationChannel] for heads up notifications
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  '1234', // id
  'Test Title', // title
  'Test Description.', // description
  importance: Importance.high,
);

class AnaSayfa extends StatefulWidget {
  final bool girdimi;
  AnaSayfa({
    this.girdimi,
  });
  final _AnaSayfaState child = _AnaSayfaState(girdimi: false);
  @override
  _AnaSayfaState createState() {
    _AnaSayfaState(
      girdimi: this.girdimi,
    );
    return child;
  }
}

class _AnaSayfaState extends State<AnaSayfa> with SingleTickerProviderStateMixin {
  bool girdimi = false;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isToogle = false;

  String _token = "";

  _AnaSayfaState({
    this.girdimi,
  });

  /*String constructFCMPayload(String token) {
    _messageCount++;
    return jsonEncode({
      'token': token,
      'data': {
        'via': 'FlutterFire Cloud Messaging!!!',
        'count': _messageCount.toString(),
      },
      'notification': {
        'title': 'Hello FlutterFire!',
        'body': 'This notification (#$_messageCount) was created via FCM!',
      },
    });
  }*/

  @override
  void initState() {
    /* const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    final initializationSettingsIOS = IOSInitializationSettings(
      onDidReceiveLocalNotification: _configureDidReceiveLocalNotificationSubject,
    );
    final initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: _configureSelectNotificationSubject);
    messaging.subscribeToTopic("testcribe");*/
    /*messaging.getInitialMessage().then((RemoteMessage message) {
      if (message != null) {
        SnackBar snackBar = SnackBar(
          content: Text("Mesaj boş"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });*/
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                icon: 'launch_background',
              ),
            ));
      }
      showNotification(message);
    });
    /*FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      bool isMessage = true;
      showNotification(message);
      if (isMessage) {
        sayfaKontrol.jumpToPage(2);
        Navigator.push(context, MaterialPageRoute(builder: (context) => bildirimSayfasi()));
      } else {
        sayfaKontrol.jumpToPage(1);
        Navigator.push(context, MaterialPageRoute(builder: (context) => profilDuzenle()));
      }
    });*/
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    googlegiris.onCurrentUserChanged.listen((googleHesap) {
      setState(() {
        kullaniciKontrol(googleHesap);
      });
    }, onError: (gHata) {
      print("Hata Mesaj: " + gHata.toString());
    });
    googlegiris.signInSilently();
    /*googlegiris.signInSilently(suppressErrors: false).then((googleHesap2) {
      setState(() {
        kullaniciKontrol(googleHesap2);
      });
    }).catchError((gHata) {
      print("Hata Mesaj 2: " + gHata.toString());
    });*/
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  static void showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails('1234', 'Yeni Mesaj', 'your channel description',
        importance: Importance.max, priority: Priority.high, ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, message.data['title'], message.data['message'], platformChannelSpecifics, payload: 'item x');
  }

  Future<void> sendPushMessage() async {
    if (_token == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }

    try {
      await http.post(
        Uri.parse('https://api.rnfirebase.io/messaging/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        //body: constructFCMPayload(_token),
      );
      print('FCM request for device sent!');
    } catch (e) {
      print(e);
    }
  }

  kullaniciGiris() {
    setState(() {
      googlegiris.signIn();
    });
  }

  kullaniciKontrol(GoogleSignInAccount girisHesap) async {
    if (girisHesap != null) {
      await kullaniciFireStoreKayit();
      setState(() {
        girdimi = true;
      });
    } else {
      setState(() {
        girdimi = false;
      });
    }
  }

  /*Scaffold anaEkrani() {

  }*/

  void toggleScreen() {
    setState(() {
      isToogle = !isToogle;
    });
  }

  Scaffold kayitEkrani() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            top: 75,
            right: 25,
            left: 25,
            bottom: 40,
          ),
          child: Container(
            decoration: BoxDecoration(
                boxShadow: [BoxShadow(offset: Offset(0, 10), blurRadius: 10, color: Colors.grey)],
                borderRadius: BorderRadius.circular(20),
                color: Colors.white),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(40)),
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        children: [
                          Container(
                            width: 220,
                            height: 90,
                            decoration: BoxDecoration(
                                boxShadow: [BoxShadow(offset: Offset(0, 10), blurRadius: 10, color: Colors.grey)],
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(1), BlendMode.dstATop),
                                  image: AssetImage("assets/images/sscard.png"),
                                )),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "maCarD",
                            style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 34, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Share your card",
                            style: TextStyle(color: Colors.black, fontSize: 10),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          toggle(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Padding toggle() {
    if (isToogle) {
      return Register();
    } else {
      return Login();
    }
  }

  Padding Login() {
    return Padding(
      padding: EdgeInsets.only(right: 20, left: 20),
      child: Container(
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(offset: Offset(0, 10), blurRadius: 10, color: Colors.grey)],
            borderRadius: BorderRadius.circular(20),
            color: Colors.white),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(right: 15, left: 15, bottom: 15),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome Back",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Sign in to continue",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller: _emailController,
                      validator: (val) => val.isNotEmpty ? null : "Please enter a mail address",
                      decoration: InputDecoration(
                        hintText: "E-mail",
                        prefixIcon: Icon(Icons.mail),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.deepOrange, width: 6),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller: _passwordController,
                      validator: (val) => val.length < 6 ? "Enter more than 6 char " : null,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Password",
                        prefixIcon: Icon(Icons.vpn_key),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.deepOrange, width: 6),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    MaterialButton(
                      onPressed: () {
                        if (formKey.currentState.validate()) {
                          debugPrint("Email= " + _emailController.text);
                          debugPrint("pass= " + _passwordController.text);
                          signIn(_emailController.text, _passwordController.text).then((value) {
                            setState(() {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GirisEkran()));
                            });
                          });
                        }
                      },
                      height: 45,
                      minWidth: double.infinity,
                      color: Colors.deepOrange[200],
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Login",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account ?"),
                        SizedBox(
                          width: 5,
                        ),
                        TextButton(
                          onPressed: () {
                            toggleScreen();
                          },
                          child: Text(
                            "Register",
                            style: TextStyle(color: Colors.deepOrange[200]),
                          ),
                        )
                      ],
                    ),
                    Center(
                      child: Text(
                        "OR",
                        style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          kullaniciGiris();
                        });
                      },
                      child: Container(
                        width: 270.0,
                        height: 65.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(150),
                          image: DecorationImage(
                            image: AssetImage("assets/images/google_signin_button1.png"),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Padding Register() {
    return Padding(
      padding: EdgeInsets.only(right: 20, left: 20),
      child: Container(
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(offset: Offset(0, 10), blurRadius: 10, color: Colors.grey)],
            borderRadius: BorderRadius.circular(20),
            color: Colors.white),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Create account to continue",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller: _emailController,
                      validator: (val) => val.isNotEmpty ? null : "Please enter a mail address",
                      decoration: InputDecoration(
                        hintText: "E-mail",
                        prefixIcon: Icon(Icons.mail),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.deepOrange.shade200, width: 6),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller: _passwordController,
                      validator: (val) => val.length < 6 ? "Enter more than 6 char " : null,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Password",
                        prefixIcon: Icon(Icons.vpn_key),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.deepOrange, width: 6),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    MaterialButton(
                      onPressed: () {
                        if (formKey.currentState.validate()) {
                          debugPrint("Email= " + _emailController.text);
                          debugPrint("pass= " + _passwordController.text);
                          createPerson(_emailController.text, _passwordController.text).then((value) {
                            setState(() {
                              isToogle = false;
                            });
                          });
                        }
                      },
                      height: 45,
                      minWidth: double.infinity,
                      color: Colors.deepOrange[200],
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Register",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account ?"),
                        SizedBox(
                          width: 5,
                        ),
                        TextButton(
                          onPressed: () {
                            toggleScreen();
                          },
                          child: Text(
                            "Login",
                            style: TextStyle(color: Colors.deepOrange[200]),
                          ),
                        )
                      ],
                    ),
                    Center(
                      child: Text(
                        "OR",
                        style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          kullaniciGiris();
                        });
                      },
                      child: Container(
                        width: 270.0,
                        height: 65.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(150),
                          image: DecorationImage(
                            image: AssetImage("assets/images/google_signin_button1.png"),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  kullaniciFireStoreKayit() async {
    final GoogleSignInAccount gAnlikKullanici = googlegiris.currentUser;
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await kullaniciRef.doc(gAnlikKullanici.id).get();
    if (!documentSnapshot.exists) {
      final username = await Navigator.push(context, MaterialPageRoute(builder: (context) => HesapOlusturmaSayfasi()));

      kullaniciRef.doc(gAnlikKullanici.id).set({
        "id": gAnlikKullanici.id,
        "profileName": gAnlikKullanici.displayName,
        "username": username,
        "url": gAnlikKullanici.photoUrl,
        "email": gAnlikKullanici.email,
        "biography": "",
        "timestamp": timestamp,
      });
      await takipciRef.doc(anlikKullanici.id).collection("takipciler").doc(anlikKullanici.id).set({});
      documentSnapshot = await kullaniciRef.doc(anlikKullanici.id).get();
    }
    anlikKullanici = Kullanici.fromDocument(documentSnapshot.data());
  }

  Future<User> signIn(String email, String password) async {
    var user = await _auth.signInWithEmailAndPassword(email: email, password: password);
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await kullaniciRef.doc(user.user.uid).get();
    if (!documentSnapshot.exists) {
      documentSnapshot = await kullaniciRef.doc(user.user.uid).get();
    }
    anlikKullanici = Kullanici.fromDocument(documentSnapshot.data());
    return user.user;
  }

  signOut() async {
    return await _auth.signOut();
  }

  Future<User> createPerson(String email, String password) async {
    var user = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await kullaniciRef.doc(user.user.uid).get();
    if (!documentSnapshot.exists) {
      final username = await Navigator.push(context, MaterialPageRoute(builder: (context) => HesapOlusturmaSayfasi()));
      kullaniciRef.doc(user.user.uid).set({
        "id": user.user.uid,
        "profileName": username,
        "username": username,
        "url": "https://www.google.com.tr/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png",
        "email": documentSnapshot.data()['email'],
        "biography": "",
        "timestamp": timestamp,
      });
      await takipciRef.doc(user.user.uid).collection("takipciler").doc(user.user.uid).set({});
      documentSnapshot = await kullaniciRef.doc(user.user.uid).get();
    }
    anlikKullanici = Kullanici.fromDocument(documentSnapshot.data());
    return user.user;
  }

  @override
  Widget build(BuildContext context) {
    if (girdimi == true) {
      return GirisEkran();
    } else {
      return kayitEkrani();
    }
  }

// ignore: missing_return
//Future _configureDidReceiveLocalNotificationSubject(int id, String title, String body, String payload) {}

// ignore: missing_return
/*Future _configureSelectNotificationSubject(String payload) {
    if (payload != null) {
      debugPrint('Notification Payload = ' + payload);
    }
  }
}*/

}
