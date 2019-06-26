import 'package:json_annotation/json_annotation.dart';

part 'list_model.g.dart';


@JsonSerializable()
class listModel extends Object {

  @JsonKey(name: 'errno')
  int errno;

  @JsonKey(name: 'errmsg')
  String errmsg;

  @JsonKey(name: 'data')
  Data data;

  listModel(this.errno,this.errmsg,this.data,);

  factory listModel.fromJson(Map<String, dynamic> srcJson) => _$listModelFromJson(srcJson);

}


@JsonSerializable()
class Data extends Object {

  @JsonKey(name: 'count')
  int count;

  @JsonKey(name: 'totalPages')
  int totalPages;

  @JsonKey(name: 'pageSize')
  int pageSize;

  @JsonKey(name: 'currentPage')
  int currentPage;

  @JsonKey(name: 'data')
  List<Data> data;

  Data(this.count,this.totalPages,this.pageSize,this.currentPage,this.data,);

  factory Data.fromJson(Map<String, dynamic> srcJson) => _$DataFromJson(srcJson);

}


@JsonSerializable()
class ListData extends Object {

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'userId')
  int userId;

  @JsonKey(name: 'content')
  String content;

  @JsonKey(name: 'open')
  int open;

  @JsonKey(name: 'public')
  int public;

  @JsonKey(name: 'read')
  int read;

  @JsonKey(name: 'like')
  int like;

  @JsonKey(name: 'title')
  String title;

  @JsonKey(name: 'create_time')
  String createTime;

  @JsonKey(name: 'cover')
  String cover;

  @JsonKey(name: 'created')
  String created;

  ListData(this.id,this.userId,this.content,this.open,this.public,this.read,this.like,this.title,this.createTime,this.cover,this.created,);

  factory ListData.fromJson(Map<String, dynamic> srcJson) => _$ListDataFromJson(srcJson);

}