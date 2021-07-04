import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_futureback/Sayfalar/AnaSayfa.dart';
import 'package:flutter_app_futureback/Sayfalar/GirisEkran.dart';
import 'package:flutter_app_futureback/Sayfalar/takipEdilenler.dart';
import 'package:flutter_app_futureback/model/Kullanici.dart';
import 'package:flutter_app_futureback/model/Mesajlar.dart';
import 'package:flutter_app_futureback/model/Sohbet.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import 'MesajlasmaSayfasi.dart';

class HomeScreen extends StatefulWidget {
  final String currentUserId;

  HomeScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  State createState() => HomeScreenState(currentUserId: currentUserId);
}

class HomeScreenState extends State<HomeScreen> {
  HomeScreenState({Key? key, required this.currentUserId});

  final String currentUserId;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final ScrollController listScrollController = ScrollController();
  TextEditingController? textDuzenlemeKontrol;
  Future<QuerySnapshot>? futureAramaSonuclari;
  int? tEdilenSayisi = 0;
  List<Sohbet>? sohbetEdilenler = [];
  bool tikladi = false;

  int _limit = 20;
  int _limitIncrement = 20;
  bool isLoading = false;
  String id = anlikKullanici!.id;
  String groupChatId = "";
  List<Choice> choices = const <Choice>[
    const Choice(title: 'Settings', icon: Icons.settings),
    const Choice(title: 'Log out', icon: Icons.exit_to_app),
  ];

  @override
  void initState() {
    super.initState();
    registerNotification();
    configLocalNotification();
    textDuzenlemeKontrol = TextEditingController();
    listScrollController.addListener(scrollListener);
  }

  @override
  void dispose() {
    textDuzenlemeKontrol!.dispose();
    super.dispose();
  }

  void registerNotification() {
    firebaseMessaging.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('onMessage: $message');
      if (message.notification != null) {
        showNotification(message.notification!);
      }
      return;
    });

    firebaseMessaging.getToken().then((token) {
      print('token: $token');
      kullaniciRef.doc(anlikKullanici!.id).update({'pushToken': token});
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });
  }

  void configLocalNotification() {
    AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings();
    InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  void showNotification(RemoteNotification remoteNotification) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'com.sametdemirtop.flutter_app_futureback',
      'Flutter chat demo',
      'your channel description',
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
    );
    IOSNotificationDetails iOSPlatformChannelSpecifics =
        IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    print(remoteNotification);

    await flutterLocalNotificationsPlugin.show(
      0,
      remoteNotification.title,
      remoteNotification.body,
      platformChannelSpecifics,
      payload: null,
    );
  }

  aramaYeriTemizleme() {
    textDuzenlemeKontrol!.clear();
    setState(() {
      textDuzenlemeKontrol!.text.isEmpty == true;
    });
  }

  aramaKontrol(String str) {
    Future<QuerySnapshot<Map<String, dynamic>>> tumKullanicilar =
        kullaniciRef.where("username", isGreaterThanOrEqualTo: str).get();
    setState(() {
      futureAramaSonuclari = tumKullanicilar;
    });
  }

  kullanicilariGosterme<Widget>() {
    return FutureBuilder<QuerySnapshot>(
      future: futureAramaSonuclari,
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return Text("");
        }
        List<KullaniciSonuc> kullaniciAramaSonucu = [];
        dataSnapshot.data!.docs.forEach((documents) {
          Kullanici herbirKullanici = Kullanici.fromDocument(documents);
          KullaniciSonuc userResult = KullaniciSonuc(herbirKullanici);
          kullaniciAramaSonucu.add(userResult);
        });
        return Column(
          children: kullaniciAramaSonucu,
        );
      },
    );
  }

  aramaCubugu() {
    return Container(
      padding: EdgeInsets.only(top: 5),
      margin: EdgeInsets.all(10.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35.0),
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 10),
                      blurRadius: 50,
                      color: Colors.grey.shade400)
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                      icon: Icon(
                        Icons.search,
                        color: Colors.black45,
                      ),
                      onPressed: () {}),
                  Expanded(
                    child: TextFormField(
                      controller: textDuzenlemeKontrol,
                      decoration: InputDecoration(
                          hintText: "Ara",
                          hintStyle: TextStyle(color: Colors.black26),
                          border: InputBorder.none),
                      onFieldSubmitted: aramaKontrol,
                    ),
                  ),
                  textDuzenlemeKontrol!.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.black45),
                          onPressed: aramaYeriTemizleme,
                        )
                      : Icon(Icons.clear, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  tEdilenleriGetirme() {
    return StreamBuilder<QuerySnapshot>(
      stream: takipEdilenRef
          .doc(anlikKullanici!.id)
          .collection("takipEdilenler")
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: EdgeInsets.all(10.0),
            itemBuilder: (context, index) =>
                buildItem(context, snapshot.data?.docs[index]),
            itemCount: snapshot.data?.docs.length,
            controller: listScrollController,
          );
        } else {
          return Container(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.transparent),
            ),
          );
        }
      },
    );
  }

  sohbetttgetir() {
    return StreamBuilder<QuerySnapshot>(
      stream: sohbetRef
          .doc(anlikKullanici!.id)
          .collection("sohbetEdilenler")
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: EdgeInsets.all(10.0),
            itemBuilder: (context, index) =>
                buildItem2(context, snapshot.data?.docs[index]),
            itemCount: snapshot.data?.docs.length,
            controller: listScrollController,
          );
        } else {
          return Container(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.transparent),
            ),
          );
        }
      },
    );
  }

  takipcileriGetirme() {
    return StreamBuilder<QuerySnapshot>(
      stream: takipciRef
          .doc(anlikKullanici!.id)
          .collection("takipciler")
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: EdgeInsets.all(10.0),
            itemBuilder: (context, index) =>
                buildItem(context, snapshot.data?.docs[index]),
            itemCount: snapshot.data?.docs.length,
            controller: listScrollController,
          );
        } else {
          return Container(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.transparent),
            ),
          );
        }
      },
    );
  }

  void onItemMenuPress(Choice choice) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => GirisEkran()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Mesajlar',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GirisEkran()),
            );
          },
        ),
      ),
      body: textDuzenlemeKontrol!.text.isEmpty
          ? SafeArea(
              child: ListView(
                children: [
                  aramaCubugu(),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(
                        top: 25, right: 30, left: 30, bottom: 30),
                    child: Column(
                      children: [
                        Container(
                          height: 500,
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    offset: Offset(0, 10),
                                    blurRadius: 10,
                                    color: Colors.grey)
                              ],
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white),
                          child: ListView(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(25),
                                child: Text(
                                  'Sohbet Geçmişi',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              sohbetttgetir(),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          height: 500,
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    offset: Offset(0, 10),
                                    blurRadius: 10,
                                    color: Colors.grey)
                              ],
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white),
                          child: ListView(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(25),
                                child: Text(
                                  'Takip Edilenler',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              tEdilenleriGetirme(),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          height: 500,
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    offset: Offset(0, 10),
                                    blurRadius: 10,
                                    color: Colors.grey)
                              ],
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white),
                          child: ListView(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(25),
                                child: Text(
                                  'Takipçiler',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              takipcileriGetirme(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : ListView(
              children: [
                aramaCubugu(),
                kullanicilariGosterme<Widget>(),
              ],
            ),
    );
  }

  checkRead() async {}

  Widget buildItem(BuildContext context, DocumentSnapshot? document) {
    if (document != null) {
      tEdilen userChat = tEdilen.fromDocument(document);
      if (id.hashCode <= userChat.id.hashCode) {
        groupChatId = '$id-${userChat.id}';
      } else {
        groupChatId = '${userChat.id}-$id';
      }
      if (userChat.id == anlikKullanici!.id) {
        return Container(
          color: Colors.white,
        );
      } else {
        return Container(
          child: TextButton(
            child: ListTile(
              dense: true,
              leading: Container(
                height: 50,
                width: 50,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: new BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            offset: Offset(0, 10),
                            blurRadius: 6,
                            color: Colors.grey.shade300)
                      ],
                      image: DecorationImage(
                          fit: BoxFit.cover, image: NetworkImage(userChat.url)),
                    ),
                  ),
                ),
              ),
              title: Text(
                userChat.profileName,
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                userChat.username,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 13.0,
                ),
              ),
              trailing: Icon(
                Icons.message,
                size: 35,
                color: Colors.deepOrange[100],
              ),
            ),
            onPressed: () async {
              QuerySnapshot snapshot1 = await messageRef
                  .doc(groupChatId)
                  .collection(groupChatId)
                  .where("idFrom", isEqualTo: userChat.id)
                  .get();
              List<Mesajlar> kullaniciress = snapshot1.docs
                  .map((doc) => Mesajlar.fromDocument(doc))
                  .toList();
              for (var doc in kullaniciress) {
                if (doc.idFrom == userChat.id) {
                  var documentReference = FirebaseFirestore.instance
                      .collection('messages')
                      .doc(groupChatId)
                      .collection(groupChatId)
                      .doc(doc.messageID);

                  FirebaseFirestore.instance
                      .runTransaction((transaction) async {
                    transaction.update(
                      documentReference,
                      {
                        'isRead': true,

                      },
                    );
                  });
                }
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Chat(
                    tikladi: tikladi = true,
                    receiverUsername: userChat.username,
                    receiverId: userChat.id,
                    receiverAvatar: userChat.url,
                  ),
                ),
              );
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
              shape: MaterialStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
          ),
          margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
        );
      }
    } else {
      return SizedBox.shrink();
    }
  }

  Widget buildItem2(BuildContext context, DocumentSnapshot? document) {
    if (document != null) {
      Sohbet userChat = Sohbet.fromDocument(document);
      if (id.hashCode <= userChat.id.hashCode) {
        groupChatId = '$id-${userChat.id}';
      } else {
        groupChatId = '${userChat.id}-$id';
      }
      DateTime dateTime = document.get('timestamp').toDate();
      return Container(
        child: TextButton(
          child: ListTile(
            dense: true,
            leading: Container(
              height: 50,
              width: 50,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: new BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          offset: Offset(0, 10),
                          blurRadius: 6,
                          color: Colors.grey.shade300)
                    ],
                    image: DecorationImage(
                        fit: BoxFit.cover, image: NetworkImage(userChat.url)),
                  ),
                ),
              ),
            ),
            title: Text(
              userChat.profileName,
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  userChat.username,
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    color: Colors.black87,
                    fontSize: 13.0,
                  ),
                ),
                Text(
                  "Last Spoke : ${DateFormat('dd MMM kk:mm').format(dateTime)}",
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12.0,
                      fontStyle: FontStyle.italic),
                ),
                Text(
                  "Last Message : ${userChat.lastContent}",
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13.0,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          onPressed: () async {
            QuerySnapshot snapshot1 = await messageRef
                .doc(groupChatId)
                .collection(groupChatId)
                .where("idFrom", isEqualTo: userChat.id)
                .get();
            List<Mesajlar> kullaniciress = snapshot1.docs
                .map((doc) => Mesajlar.fromDocument(doc))
                .toList();
            for (var doc in kullaniciress) {
              if (doc.idFrom == userChat.id) {
                var documentReference = FirebaseFirestore.instance
                    .collection('messages')
                    .doc(groupChatId)
                    .collection(groupChatId)
                    .doc(doc.messageID);

                FirebaseFirestore.instance.runTransaction((transaction) async {
                  transaction.update(
                    documentReference,
                    {
                      'isRead': true,
                    },
                  );
                });
              }
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Chat(
                  tikladi: tikladi = true,
                  receiverUsername: userChat.username,
                  receiverId: userChat.id,
                  receiverAvatar: userChat.url,
                ),
              ),
            );
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
            shape: MaterialStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}

class Choice {
  const Choice({required this.title, required this.icon});

  final String title;
  final IconData icon;
}

class KullaniciSonuc extends StatelessWidget {
  final Kullanici? herbirKullanici;
  KullaniciSonuc(this.herbirKullanici);
  String id = anlikKullanici!.id;
  String groupChatId = "";
  bool tikladi = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () =>
                sendUserToChatPage(context, kullaniciProfil: herbirKullanici),
            child: ListTile(
              leading: Container(
                height: 50,
                width: 50,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: new BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                            offset: Offset(0, 10),
                            blurRadius: 10,
                            color: Colors.grey)
                      ],
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(herbirKullanici!.url)),
                    ),
                  ),
                ),
              ),
              title: Text(
                herbirKullanici!.profileName,
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                herbirKullanici!.username,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 13.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  sendUserToChatPage(
    context, {
    required Kullanici? kullaniciProfil,
  }) async {
    if (id.hashCode <= kullaniciProfil!.id.hashCode) {
      groupChatId = '$id-${kullaniciProfil.id}';
    } else {
      groupChatId = '${kullaniciProfil.id}-$id';
    }

    QuerySnapshot snapshot1 = await messageRef
        .doc(groupChatId)
        .collection(groupChatId)
        .where("idFrom", isEqualTo: kullaniciProfil.id)
        .get();
    List<Mesajlar> kullaniciress =
        snapshot1.docs.map((doc) => Mesajlar.fromDocument(doc)).toList();
    for (var doc in kullaniciress) {
      if (doc.idFrom == kullaniciProfil.id) {
        var documentReference = FirebaseFirestore.instance
            .collection('messages')
            .doc(groupChatId)
            .collection(groupChatId)
            .doc(doc.messageID);

        FirebaseFirestore.instance.runTransaction((transaction) async {
          transaction.update(
            documentReference,
            {
              'isRead': true,
            },
          );
        });
      }
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Chat(
                  tikladi: tikladi = true,
                  receiverUsername: kullaniciProfil.username,
                  receiverId: kullaniciProfil.id,
                  receiverAvatar: kullaniciProfil.url,
                )));
  }
}
