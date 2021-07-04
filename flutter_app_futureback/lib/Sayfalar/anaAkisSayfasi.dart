import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_futureback/Sayfalar/AnaSayfa.dart';
import 'package:flutter_app_futureback/Sayfalar/takipEdilenler.dart';
import 'package:flutter_app_futureback/model/Kullanici.dart';
import 'package:flutter_app_futureback/widgets/gonderi.dart';

import 'MessageHomePage.dart';

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

  PreferredSize akisBaslik() {
    return PreferredSize(
        child: AppBar(
          elevation: 10,
          iconTheme: IconThemeData(color: Colors.black),
          automaticallyImplyLeading: false,
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: IconButton(
                iconSize: 40,
                icon: Icon(
                  Icons.mark_email_read_rounded,
                  color: Colors.deepOrange[200],
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomeScreen(
                                currentUserId: anlikKullanici!.id,
                              )));
                },
              ),
            ),
          ],
          title: Text(
            "Kartlar",
            style: TextStyle(
              color: Colors.black,
              //fontFamily: uygulamaBasligi ? "Signatra" : "",
              fontSize: 22.0,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50)),
          ),
        ),
        preferredSize: Size.fromHeight(50));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: akisBaslik(),
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
