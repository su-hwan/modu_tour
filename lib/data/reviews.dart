import 'package:firebase_database/firebase_database.dart';
import 'package:modu_tour/util.dart';

class Review {
  String id;
  String review;
  String createTime;

  Review(this.id, this.review, this.createTime);

  factory Review.fromSnapshot(DataSnapshot snapshot) {
    final map = Util.dataSnapshotToMap(snapshot);
    return Review.fromJson(map);
  }

  factory Review.fromJson(Map<String, dynamic> map) {
    return Review(
        map['id'], map['review'], map['createTime']);
  }

  toJson() {
    return {
      'id': id,
      'review': review,
      'createTime': createTime,
    };
  }
}
