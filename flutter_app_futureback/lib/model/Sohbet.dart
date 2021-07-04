import 'package:cloud_firestore/cloud_firestore.dart';

class Sohbet {
  final String lastContent;
  final String id;
  final String url;
  final Timestamp? timestamp;
  final String username;
  final String profileName;

  Sohbet({
    required this.lastContent,
    required this.id,
    required this.url,
    required this.timestamp,
    required this.username,
    required this.profileName,
  });

  factory Sohbet.fromDocument(DocumentSnapshot doc) {
    return Sohbet(
      lastContent: doc['lastContent'],
      id: doc['id'],
      url: doc['url'],
      timestamp: doc['timestamp'],
      username: doc['username'],
      profileName: doc['profileName'],
    );
  }
}
