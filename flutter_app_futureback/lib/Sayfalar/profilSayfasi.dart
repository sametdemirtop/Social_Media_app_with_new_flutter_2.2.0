import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_futureback/Sayfalar/AnaSayfa.dart';
import 'package:flutter_app_futureback/Sayfalar/gonderiEkranSayfasi.dart';
import 'package:flutter_app_futureback/Sayfalar/profilDuzenle.dart';
import 'package:flutter_app_futureback/Sayfalar/takipEdilenler.dart';
import 'package:flutter_app_futureback/Sayfalar/takipciler.dart';
import 'package:flutter_app_futureback/model/Kullanici.dart';
import 'package:flutter_app_futureback/widgets/Progress.dart';
import 'package:flutter_app_futureback/widgets/gonderi.dart';
import 'package:flutter_app_futureback/widgets/gonderiListesi.dart';

import 'kaydedilenKartlar.dart';

// ignore: camel_case_types
class profilSayfasi extends StatefulWidget {
  final String? kullaniciprofilID;
  final String? postID;
  profilSayfasi({this.kullaniciprofilID, this.postID});

  @override
  _profilSayfasiState createState() => _profilSayfasiState();
}

// ignore: camel_case_types
class _profilSayfasiState extends State<profilSayfasi>
    with AutomaticKeepAliveClientMixin<profilSayfasi> {
  final String? onlineKullaniciID = anlikKullanici!.id;
  List<Gonderiler>? gonderiListesi = [];
  // ignore: non_constant_identifier_names
  String? GonderiStili = "grid";
  int? gonderiHesapla = 0;
  int? toplamTakipciHesapla = -1;
  int? toplamTakipEdilenHesapla = 0;
  bool? takip = false;
  bool? yuklenme = false;
  @override
  void initState() {
    super.initState();
    tumProfiliGetir();
    tumTakipedilenleriGetirveHesapla();
    tumTakipcileriGetirveHesapla();
    takipEdiyormu();
  }

  tumTakipedilenleriGetirveHesapla() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await takipEdilenRef
        .doc(widget.kullaniciprofilID)
        .collection("takipEdilenler")
        .get();
    setState(() {
      toplamTakipEdilenHesapla = querySnapshot.docs.length;
    });
  }

  takipEdiyormu() async {
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await takipciRef
        .doc(widget.kullaniciprofilID)
        .collection("takipciler")
        .doc(onlineKullaniciID)
        .get();
    setState(() {
      takip = documentSnapshot.exists;
    });
  }

  tumTakipcileriGetirveHesapla() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await takipciRef
        .doc(widget.kullaniciprofilID)
        .collection("takipciler")
        .get();
    setState(() {
      toplamTakipciHesapla = querySnapshot.docs.length;
    });
  }

  PreferredSize baslikOlustur() {
    return PreferredSize(
        child: AppBar(
            elevation: 10,
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            title: FutureBuilder<DocumentSnapshot>(
                future: kullaniciRef.doc(widget.kullaniciprofilID).get(),
                builder: (context, dataSnapshot) {
                  if (!dataSnapshot.hasData) {
                    return Text("");
                  }
                  Kullanici kullanici =
                      Kullanici.fromDocument(dataSnapshot.data!);
                  return Text(kullanici.username,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 23,
                          fontWeight: FontWeight.bold));
                }),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(100),
              ),
            )),
        preferredSize: Size.fromHeight(55));
  }

  takipEdilenleriGor() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => takipEdilenler(
                kullaniciprofilID: widget.kullaniciprofilID,
                anlikKullaniciID: onlineKullaniciID)));
  }

  takipcileriGor() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => takipciler(
                kullaniciprofilID: widget.kullaniciprofilID,
                anlikKullaniciID: onlineKullaniciID)));
  }

  Column sutunOlustur(String baslik, int sayac) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          sayac.toString(),
          style: TextStyle(
              fontSize: 25.0, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 5.0),
          child: Text(
            baslik,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  butonOlustur() {
    bool kendiProfilimi = onlineKullaniciID == widget.kullaniciprofilID;
    if (kendiProfilimi) {
      return baslikFonksiyonveButonOlusturma(
        baslik: "Profil Düzenle",
        fonskiyonIslevi: kullaniciProfilDuzenle,
      );
    } else if (takip!) {
      return baslikFonksiyonveButonOlusturma(
        baslik: "Takipten Çıkar",
        fonskiyonIslevi: takiptenCikarmaKontrol,
      );
    } else if (!takip!) {
      return baslikFonksiyonveButonOlusturma(
        baslik: "Takip Et",
        fonskiyonIslevi: takipEtmeKontrolu,
      );
    }
  }

  profilBasligi() {
    return FutureBuilder<DocumentSnapshot>(
      future: kullaniciRef.doc(widget.kullaniciprofilID).get(),
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return circularProgress();
        }
        Kullanici kullanici = Kullanici.fromDocument(dataSnapshot.data!);
        var size = MediaQuery.of(context).size;
        return Container(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        offset: Offset(0, 10),
                        blurRadius: 100,
                        color: Colors.grey)
                  ],
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(7.0),
                      child: Container(
                        width: (size.width - 3) / 3,
                        height: (size.height - 3) / 6,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  offset: Offset(0, 6),
                                  blurRadius: 2,
                                  color: Colors.grey)
                            ],
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                                image: NetworkImage(kullanici.url),
                                fit: BoxFit.cover)),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  kullanici.profileName,
                  style: TextStyle(
                    fontSize: 22.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      BoxShadow(
                        color: Color(0x54000000),
                        spreadRadius: 2,
                        blurRadius: 50,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 3),
                child: Text(
                  kullanici.biography,
                  style: TextStyle(fontSize: 18.0, color: Colors.black),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      sutunOlustur("Gönderi", gonderiHesapla!),
                      GestureDetector(
                        onTap: () {
                          takipEdilenleriGor();
                        },
                        child: sutunOlustur("Takip", toplamTakipEdilenHesapla!),
                      ),
                      GestureDetector(
                        onTap: () {
                          takipcileriGor();
                        },
                        child: sutunOlustur("Takipçi", toplamTakipciHesapla!),
                      ),
                    ],
                  ),
                  SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: butonOlustur(),
                      ),
                      (widget.kullaniciprofilID == onlineKullaniciID)
                          ? Expanded(
                              child: kaydedilenlerButonu(),
                            )
                          : Text(""),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  kaydedilenlerButonu() {
    return Container(
      padding: EdgeInsets.only(top: 3),
      child: TextButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => kaydedilenKartlar(
                        kullaniciID: widget.kullaniciprofilID,
                      )));
        },
        child: Container(
          width: 200.0,
          height: 50,
          child: Text(
            "Kaydedilenler",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  offset: Offset(0, 10), blurRadius: 10, color: Colors.grey)
            ],
            color: Colors.teal,
            border: Border.all(color: Colors.orange.shade50),
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    );
  }

  takiptenCikarmaKontrol() {
    setState(() {
      takip = false;
    });
    takipciRef
        .doc(widget.kullaniciprofilID)
        .collection("takipciler")
        .doc(onlineKullaniciID)
        .get()
        .then((takipci) {
      setState(() {
        if (takipci.exists) {
          takipci.reference.delete();
        }
      });
    });
    takipEdilenRef
        .doc(onlineKullaniciID)
        .collection("takipEdilenler")
        .doc(widget.kullaniciprofilID)
        .get()
        .then((takipedilen) {
      setState(() {
        if (takipedilen.exists) {
          takipedilen.reference.delete();
        }
      });
    });
    bildirimRef
        .doc(widget.kullaniciprofilID)
        .collection("bildirimler")
        .doc(onlineKullaniciID)
        .get()
        .then((bildirim) {
      setState(() {
        if (bildirim.exists) {
          bildirim.reference.delete();
        }
      });
    });
  }

  takipEtmeKontrolu() {
    setState(() {
      takip = true;
    });
    takipciRef
        .doc(widget.kullaniciprofilID)
        .collection("takipciler")
        .doc(onlineKullaniciID)
        .set({
      "id": onlineKullaniciID,
    });
    takipEdilenRef
        .doc(onlineKullaniciID)
        .collection("takipEdilenler")
        .doc(widget.kullaniciprofilID)
        .set({
      "id": widget.kullaniciprofilID,
    });
    bildirimRef
        .doc(widget.kullaniciprofilID)
        .collection("bildirimler")
        .doc(anlikKullanici!.id)
        .set({
      "type": "Follow",
      "commentData": "takip",
      "ownerID": widget.kullaniciprofilID,
      "username": anlikKullanici!.username,
      "timestamp": timestamp,
      "userProfileImg": anlikKullanici!.url,
      "userID": anlikKullanici!.id,
      "url": "",
      "postID": "",
    });
  }

  kullaniciProfilDuzenle() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                profilDuzenle(onlineKullaniciID: widget.kullaniciprofilID)));
  }

  Container baslikFonksiyonveButonOlusturma(
      {String? baslik, Function? fonskiyonIslevi}) {
    return Container(
      padding: EdgeInsets.only(top: 3),
      child: TextButton(
        onPressed: () {
          setState(() {
            fonskiyonIslevi!();
          });
        },
        child: Container(
          width: 200.0,
          height: 50,
          child: Text(
            baslik!,
            style: TextStyle(
                color: takip! ? Colors.white : Colors.white,
                fontWeight: FontWeight.bold),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  offset: Offset(0, 10), blurRadius: 10, color: Colors.grey)
            ],
            color: takip! ? Colors.brown[100] : Colors.deepOrange[200],
            border: Border.all(color: Colors.orange.shade50),
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    );
  }

  Scaffold anaMenu() {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: baslikOlustur(),
      body: RefreshIndicator(
        color: Colors.black,
        child: ListView(
          children: [
            SizedBox(
              height: 12,
            ),
            profilBasligi(),
            SizedBox(
              height: 30,
            ),
            listeVeyaGridGonderiOlustur(),
            SizedBox(
              height: 35,
            ),
            profilGonderisiGoster(),
          ],
        ),
        onRefresh: () => tumProfiliGetir(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return anaMenu();
  }

  @override
  bool get wantKeepAlive => true;

  profilGonderisiGoster() {
    if (yuklenme!) {
      return circularProgress();
    } else if (gonderiListesi!.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Center(
                child: Text(
                  "Gonderi Yok",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (GonderiStili == "grid") {
      List<gonderiListeleme> gridListesi = [];
      var size = MediaQuery.of(context).size;
      gonderiListesi!.forEach((herbirGonderi) {
        gridListesi.add(gonderiListeleme(herbirGonderi));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 3,
        crossAxisSpacing: 0,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: List.generate(gridListesi.length, (index) {
          return GestureDetector(
            child: Padding(
              padding: const EdgeInsets.all(7.0),
              child: Container(
                width: (size.width - 3) / 3,
                height: (size.height - 3) / 6,
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          offset: Offset(0, 6),
                          blurRadius: 2,
                          color: Colors.grey)
                    ],
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                        image: NetworkImage(
                            gridListesi[index].gonderi!.url as String),
                        fit: BoxFit.cover)),
              ),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => gonderiEkranSayfasi(
                          gonderiID:
                              gridListesi[index].gonderi!.postID as String,
                          kullaniciID:
                              gridListesi[index].gonderi!.ownerID as String)));
            },
          );
        }),
      );
    } else if (GonderiStili == "list") {
      return Column(
        children: gonderiListesi!,
      );
    }

    return Column(
      children: gonderiListesi!,
    );
  }

  tumProfiliGetir() async {
    setState(() {
      yuklenme = true;
    });

    QuerySnapshot querySnapshot = await gonderiRef
        .doc(widget.kullaniciprofilID)
        .collection("kullaniciGonderi")
        .orderBy("timestamp", descending: true)
        .get();
    setState(() {
      yuklenme = false;
      gonderiHesapla = querySnapshot.docs.length;
      gonderiListesi = querySnapshot.docs
          .map((documentsnapshot) => Gonderiler.fromDocument(documentsnapshot))
          .toList();
    });
    QuerySnapshot querySnapshot1 = await takipEdilenRef
        .doc(widget.kullaniciprofilID)
        .collection("takipEdilenler")
        .get();
    setState(() {
      toplamTakipEdilenHesapla = querySnapshot1.docs.length;
    });
    QuerySnapshot querySnapshot2 = await takipciRef
        .doc(widget.kullaniciprofilID)
        .collection("takipciler")
        .get();
    setState(() {
      toplamTakipciHesapla = querySnapshot2.docs.length;
    });
  }

  Widget bottomGridTile(Map<String, dynamic> data) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.all(7.0),
        child: Container(
          width: (size.width - 3) / 3,
          height: (size.height - 3) / 6,
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x540000000),
                  spreadRadius: 1,
                  blurRadius: 0.1,
                ),
              ],
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                  image: NetworkImage(data["url"]), fit: BoxFit.cover)),
        ),
      ),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => gonderiEkranSayfasi(
                    gonderiID: data["postID"], kullaniciID: data["ownerID"])));
      },
    );
  }

  listeVeyaGridGonderiOlustur() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(offset: Offset(0, 10), blurRadius: 10, color: Colors.grey)
          ],
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                stilVerme("grid");
              },
              icon: Icon(Icons.grid_on),
              color: GonderiStili == "grid" ? Colors.black : Colors.black38,
            ),
            IconButton(
              onPressed: () {
                stilVerme("list");
              },
              icon: Icon(Icons.list),
              color: GonderiStili == "list" ? Colors.black : Colors.black38,
            ),
          ],
        ),
      ),
    );
  }

  stilVerme(String stil) {
    setState(() {
      this.GonderiStili = stil;
    });
  }
}
