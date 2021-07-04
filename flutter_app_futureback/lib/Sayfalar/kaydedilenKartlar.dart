import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_futureback/Sayfalar/profilSayfasi.dart';
import 'package:flutter_app_futureback/widgets/baslik.dart';
import 'package:flutter_app_futureback/widgets/gonderi.dart';
import 'package:flutter_app_futureback/widgets/progress.dart';

import 'AnaSayfa.dart';

class kaydedilenKartlar extends StatefulWidget {
  final String? kullaniciID;
  kaydedilenKartlar({
    required this.kullaniciID,
  });
  @override
  _kaydedilenKartlarState createState() => _kaydedilenKartlarState();
}

class _kaydedilenKartlarState extends State<kaydedilenKartlar> {
  List<kart> tumKartlar = [];

  @override
  void initState() {
    super.initState();
    kartlariGetir();
  }

  kartlariGetir() async {
    QuerySnapshot<Map<String, dynamic>> snapshot1 = await kartlarRef.doc(widget.kullaniciID).collection("Kaydedilen Kartlar").get();
    List<kart> kullanicires = snapshot1.docs.map((doc) => kart.fromDocument(doc.data())).toList();
    setState(() {
      this.tumKartlar = kullanicires;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: akisRef.get(),
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            return circularProgress();
          }
          List<Gonderiler> tumAkisKartlari = [];
          dataSnapshot.data!.docs.forEach((element) {
            Gonderiler gonderi = Gonderiler.fromDocument(element);
            for (var doc in tumKartlar) {
              if (gonderi.postID == doc.postID) {
                tumAkisKartlari.add(gonderi);
              }
            }
          });
          return Scaffold(
            backgroundColor: Colors.grey.shade100,
            appBar: baslik(context, strBaslik: "Kaydedilen Kartlar"),
            body: RefreshIndicator(
                color: Colors.black,
                child: ListView(
                  children: tumAkisKartlari,
                ),
                onRefresh: () {
                  return kartlariGetir();
                }),
          );
        });
  }

  onUserTap(String userId, String postId) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => profilSayfasi(kullaniciprofilID: userId, postID: postId)));
  }
}

class kart {
  final String postID;
  final String ownerID;
  final String username;

  kart({
    required this.postID,
    required this.username,
    required this.ownerID,
  });

  factory kart.fromDocument(Map<String, dynamic> doc) {
    return kart(
      postID: doc['postID'],
      ownerID: doc['ownerID'],
      username: doc['username'],
    );
  }
}
