class LocalUser {
  LocalUser({
    this.userName,
    this.password,
    this.userType,
  });

  LocalUser.fromJson(Map<String, dynamic> json) {
    userName = json['username'] as String;
    password = json['password'] as String;
    userType = json['userType'] as String;

  }
  String? userName;
  String? password;
  String? userType;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['username'] = userName;
    data['password'] = password;
    data['userType'] = password;


    return data;
  }
}
