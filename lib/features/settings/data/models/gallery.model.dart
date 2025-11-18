import 'dart:convert';

class Gallery {

    Gallery({
        this.id,
        this.providerId,
        this.imageUrl,
        this.imageId,
        this.caption,
        this.displayOrder,
        this.createdAt,
        this.updatedAt,
    });

    factory Gallery.fromJson(Map<String, dynamic> json) => Gallery(
        id: json['id'] as int,
        providerId: json['providerId'] as int ,
        imageUrl: json['imageUrl']as String,
        imageId: json['imageId']as String,
        caption: json['caption']as String,
        displayOrder: json['displayOrder']as int,
        createdAt: json['createdAt'] == null ? null : DateTime.parse(json['createdAt'] as String),
        updatedAt: json['updatedAt'] == null ? null : DateTime.parse(json['updatedAt'] as String),
    );

    factory Gallery.fromRawJson(String str) => Gallery.fromJson(json.decode(str) as Map<String, dynamic>);
    final int? id;
    final int? providerId;
    final String? imageUrl;
    final String? imageId;
    final String? caption;
    final int? displayOrder;
    final DateTime? createdAt;
    final DateTime? updatedAt;

    String toRawJson() => json.encode(toJson());

    Map<String, dynamic> toJson() => {
        'id': id,
        'providerId': providerId,
        'imageUrl': imageUrl,
        'imageId': imageId,
        'caption': caption,
        'displayOrder': displayOrder,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
    };
}
