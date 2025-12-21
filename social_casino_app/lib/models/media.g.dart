// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MediaSizeImpl _$$MediaSizeImplFromJson(Map<String, dynamic> json) =>
    _$MediaSizeImpl(
      url: json['url'] as String?,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      mimeType: json['mimeType'] as String?,
      filesize: (json['filesize'] as num?)?.toInt(),
      filename: json['filename'] as String?,
    );

Map<String, dynamic> _$$MediaSizeImplToJson(_$MediaSizeImpl instance) =>
    <String, dynamic>{
      'url': instance.url,
      'width': instance.width,
      'height': instance.height,
      'mimeType': instance.mimeType,
      'filesize': instance.filesize,
      'filename': instance.filename,
    };

_$MediaSizesImpl _$$MediaSizesImplFromJson(Map<String, dynamic> json) =>
    _$MediaSizesImpl(
      thumbnail: json['thumbnail'] == null
          ? null
          : MediaSize.fromJson(json['thumbnail'] as Map<String, dynamic>),
      card: json['card'] == null
          ? null
          : MediaSize.fromJson(json['card'] as Map<String, dynamic>),
      hero: json['hero'] == null
          ? null
          : MediaSize.fromJson(json['hero'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$MediaSizesImplToJson(_$MediaSizesImpl instance) =>
    <String, dynamic>{
      'thumbnail': instance.thumbnail,
      'card': instance.card,
      'hero': instance.hero,
    };

_$MediaImpl _$$MediaImplFromJson(Map<String, dynamic> json) => _$MediaImpl(
  id: json['id'] as String,
  alt: json['alt'] as String,
  url: json['url'] as String,
  filename: json['filename'] as String,
  mimeType: json['mimeType'] as String,
  filesize: (json['filesize'] as num).toInt(),
  width: (json['width'] as num?)?.toInt(),
  height: (json['height'] as num?)?.toInt(),
  sizes: json['sizes'] == null
      ? null
      : MediaSizes.fromJson(json['sizes'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$MediaImplToJson(_$MediaImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'alt': instance.alt,
      'url': instance.url,
      'filename': instance.filename,
      'mimeType': instance.mimeType,
      'filesize': instance.filesize,
      'width': instance.width,
      'height': instance.height,
      'sizes': instance.sizes,
    };
