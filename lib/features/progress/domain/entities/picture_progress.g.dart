// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'picture_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PictureProgress _$PictureProgressFromJson(Map<String, dynamic> json) =>
    _PictureProgress(
      id: json['id'] as String,
      assetDir: json['dir'] as String,
      filled:
          (json['filled'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toSet() ??
          const <int>{},
      regionCount: (json['regions'] as num?)?.toInt() ?? 0,
      starred: json['starred'] as bool? ?? false,
    );

Map<String, dynamic> _$PictureProgressToJson(_PictureProgress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'dir': instance.assetDir,
      'filled': instance.filled.toList(),
      'regions': instance.regionCount,
      'starred': instance.starred,
    };
