import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:modu_tour/data/user.dart';
import 'package:modu_tour/make_dialog.dart';

class SignPage extends StatefulWidget {
  const SignPage({super.key});

  @override
  State<SignPage> createState() => _SignPageState();
}

class _SignPageState extends State<SignPage> {
  final TextEditingController _idTextController = TextEditingController();
  final TextEditingController _pwTextController = TextEditingController();
  final TextEditingController _pwCheckTextController = TextEditingController();
  late FirebaseDatabase _database;
  late DatabaseReference _ref;

  @override
  void initState() {
    _database = FirebaseDatabase.instance;
    _ref = _database!.ref('users');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _idTextController,
                  maxLines: 1,
                  decoration: const InputDecoration(
                      labelText: '아이디',
                      hintText: '4자 이상 입력하세요.',
                      border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _pwTextController,
                  maxLines: 1,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: '비밀번호',
                      hintText: '6자 이상 입력하세요.',
                      border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _pwCheckTextController,
                  maxLines: 1,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: '비밀번호 확인', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              buttonJoin(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget buttonJoin(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          child: const Text('회원가입'),
          onPressed: () async {
            if (_idTextController.value.text.length < 4 ||
                _pwTextController.value.text.length < 6) {
              MakeDialog.build(context, '길이가 짧습니다.');
            } else if (_pwTextController.value.text !=
                _pwCheckTextController.value.text) {
              MakeDialog.build(context, '비밀번호가 일치하지 않습니다.');
            } else {
              final userId = _idTextController.value.text;
              final snapshot = await _ref.child(userId).get();

              if(!mounted) return;
              if (snapshot.exists) {
                MakeDialog.build(context, '아이디가 이미 존재 합니다.');
                return;
              }
              var bytes = utf8.encode(_pwTextController.value.text);
              var digest = sha1.convert(bytes);
              await _ref
                  .child(_idTextController.value.text)
                  .push()
                  .set(User(
                          id: _idTextController.value.text,
                          pw: digest.toString(),
                          createTime: DateTime.now().toIso8601String())
                      .toJson())
                  .then((_) {
                Navigator.of(context).pop();
              });
            }
          },
        ),
      ],
    );
  }
}
