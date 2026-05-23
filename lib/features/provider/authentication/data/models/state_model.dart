import 'package:resq360/core/models/api_response.dart';

class StateModel extends EmptyResponse {
  StateModel({this.name});

  factory StateModel.fromJson(String stateName) {
    return StateModel(name: stateName);
  }

  String? name;

  @override
  List<Object?> get props => [name];
}
