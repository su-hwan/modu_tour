import 'package:firebase_database/firebase_database.dart';
import 'package:modu_tour/util.dart';

class DisableInfo {
  String? key;
  int? disable1;
  int? disable2;
  String? id;
  String? createTime;

  DisableInfo(
      {this.key, this.id, this.disable1, this.disable2, this.createTime});

  factory DisableInfo.fromSnapshot(DataSnapshot snapshot) {
    final json = Util.dataSnapshotToMap(snapshot);
    return DisableInfo.fromJson(json);
  }

  factory DisableInfo.fromJson(Map<String, dynamic> json) {
    return DisableInfo(
        key: json['snapshot_key'],
        id: json['id'],
        disable1: json['disable1'],
        disable2: json['disable2'],
        createTime: json['createTime']);
  }

  toJson() {
    return {
      'id': id,
      'disable1': disable1,
      'disable2': disable2,
      'createTime': createTime,
    };
  }
}
