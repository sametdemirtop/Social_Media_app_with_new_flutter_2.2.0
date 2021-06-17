import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_futureback/Sayfalar/AnaSayfa.dart';
import 'package:flutter_app_futureback/Sayfalar/bildirimSayfasi.dart';
import 'package:flutter_app_futureback/model/Kullanici.dart';
import 'package:flutter_app_futureback/widgets/Progress.dart';
import 'package:flutter_app_futureback/widgets/baslik.dart';
import 'package:flutter_app_futureback/widgets/gonderi.dart';

// ignore: camel_case_types
class gonderiEkranSayfasi extends StatefulWidget {
  final String gonderiID;
  final String kullaniciID;
  gonderiEkranSayfasi({this.gonderiID, this.kullaniciID});
  @override
  _gonderiEkranSayfasiState createState() => _gonderiEkranSayfasiState();
}

// ignore: camel_case_types
class _gonderiEkranSayfasiState extends State<gonderiEkranSayfasi> {
  @override
  void initState() {
    super.initState();
    gonderiSahibimiDegilmi();
  }

  bool gonderiSahibi;

  profilGoruntuleme() {
    if (gonderiSahibi == true) {
      return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: gonderiRef.doc(anlikKullanici.id).collection("kullaniciGonderi").doc(widget.gonderiID).get(),
          builder: (context, documentSnapshot) {
            if (!documentSnapshot.hasData) {
              return circularProgress();
            }

            List<Gonderiler> gonderiler = [];
            Gonderiler gonderi;
            Bildirim bildirim = Bildirim.fromDocument(documentSnapshot.data.data());
            gonderiler.add(Gonderiler.fromDocument(documentSnapshot.data.data()));
            for (var doc in gonderiler) {
              if (doc.url == bildirim.url) {
                gonderi = doc;
              }
            }

            return Center(
              child: Scaffold(
                backgroundColor: Colors.white,
                appBar: baslik(context, strBaslik: ""),
                body: SingleChildScrollView(
                  child: gonderi,
                ),
              ),
            );
          });
    } else {
      return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: gonderiRef.doc(widget.kullaniciID).collection("kullaniciGonderi").doc(widget.gonderiID).get(),
          builder: (context, documentSnapshot) {
            if (!documentSnapshot.hasData) {
              return circularProgress();
            }

            List<Gonderiler> gonderiler = [];
            Gonderiler gonderi;
            Bildirim bildiri = Bildirim.fromDocument(documentSnapshot.data.data());
            gonderiler.add(Gonderiler.fromDocument(documentSnapshot.data.data()));
            for (var doc in gonderiler) {
              if (doc.url == bildiri.url) {
                gonderi = doc;
              }
            }

            return Center(
              child: Scaffold(
                backgroundColor: Colors.white,
                appBar: baslik(context, strBaslik: ""),
                body: SingleChildScrollView(
                  child: gonderi,
                ),
              ),
            );
          });
    }
  }

  gonderiSahibimiDegilmi() {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: takipciRef.doc(anlikKullanici.id).collection("takipciler").doc(widget.kullaniciID).get(),
        // ignore: missing_return
        builder: (context, ds) {
          if (!ds.hasData) {
            return circularProgress();
          }
          Kullanici kullanici = Kullanici.fromDocument(ds.data.data());
          if (anlikKullanici.id == kullanici.id) {
            gonderiSahibi = true;
          } else {
            gonderiSahibi = false;
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: profilGoruntuleme(),
    );
  }
}
