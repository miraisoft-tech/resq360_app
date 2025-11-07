class CustomerUserModel {
  CustomerUserModel({
    this.id,
    this.email,
    this.fullName,
    this.profileImage,
    this.phoneNumber,
    this.isEmailVerified = false,
    this.isKYCVerified = false,
    this.kycStatus,
    this.createdAt,
    this.updatedAt,
    this.wallet,
    this.location,
  });

  factory CustomerUserModel.fromJson(Map<String, dynamic> json) {
    return CustomerUserModel(
      id: json['id'] as int?,
      email: json['email'] as String?,
      fullName: json['fullName'] as String?,
      profileImage: json['profileImage'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isKYCVerified: json['isKYCVerified'] as bool? ?? false,
      kycStatus: json['kycStatus'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      wallet: json['wallet'] != null
          ? Wallet.fromJson(json['wallet'] as Map<String, dynamic>)
          : null,
      location: (json['Location'] as List?)
          ?.map((e) => Location.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final int? id;
  final String? email;
  final String? fullName;
  final String? profileImage;
  final String? phoneNumber;
  final bool isEmailVerified;
  final bool isKYCVerified;
  final String? kycStatus;
  final String? createdAt;
  final String? updatedAt;
  final Wallet? wallet;
  final List<Location>? location;

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'fullName': fullName,
        'profileImage': profileImage,
        'phoneNumber': phoneNumber,
        'isEmailVerified': isEmailVerified,
        'isKYCVerified': isKYCVerified,
        'kycStatus': kycStatus,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'wallet': wallet?.toJson(),
        'Location': location?.map((e) => e.toJson()).toList(),
      };
}

class Wallet {
  Wallet({
    this.balance,
    this.availableBalance,
    this.currency,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
        balance: json['balance']?.toString(),
        availableBalance: json['availableBalance']?.toString(),
        currency: json['currency'] as String?,
      );

  final String? balance;
  final String? availableBalance;
  final String? currency;

  Map<String, dynamic> toJson() => {
        'balance': balance,
        'availableBalance': availableBalance,
        'currency': currency,
      };
}

class Location {
  Location({
    this.id,
    this.city,
    this.state,
    this.latitude,
    this.longitude,
    this.address,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        id: json['id'] as int?,
        city: json['city'] as String?,
        state: json['state'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        address: json['address'] as String?,
      );

  final int? id;
  final String? city;
  final String? state;
  final double? latitude;
  final double? longitude;
  final String? address;

  Map<String, dynamic> toJson() => {
        'id': id,
        'city': city,
        'state': state,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
      };
}
