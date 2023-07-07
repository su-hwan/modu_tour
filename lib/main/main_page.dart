import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:modu_tour/main/favorite_page.dart';
import 'package:modu_tour/main/setting_page.dart';

import 'map_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  late FirebaseDatabase _database;
  late DatabaseReference _ref;

  late TabController _tabController;
  late String id;

  @override
  void initState() {
    super.initState();
    _database = FirebaseDatabase.instance;
    _ref = _database.ref('tour');

    _tabController = TabController(length: 3, vsync: this);
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //화면이동 route 방식에서 argument 받아 올 때 이용함
    final id = (ModalRoute.of(context)!.settings.arguments as String?)!;

    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: [
          MapPage(id: id, db: null, dbRef: _ref,),
          FavoritePage(),
          SettingPage(),
        ],
      ),
      bottomNavigationBar: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(icon: Icon(Icons.map)),
          Tab(icon: Icon(Icons.star)),
          Tab(icon: Icon(Icons.settings)),
        ],
        labelColor: Colors.amber,
        indicatorColor: Colors.deepOrangeAccent,

      ),
    );
  }
}
