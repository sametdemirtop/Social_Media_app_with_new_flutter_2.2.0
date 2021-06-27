import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_futureback/Sayfalar/AnaSayfa.dart';
import 'package:flutter_app_futureback/Sayfalar/takipEdilenler.dart';
import 'package:flutter_app_futureback/model/Kullanici.dart';
import 'package:flutter_app_futureback/widgets/baslik.dart';
import 'package:flutter_app_futureback/widgets/gonderi.dart';

// ignore: camel_case_types
class anaAkisSayfasi extends StatefulWidget {
  final Kullanici? gAnlikKullanici;
  anaAkisSayfasi({
    required this.gAnlikKullanici,
  });

  @override
  _anaAkisSayfasiState createState() => _anaAkisSayfasiState();
}

// ignore: camel_case_types
class _anaAkisSayfasiState extends State<anaAkisSayfasi>
    with AutomaticKeepAliveClientMixin<anaAkisSayfasi> {
  List<Gonderiler> tEdilenGonderiler = [];
  List<tEdilen>? takipEdilenKullanicilar = [];
  bool? isEmpty;
  @override
  void initState() {
    tumGonderiler();
    super.initState();
  }

  tumGonderiler() async {
    QuerySnapshot snapshot1 = await takipEdilenRef
        .doc(anlikKullanici!.id)
        .collection("takipEdilenler")
        .get();
    List<tEdilen> kullaniciress =
        snapshot1.docs.map((doc) => tEdilen.fromDocument(doc)).toList();
    setState(() {
      this.takipEdilenKullanicilar = kullaniciress;
    });
    QuerySnapshot myQuerySnapshot = await akisRef
        .where("ownerID",
            whereIn: takipEdilenKullanicilar!.map((e) => e.id).toList())
        .get();
    List<Gonderiler> kullanicires =
        myQuerySnapshot.docs.map((e) => Gonderiler.fromDocument(e)).toList();
    setState(() {
      this.tEdilenGonderiler = kullanicires;
    });
  }

  checkSitutaion() {
    if (takipEdilenKullanicilar!.isEmpty == true &&
        tEdilenGonderiler.isEmpty == true) {
      tumGonderiler();
      return RefreshIndicator(
          color: Colors.black,
          child: Center(
            child: Container(
              color: Colors.white,
              child: Text("Henüz birini takip etmediniz.."),
            ),
          ),
          onRefresh: () {
            return tumGonderiler();
          });
    } else if (takipEdilenKullanicilar!.isEmpty == true &&
        tEdilenGonderiler.isEmpty == false) {
      tumGonderiler();
      return RefreshIndicator(
          color: Colors.black,
          child: Center(
            child: Container(
              color: Colors.white,
              child: Text("Henüz birini takip etmediniz.."),
            ),
          ),
          onRefresh: () {
            return tumGonderiler();
          });
    } else if (takipEdilenKullanicilar!.isEmpty == false &&
        tEdilenGonderiler.isEmpty == false) {
      return RefreshIndicator(
          color: Colors.black,
          child: ListView(
            children: tEdilenGonderiler,
          ),
          onRefresh: () {
            return tumGonderiler();
          });
    } else {
      return ListView(
        children: tEdilenGonderiler,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: baslik(context, strBaslik: "Kartlar", geriButonuYokSay: true),
      body: RefreshIndicator(
        color: Colors.black,
        child: checkSitutaion(),
        onRefresh: () => tumGonderiler(),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
