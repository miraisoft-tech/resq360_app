class LocalUser {
  LocalUser({
    this.userName,
    this.password,
  });

  LocalUser.fromJson(Map<String, dynamic> json) {
    userName = json['username'] as String;
    password = json['password'] as String;
  }
  String? userName;
  String? password;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['username'] = userName;
    data['password'] = password;

    return data;
  }
}
