import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Util {

  static Map<String, dynamic> dataSnapshotToMap(DataSnapshot snapshot) {
    final castedSnapshot = snapshot.value as Map<dynamic, dynamic>;
    final mapData = Map<String, dynamic>.from(castedSnapshot);
    mapData['snapshot_key'] = snapshot.key;
    return mapData;
  }

}

class MakeDialog {
  static void build(BuildContext context, String text) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(text),
          );
        });
  }
}