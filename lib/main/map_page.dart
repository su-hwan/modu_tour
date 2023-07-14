import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:modu_tour/data/tour.dart';
import 'package:modu_tour/main/tour_detail_page.dart';
import 'package:modu_tour/util.dart';
import 'package:sqflite/sqflite.dart';

import 'package:modu_tour/data/list_data.dart';

class MapPage extends StatefulWidget {
  final DatabaseReference? dbRef; //firebase db
  final Future<Database>? db; //sql lite db
  final String? id; //user id

  const MapPage({super.key, this.dbRef, this.db, this.id});

  @override
  State<MapPage> createState() => _MapPageState();
}

const String AUTH_KEY =
    'I0J4Z80b%2Bpbd8byjRxkwQtZEJIFlpdWN9Fptdtod7jvTZ3f8GZdiDy0qRjl0TJNQJzjyhQrFfHPmmTY7TYISZg%3D%3D'; //오픈 API 키

class _MapPageState extends State<MapPage> {
  List<DropdownMenuItem<Item>> list = List.empty(growable: true);
  List<DropdownMenuItem<Item>> subList = List.empty(growable: true);
  List<TourData> tourData = List.empty(growable: true);
  final ScrollController _scrollController = ScrollController();

  Item? area;
  Item? kind;
  int page = 1;

  @override
  void initState() {
    super.initState();
    list = Area().seoulArea;
    subList = Kind().kinds;

    area = list[0].value;
    kind = subList[0].value;

    //스크롤바 맨 아래까지 도달하면 다음 페이지의 tourData 가져옴
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange) {
        page++;
        getAreaList(area: area!.value, contentTypeId: kind!.value, page: page);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('검색하기'),
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                DropdownButton<Item>(
                    items: list,
                    value: area,
                    style: const TextStyle(color: Colors.black),
                    onChanged: (value) {
                      Item selectedItem = value!;
                      setState(() {
                        area = selectedItem;
                      });
                    }),
                const SizedBox(width: 10),
                DropdownButton<Item>(
                    items: subList,
                    value: kind,
                    onChanged: (value) {
                      Item selectedItem = value!;
                      setState(() {
                        kind = selectedItem;
                      });
                    }),
                const SizedBox(width: 10),
                ElevatedButton(
                    onPressed: () {
                      page = 1;
                      tourData.clear();
                      getAreaList(
                          area: area!.value,
                          contentTypeId: kind!.value,
                          page: page);
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.blueAccent),
                    ),
                    child: const Text(
                      '검색하기',
                      style: TextStyle(color: Colors.white),
                    )),
              ],
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: tourData.length,
                  controller: _scrollController,
                  itemBuilder: (context, index) {
                    return Card(
                      child: InkWell(
                        //InkWell : 제스처 안되는 자식위젯 onTap 기능 제공
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => TourDetailPage(
                                id: widget.id,
                                tourData: tourData[index],
                                index: index,
                                databaseRef: widget.dbRef,
                              ),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Hero(
                              //animation 작동 위젯
                              tag: 'tourinfo$index',
                              child: Container(
                                margin: const EdgeInsets.all(10),
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.black, width: 1),
                                  image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: getImage(tourData[index].imagePath),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 150,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    tourData[index].title!,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text('주소 : ${tourData[index].address}'),
                                  tourData[index].tel != null
                                      ? Text('전화번호 : ${tourData[index].tel}')
                                      : Container(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider getImage(final imagePath) {
    if (imagePath != null && imagePath != '') {
      return NetworkImage(imagePath);
    } else {
      return const AssetImage('repo/images/map_location.png');
    }
  }

  void getAreaList(
      {required int area,
      required int contentTypeId,
      required int page}) async {
    var url =
        'http://api.visitkorea.or.kr/openapi/service/rest/KorService/areaBasedList?'
        'ServiceKey=$AUTH_KEY&MobileOS=AND&MobileApp=ModuTour&_type=json&areaCode=1'
        '&numOfRows=10&sigunguCode=$area&pageNo=$page';
    if (contentTypeId != 0) {
      url += '&contentTypeId=$contentTypeId';
    }
    var response = await http.get(Uri.parse(url));
    String body = utf8.decode(response.bodyBytes);
    print(body);
    var json = jsonDecode(body);
    if (json['response']['header']['resultCode'] == '0000') {
      if (!mounted) return;
      if (json['response']['body']['items'] == '') {
        MakeDialog.build(context, '마지막 데이터 입니다.');
      } else {
        List jsonArray = json['response']['body']['items']['item'];
        for (var element in jsonArray) {
          setState(() {
            tourData.add(TourData.fromJson(element));
          });
        }
      }
    } else {
      print('error: 서버에서 데이터를 가져 올 수 없음');
    }
  }
}
