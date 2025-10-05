import 'package:resq360/core/models/api_response.dart';

class AuthResponse extends EmptyResponse {
  AuthResponse({
    this.token,
    this.firstName,
    this.lastName,
    this.email,
    this.address,
    this.phone,
    this.expDate,
    this.hasPIN,
    this.code,
    this.user,
  });

  AuthResponse.fromJson(Map<String, dynamic> json) {
    token = json['token'] as String?;
    firstName = json['firstName'] as String?;
    lastName = json['lastName'] as String?;
    email = json['email'] as String?;
    phone = json['phone'] as String?;
    expDate = json['expiresIn'] as String?;
    hasPIN = json['hasPIN'] as bool?;
    code = (json['code'] ?? json['reference']) as String?;
    if (json['user'] != null) {
      user = UserModel.fromJson(json['user'] as Map<String, dynamic>);
    } else {
      user = UserModel();
    }
  }

  String? token;
  String? firstName;
  String? lastName;
  String? email;
  String? address;
  String? phone;
  String? expDate;
  bool? hasPIN;
  String? code;
  UserModel? user;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['token'] = token;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['email'] = email;
    data['address'] = address;
    data['phone'] = phone;
    data['expDate'] = expDate;
    data['hasPIN'] = hasPIN;
    data['code'] = code;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }

  AuthResponse copyWith({
    String? token,
    String? firstName,
    String? lastName,
    String? email,
    String? address,
    String? phone,
    String? expDate,
    bool? hasPIN,
    String? code,
    UserModel? user,
  }) {
    return AuthResponse(
      token: token ?? this.token,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      expDate: expDate ?? this.expDate,
      hasPIN: hasPIN ?? this.hasPIN,
      code: code ?? this.code,
      user: user ?? this.user,
    );
  }
}

class UserModel extends EmptyResponse {
  UserModel({
    this.id,
    this.photoUrl,
    this.firstName,
    this.lastName,
    this.email,
    this.address,
    this.phone,
    this.state,
    this.accountState,
    this.code,
    this.isTruckAssigned,
    this.companyId,
    this.companyName,
    this.companyIconUrl,
    this.userId,
    this.referralCode,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String?,
    photoUrl: json['profilePic'] as String?,
    firstName: json['firstName'] as String?,
    lastName: json['lastName'] as String?,
    email: json['email'] as String?,
    address: json['address'] as String?,
    phone: json['phoneNumber'] as String?,
    state: json['state'] as String?,
    accountState: json['accountState'] as bool?,
    code: json['code'] as String?,
    isTruckAssigned: json['isTruckAssigned'] as bool?,
    companyId: json['companyId'] as String?,
    companyName: json['companyName'] as String?,
    companyIconUrl: json['companyIconUrl'] as String?,
    userId: json['userId'] as String?,
    referralCode: json['referralCode'] as String?,
  );

  final String? id;
  final String? photoUrl;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? address;
  final String? phone;
  final String? state;
  final bool? accountState;
  final String? code;
  final bool? isTruckAssigned;
  final String? companyId;
  final String? companyName;
  final String? companyIconUrl;
  final String? userId;
  final String? referralCode;

  Map<String, dynamic> toJson() => {
    'id': id,
    'profilePic': photoUrl,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'address': address,
    'phoneNumber': phone,
    'state': state,
    'accountState': accountState,
    'code': code,
    'isTruckAssigned': isTruckAssigned,
    'companyId': companyId,
    'companyName': companyName,
    'companyIconUrl': companyIconUrl,
    'userId': userId,
    'referralCode': referralCode,
  };

  UserModel copyWith({
    String? id,
    String? photoUrl,
    String? firstName,
    String? lastName,
    String? email,
    String? address,
    String? phone,
    String? state,
    bool? accountState,
    String? code,
    bool? isTruckAssigned,
    String? companyId,
    String? companyName,
    String? companyIconUrl,
    String? userId,
  }) {
    return UserModel(
      id: id ?? this.id,
      photoUrl: photoUrl ?? this.photoUrl,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      state: state ?? this.state,
      accountState: accountState ?? this.accountState,
      code: code ?? this.code,
      isTruckAssigned: isTruckAssigned ?? this.isTruckAssigned,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      companyIconUrl: companyIconUrl ?? this.companyIconUrl,
      userId: userId ?? this.userId,
    );
  }
}
