import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_futureback/Sayfalar/AnaSayfa.dart';
import 'package:flutter_app_futureback/model/Kullanici.dart';
import 'package:flutter_app_futureback/widgets/progress.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

// ignore: camel_case_types
class profilDuzenle extends StatefulWidget {
  final String onlineKullaniciID;
  profilDuzenle({this.onlineKullaniciID});
  @override
  _profilDuzenleState createState() => _profilDuzenleState();
}

// ignore: camel_case_types
class _profilDuzenleState extends State<profilDuzenle> {
  TextEditingController profilIsimKontrolu = TextEditingController();
  TextEditingController biographyDuzenKontrolu = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final formKey1 = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool yukleniyor = false;
  Kullanici kullanici;
  ButtonState stateOnlyText = ButtonState.idle;
  ButtonState stateTextWithIcon = ButtonState.idle;
  void onPressedIconWithText() {
    switch (stateTextWithIcon) {
      case ButtonState.idle:
        stateTextWithIcon = ButtonState.loading;
        Future.delayed(Duration(milliseconds: 500), () {
          setState(() {
            stateTextWithIcon = Random.secure().nextBool() ? ButtonState.success : ButtonState.success;
            kullaniciBilgisiGuncelleme();
          });
        });
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context);
        });

        break;
      case ButtonState.loading:
        break;
      case ButtonState.success:
        stateTextWithIcon = ButtonState.idle;
        break;
      case ButtonState.fail:
        stateTextWithIcon = ButtonState.idle;
        break;
    }
    setState(() {
      stateTextWithIcon = stateTextWithIcon;
    });
  }

  @override
  void initState() {
    super.initState();
    kullaniciBilgisiAlmaveGosterme();
  }

  kullaniciBilgisiAlmaveGosterme() async {
    setState(() {
      yukleniyor = true;
    });
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await kullaniciRef.doc(widget.onlineKullaniciID).get();
    kullanici = Kullanici.fromDocument(documentSnapshot.data());
    profilIsimKontrolu.text = kullanici.profileName;
    biographyDuzenKontrolu.text = kullanici.biography;
  }

  kullaniciBilgisiGuncelleme() {
    if (formKey.currentState.validate() && formKey1.currentState.validate()) {
      formKey.currentState.save();
      formKey1.currentState.save();
      kullaniciRef.doc(widget.onlineKullaniciID).update({
        "profileName": profilIsimKontrolu.text,
        "biography": biographyDuzenKontrolu.text,
      });
      SnackBar snackBar = SnackBar(duration: const Duration(seconds: 1), content: Text("Profil Güncellendi"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Profil Düzenle",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.all(10),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 40,
              ),
            ),
          ),
        ],
      ),
      body: yukleniyor == false ? circularProgress<Widget>() : liste<Widget>(),
    );
  }

  ListView liste<Widget>() {
    return ListView(
      children: [
        Container(
          child: Column(
            children: [
              profilBasligi(),
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    kullaniciProfilIsmiAlaniOlusturma(),
                    SizedBox(
                      height: 30,
                    ),
                    kullaniciBiographyAlaniOlusturma(),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(32.0),
              ),
              buildTextWithIcon(),
              SizedBox(
                height: 75,
              ),
              TextButton(
                  onPressed: () {
                    kullaniciCikisi();

                    signOut();
                  },
                  child: Text("Çıkış")),
            ],
          ),
        ),
      ],
    );
  }

  profilBasligi() {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: kullaniciRef.doc(widget.onlineKullaniciID).get(),
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return circularProgress();
        }
        Kullanici kullanici = Kullanici.fromDocument(dataSnapshot.data.data());
        return Container(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [BoxShadow(offset: Offset(0, 10), blurRadius: 35, color: Colors.grey)],
                  ),
                  child: CircleAvatar(
                    radius: 60.0,
                    backgroundImage: NetworkImage(kullanici.url),
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
            ],
          ),
        );
      },
    );
  }

  Widget buildTextWithIcon() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 50,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: ProgressButton.icon(iconedButtons: {
        ButtonState.idle: IconedButton(text: "Güncelle", icon: Icon(Icons.update, color: Colors.white), color: Colors.deepOrange),
        ButtonState.loading: IconedButton(text: "Loading", color: Colors.deepPurple.shade700),
        ButtonState.fail: IconedButton(text: "Failed", icon: Icon(Icons.cancel, color: Colors.white), color: Colors.red.shade300),
        ButtonState.success: IconedButton(
            text: "Güncellendi",
            icon: Icon(
              Icons.check_circle,
              color: Colors.white,
            ),
            color: Colors.green.shade400)
      }, onPressed: onPressedIconWithText, state: stateTextWithIcon),
    );
  }

  kullaniciCikisi() async {
    await googlegiris.signOut();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AnaSayfa(
                  girdimi: false,
                )));
  }

  signOut() async {
    return await _auth.signOut();
  }

  Column kullaniciProfilIsmiAlaniOlusturma() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Form(
          key: formKey,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(offset: Offset(0, 1), blurRadius: 100, color: Colors.grey.shade400.withOpacity(0.5))],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                style: TextStyle(color: Colors.black),
                controller: profilIsimKontrolu,
                decoration: InputDecoration(
                  fillColor: Colors.deepOrange[200],
                  labelText: "Profil İsmi",
                  hintText: "Profil İsmini gir",
                  enabledBorder: OutlineInputBorder(
                    gapPadding: 0.1,
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(color: Colors.deepOrange, width: 6),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(width: 6),
                  ),
                ),
                validator: (girilenDeger) {
                  if (girilenDeger.trim().length > 3 || girilenDeger.isEmpty == false) {
                    return null;
                  } else
                    return "Profil İsmi çok kısa";
                },
                onSaved: (kaydedilecekDeger) {
                  profilIsimKontrolu.text = kaydedilecekDeger;
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Column kullaniciBiographyAlaniOlusturma() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Form(
          key: formKey1,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(offset: Offset(0, 1), blurRadius: 100, color: Colors.grey.shade400.withOpacity(0.5))],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                style: TextStyle(color: Colors.black),
                controller: biographyDuzenKontrolu,
                decoration: InputDecoration(
                  fillColor: Colors.deepOrange[200],
                  labelText: "Biography",
                  hintText: "Profil İsmini gir",
                  enabledBorder: OutlineInputBorder(
                    gapPadding: 0.1,
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(color: Colors.deepOrange, width: 6),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(width: 6),
                  ),
                ),
                validator: (girilenDeger) {
                  if (girilenDeger.trim().length < 110) {
                    return null;
                  } else
                    return "Biography çok uzun";
                },
                onSaved: (kaydedilecekDeger) {
                  biographyDuzenKontrolu.text = kaydedilecekDeger;
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
