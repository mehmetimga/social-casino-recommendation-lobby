import 'package:freezed_annotation/freezed_annotation.dart';

part 'media.freezed.dart';
part 'media.g.dart';

@freezed
class MediaSize with _$MediaSize {
  const factory MediaSize({
    String? url,
    int? width,
    int? height,
    String? mimeType,
    int? filesize,
    String? filename,
  }) = _MediaSize;

  factory MediaSize.fromJson(Map<String, dynamic> json) =>
      _$MediaSizeFromJson(json);
}

@freezed
class MediaSizes with _$MediaSizes {
  const factory MediaSizes({
    MediaSize? thumbnail,
    MediaSize? card,
    MediaSize? hero,
  }) = _MediaSizes;

  factory MediaSizes.fromJson(Map<String, dynamic> json) =>
      _$MediaSizesFromJson(json);
}

@freezed
class Media with _$Media {
  const factory Media({
    required String id,
    required String alt,
    required String url,
    required String filename,
    required String mimeType,
    required int filesize,
    int? width,
    int? height,
    MediaSizes? sizes,
  }) = _Media;

  factory Media.fromJson(Map<String, dynamic> json) => _$MediaFromJson(json);
}
