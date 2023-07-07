import 'dart:async';
import 'dart:math' as math;

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:modu_tour/data/disable_info.dart';
import 'package:modu_tour/data/reviews.dart';
import 'package:modu_tour/data/tour.dart';

class TourDetailPage extends StatefulWidget {
  final TourData? tourData;
  final int? index;
  final DatabaseReference? databaseRef;
  final String? id;

  const TourDetailPage(
      {super.key, this.tourData, this.index, this.databaseRef, this.id});

  @override
  State<TourDetailPage> createState() => _TourDetailPageState();
}

class _TourDetailPageState extends State<TourDetailPage> {
  final Completer<GoogleMapController> _mapController = Completer();
  Map<MarkerId, Marker> markers = {};
  CameraPosition? _googleMapCamera;
  final TextEditingController _reviewController = TextEditingController();
  Marker? marker;
  List<Review> reviews = List.empty(growable: true);
  bool _disableWidget = false;
  DisableInfo? _disableInfo;
  double disableCheck1 = 0;
  double disableCheck2 = 0;

  @override
  void initState() {
    super.initState();
    widget.databaseRef!
        .child('tour')
        .child(widget.tourData!.id.toString())
        .child('review')
        .onChildAdded
        .listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          reviews.add(Review.fromSnapshot(event.snapshot));
        });
      }
    }); //widget.tourData!.listen

    _googleMapCamera = CameraPosition(
        target: LatLng(
          double.parse(widget.tourData!.mapy.toString()),
          double.parse(widget.tourData!.mapx.toString()),
        ),
        zoom: 16);
    MarkerId markerId = MarkerId(widget.tourData.hashCode.toString());
    marker = Marker(
      markerId: markerId,
      position: LatLng(
        double.parse(widget.tourData!.mapy.toString()),
        double.parse(widget.tourData!.mapx.toString()),
      ),
      flat: true,
    );
    markers[markerId] = marker!;
    getDisableInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                '${widget.tourData!.title}',
                style: const TextStyle(color: Colors.white, fontSize: 40),
              ),
              centerTitle: true,
              titlePadding: const EdgeInsets.only(top: 10),
            ),
            pinned: true,
            backgroundColor: Colors.deepOrangeAccent,
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(
                height: 20,
              ),
              Center(
                child: Column(
                  children: [
                    Hero(
                      tag: 'tourinfo${widget.index}',
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 1),
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: getImage(widget.tourData!.imagePath),
                            )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        widget.tourData!.address!,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    getGoogleMap(),
                    !_disableWidget ? setDisableWidget() : showDisableWidget(),
                  ],
                ),
              ),
            ]),
          ),
          SliverPersistentHeader(
            delegate: _HeaderDelegate(
              minHeight: 50,
              maxHeight: 100,
              child: Container(
                color: Colors.lightBlueAccent,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '후기',
                        style: TextStyle(fontSize: 30, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            pinned: true,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              childCount: reviews.length,
              (context, index) {
                return Card(
                  child: InkWell(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 10, bottom: 10, left: 10),
                      child: Text(
                        '${reviews[index].id} : ${reviews[index].review}',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                    onDoubleTap: () {
                      if (reviews[index].id == widget.id) {
                        widget.databaseRef!
                            .child('tour')
                            .child(widget.tourData!.id.toString())
                            .child('review')
                            .child(widget.id!)
                            .remove();
                        setState(() {
                          reviews.removeAt(index);
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return writeReviewDialog(context);
                      },
                    );
                  },
                  child: const Text('댓글 쓰기')),
            ]),
          ),
        ],
      ),
    );
  }

  //후기쓰기 팝업창
  Widget writeReviewDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('후기 쓰기'),
      content: TextField(
        controller: _reviewController,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Review review = Review(widget.id!, _reviewController.value.text,
                DateTime.now().toIso8601String());
            widget.databaseRef!
                .child('tour')
                .child(widget.tourData!.id.toString())
                .child('review')
                .child(widget.id!)
                .set(review);
          },
          child: const Text('후기 쓰기'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('종료하기'),
        ),
      ],
    );
  }

  void getDisableInfo() {
    widget.databaseRef!
        .child('tour')
        .child(widget.tourData!.id.toString())
        .onValue
        .listen((event) {
      // if (event.isDefinedAndNotNull) {
      if (event.snapshot.exists) {
        _disableInfo = DisableInfo.fromSnapshot(event.snapshot);
      }
      if (_disableInfo != null && _disableInfo!.id == null) {
        _disableWidget = false;
      } else {
        _disableWidget = true;
      }
      // }
    });
  }

  ImageProvider getImage(String? imagePath) {
    if (imagePath == null) {
      return const AssetImage('repo/images/map_location.png');
    } else {
      return NetworkImage(imagePath);
    }
  }

  Widget setDisableWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('데이터가 없습니다. 추가해 주세요'),
          Text('시각 장애인 이용 점수 : ${disableCheck1.floor()}'),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Slider(
              value: disableCheck1,
              min: 0,
              max: 10,
              onChanged: (value) {
                setState(() {
                  disableCheck1 = value;
                });
              },
            ),
          ),
          Text('청각 장애인 이용 점수 : ${disableCheck2.floor()}'),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Slider(
              value: disableCheck2,
              min: 0,
              max: 10,
              onChanged: (value) {
                setState(() {
                  disableCheck2 = value;
                });
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              DisableInfo info = DisableInfo(
                id: widget.id,
                disable1: disableCheck1.floor(),
                disable2: disableCheck2.floor(),
                createTime: DateTime.now().toIso8601String(),
              );
              widget.databaseRef!
                  .child('tour')
                  .child(widget.tourData!.id.toString())
                  .set(info.toJson())
                  .then((value) {
                setState(() {
                  _disableWidget = true;
                });
              });
            },
            child: const Text('데이터 저장하기'),
          ),
        ],
      ),
    );
  }

  Widget getGoogleMap() {
    return SizedBox(
      height: 40,
      width: MediaQuery.of(context).size.width - 50,
      //구글맵
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _googleMapCamera!,
        onMapCreated: (GoogleMapController controller) {
          _mapController.complete(controller);
        },
        markers: Set<Marker>.of(markers.values),
      ),
    );
  }

  Widget showDisableWidget() {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Icon(Icons.accessible, size: 40, color: Colors.orange),
              Text(
                '지체 장애 점수 : ${_disableInfo!.disable2}',
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Icon(Icons.remove_red_eye, size: 40, color: Colors.orange),
              Text(
                '시각 장애 점수 : ${_disableInfo!.disable1}',
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Text('작성자 : ${_disableInfo!.id}'),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _disableWidget = false;
              });
            },
            child: const Text('새로 작성하기'),
          ),
        ],
      ),
    );
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _HeaderDelegate(
      {required this.minHeight, required this.maxHeight, required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(
      child: child,
    );
  }

  @override
  double get maxExtent => math.max(maxHeight, minHeight);

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(_HeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
