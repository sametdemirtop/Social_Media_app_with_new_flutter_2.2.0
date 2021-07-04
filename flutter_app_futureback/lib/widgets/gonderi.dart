import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_futureback/Sayfalar/AnaSayfa.dart';
import 'package:flutter_app_futureback/Sayfalar/profilSayfasi.dart';
import 'package:flutter_app_futureback/Sayfalar/yorumSayfasi.dart';
import 'package:flutter_app_futureback/model/Kullanici.dart';

import 'progress.dart';

bool? isLiked;
bool? kaydedildimi;

// ignore: must_be_immutable
class Gonderiler extends StatefulWidget {
  final String? postID;
  final String? ownerID;
  final likes;
  final String? username;
  final String? description;
  final String? location;
  final String? url;
  final kaydedilenler;

  bool yuklenme = false;

  Gonderiler(
      {this.postID,
      this.ownerID,
      this.likes,
      this.username,
      this.description,
      this.location,
      this.url,
      this.kaydedilenler});
  factory Gonderiler.fromDocument(DocumentSnapshot doc) {
    return Gonderiler(
      postID: doc['postID'],
      ownerID: doc['ownerID'],
      likes: doc['likes'],
      username: doc['username'],
      description: doc['description'],
      location: doc['location'],
      url: doc['url'],
      kaydedilenler: doc['kaydedilenler'],
    );
  }
  int toplamBegeniSayisi(likes) {
    if (likes == null) {
      return 0;
    }
    int sayac = 0;
    likes.values.forEach((herbirDeger) {
      if (herbirDeger == true) {
        sayac = sayac + 1;
      }
    });
    return sayac;
  }

  @override
  _GonderilerState createState() => _GonderilerState(
      postID: this.postID!,
      ownerID: this.ownerID!,
      likes: this.likes,
      username: this.username!,
      description: this.description!,
      location: this.location!,
      url: this.url!,
      likeCount: toplamBegeniSayisi(this.likes),
      kaydedilenler: this.kaydedilenler);
}

class _GonderilerState extends State<Gonderiler> {
  final String? postID;
  final String? ownerID;
  Map? likes;
  final String? username;
  final String? description;
  final String? location;
  final String? url;
  int? likeCount;
  bool? showHeart = false;
  final String? onlineUserID = anlikKullanici!.id;
  List<Gonderiler>? gonderiListesi;
  Map? kaydedilenler;

  int? gonderiHesapla;

  _GonderilerState(
      {this.postID,
      this.ownerID,
      this.likes,
      this.username,
      this.description,
      this.location,
      this.url,
      this.likeCount,
      this.kaydedilenler});
  @override
  Widget build(BuildContext context) {
    isLiked = (likes![anlikKullanici!.id.toString()] == true);
    kaydedildimi = (kaydedilenler![anlikKullanici!.id.toString()] == true);
    return Padding(
      padding: EdgeInsets.only(top: 10, right: 20, left: 20, bottom: 20),
      child: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(offset: Offset(0, 10), blurRadius: 10, color: Colors.grey)
        ], borderRadius: BorderRadius.circular(20), color: Colors.white),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            gonderiBaslikOlustur(),
            gonderiFotografiOlusturma(),
            gonderiAltBilgileri(),
          ],
        ),
      ),
    );
  }

  gonderiBaslikOlustur() {
    return FutureBuilder<DocumentSnapshot>(
        future: kullaniciRef.doc(ownerID).get(),
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            return circularProgress();
          }
          Kullanici kullanici1 = Kullanici.fromDocument(dataSnapshot.data!);
          bool isPostOwner = onlineUserID == ownerID;
          return ListTile(
            leading: GestureDetector(
              onTap: () =>
                  kullaniciProfiliGoster(context, kullaniciProfilID: ownerID),
              child: Container(
                height: 45,
                width: 45,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: new BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(kullanici1.url)),
                    ),
                  ),
                ),
              ),
            ),
            title: GestureDetector(
              onTap: () => kullaniciProfiliGoster(context,
                  kullaniciProfilID: kullanici1.id),
              child: Text(
                kullanici1.username,
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            subtitle: Text(
              location!,
              style: TextStyle(color: Colors.black),
            ),
            trailing: isPostOwner
                ? IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      gonderiSilmeKontrolu(context);
                    },
                  )
                : Text(""),
          );
        });
  }

  gonderiSilmeKontrolu(BuildContext mcontext) {
    return showDialog(
        context: mcontext,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              "Silme İşlemi gerçekleştirilsin mi ?",
              style: TextStyle(color: Colors.black),
            ),
            children: [
              SimpleDialogOption(
                child: Text("Sil",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                onPressed: () {
                  kullaniciGonderiSilme();
                  Navigator.pop(context);
                },
              ),
              SimpleDialogOption(
                child: Text("Çık",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  kullaniciGonderiSilme() async {
    await gonderiRef
        .doc(ownerID)
        .collection("kullaniciGonderi")
        .doc(postID)
        .get()
        .then((value) async {
      if (value.exists) {
        value.reference.delete();
      }
      Navigator.pop(context);
      setState(() {});
    });
    FirebaseStorage.instance.ref().child("post_$postID.jpg").delete();
    QuerySnapshot querySnapshot = await bildirimRef
        .doc(ownerID)
        .collection("bildirimler")
        .where("postID", isEqualTo: postID)
        .get();
    querySnapshot.docs.forEach((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });
    QuerySnapshot commentquerySnapshot =
        await yorumRef.doc(postID).collection("yorumlar").get();
    commentquerySnapshot.docs.forEach((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });
    QuerySnapshot streamSnapshot =
        await akisRef.where("postID", isEqualTo: postID).get();
    streamSnapshot.docs.forEach((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });
  }

  gonderiFotografiOlusturma() {
    return InteractiveViewer(
      minScale: 0.2,
      child: Stack(
        children: [
          Image.network(
            url!,
          ),
          showHeart!
              ? Icon(
                  Icons.favorite,
                  size: 140,
                  color: Colors.deepOrange[200],
                )
              : Text(""),
        ],
      ),
    );
  }

  begeniSil() {
    bool isNotPostOwner = onlineUserID != ownerID;
    if (isNotPostOwner) {
      bildirimRef
          .doc(ownerID)
          .collection("bildirimler")
          .doc(postID)
          .get()
          .then((begeni) => {
                if (begeni.exists)
                  {
                    begeni.reference.delete(),
                  }
              });
    }
  }

  begeniEkle() {
    bool isNotPostOwner = onlineUserID != ownerID;
    if (isNotPostOwner) {
      bildirimRef.doc(ownerID).collection("bildirimler").doc(postID).set({
        "type": 'like',
        "username": anlikKullanici!.username,
        "userID": anlikKullanici!.id,
        "timestamp": timestamp,
        "url": url,
        "postID": postID,
        "userProfileImg": anlikKullanici!.url,
        "commentData": "",
        "ownerID": ownerID,
      });
    }
  }

  kullaniciGonderiBegeniKontrolu() {
    var kullaniciID = anlikKullanici!.id;
    bool _liked = (likes![kullaniciID] == true);
    if (_liked) {
      gonderiRef
          .doc(ownerID)
          .collection("kullaniciGonderi")
          .doc(postID)
          .update({"likes.$kullaniciID": false});
      akisRef.doc(postID).update({"likes.$kullaniciID": false});
      begeniSil();
      setState(() {
        likeCount = likeCount! - 1;
        isLiked = false;
        likes![kullaniciID] = false;
      });
    } else if (!_liked) {
      gonderiRef
          .doc(ownerID)
          .collection("kullaniciGonderi")
          .doc(postID)
          .update({"likes.$kullaniciID": true});
      akisRef.doc(postID).update({"likes.$kullaniciID": true});
      begeniEkle();
      setState(() {
        likeCount = likeCount! + 1;
        isLiked = true;
        likes![kullaniciID] = true;
        showHeart = true;
        Timer(Duration(milliseconds: 800), () {
          setState(() {
            showHeart = false;
          });
        });
      });
    }
  }

  kaydetmeSil() {
    bool isNotPostOwner = onlineUserID != ownerID;
    if (isNotPostOwner) {
      bildirimRef
          .doc(ownerID)
          .collection("bildirimler")
          .doc(onlineUserID! + postID!)
          .get()
          .then((kaydetme) => {
                if (kaydetme.exists)
                  {
                    kaydetme.reference.delete(),
                  }
              });
    }
  }

  kaydetmeEkle() {
    bool isNotPostOwner = onlineUserID != ownerID;
    if (isNotPostOwner) {
      bildirimRef
          .doc(ownerID)
          .collection("bildirimler")
          .doc(onlineUserID! + postID!)
          .set({
        "type": 'kaydetme',
        "username": anlikKullanici!.username,
        "userID": anlikKullanici!.id,
        "timestamp": timestamp,
        "url": url,
        "postID": postID,
        "userProfileImg": anlikKullanici!.url,
        "commentData": "kaydetme",
        "ownerID": ownerID,
      });
    }
  }

  kullaniciKartKaydetmeKontrolu() async {
    var kullaniciID = anlikKullanici!.id;
    bool _kayit = (kaydedilenler![kullaniciID] == true);
    if (_kayit) {
      gonderiRef
          .doc(ownerID)
          .collection("kullaniciGonderi")
          .doc(postID)
          .update({"kaydedilenler.$kullaniciID": false});
      akisRef.doc(postID).update({"kaydedilenler.$kullaniciID": false});
      kartlarRef
          .doc(anlikKullanici!.id)
          .collection("Kaydedilen Kartlar")
          .doc(postID)
          .get()
          .then((kaydetme) => {
                if (kaydetme.exists)
                  {
                    kaydetme.reference.delete(),
                  }
              });
      kaydetmeSil();
      setState(() {
        kaydedildimi = false;
        kaydedilenler![kullaniciID] = false;
      });
    } else if (!_kayit) {
      gonderiRef
          .doc(ownerID)
          .collection("kullaniciGonderi")
          .doc(postID)
          .update({"kaydedilenler.$kullaniciID": true});
      akisRef.doc(postID).update({"kaydedilenler.$kullaniciID": true});
      kaydetmeEkle();
      kartKaydet();
      setState(() {
        kaydedildimi = true;
        kaydedilenler![kullaniciID] = true;
      });
    }
  }

  gonderiAltBilgileri() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 40.0, left: 20),
            ),
            GestureDetector(
              onTap: () {
                kullaniciGonderiBegeniKontrolu();
              },
              child: Icon(
                isLiked! ? Icons.favorite : Icons.favorite_border,
                size: 28,
                color: Colors.deepOrange[200],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 20),
            ),
            GestureDetector(
              onTap: () {
                yorumlariGoster(context,
                    postID: postID, ownerID: ownerID, url: url);
              },
              child: Icon(
                Icons.messenger_outline_rounded,
                size: 28,
                color: Colors.black54,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 190),
            ),
            GestureDetector(
              onTap: () {
                if (kaydedildimi == false) {
                  SnackBar snackBar =
                      SnackBar(content: Text("Kart Kaydedildi"));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
                kullaniciKartKaydetmeKontrolu();
                kartKaydet();
              },
              child: Icon(
                kaydedildimi == true
                    ? Icons.bookmarks
                    : Icons.bookmarks_outlined,
                size: 28,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$likeCount beğenme",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(left: 20),
              child: GestureDetector(
                  onTap: () => kullaniciProfiliGoster(context,
                      kullaniciProfilID: ownerID),
                  child: Text("$username",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold))),
            ),
            Expanded(
              child: Text(
                " " + description!,
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        FutureBuilder<QuerySnapshot>(
          future: yorumRef
              .doc(postID)
              .collection("yorumlar")
              .orderBy("timestamp", descending: false)
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            }
            List<yorum> yorumlar = [];
            snapshot.data!.docs.forEach((document) {
              yorumlar.add(yorum.fromDocument(document));
            });
            return yorumlar.length > 0
                ? GestureDetector(
                    onTap: () {
                      yorumlariGoster(context,
                          postID: postID, ownerID: ownerID, url: url);
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 20),
                          child: Text(
                            yorumlar.length.toString() + " " + "yorumu gör",
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Text("");
          },
        ),
      ],
    );
  }

  yorumlariGoster(BuildContext context,
      {String? postID, String? url, String? ownerID}) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return yorumSayfasi(postID: postID, postOwnerID: ownerID, postUrl: url);
    }));
  }

  kartKaydet() async {
    await kartlarRef
        .doc(anlikKullanici!.id)
        .collection("Kaydedilen Kartlar")
        .doc(postID)
        .set({
      "postID": postID,
      "ownerID": ownerID,
      "username": username,
    });
  }

  kullaniciProfiliGoster(BuildContext context, {String? kullaniciProfilID}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => profilSayfasi(
                  kullaniciprofilID: kullaniciProfilID,
                  postID: '',
                )));
  }
}
