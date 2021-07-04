import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_futureback/Sayfalar/AnaSayfa.dart';
import 'package:flutter_app_futureback/widgets/Progress.dart';
import 'package:flutter_app_futureback/widgets/baslik.dart';
import 'package:flutter_app_futureback/widgets/gonderi.dart';

// ignore: camel_case_types
class gonderiEkranSayfasi extends StatefulWidget {
  final String gonderiID;
  final String kullaniciID;
  gonderiEkranSayfasi({required this.gonderiID, required this.kullaniciID});
  @override
  _gonderiEkranSayfasiState createState() => _gonderiEkranSayfasiState();
}

// ignore: camel_case_types
class _gonderiEkranSayfasiState extends State<gonderiEkranSayfasi> {
  @override
  void initState() {
    super.initState();
  }

  fotografGoruntuleme() {
    return FutureBuilder<DocumentSnapshot>(
        future: akisRef.doc(widget.gonderiID).get(),
        builder: (context, ds) {
          if (!ds.hasData) {
            return circularProgress();
          }

          Gonderiler? gonderi = Gonderiler.fromDocument(ds.data!);
          return SingleChildScrollView(
            child: gonderi,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: baslik(context, strBaslik: ""),
      body: Container(
        child: fotografGoruntuleme(),
      ),
    );
  }
}
