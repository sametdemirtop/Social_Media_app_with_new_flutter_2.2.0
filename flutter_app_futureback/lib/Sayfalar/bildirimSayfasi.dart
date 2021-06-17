import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_futureback/Sayfalar/AnaSayfa.dart';
import 'package:flutter_app_futureback/Sayfalar/profilSayfasi.dart';
import 'package:flutter_app_futureback/widgets/Progress.dart';
import 'package:flutter_app_futureback/widgets/baslik.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'bildirimGonderisi.dart';

class bildirimSayfasi extends StatefulWidget {
  @override
  _bildirimSayfasiState createState() => _bildirimSayfasiState();
}

class _bildirimSayfasiState extends State<bildirimSayfasi> with AutomaticKeepAliveClientMixin<bildirimSayfasi> {
  List<Bildirim> tumBildirimler = [];
  @override
  void initState() {
    super.initState();
    bildirimleriGetir();
  }

  bildirimleriGetir() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await bildirimRef.doc(anlikKullanici.id).collection("bildirimler").orderBy('timestamp', descending: true).get();

    List<Bildirim> bildirimler = snapshot.docs.map((doc) => Bildirim.fromDocument(doc.data())).toList();

    setState(() {
      this.tumBildirimler = bildirimler;
    });
  }

  bildirimOlustur() {
    if (tumBildirimler == null) {
      return circularProgress();
    } else if (tumBildirimler.isEmpty) {
      return Text("");
    } else {
      return ListView(
        children: tumBildirimler,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: baslik(context, strBaslik: "Bildirimler", geriButonuYokSay: true),
      body: Container(
        child: RefreshIndicator(
          color: Colors.black54,
          onRefresh: () => bildirimleriGetir(),
          child: bildirimOlustur(),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

String bilidirmAciklamasi = "";
Widget bildirimSecenek;

class Bildirim extends StatelessWidget {
  final String username;
  final String type;
  final String commentData;
  final String postID;
  final String userID;
  final String userProfileImg;
  final String url;
  final Timestamp timestamp;

  Bildirim({this.username, this.type, this.commentData, this.postID, this.userID, this.userProfileImg, this.timestamp, this.url});

  factory Bildirim.fromDocument(Map<String, dynamic> doc) {
    return Bildirim(
      username: doc['username'],
      type: doc['type'],
      commentData: doc['commentData'],
      postID: doc['postID'],
      userID: doc['userID'],
      userProfileImg: doc['userProfileImg'],
      url: doc['url'],
      timestamp: doc['timestamp'],
    );
  }
  @override
  Widget build(BuildContext context) {
    bildirimSecenekDuzenle(context);

    return Container(
      child: ListTile(
        title: GestureDetector(
          onTap: () {
            displayUserProfile(context, userProfileID: userID);
          },
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(style: TextStyle(fontSize: 14, color: Colors.black), children: [
              TextSpan(text: username, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              TextSpan(
                text: "$bilidirmAciklamasi",
              ),
            ]),
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            displayUserProfile(context, userProfileID: userID);
          },
          child: CircleAvatar(
            radius: 25,
            backgroundImage: userProfileImg != null ? NetworkImage(userProfileImg) : null,
          ),
        ),
        subtitle: Text(
          timeago.format(timestamp.toDate()),
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.black45),
        ),
        trailing: bildirimSecenek,
      ),
    );
  }

  bildirimSecenekDuzenle(context) {
    if (type == 'like' || type == 'comment' || type == 'kaydetme') {
      bildirimSecenek = InkWell(
        onTap: () {
          gonderiyiGoster(context, gonderiID: postID, kullaniciID: userID);
        },
        child: Container(
          height: 50,
          width: 50,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: new BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(offset: Offset(0, 10), blurRadius: 10, color: Colors.grey)],
                image: url != null ? DecorationImage(fit: BoxFit.cover, image: NetworkImage(url)) : null,
              ),
            ),
          ),
        ),
      );
    } else {
      bildirimSecenek = Text("");
    }
    if (type == 'Follow') {
      bilidirmAciklamasi = " " + "seni takip etmeye başladı";
    } else if (type == 'comment') {
      bilidirmAciklamasi = " " + "yorum yaptı : $commentData";
    } else if (type == 'like') {
      bilidirmAciklamasi = " " + "senin fotoğrafını beğendi";
    } else if (type == 'kaydetme') {
      bilidirmAciklamasi = " " + "senin kartını kaydetti";
    } else {
      bilidirmAciklamasi = "Error type  $type";
    }
  }
}

gonderiyiGoster(context, {String gonderiID, String kullaniciID}) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => bildirimGonderisi(
                gonderiID: gonderiID,
                kullaniciID: kullaniciID,
              )));
}

displayUserProfile(context, {String userProfileID}) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => profilSayfasi(
                kullaniciprofilID: userProfileID,
                postID: '',
              )));
}
