class User {
  String id;
  String pw;
  String createTime;

  User({required this.id, required this.pw, required this.createTime});

  User.fromJson(Map<String, dynamic> data)
      : id = data['id'] ?? '',
        pw = data['pw'] ?? '',
        createTime = data['createTime'] ?? '';

  toJson() {
    return <String, String>{'id': id, 'pw': pw, 'createTime': createTime};
  }
}
