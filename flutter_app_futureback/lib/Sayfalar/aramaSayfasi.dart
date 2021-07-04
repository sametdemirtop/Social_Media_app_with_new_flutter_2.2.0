import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_futureback/Sayfalar/AnaSayfa.dart';
import 'package:flutter_app_futureback/Sayfalar/profilSayfasi.dart';
import 'package:flutter_app_futureback/model/Kullanici.dart';

// ignore: camel_case_types
class aramaSayfasi extends StatefulWidget {
  @override
  _aramaSayfasiState createState() => _aramaSayfasiState();
}

// ignore: camel_case_types
class _aramaSayfasiState extends State<aramaSayfasi> {
  TextEditingController? textDuzenlemeKontrol;
  Future<QuerySnapshot>? futureAramaSonuclari;
  aramaYeriTemizleme() {
    textDuzenlemeKontrol!.clear();
  }

  @override
  void initState() {
    textDuzenlemeKontrol = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    textDuzenlemeKontrol!.dispose();
    super.dispose();
  }

  aramaKontrol(String str) {
    Future<QuerySnapshot<Map<String, dynamic>>> tumKullanicilar =
        kullaniciRef.where("username", isGreaterThanOrEqualTo: str).get();
    setState(() {
      futureAramaSonuclari = tumKullanicilar;
    });
  }

  PreferredSize aramaSayfasiBasligi() {
    return PreferredSize(
        child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            title: Container(
              padding: EdgeInsets.only(top: 5),
              margin: EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(35.0),
                        boxShadow: [
                          BoxShadow(
                              offset: Offset(0, 10),
                              blurRadius: 10,
                              color: Colors.grey)
                        ],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                              icon: Icon(
                                Icons.person_search,
                                color: Colors.black45,
                              ),
                              onPressed: () {}),
                          Expanded(
                            child: TextFormField(
                              controller: textDuzenlemeKontrol,
                              decoration: InputDecoration(
                                  hintText: "Ara",
                                  hintStyle: TextStyle(color: Colors.black26),
                                  border: InputBorder.none),
                              onFieldSubmitted: aramaKontrol,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.clear, color: Colors.black45),
                            onPressed: aramaYeriTemizleme,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(50),
                  bottomLeft: Radius.circular(50)),
            )),
        preferredSize: Size.fromHeight(80));
  }

  kullanicilariGosterme<Widget>() {
    return FutureBuilder<QuerySnapshot>(
      future: futureAramaSonuclari,
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return Text("");
        }
        List<KullaniciSonuc> kullaniciAramaSonucu = [];
        dataSnapshot.data!.docs.forEach((documents) {
          Kullanici herbirKullanici = Kullanici.fromDocument(documents);
          KullaniciSonuc userResult = KullaniciSonuc(herbirKullanici);
          kullaniciAramaSonucu.add(userResult);
        });
        return ListView(
          children: kullaniciAramaSonucu,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: aramaSayfasiBasligi(),
      ),
      body: kullanicilariGosterme<Widget>(),
    );
  }
}

class KullaniciSonuc extends StatelessWidget {
  final Kullanici? herbirKullanici;
  KullaniciSonuc(this.herbirKullanici);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              kullaniciProfiliGoster(context,
                  kullaniciProfilID: herbirKullanici!.id);
            },
            child: ListTile(
              leading: Container(
                height: 50,
                width: 50,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: new BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                            offset: Offset(0, 10),
                            blurRadius: 10,
                            color: Colors.grey)
                      ],
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(herbirKullanici!.url)),
                    ),
                  ),
                ),
              ),
              title: Text(
                herbirKullanici!.profileName,
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                herbirKullanici!.username,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 13.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  kullaniciProfiliGoster(
    context, {
    required String kullaniciProfilID,
  }) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => profilSayfasi(
                  kullaniciprofilID: kullaniciProfilID,
                )));
  }
}
