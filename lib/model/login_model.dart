import 'package:json_annotation/json_annotation.dart';

part 'login_model.g.dart';


@JsonSerializable()
class LoginModel extends Object{

  @JsonKey(name: 'errno')
  int errno;

  @JsonKey(name: 'errmsg')
  String errmsg;

  @JsonKey(name: 'data')
  dynamic data;

  LoginModel(this.errno,this.errmsg,this.data,);

  factory LoginModel.fromJson(Map<String, dynamic> srcJson) => _$LoginModelFromJson(srcJson);

}


