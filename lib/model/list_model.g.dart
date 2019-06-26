// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

listModel _$listModelFromJson(Map<String, dynamic> json) {
  return listModel(
      json['errno'] as int,
      json['errmsg'] as String,
      json['data'] == null
          ? null
          : Data.fromJson(json['data'] as Map<String, dynamic>));
}

Map<String, dynamic> _$listModelToJson(listModel instance) => <String, dynamic>{
      'errno': instance.errno,
      'errmsg': instance.errmsg,
      'data': instance.data
    };

Data _$DataFromJson(Map<String, dynamic> json) {
  return Data(
      json['count'] as int,
      json['totalPages'] as int,
      json['pageSize'] as int,
      json['currentPage'] as int,
      (json['data'] as List)
          ?.map((e) =>
              e == null ? null : Data.fromJson(e as Map<String, dynamic>))
          ?.toList());
}

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
      'count': instance.count,
      'totalPages': instance.totalPages,
      'pageSize': instance.pageSize,
      'currentPage': instance.currentPage,
      'data': instance.data
    };

ListData _$ListDataFromJson(Map<String, dynamic> json) {
  return ListData(
      json['id'] as int,
      json['userId'] as int,
      json['content'] as String,
      json['open'] as int,
      json['public'] as int,
      json['read'] as int,
      json['like'] as int,
      json['title'] as String,
      json['create_time'] as String,
      json['cover'] as String,
      json['created'] as String);
}

Map<String, dynamic> _$ListDataToJson(ListData instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'content': instance.content,
      'open': instance.open,
      'public': instance.public,
      'read': instance.read,
      'like': instance.like,
      'title': instance.title,
      'create_time': instance.createTime,
      'cover': instance.cover,
      'created': instance.created
    };
