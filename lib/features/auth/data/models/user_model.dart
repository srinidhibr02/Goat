import '../../domain/entities/app_user.dart';

/// Data model extending [AppUser] with JSON serialisation.
class UserModel extends AppUser {
  const UserModel({
    required super.uid,
    super.email,
    super.displayName,
    super.photoUrl,
    super.phoneNumber,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        uid: json['uid'] as String,
        email: json['email'] as String?,
        displayName: json['displayName'] as String?,
        photoUrl: json['photoUrl'] as String?,
        phoneNumber: json['phoneNumber'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'phoneNumber': phoneNumber,
      };
}
