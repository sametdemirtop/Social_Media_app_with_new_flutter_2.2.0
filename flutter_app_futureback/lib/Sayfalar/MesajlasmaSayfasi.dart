import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_futureback/Sayfalar/MessageHomePage.dart';
import 'package:flutter_app_futureback/model/Kullanici.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AnaSayfa.dart';
import 'FullImageWidget.dart';

class Chat extends StatelessWidget {
  final String receiverId;
  final String receiverUsername;
  final String receiverAvatar;

  Chat({
    required this.receiverId,
    required this.receiverAvatar,
    required this.receiverUsername,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () async {
              DocumentSnapshot ds =
                  await kullaniciRef.doc(anlikKullanici!.id).get();
              Kullanici k1 = Kullanici.fromDocument(ds);
              DocumentSnapshot ds1 =
                  await kullaniciRef.doc(k1.chattingWith).get();
              Kullanici k2 = Kullanici.fromDocument(ds1);
              sohbetRef
                  .doc(k2.id)
                  .collection("sohbetEdilenler")
                  .doc(anlikKullanici!.id)
                  .update({
                "isEntered": false,
              });

              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomeScreen(
                            currentUserId: anlikKullanici!.id,
                          )));
            }),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.black,
              backgroundImage: NetworkImage(receiverAvatar),
            ),
            SizedBox(
              width: 10,
            ),
            Text(receiverUsername,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 23,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
      ),
      body: ChatScreen(
        receiverId: receiverId,
        receiverUsername: receiverUsername,
        receiverAvatar: receiverAvatar,
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverAvatar;
  final String receiverUsername;

  ChatScreen(
      {required this.receiverId,
      required this.receiverAvatar,
      required this.receiverUsername});

  @override
  State createState() => ChatScreenState(
        receiverId: receiverId,
        receiverAvatar: receiverAvatar,
        receiverUsername: receiverUsername,
      );
}

class ChatScreenState extends State<ChatScreen> {
  ChatScreenState({
    required this.receiverId,
    required this.receiverAvatar,
    required this.receiverUsername,
  });

  String receiverId;

  String receiverAvatar;
  String receiverUsername;
  String? id = anlikKullanici!.id;

  String? messageID;

  List<QueryDocumentSnapshot> listMessage = new List.from([]);
  int _limit = 20;
  int _limitIncrement = 20;
  String groupChatId = "";
  SharedPreferences? prefs;

  File? imageFile;
  bool isLoading = false;
  bool isShowSticker = false;
  String imageUrl = "";

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  var formKey = GlobalKey<FormState>();

  _scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);
    listScrollController.addListener(_scrollListener);
    readLocal();
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  readLocal() async {
    if (id.hashCode <= receiverId.hashCode) {
      groupChatId = '$id-$receiverId';
    } else {
      groupChatId = '$receiverId-$id';
    }

    kullaniciRef.doc(id).update({'chattingWith': receiverId});
    setState(() {});
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile? pickedFile;

    pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      if (imageFile != null) {
        setState(() {
          isLoading = true;
        });
        uploadFile();
      }
    }
  }

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(imageFile!);

    try {
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  Future<void> onSendMessage(String content, int type) async {
    if (content.trim() != '') {
      textEditingController.clear();
      String time = DateTime.now().millisecondsSinceEpoch.toString();
      DocumentSnapshot ds = await kullaniciRef.doc(anlikKullanici!.id).get();
      Kullanici k1 = Kullanici.fromDocument(ds);
      DocumentSnapshot ds1 = await kullaniciRef.doc(k1.chattingWith).get();
      Kullanici k2 = Kullanici.fromDocument(ds1);

      var documentReference = FirebaseFirestore.instance
          .collection('messages')
          .doc(groupChatId)
          .collection(groupChatId)
          .doc(time);

      sohbetRef
          .doc(id)
          .collection("sohbetEdilenler")
          .doc(k2.id)
          .get()
          .then((value1) async {
        sohbetRef
            .doc(k2.id)
            .collection("sohbetEdilenler")
            .doc(id)
            .get()
            .then((value2) {
          if (value1.exists == true && value2.exists == true) {
            if (value1.get("isEntered") == false &&
                value2.get("isEntered") == true) {
              FirebaseFirestore.instance.runTransaction((transaction) async {
                transaction.set(
                  documentReference,
                  {
                    'messageID': time,
                    'idFrom': id,
                    'idTo': receiverId,
                    'timestamp': DateTime.now(),
                    'content': content,
                    'type': type,
                    'isRead': false,
                  },
                );
              });
              sohbetRef.doc(id).collection("sohbetEdilenler").doc(k2.id).set({
                "id": k2.id,
                "url": k2.url,
                "username": k2.username,
                "profileName": k2.profileName,
                "lastContent": content,
                "timestamp": DateTime.now(),
                "isEntered": false,
                "messageID": time,
              });
              sohbetRef.doc(k2.id).collection("sohbetEdilenler").doc(id).set({
                "id": id,
                "url": anlikKullanici!.url,
                "username": anlikKullanici!.username,
                "profileName": anlikKullanici!.profileName,
                "lastContent": content,
                "timestamp": DateTime.now(),
                "isEntered": true,
                "messageID": time,
              });
            } else if (value1.get("isEntered") == true &&
                value2.get("isEntered") == false) {
              FirebaseFirestore.instance.runTransaction((transaction) async {
                transaction.set(
                  documentReference,
                  {
                    'messageID': time,
                    'idFrom': id,
                    'idTo': receiverId,
                    'timestamp': DateTime.now(),
                    'content': content,
                    'type': type,
                    'isRead': false,
                  },
                );
              });
              sohbetRef.doc(id).collection("sohbetEdilenler").doc(k2.id).set({
                "id": k2.id,
                "url": k2.url,
                "username": k2.username,
                "profileName": k2.profileName,
                "lastContent": content,
                "timestamp": DateTime.now(),
                "isEntered": true,
                "messageID": time,
              });
              sohbetRef.doc(k2.id).collection("sohbetEdilenler").doc(id).set({
                "id": id,
                "url": anlikKullanici!.url,
                "username": anlikKullanici!.username,
                "profileName": anlikKullanici!.profileName,
                "lastContent": content,
                "timestamp": DateTime.now(),
                "isEntered": false,
                "messageID": time,
              });
            } else if (value1.get("isEntered") == true &&
                value2.get("isEntered") == true) {
              FirebaseFirestore.instance.runTransaction((transaction) async {
                transaction.set(
                  documentReference,
                  {
                    'messageID': time,
                    'idFrom': id,
                    'idTo': receiverId,
                    'timestamp': DateTime.now(),
                    'content': content,
                    'type': type,
                    'isRead': true,
                  },
                );
              });
              sohbetRef.doc(id).collection("sohbetEdilenler").doc(k2.id).set({
                "id": k2.id,
                "url": k2.url,
                "username": k2.username,
                "profileName": k2.profileName,
                "lastContent": content,
                "timestamp": DateTime.now(),
                "isEntered": true,
                "messageID": time,
              });
              sohbetRef.doc(k2.id).collection("sohbetEdilenler").doc(id).set({
                "id": id,
                "url": anlikKullanici!.url,
                "username": anlikKullanici!.username,
                "profileName": anlikKullanici!.profileName,
                "lastContent": content,
                "timestamp": DateTime.now(),
                "isEntered": true,
                "messageID": time,
              });
            } else if (value1.get("isEntered") == false &&
                value2.get("isEntered") == false) {
              sohbetRef.doc(id).collection("sohbetEdilenler").doc(k2.id).set({
                "id": k2.id,
                "url": k2.url,
                "username": k2.username,
                "profileName": k2.profileName,
                "lastContent": content,
                "timestamp": DateTime.now(),
                "isEntered": false,
                "messageID": time,
              });
              sohbetRef.doc(k2.id).collection("sohbetEdilenler").doc(id).set({
                "id": id,
                "url": anlikKullanici!.url,
                "username": anlikKullanici!.username,
                "profileName": anlikKullanici!.profileName,
                "lastContent": content,
                "timestamp": DateTime.now(),
                "isEntered": false,
                "messageID": time,
              });
            }
          } else {
            FirebaseFirestore.instance.runTransaction((transaction) async {
              transaction.set(
                documentReference,
                {
                  'messageID': time,
                  'idFrom': id,
                  'idTo': receiverId,
                  'timestamp': DateTime.now(),
                  'content': content,
                  'type': type,
                  'isRead': false,
                },
              );
            }).then((value) {
              if (k2.id == receiverId) {
                sohbetRef.doc(id).collection("sohbetEdilenler").doc(k2.id).set({
                  "id": k2.id,
                  "url": k2.url,
                  "username": k2.username,
                  "profileName": k2.profileName,
                  "lastContent": content,
                  "timestamp": DateTime.now(),
                  "isEntered": false,
                  "messageID": time,
                });
                sohbetRef.doc(k2.id).collection("sohbetEdilenler").doc(id).set({
                  "id": id,
                  "url": anlikKullanici!.url,
                  "username": anlikKullanici!.username,
                  "profileName": anlikKullanici!.profileName,
                  "lastContent": content,
                  "timestamp": DateTime.now(),
                  "isEntered": true,
                  "messageID": time,
                });
              } else {
                sohbetRef.doc(id).collection("sohbetEdilenler").doc(k2.id).set({
                  "id": k2.id,
                  "url": k2.url,
                  "username": k2.username,
                  "profileName": k2.profileName,
                  "lastContent": content,
                  "timestamp": DateTime.now(),
                  "isEntered": true,
                  "messageID": time,
                });
                sohbetRef.doc(k2.id).collection("sohbetEdilenler").doc(id).set({
                  "id": id,
                  "url": anlikKullanici!.url,
                  "username": anlikKullanici!.username,
                  "profileName": anlikKullanici!.profileName,
                  "lastContent": content,
                  "timestamp": DateTime.now(),
                  "isEntered": false,
                  "messageID": time,
                });
              }
            });
          }
        });
      });
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(
          timeInSecForIosWeb: 0,
          msg: 'Nothing to send',
          backgroundColor: Colors.black,
          textColor: Colors.red);
    }
  }

  Widget buildItem(int index, DocumentSnapshot? document) {
    if (document != null) {
      DateTime dateTime = document.get('timestamp').toDate();
      if (document.get('idFrom') == id) {
        return Column(
          children: [
            Row(
              children: <Widget>[
                document.get('type') == 0
                    // Text
                    ? Container(
                        child: Text(
                          document.get('content'),
                          style: TextStyle(color: Colors.black),
                        ),
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        width: 200.0,
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(8.0)),
                        margin: EdgeInsets.only(
                            bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                            right: 10.0),
                      )
                    : document.get('type') == 1
                        // Image
                        ? Container(
                            child: OutlinedButton(
                              child: Material(
                                child: Image.network(
                                  document.get("content"),
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8.0),
                                        ),
                                      ),
                                      width: 200.0,
                                      height: 200.0,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.black,
                                          value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null &&
                                                  loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, object, stackTrace) {
                                    return Material(
                                      child: Image.asset(
                                        'images/img_not_available.jpeg',
                                        width: 200.0,
                                        height: 200.0,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                    );
                                  },
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                clipBehavior: Clip.hardEdge,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FullPhoto(
                                      url: document.get('content'),
                                    ),
                                  ),
                                );
                              },
                              style: ButtonStyle(
                                  padding:
                                      MaterialStateProperty.all<EdgeInsets>(
                                          EdgeInsets.all(0))),
                            ),
                            margin: EdgeInsets.only(
                                bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                                right: 10.0),
                          )
                        // Sticker
                        : Container(
                            child: Image.asset(
                              'images/${document.get('content')}.gif',
                              width: 100.0,
                              height: 100.0,
                              fit: BoxFit.cover,
                            ),
                            margin: EdgeInsets.only(
                                bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                                right: 10.0),
                          ),
              ],
              mainAxisAlignment: MainAxisAlignment.end,
            ),
            Row(
              children: [
                isLastMessageRight(index)
                    ? Container(
                        child: Text(
                          DateFormat('dd MMM kk:mm').format(dateTime),
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12.0,
                              fontStyle: FontStyle.italic),
                        ),
                        margin: EdgeInsets.only(left: 270, bottom: 10.0),
                      )
                    : Container(
                        child: Text(
                          DateFormat('dd MMM kk:mm').format(dateTime),
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12.0,
                              fontStyle: FontStyle.italic),
                        ),
                        margin: EdgeInsets.only(left: 270, bottom: 5.0),
                      ),
                document.get('isRead') == true
                    ? Container(
                        child: Icon(
                          Icons.done_all,
                          color: Colors.blue,
                        ),
                        margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
                      )
                    : Container(
                        child: Icon(
                          Icons.done_all,
                          color: Colors.grey,
                        ),
                        margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
                      ),
              ],
            ),
          ],
        );
      } else {
        // Left (peer message)
        return Container(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  isLastMessageLeft(index)
                      ? Material(
                          child: Image.network(
                            receiverAvatar,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  value: loadingProgress.expectedTotalBytes !=
                                              null &&
                                          loadingProgress.expectedTotalBytes !=
                                              null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, object, stackTrace) {
                              return Icon(
                                Icons.account_circle,
                                size: 35,
                                color: Colors.grey,
                              );
                            },
                            width: 35,
                            height: 35,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(18.0),
                          ),
                          clipBehavior: Clip.hardEdge,
                        )
                      : Material(
                          child: Image.network(
                            receiverAvatar,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  value: loadingProgress.expectedTotalBytes !=
                                              null &&
                                          loadingProgress.expectedTotalBytes !=
                                              null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, object, stackTrace) {
                              return Icon(
                                Icons.account_circle,
                                size: 35,
                                color: Colors.grey,
                              );
                            },
                            width: 35,
                            height: 35,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(18.0),
                          ),
                          clipBehavior: Clip.hardEdge,
                        ),
                  document.get('type') == 0
                      ? Container(
                          child: Text(
                            document.get('content'),
                            style: TextStyle(color: Colors.white),
                          ),
                          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                          width: 200.0,
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8.0)),
                          margin: EdgeInsets.only(left: 10.0),
                        )
                      : document.get('type') == 1
                          ? Container(
                              child: TextButton(
                                child: Material(
                                  child: Image.network(
                                    document.get('content'),
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8.0),
                                          ),
                                        ),
                                        width: 200.0,
                                        height: 200.0,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.black,
                                            value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null &&
                                                    loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder:
                                        (context, object, stackTrace) =>
                                            Material(
                                      child: Image.asset(
                                        'images/img_not_available.jpeg',
                                        width: 200.0,
                                        height: 200.0,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                    ),
                                    width: 200.0,
                                    height: 200.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0)),
                                  clipBehavior: Clip.hardEdge,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => FullPhoto(
                                              url: document.get('content'))));
                                },
                                style: ButtonStyle(
                                    padding:
                                        MaterialStateProperty.all<EdgeInsets>(
                                            EdgeInsets.all(0))),
                              ),
                              margin: EdgeInsets.only(left: 10.0),
                            )
                          : Container(
                              child: Image.asset(
                                'images/${document.get('content')}.gif',
                                width: 100.0,
                                height: 100.0,
                                fit: BoxFit.cover,
                              ),
                              margin: EdgeInsets.only(
                                  bottom:
                                      isLastMessageRight(index) ? 20.0 : 10.0,
                                  right: 10.0),
                            ),
                ],
              ),

              // Time

              isLastMessageLeft(index)
                  ? Container(
                      child: Text(
                        DateFormat('dd MMM kk:mm').format(dateTime),
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12.0,
                            fontStyle: FontStyle.italic),
                      ),
                      margin:
                          EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
                    )
                  : Container(
                      child: Text(
                        DateFormat('dd MMM kk:mm').format(dateTime),
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12.0,
                            fontStyle: FontStyle.italic),
                      ),
                      margin:
                          EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
                    ),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
          margin: EdgeInsets.only(bottom: 10.0),
        );
      }
    } else {
      return SizedBox.shrink();
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 && listMessage[index - 1].get('idFrom') == id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 && listMessage[index - 1].get('idFrom') != id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      kullaniciRef.doc(id).update({'chattingWith': ""});
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: [
          Column(
            children: [
              buildListMessage(),
              buildInput(),
            ],
          ),
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? const CircularProgressIndicator(
              backgroundColor: Colors.white,
            )
          : Container(),
    );
  }

  Widget buildInput() {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(offset: Offset(0, 10), blurRadius: 10, color: Colors.grey)
        ], borderRadius: BorderRadius.circular(30), color: Colors.black),
        height: 50.0,
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.add),
                onPressed: getImage,
                color: Colors.white,
              ),
              SizedBox(
                width: 30,
              ),
              // Edit text
              Flexible(
                child: Container(
                  child: TextFormField(
                    key: formKey,
                    style: TextStyle(color: Colors.white, fontSize: 15.0),
                    controller: textEditingController,
                    decoration: InputDecoration.collapsed(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    focusNode: focusNode,
                  ),
                ),
              ),

              // Button send message
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text, 0),
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId.isNotEmpty
          ? StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .doc(groupChatId)
                  .collection(groupChatId)
                  .orderBy('timestamp', descending: true)
                  .limit(_limit)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  listMessage.addAll(snapshot.data!.docs);
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) =>
                        buildItem(index, snapshot.data?.docs[index]),
                    itemCount: snapshot.data?.docs.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  );
                }
              },
            )
          : Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            ),
    );
  }
}
