import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_futureback/Sayfalar/AnaSayfa.dart';
import 'package:flutter_app_futureback/Sayfalar/aramaSayfasi.dart';
import 'package:flutter_app_futureback/model/Kullanici.dart';
import 'package:flutter_app_futureback/widgets/baslik.dart';
import 'package:flutter_app_futureback/widgets/progress.dart';

// ignore: camel_case_types
class takipEdilenler extends StatefulWidget {
  final String? kullaniciprofilID;
  final String? anlikKullaniciID;
  takipEdilenler({this.kullaniciprofilID, this.anlikKullaniciID});
  @override
  _takipEdilenlerState createState() => _takipEdilenlerState();
}

// ignore: camel_case_types
class _takipEdilenlerState extends State<takipEdilenler> {
  List<tEdilen>? takipEdilenKullanicilar = [];
  @override
  void initState() {
    super.initState();
    profilKontrol();
  }

  profilKontrol() {
    bool kendiProfilimi = widget.anlikKullaniciID == widget.kullaniciprofilID;
    if (kendiProfilimi) {
      return takipEdilenKullanicilarAnlik();
    } else {
      return takipEdilenKullanicilarKullanici();
    }
  }

  takipEdilenKullanicilarAnlik() async {
    QuerySnapshot snapshot = await takipEdilenRef
        .doc(widget.anlikKullaniciID)
        .collection("takipEdilenler")
        .get();

    List<tEdilen> kullanicires =
        snapshot.docs.map((doc) => tEdilen.fromDocument(doc)).toList();

    setState(() {
      this.takipEdilenKullanicilar = kullanicires;
    });
  }

  takipEdilenKullanicilarKullanici() async {
    QuerySnapshot snapshot = await takipEdilenRef
        .doc(widget.kullaniciprofilID)
        .collection("takipEdilenler")
        .get();

    List<tEdilen>? kullanicires =
        snapshot.docs.map((doc) => tEdilen.fromDocument(doc)).toList();
    setState(() {
      this.takipEdilenKullanicilar = kullanicires;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: kullaniciRef.get(),
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            return circularProgress();
          }
          List<KullaniciSonuc>? kullaniciAramaSonucu = [];
          dataSnapshot.data!.docs.forEach((documents) {
            Kullanici? herbirKullanici = Kullanici.fromDocument(documents);
            for (var doc in takipEdilenKullanicilar!) {
              if (doc.id == herbirKullanici.id) {
                KullaniciSonuc? userResult = KullaniciSonuc(herbirKullanici);
                kullaniciAramaSonucu.add(userResult);
              }
            }
          });
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: baslik(context, strBaslik: "Takip Edilenler"),
            body: RefreshIndicator(
                color: Colors.black,
                child: ListView(
                  children: kullaniciAramaSonucu,
                ),
                onRefresh: () {
                  return profilKontrol();
                }),
          );
        });
  }
}

// ignore: camel_case_types
class tEdilen {
  final String id;

  tEdilen({required this.id});

  factory tEdilen.fromDocument(DocumentSnapshot doc) {
    return tEdilen(
      id: doc['id'],
    );
  }
}
