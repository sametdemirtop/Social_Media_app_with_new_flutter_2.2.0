class Kullanici {
  final String id;
  final String profileName;
  final String username;
  final String url;
  final String email;
  final String biography;

  Kullanici({
    this.id,
    this.profileName,
    this.username,
    this.url,
    this.email,
    this.biography,
  });

  factory Kullanici.fromDocument(Map<String, dynamic> doc) {
    return Kullanici(
      id: doc['id'],
      email: doc['email'],
      username: doc['username'],
      url: doc['url'],
      profileName: doc['profileName'],
      biography: doc['biography'],
    );
  }
}
