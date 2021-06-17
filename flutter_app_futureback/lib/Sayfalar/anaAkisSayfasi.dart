import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_futureback/Sayfalar/AnaSayfa.dart';
import 'package:flutter_app_futureback/Sayfalar/takipEdilenler.dart';
import 'package:flutter_app_futureback/model/Kullanici.dart';
import 'package:flutter_app_futureback/widgets/baslik.dart';
import 'package:flutter_app_futureback/widgets/gonderi.dart';

class anaAkisSayfasi extends StatefulWidget {
  final Kullanici gAnlikKullanici;
  anaAkisSayfasi({this.gAnlikKullanici});
  @override
  _anaAkisSayfasiState createState() => _anaAkisSayfasiState();
}

class _anaAkisSayfasiState extends State<anaAkisSayfasi> with AutomaticKeepAliveClientMixin<anaAkisSayfasi> {
  List<tEdilen> takipEdilenKullanicilar = [];
  List<Gonderiler> tEdilenGonderiler = [];

  @override
  void initState() {
    takipEdilenKullanicilariGetir();
    super.initState();
  }

  tumGonderiler() async {
    QuerySnapshot myQuerySnapshot = await akisRef.where("ownerID", whereIn: takipEdilenKullanicilar.map((e) => e.id).toList()).get();
    List<Gonderiler> kullanicires = myQuerySnapshot.docs.map((e) => Gonderiler.fromDocument(e.data())).toList();
    setState(() {
      this.tEdilenGonderiler = kullanicires;
    });
  }

  takipEdilenKullanicilariGetir() async {
    QuerySnapshot snapshot1 = await takipEdilenRef.doc(anlikKullanici.id).collection("takipEdilenler").get();
    List<tEdilen> kullanicires = snapshot1.docs.map((doc) => tEdilen.fromDocument(doc.data())).toList();
    setState(() {
      this.takipEdilenKullanicilar = kullanicires;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: baslik(context, strBaslik: "Kartlar", geriButonuYokSay: true),
      body: RefreshIndicator(
          color: Colors.black,
          child: ListView(
            children: tEdilenGonderiler,
          ),
          onRefresh: () {
            return tumGonderiler();
          }),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
