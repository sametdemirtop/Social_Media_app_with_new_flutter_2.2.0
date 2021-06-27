import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_futureback/Sayfalar/AnaSayfa.dart';
import 'package:flutter_app_futureback/Sayfalar/profilSayfasi.dart';
import 'package:flutter_app_futureback/Sayfalar/takipEdilenler.dart';
import 'package:flutter_app_futureback/Sayfalar/yuklemeSayfasi.dart';
import 'package:image_picker/image_picker.dart';

import 'anaAkisSayfasi.dart';
import 'aramaSayfasi.dart';
import 'bildirimSayfasi.dart';

class GirisEkran extends StatefulWidget {
  @override
  _GirisEkranState createState() => _GirisEkranState();
}

class _GirisEkranState extends State<GirisEkran>
    with SingleTickerProviderStateMixin {
  PageController? sayfaKontrol;
  int sayfaSayisi = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Key? key;
  File? dosya;
  final imagePicker = ImagePicker();
  Color favoriRenk = Colors.black38.withOpacity(0.4);
  int sayfaNum = 4;
  bool tiklandimi = false;
  AnimationController? animasyonKontrol;
  late Animation<Color?> butonKontrol;
  Animation<double>? animasyonIkonu;
  Animation<double>? butonaCevirme;
  Curve egri = Curves.easeOut;
  double fabYukseklik = 56.0;
  List<tEdilen> takipEdilenKullanicilar = [];

  @override
  void initState() {
    sayfaKontrol = PageController(initialPage: 0);
    animasyonKontrol =
        AnimationController(vsync: this, duration: Duration(milliseconds: 1))
          ..addListener(() {
            setState(() {});
          });
    animasyonIkonu =
        Tween<double>(begin: 0.0, end: 1.0).animate(animasyonKontrol!);
    butonKontrol = ColorTween(begin: Colors.blue, end: Colors.red).animate(
        CurvedAnimation(
            parent: animasyonKontrol!,
            curve: Interval(0.00, 1.00, curve: Curves.linear)));
    butonaCevirme = Tween<double>(begin: fabYukseklik, end: -14.0).animate(
        CurvedAnimation(
            parent: animasyonKontrol!,
            curve: Interval(0.0, 0.75, curve: egri)));
    super.initState();
  }

  @override
  void dispose() {
    animasyonKontrol!.dispose();
    super.dispose();
  }

  onTapPageChange(int pageIndex) {
    sayfaKontrol!.animateToPage(pageIndex,
        duration: Duration(milliseconds: 400), curve: Curves.bounceInOut);
  }

  whenPageChanges(int sayfaSayi) {
    setState(() {
      this.sayfaNum = sayfaSayi;
      sayfaKontrol!.jumpToPage(sayfaSayi);
    });
  }

  void animate() {
    if (!tiklandimi) {
      setState(() {
        // ignore: unnecessary_statements
        tiklandimi == true;
      });
      animasyonKontrol!.forward();
    } else {
      animasyonKontrol!.reverse();
    }
    tiklandimi = !tiklandimi;
  }

  Future kameradanFotograf() async {
    final fotograf = await imagePicker.getImage(source: ImageSource.camera);
    setState(() {
      dosya = File(fotograf!.path);
    });
  }

  Future galeridenFotograf() async {
    final fotograf = await imagePicker.getImage(source: ImageSource.gallery);
    setState(() {
      dosya = File(fotograf!.path);
    });
  }

  Widget butonKamera() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x540000000),
            spreadRadius: 2,
            blurRadius: 65,
          ),
        ],
      ),
      child: FloatingActionButton(
        heroTag: "1",
        backgroundColor: Colors.white,
        mini: true,
        onPressed: () {
          print("tapped");
          kameradanFotograf().then((value) {
            // ignore: unnecessary_null_comparison
            if (dosya != null) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => yuklemeSayfasi(
                            kullanici: anlikKullanici,
                            dosya: dosya,
                          )));
            } else {
              sayfaKontrol!.jumpToPage(0);
            }
          });
        },
        tooltip: "kamera",
        child: Icon(Icons.camera_alt_sharp),
      ),
    );
  }

  Widget butonGaleri() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x540000000),
            spreadRadius: 2,
            blurRadius: 65,
          ),
        ],
      ),
      child: FloatingActionButton(
        heroTag: "2",
        mini: true,
        backgroundColor: Colors.white,
        onPressed: () {
          print("tapped");
          galeridenFotograf().then((value) {
            // ignore: unnecessary_null_comparison
            if (dosya != null) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => yuklemeSayfasi(
                            kullanici: anlikKullanici,
                            dosya: dosya,
                          )));
            } else {
              sayfaKontrol!.jumpToPage(0);
            }
          });
        },
        tooltip: "galeri",
        child: Icon(Icons.add_photo_alternate_rounded),
      ),
    );
  }

  Widget butonEkleme() {
    return Container(
      width: 70,
      height: 70,
      child: FloatingActionButton(
        //BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(45.0))),
        heroTag: "3",
        backgroundColor: Colors.white,
        onPressed: animate,
        tooltip: "ekleme",
        child: Container(
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            image: DecorationImage(
                image: AssetImage("assets/images/sscard.png"),
                fit: BoxFit.fill),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      key: _scaffoldKey,
      body: PageView(
        children: [
          anaAkisSayfasi(
            gAnlikKullanici: anlikKullanici,
          ),
          aramaSayfasi(),
          bildirimSayfasi(),
          profilSayfasi(
            kullaniciprofilID: anlikKullanici!.id,
            postID: '',
          ),
        ],
        controller: sayfaKontrol,
        onPageChanged: whenPageChanges,
        physics: NeverScrollableScrollPhysics(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 15.0),
        child: FittedBox(
          child: Container(
            child: Column(
              children: [
                Transform(
                  transform: Matrix4.translationValues(
                      0.0, butonaCevirme!.value * 2.0, 0.0),
                  child: butonKamera(),
                ),
                Transform(
                  transform: Matrix4.translationValues(
                      0.0, butonaCevirme!.value * 1.0, 0.0),
                  child: butonGaleri(),
                ),
                butonEkleme(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        child: ClipRRect(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          child: BottomAppBar(
            notchMargin: 24,
            shape: CircularNotchedRectangle(),
            child: Container(
              height: 57,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    padding: EdgeInsets.only(left: 28.0),
                    icon: Icon(
                      Icons.home_filled,
                      color:
                          sayfaNum == 0 ? Colors.deepOrange[200] : favoriRenk,
                    ),
                    onPressed: () {
                      whenPageChanges(0);
                    },
                  ),
                  IconButton(
                    padding: EdgeInsets.only(right: 28.0),
                    icon: Icon(
                      Icons.search,
                      color:
                          sayfaNum == 1 ? Colors.deepOrange[200] : favoriRenk,
                    ),
                    onPressed: () {
                      whenPageChanges(1);
                    },
                  ),
                  IconButton(
                    padding: EdgeInsets.only(left: 28.0),
                    icon: Icon(
                      Icons.favorite,
                      color:
                          sayfaNum == 2 ? Colors.deepOrange[200] : favoriRenk,
                    ),
                    onPressed: () {
                      whenPageChanges(2);
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      sayfaKontrol!.jumpToPage(3);
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: 15),
                      child: CircleAvatar(
                        child: Container(
                          height: 37,
                          width: 37,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  offset: Offset(0, 10),
                                  blurRadius: 10,
                                  color: Colors.grey)
                            ],
                            borderRadius: BorderRadius.circular(14),
                            // ignore: unnecessary_null_comparison
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(anlikKullanici!.url)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            color: Colors.white.withOpacity(1),
          ),
        ),
      ),
    );
  }
}
