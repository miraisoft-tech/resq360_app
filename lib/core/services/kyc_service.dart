// import 'dart:developer';

// import 'package:dio/dio.dart';
// import 'package:resq360/core/models/api_response.dart';
// import 'package:resq360/core/services/base_api.dart';
// import 'package:resq360/features/customer/authentication/data/models/auth/identity_response.dart';
// import 'package:resq360/features/customer/authentication/data/models/auth/kyc_response.model.dart';
// import 'package:resq360/features/customer/authentication/data/models/auth/upload_response.model.dart';

// class KycRepo extends BaseAPI {
//   factory KycRepo() {
//     return instance;
//   }

//   KycRepo._internal();
//   static final KycRepo instance = KycRepo._internal();
  
//   // KYC

//   Future<ApiResult<UploadResponse>> uploadSingle({
//     required String filePath,
//   }) async {
//     try {
//       const url = '/upload/single';

//       final formData = FormData.fromMap({
//         'file': await MultipartFile.fromFile(filePath),
//       });

//       final res = await dio().post<Map<String, dynamic>>(url, data: formData);

//       log('${res.statusCode}');
//       log('${res.data}');

//       if (res.statusCode == 200 && res.data != null) {
//         final success = res.data!['success'] == true;

//         if (success) {
//           final dataList = res.data!['data'] as List<dynamic>;
//           final uploads =
//               dataList
//                   .map(
//                     (item) =>
//                         UploadResponse.fromJson(item as Map<String, dynamic>),
//                   )
//                   .toList();
//           log(
//             'suceeded in Uploading files: ${uploads.first.id} / ${uploads.first.url}',
//           );
//           // returns the first one
//           return ApiResult(data: uploads.first);
//         } else {
//           return ApiResult(
//             error: res.data!['message']?.toString() ?? 'Upload failed',
//           );
//         }
//       }

//       return ApiResult(
//         error: res.data?['message']?.toString() ?? 'Upload failed',
//       );
//     } on Exception catch (e, s) {
//       log('$e');
//       log('$s');
//       return ApiResult(error: '$e $s');
//     }
//   }

//   Future<ApiResult<KycResponse>> submitFaceId({
//     required String selfieImageUrl,
//     required String selfieImageId,
//   }) async {
//     try {
//       const url = '/kyc/submit/face-id';

//       final data = {
//         'selfieImageUrl': selfieImageUrl,
//         'selfieImageId': selfieImageId,
//       };

//       log('........Submitting Face ID with data: $data..........');
//       final res = await dio().post<Map<String, dynamic>>(url, data: data);
//       log('Raw data type1: ${res.data.runtimeType}');

//       log('${res.statusCode}');
//       log('${res.data}');
//       log('Raw data type2: ${res.data.runtimeType}');

//       if (res.statusCode == 200 && res.data != null) {
//         if (res.data is Map<String, dynamic>) {
//           final body = res.data;
//           final success = body?['success'] == true;

//           if (success) {
//             final response = KycResponse.fromJson(body!);
//             return ApiResult(data: response);
//           } else {
//             return ApiResult(
//               error: body!['message']?.toString() ?? 'Face ID submission failed',
//             );
//           }
//         } else {
//           return ApiResult(error: 'Invalid response format');
//         }
//       } else {
//         return ApiResult(error: 'Unexpected server response');
//       }
//     } on Exception catch (e, s) {
//       log('submitFaceId error: $e\n$s');
//       return ApiResult(error: e.toString());
//     }
//   }

//   Future<ApiResult<KycResponse>> uploadAndSubmitFaceId({
//     required String filePath,
//   }) async {
//     final uploadResult = await uploadSingle(filePath: filePath);

//     if (uploadResult.data == null) {
//       return ApiResult(error: uploadResult.error);
//     }

//     final upload = uploadResult.data!;
//     final submitResult = await submitFaceId(
//       selfieImageUrl: upload.url,
//       selfieImageId: upload.id,
//     );

//     return submitResult;
//   }

//   Future<ApiResult<IdentityResponse>> submitIdentity({
//     required String documentType,
//     required String documentUrl,
//   }) async {
//     const url = '/kyc/submit/identity'; // ensure leading slash

//     try {
//       final data = {
//         'documentType': documentType,
//         'documentUrl': documentUrl,
//       };

//       log('Submitting identity with data: $data');

//       final res = await dio().post<Map<String, dynamic>>(url, data: data);

//       log('${res.statusCode}');
//       log('${res.data}');

//       if (res.statusCode == 200 && res.data != null) {
//         final body = res.data!;
//         final success = body['success'] == true;

//         if (success) {
//           final identityResponse = IdentityResponse.fromJson(body);
//           return ApiResult(data: identityResponse);
//         } else {
//           return ApiResult(
//             error: body['message']?.toString() ?? 'Identity submission failed',
//           );
//         }
//       }

//       return ApiResult(error: 'Unexpected server response');
//     } on Exception catch (e, s) {
//       log('submitIdentity error: $e\n$s');
//       return ApiResult(error: e.toString());
//     }
//   }

//   Future<ApiResult<IdentityResponse>> uploadAndSubmitIdentity({
//     required String documentType,
//     required String filePath,
//   }) async {
//     // Upload the document file
//     final uploadResult = await uploadSingle(filePath: filePath);

//     if (uploadResult.data == null) {
//       return ApiResult(error: uploadResult.error);
//     }

//     final upload = uploadResult.data!;

//     // Submit the identity data
//     final submitResult = await submitIdentity(
//       documentType: documentType,
//       documentUrl: upload.url,
//     );

//     return submitResult;
//   }

//   Future<bool> submitKycAddress({
//     required String state,
//     required String city,
//     required String address,
//   }) async {
//     const url = '/kyc/submit/address-information';
//     try {
//       final data = {
//         'state': state,
//         'city': city,
//         'address': address,
//       };

//       final res = await dio().post<Map<String, dynamic>>(
//         url,
//         data: data,
//       );
//       log('${res.statusCode}');
//       log('${res.data}');

//       if (res.statusCode == 200 && res.data != null) {
//         final success = res.data!['success'] == true;

//         if (success) {
//           return true;
//         } else {
//           return false;
//         }
//       }
//       return false;
//     } on Exception catch (e) {
//       log('$e');
//       return false;
//     }
//   }

//   // Future<ApiResult<UserKycInfo>> getUserKycInfo() async {
//   //   const url = '/kyc/my-kyc';

//   //   try {
//   //     final res = await dio().get<Map<String, dynamic>>(url);

//   //     log(res.data);
//   //     if (res.statusCode == 200) {
//   //       final userKycInfo = UserKycInfo.fromJson(res.data!);
//   //       return ApiResult(data: userKycInfo);
//   //     } else {
//   //       final error = res.data?['message'];
//   //       log(error);
//   //       return ApiResult(
//   //         error: res.data!['message']?.toString() ?? "failed to get user's Kyc",
//   //       );
//   //     }
//   //   } on Exception catch (e) {
//   //     log(e);
//   //     return ApiResult(error: e.toString());
//   //   }
//   // }
// }
