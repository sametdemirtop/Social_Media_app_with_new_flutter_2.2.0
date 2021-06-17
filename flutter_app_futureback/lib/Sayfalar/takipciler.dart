import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_futureback/Sayfalar/AnaSayfa.dart';
import 'package:flutter_app_futureback/Sayfalar/aramaSayfasi.dart';
import 'package:flutter_app_futureback/model/Kullanici.dart';
import 'package:flutter_app_futureback/widgets/baslik.dart';
import 'package:flutter_app_futureback/widgets/progress.dart';

// ignore: camel_case_types
class takipciler extends StatefulWidget {
  final String kullaniciprofilID;
  final String anlikKullaniciID;
  takipciler({this.kullaniciprofilID, this.anlikKullaniciID});
  @override
  _takipcilerState createState() => _takipcilerState();
}

// ignore: camel_case_types
class _takipcilerState extends State<takipciler> {
  List<takipci> tumTakipciler = [];
  void initState() {
    super.initState();
    profilKontrol();
  }

  profilKontrol() {
    bool kendiProfilimi = widget.anlikKullaniciID == widget.kullaniciprofilID;
    if (kendiProfilimi) {
      return takipcileriGetirAnlik();
    } else {
      return takipcileriGetirKullanici();
    }
  }

  takipcileriGetirAnlik() async {
    QuerySnapshot snapshot = await takipciRef.doc(widget.anlikKullaniciID).collection("takipciler").get();

    List<takipci> kullanicires1 = snapshot.docs.map((doc) => takipci.fromDocument(doc.data())).toList();
    setState(() {
      this.tumTakipciler = kullanicires1;
    });
  }

  takipcileriGetirKullanici() async {
    QuerySnapshot snapshot = await takipciRef.doc(widget.kullaniciprofilID).collection("takipciler").get();

    List<takipci> kullanicires1 = snapshot.docs.map((doc) => takipci.fromDocument(doc.data())).toList();
    setState(() {
      this.tumTakipciler = kullanicires1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: kullaniciRef.get(),
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            return circularProgress();
          }
          List<KullaniciSonuc> kullaniciAramaSonucu = [];
          dataSnapshot.data.docs.forEach((documents) {
            Kullanici herbirKullanici = Kullanici.fromDocument(documents.data());
            for (var doc in tumTakipciler) {
              if (doc.id == herbirKullanici.id) {
                KullaniciSonuc userResult = KullaniciSonuc(herbirKullanici);
                kullaniciAramaSonucu.add(userResult);
              }
            }
          });
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: baslik(context, strBaslik: "Takipçiler"),
            body: RefreshIndicator(
              color: Colors.black,
              child: ListView(
                children: kullaniciAramaSonucu,
              ),
              onRefresh: () {
                return profilKontrol();
              },
            ),
          );
        });
  }
}

// ignore: camel_case_types
class takipci {
  final String id;

  takipci({this.id});

  factory takipci.fromDocument(Map<String, dynamic> doc) {
    return takipci(
      id: doc['id'],
    );
  }
}
