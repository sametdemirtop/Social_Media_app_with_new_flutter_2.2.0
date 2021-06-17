import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_futureback/widgets/Progress.dart';
import 'package:flutter_app_futureback/widgets/gonderi.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'AnaSayfa.dart';

// ignore: must_be_immutable, camel_case_types
class yorumSayfasi extends StatefulWidget {
  final String postID;
  final String postOwnerID;
  final String postUrl;
  yorumSayfasi({this.postID, this.postOwnerID, this.postUrl});

  TextEditingController yorumduzeltmeKontrolu = TextEditingController();
  yorumlariGoster() => createState().yorumlariGoster();

  @override
  _yorumSayfasiState createState() => _yorumSayfasiState(postID: postID, postOwnerID: postOwnerID, postUrl: postUrl);
}

// ignore: camel_case_types
class _yorumSayfasiState extends State<yorumSayfasi> {
  final String postID;
  final String postOwnerID;
  final String postUrl;
  _yorumSayfasiState({this.postID, this.postOwnerID, this.postUrl});

  var formKey = GlobalKey<FormState>();

  // ignore: missing_return
  yorumlariGoster() {
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: yorumRef.doc(postID).collection("yorumlar").orderBy("timestamp", descending: false).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<yorum> yorumlar = [];
          snapshot.data.docs.forEach((document) {
            yorumlar.add(yorum.fromDocument(document.data()));
          });
          return Container(
            color: Colors.white,
            child: ListView(
              children: yorumlar,
            ),
          );
        });
  }

  yorumlariKaydet() {
    yorumRef.doc(postID).collection("yorumlar").add({
      "username": anlikKullanici.username,
      "comment": widget.yorumduzeltmeKontrolu.text,
      "timestamp": DateTime.now(),
      "url": anlikKullanici.url,
      "userID": anlikKullanici.id,
    });
    bool isNotPostOwner = postOwnerID != anlikKullanici.id;
    if (isNotPostOwner) {
      bildirimRef.doc(postOwnerID).collection("bildirimler").add({
        "type": "comment",
        "commentData": widget.yorumduzeltmeKontrolu.text,
        "postID": postID,
        "userID": anlikKullanici.id,
        "username": anlikKullanici.username,
        "userProfileImg": anlikKullanici.url,
        "url": postUrl,
        "timestamp": timestamp,
      });
    }
    widget.yorumduzeltmeKontrolu.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Yorumlar",
          style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: yorumlariGoster(),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 85,
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                    color: Color(0x540000000),
                    spreadRadius: 4,
                    blurRadius: 7,
                  ),
                ], borderRadius: BorderRadius.circular(20), color: Colors.white),
                child: ListTile(
                  title: Row(
                    children: [
                      Padding(
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(anlikKullanici.url),
                        ),
                        padding: EdgeInsets.only(top: 20),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Form(
                          key: formKey,
                          child: TextFormField(
                            controller: widget.yorumduzeltmeKontrolu,
                            decoration: InputDecoration(
                              labelText: "Yorum yaz",
                              labelStyle: TextStyle(color: Colors.black54),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black54)),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black54)),
                            ),
                            style: TextStyle(color: Colors.black),
                            validator: (girilenDeger) {
                              if (girilenDeger.length > 0) {
                                return null;
                              } else
                                return "";
                            },
                            onSaved: (kaydedilecekDeger) {
                              widget.yorumduzeltmeKontrolu.text = kaydedilecekDeger;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: OutlinedButton(
                    onPressed: () {
                      if (formKey.currentState.validate()) {
                        formKey.currentState.save();
                        yorumlariKaydet();
                      }
                    },
                    child: Text(
                      "Gönder",
                      style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: camel_case_types
class yorum extends StatefulWidget {
  final String username;
  final String userID;
  final String url;
  final String comment;
  final Timestamp timestamp;
  yorum({
    this.username,
    this.userID,
    this.url,
    this.comment,
    this.timestamp,
  });
  factory yorum.fromDocument(Map<String, dynamic> doc) {
    return yorum(
      username: doc['username'],
      userID: doc['userID'],
      url: doc['url'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
    );
  }

  @override
  _yorumState createState() => _yorumState();
}

// ignore: camel_case_types
class _yorumState extends State<yorum> {
  var formKey = GlobalKey<FormState>();
  bool onay = false;

  yorumSil() async {
    List<Gonderiler> gonderis = [];
    QuerySnapshot<Map<String, dynamic>> ss = await akisRef.get();
    ss.docs.forEach((document) {
      gonderis.add(Gonderiler.fromDocument(document.data()));
    });
    for (var doc in gonderis) {
      QuerySnapshot<Map<String, dynamic>> commentquerySnapshot =
          await yorumRef.doc(doc.postID).collection("yorumlar").where("comment", isEqualTo: widget.comment).get();
      commentquerySnapshot.docs.forEach((document) async {
        yorum yorums = yorum.fromDocument(document.data());
        if (anlikKullanici.id == yorums.userID) {
          if (document.exists) {
            document.reference.delete();
            SnackBar snackBar = SnackBar(content: Text("Yorum Silindi.."));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
          QuerySnapshot<Map<String, dynamic>> qs =
              await bildirimRef.doc(doc.ownerID).collection("bildirimler").where("commentData", isEqualTo: widget.comment).get();
          qs.docs.forEach((document) {
            if (document.exists) {
              document.reference.delete();
            }
          });
        } else {
          SnackBar snackBar = SnackBar(content: Text("Başkasının yorumu silinemez"));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          setState(() {
            FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                future: yorumRef.doc(doc.postID).collection("yorumlar").orderBy("timestamp", descending: false).get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return circularProgress();
                  }
                  List<yorum> yorumlar = [];
                  snapshot.data.docs.forEach((document) {
                    yorumlar.add(yorum.fromDocument(document.data()));
                  });
                  return Container(
                    color: Colors.white,
                    child: ListView(
                      children: yorumlar,
                    ),
                  );
                });
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(7),
      child: Column(
        children: [
          Dismissible(
            onDismissed: (direct) async {
              yorumSil();
            },
            key: Key(UniqueKey().toString()),
            background: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20),
              color: Colors.red,
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            child: ListTile(
              title: Text(
                widget.username + " : " + widget.comment,
                style: TextStyle(fontSize: 15, color: Colors.black),
              ),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(widget.url),
              ),
              subtitle: Text(
                timeago.format(widget.timestamp.toDate()),
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
