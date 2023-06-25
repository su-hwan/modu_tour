import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:modu_tour/make_dialog.dart';

import 'data/user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  FirebaseDatabase? _database;
  DatabaseReference? _ref;

  double opacity = 0;
  AnimationController? _animationController;
  Animation? _animation;
  TextEditingController? _idTextController;
  TextEditingController? _pwdTextController;

  @override
  void initState() {
    super.initState();

    _database = FirebaseDatabase.instance;
    _ref = _database!.ref('users');

    _idTextController = TextEditingController();
    _pwdTextController = TextEditingController();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _animation =
        Tween<double>(begin: 0, end: pi * 2).animate(_animationController!);
    _animationController!.repeat();

    // Timer(const Duration(seconds: 2), () {
    //   setState(() {
    //     opacity = 1;
    //   });
    // });
    opacity = 1;
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animationController!,
              builder: (context, widget) {
                return Transform.rotate(
                  angle: _animation!.value,
                  child: widget,
                );
              },
              child: const Icon(
                Icons.airplanemode_active,
                color: Colors.deepOrangeAccent,
                size: 80,
              ),
            ),
            const SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  '모두의 여행',
                  style: TextStyle(fontSize: 30),
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: opacity,
              duration: const Duration(seconds: 1),
              child: Column(
                children: [
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _idTextController,
                      maxLines: 1,
                      decoration: const InputDecoration(
                        labelText: '아이디',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _pwdTextController,
                      obscureText: true,
                      maxLines: 1,
                      decoration: const InputDecoration(
                        labelText: '비밀번호',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  buttonJoinNLogin(context),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget buttonJoinNLogin(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/sign'),
            child: const Text('회원가입')),
        TextButton(
            onPressed: () async {
              if (_idTextController!.value.text.isEmpty ||
                  _pwdTextController!.value.text.isEmpty) {
                MakeDialog.build(context, '빈칸이 있습니다.');
              } else {
                final snapshot =
                    await _ref!.child(_idTextController!.value.text).get();
                if (!mounted) return;
                if (!snapshot.exists) {
                  MakeDialog.build(context, '아이디가 없습니다.');
                } else {
                  final castedSnapshot =
                      snapshot.value as Map<dynamic, dynamic>;

                  final mapData =
                      Map<String, dynamic>.from(castedSnapshot.values.single);
                  User user = User.fromJson(mapData);
                  var bytes = utf8.encode(_pwdTextController!.value.text);
                  var digest = sha1.convert(bytes);
                  print('user.pw: ${user.pw}, digest: ${digest.toString()}');
                  if (user.pw == digest.toString()) {
                    Navigator.of(context).pushReplacementNamed("/main",
                        arguments: _idTextController!.value.text);
                  } else {
                    MakeDialog.build(context, '비밀번호가 틀립니다.');
                  }
                }
              }
            },
            child: const Text('로그인'))
      ],
    );
  }
}
