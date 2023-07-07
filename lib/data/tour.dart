// ignore_for_file: public_member_api_docs, sort_constructors_first

class TourData {
  String? title;
  String? tel;
  String? zipcode;
  String? address;
  var id;
  var mapx;
  var mapy;
  String? imagePath;

  TourData({
    this.title,
    this.tel,
    this.zipcode,
    this.address,
    this.id,
    this.mapx,
    this.mapy,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'tel': tel,
      'zipcode': zipcode,
      'address': address,
      'mapx': mapx,
      'mapy': mapy,
      'imagePath': imagePath,
    };
  }

  TourData.fromJson(Map map)
      : title = map['title'],
        tel = map['tel'],
        zipcode = map['zipcode'],
        address = map['addr1']+map['addr2'],
        id = map['id'],
        mapx = map['mapx'],
        mapy = map['mapy'],
        imagePath = map['firstimage'];
}
