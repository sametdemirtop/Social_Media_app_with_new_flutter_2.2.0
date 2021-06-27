import 'package:flutter/material.dart';
import 'package:flutter_app_futureback/Sayfalar/gonderiEkranSayfasi.dart';
import 'package:flutter_app_futureback/widgets/gonderi.dart';

// ignore: camel_case_types
class gonderiListeleme extends StatelessWidget {
  final Gonderiler? gonderi;
  gonderiListeleme(this.gonderi);
  tumGonderileriGoster(context, {String? gonderiID, String? kullaniciID}) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => gonderiEkranSayfasi(gonderiID: gonderiID!, kullaniciID: kullaniciID!)));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        tumGonderileriGoster(context, gonderiID: gonderi!.postID, kullaniciID: gonderi!.ownerID);
      },
      child: Image.network(gonderi!.url as String),
    );
  }
}
