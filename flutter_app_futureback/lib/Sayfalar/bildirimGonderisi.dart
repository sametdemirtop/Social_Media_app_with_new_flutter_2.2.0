import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_futureback/Sayfalar/AnaSayfa.dart';
import 'package:flutter_app_futureback/widgets/baslik.dart';
import 'package:flutter_app_futureback/widgets/gonderi.dart';
import 'package:flutter_app_futureback/widgets/progress.dart';

class bildirimGonderisi extends StatelessWidget {
  final String? gonderiID;
  final String? kullaniciID;
  bildirimGonderisi({required this.kullaniciID, required this.gonderiID});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
        future: gonderiRef
            .doc(anlikKullanici!.id)
            .collection("kullaniciGonderi")
            .doc(gonderiID)
            .get(),
        builder: (context, ds) {
          if (!ds.hasData) {
            return circularProgress();
          }
          Gonderiler gonderiler = Gonderiler.fromDocument(ds.data!);
          return Center(
            child: Scaffold(
              backgroundColor: Colors.grey.shade100,
              appBar: baslik(context, strBaslik: ""),
              body: SingleChildScrollView(child: gonderiler),
            ),
          );
        });
  }
}
