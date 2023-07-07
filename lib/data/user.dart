import 'package:firebase_database/firebase_database.dart';
import 'package:modu_tour/util.dart';

class User {
  String id;
  String pw;
  String createTime;

  User({required this.id, required this.pw, required this.createTime});

  factory User.fromJson(DataSnapshot snapshot) {
    final json = Util.dataSnapshotToMap(snapshot);
    return User(
      id: json['id'] ?? '',
      pw: json['pw'] ?? '',
      createTime:  json['createTime'] ?? ''
    );
  }

  toJson() {
    return <String, String>{'id': id, 'pw': pw, 'createTime': createTime};
  }
}
