// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'media.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MediaSize _$MediaSizeFromJson(Map<String, dynamic> json) {
  return _MediaSize.fromJson(json);
}

/// @nodoc
mixin _$MediaSize {
  String? get url => throw _privateConstructorUsedError;
  int? get width => throw _privateConstructorUsedError;
  int? get height => throw _privateConstructorUsedError;
  String? get mimeType => throw _privateConstructorUsedError;
  int? get filesize => throw _privateConstructorUsedError;
  String? get filename => throw _privateConstructorUsedError;

  /// Serializes this MediaSize to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MediaSize
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MediaSizeCopyWith<MediaSize> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MediaSizeCopyWith<$Res> {
  factory $MediaSizeCopyWith(MediaSize value, $Res Function(MediaSize) then) =
      _$MediaSizeCopyWithImpl<$Res, MediaSize>;
  @useResult
  $Res call({
    String? url,
    int? width,
    int? height,
    String? mimeType,
    int? filesize,
    String? filename,
  });
}

/// @nodoc
class _$MediaSizeCopyWithImpl<$Res, $Val extends MediaSize>
    implements $MediaSizeCopyWith<$Res> {
  _$MediaSizeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MediaSize
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = freezed,
    Object? width = freezed,
    Object? height = freezed,
    Object? mimeType = freezed,
    Object? filesize = freezed,
    Object? filename = freezed,
  }) {
    return _then(
      _value.copyWith(
            url: freezed == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String?,
            width: freezed == width
                ? _value.width
                : width // ignore: cast_nullable_to_non_nullable
                      as int?,
            height: freezed == height
                ? _value.height
                : height // ignore: cast_nullable_to_non_nullable
                      as int?,
            mimeType: freezed == mimeType
                ? _value.mimeType
                : mimeType // ignore: cast_nullable_to_non_nullable
                      as String?,
            filesize: freezed == filesize
                ? _value.filesize
                : filesize // ignore: cast_nullable_to_non_nullable
                      as int?,
            filename: freezed == filename
                ? _value.filename
                : filename // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MediaSizeImplCopyWith<$Res>
    implements $MediaSizeCopyWith<$Res> {
  factory _$$MediaSizeImplCopyWith(
    _$MediaSizeImpl value,
    $Res Function(_$MediaSizeImpl) then,
  ) = __$$MediaSizeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? url,
    int? width,
    int? height,
    String? mimeType,
    int? filesize,
    String? filename,
  });
}

/// @nodoc
class __$$MediaSizeImplCopyWithImpl<$Res>
    extends _$MediaSizeCopyWithImpl<$Res, _$MediaSizeImpl>
    implements _$$MediaSizeImplCopyWith<$Res> {
  __$$MediaSizeImplCopyWithImpl(
    _$MediaSizeImpl _value,
    $Res Function(_$MediaSizeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MediaSize
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = freezed,
    Object? width = freezed,
    Object? height = freezed,
    Object? mimeType = freezed,
    Object? filesize = freezed,
    Object? filename = freezed,
  }) {
    return _then(
      _$MediaSizeImpl(
        url: freezed == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String?,
        width: freezed == width
            ? _value.width
            : width // ignore: cast_nullable_to_non_nullable
                  as int?,
        height: freezed == height
            ? _value.height
            : height // ignore: cast_nullable_to_non_nullable
                  as int?,
        mimeType: freezed == mimeType
            ? _value.mimeType
            : mimeType // ignore: cast_nullable_to_non_nullable
                  as String?,
        filesize: freezed == filesize
            ? _value.filesize
            : filesize // ignore: cast_nullable_to_non_nullable
                  as int?,
        filename: freezed == filename
            ? _value.filename
            : filename // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MediaSizeImpl implements _MediaSize {
  const _$MediaSizeImpl({
    this.url,
    this.width,
    this.height,
    this.mimeType,
    this.filesize,
    this.filename,
  });

  factory _$MediaSizeImpl.fromJson(Map<String, dynamic> json) =>
      _$$MediaSizeImplFromJson(json);

  @override
  final String? url;
  @override
  final int? width;
  @override
  final int? height;
  @override
  final String? mimeType;
  @override
  final int? filesize;
  @override
  final String? filename;

  @override
  String toString() {
    return 'MediaSize(url: $url, width: $width, height: $height, mimeType: $mimeType, filesize: $filesize, filename: $filename)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MediaSizeImpl &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType) &&
            (identical(other.filesize, filesize) ||
                other.filesize == filesize) &&
            (identical(other.filename, filename) ||
                other.filename == filename));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    url,
    width,
    height,
    mimeType,
    filesize,
    filename,
  );

  /// Create a copy of MediaSize
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MediaSizeImplCopyWith<_$MediaSizeImpl> get copyWith =>
      __$$MediaSizeImplCopyWithImpl<_$MediaSizeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MediaSizeImplToJson(this);
  }
}

abstract class _MediaSize implements MediaSize {
  const factory _MediaSize({
    final String? url,
    final int? width,
    final int? height,
    final String? mimeType,
    final int? filesize,
    final String? filename,
  }) = _$MediaSizeImpl;

  factory _MediaSize.fromJson(Map<String, dynamic> json) =
      _$MediaSizeImpl.fromJson;

  @override
  String? get url;
  @override
  int? get width;
  @override
  int? get height;
  @override
  String? get mimeType;
  @override
  int? get filesize;
  @override
  String? get filename;

  /// Create a copy of MediaSize
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MediaSizeImplCopyWith<_$MediaSizeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MediaSizes _$MediaSizesFromJson(Map<String, dynamic> json) {
  return _MediaSizes.fromJson(json);
}

/// @nodoc
mixin _$MediaSizes {
  MediaSize? get thumbnail => throw _privateConstructorUsedError;
  MediaSize? get card => throw _privateConstructorUsedError;
  MediaSize? get hero => throw _privateConstructorUsedError;

  /// Serializes this MediaSizes to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MediaSizes
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MediaSizesCopyWith<MediaSizes> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MediaSizesCopyWith<$Res> {
  factory $MediaSizesCopyWith(
    MediaSizes value,
    $Res Function(MediaSizes) then,
  ) = _$MediaSizesCopyWithImpl<$Res, MediaSizes>;
  @useResult
  $Res call({MediaSize? thumbnail, MediaSize? card, MediaSize? hero});

  $MediaSizeCopyWith<$Res>? get thumbnail;
  $MediaSizeCopyWith<$Res>? get card;
  $MediaSizeCopyWith<$Res>? get hero;
}

/// @nodoc
class _$MediaSizesCopyWithImpl<$Res, $Val extends MediaSizes>
    implements $MediaSizesCopyWith<$Res> {
  _$MediaSizesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MediaSizes
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? thumbnail = freezed,
    Object? card = freezed,
    Object? hero = freezed,
  }) {
    return _then(
      _value.copyWith(
            thumbnail: freezed == thumbnail
                ? _value.thumbnail
                : thumbnail // ignore: cast_nullable_to_non_nullable
                      as MediaSize?,
            card: freezed == card
                ? _value.card
                : card // ignore: cast_nullable_to_non_nullable
                      as MediaSize?,
            hero: freezed == hero
                ? _value.hero
                : hero // ignore: cast_nullable_to_non_nullable
                      as MediaSize?,
          )
          as $Val,
    );
  }

  /// Create a copy of MediaSizes
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MediaSizeCopyWith<$Res>? get thumbnail {
    if (_value.thumbnail == null) {
      return null;
    }

    return $MediaSizeCopyWith<$Res>(_value.thumbnail!, (value) {
      return _then(_value.copyWith(thumbnail: value) as $Val);
    });
  }

  /// Create a copy of MediaSizes
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MediaSizeCopyWith<$Res>? get card {
    if (_value.card == null) {
      return null;
    }

    return $MediaSizeCopyWith<$Res>(_value.card!, (value) {
      return _then(_value.copyWith(card: value) as $Val);
    });
  }

  /// Create a copy of MediaSizes
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MediaSizeCopyWith<$Res>? get hero {
    if (_value.hero == null) {
      return null;
    }

    return $MediaSizeCopyWith<$Res>(_value.hero!, (value) {
      return _then(_value.copyWith(hero: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MediaSizesImplCopyWith<$Res>
    implements $MediaSizesCopyWith<$Res> {
  factory _$$MediaSizesImplCopyWith(
    _$MediaSizesImpl value,
    $Res Function(_$MediaSizesImpl) then,
  ) = __$$MediaSizesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({MediaSize? thumbnail, MediaSize? card, MediaSize? hero});

  @override
  $MediaSizeCopyWith<$Res>? get thumbnail;
  @override
  $MediaSizeCopyWith<$Res>? get card;
  @override
  $MediaSizeCopyWith<$Res>? get hero;
}

/// @nodoc
class __$$MediaSizesImplCopyWithImpl<$Res>
    extends _$MediaSizesCopyWithImpl<$Res, _$MediaSizesImpl>
    implements _$$MediaSizesImplCopyWith<$Res> {
  __$$MediaSizesImplCopyWithImpl(
    _$MediaSizesImpl _value,
    $Res Function(_$MediaSizesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MediaSizes
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? thumbnail = freezed,
    Object? card = freezed,
    Object? hero = freezed,
  }) {
    return _then(
      _$MediaSizesImpl(
        thumbnail: freezed == thumbnail
            ? _value.thumbnail
            : thumbnail // ignore: cast_nullable_to_non_nullable
                  as MediaSize?,
        card: freezed == card
            ? _value.card
            : card // ignore: cast_nullable_to_non_nullable
                  as MediaSize?,
        hero: freezed == hero
            ? _value.hero
            : hero // ignore: cast_nullable_to_non_nullable
                  as MediaSize?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MediaSizesImpl implements _MediaSizes {
  const _$MediaSizesImpl({this.thumbnail, this.card, this.hero});

  factory _$MediaSizesImpl.fromJson(Map<String, dynamic> json) =>
      _$$MediaSizesImplFromJson(json);

  @override
  final MediaSize? thumbnail;
  @override
  final MediaSize? card;
  @override
  final MediaSize? hero;

  @override
  String toString() {
    return 'MediaSizes(thumbnail: $thumbnail, card: $card, hero: $hero)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MediaSizesImpl &&
            (identical(other.thumbnail, thumbnail) ||
                other.thumbnail == thumbnail) &&
            (identical(other.card, card) || other.card == card) &&
            (identical(other.hero, hero) || other.hero == hero));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, thumbnail, card, hero);

  /// Create a copy of MediaSizes
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MediaSizesImplCopyWith<_$MediaSizesImpl> get copyWith =>
      __$$MediaSizesImplCopyWithImpl<_$MediaSizesImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MediaSizesImplToJson(this);
  }
}

abstract class _MediaSizes implements MediaSizes {
  const factory _MediaSizes({
    final MediaSize? thumbnail,
    final MediaSize? card,
    final MediaSize? hero,
  }) = _$MediaSizesImpl;

  factory _MediaSizes.fromJson(Map<String, dynamic> json) =
      _$MediaSizesImpl.fromJson;

  @override
  MediaSize? get thumbnail;
  @override
  MediaSize? get card;
  @override
  MediaSize? get hero;

  /// Create a copy of MediaSizes
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MediaSizesImplCopyWith<_$MediaSizesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Media _$MediaFromJson(Map<String, dynamic> json) {
  return _Media.fromJson(json);
}

/// @nodoc
mixin _$Media {
  String get id => throw _privateConstructorUsedError;
  String get alt => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  String get filename => throw _privateConstructorUsedError;
  String get mimeType => throw _privateConstructorUsedError;
  int get filesize => throw _privateConstructorUsedError;
  int? get width => throw _privateConstructorUsedError;
  int? get height => throw _privateConstructorUsedError;
  MediaSizes? get sizes => throw _privateConstructorUsedError;

  /// Serializes this Media to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Media
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MediaCopyWith<Media> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MediaCopyWith<$Res> {
  factory $MediaCopyWith(Media value, $Res Function(Media) then) =
      _$MediaCopyWithImpl<$Res, Media>;
  @useResult
  $Res call({
    String id,
    String alt,
    String url,
    String filename,
    String mimeType,
    int filesize,
    int? width,
    int? height,
    MediaSizes? sizes,
  });

  $MediaSizesCopyWith<$Res>? get sizes;
}

/// @nodoc
class _$MediaCopyWithImpl<$Res, $Val extends Media>
    implements $MediaCopyWith<$Res> {
  _$MediaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Media
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? alt = null,
    Object? url = null,
    Object? filename = null,
    Object? mimeType = null,
    Object? filesize = null,
    Object? width = freezed,
    Object? height = freezed,
    Object? sizes = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            alt: null == alt
                ? _value.alt
                : alt // ignore: cast_nullable_to_non_nullable
                      as String,
            url: null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String,
            filename: null == filename
                ? _value.filename
                : filename // ignore: cast_nullable_to_non_nullable
                      as String,
            mimeType: null == mimeType
                ? _value.mimeType
                : mimeType // ignore: cast_nullable_to_non_nullable
                      as String,
            filesize: null == filesize
                ? _value.filesize
                : filesize // ignore: cast_nullable_to_non_nullable
                      as int,
            width: freezed == width
                ? _value.width
                : width // ignore: cast_nullable_to_non_nullable
                      as int?,
            height: freezed == height
                ? _value.height
                : height // ignore: cast_nullable_to_non_nullable
                      as int?,
            sizes: freezed == sizes
                ? _value.sizes
                : sizes // ignore: cast_nullable_to_non_nullable
                      as MediaSizes?,
          )
          as $Val,
    );
  }

  /// Create a copy of Media
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MediaSizesCopyWith<$Res>? get sizes {
    if (_value.sizes == null) {
      return null;
    }

    return $MediaSizesCopyWith<$Res>(_value.sizes!, (value) {
      return _then(_value.copyWith(sizes: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MediaImplCopyWith<$Res> implements $MediaCopyWith<$Res> {
  factory _$$MediaImplCopyWith(
    _$MediaImpl value,
    $Res Function(_$MediaImpl) then,
  ) = __$$MediaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String alt,
    String url,
    String filename,
    String mimeType,
    int filesize,
    int? width,
    int? height,
    MediaSizes? sizes,
  });

  @override
  $MediaSizesCopyWith<$Res>? get sizes;
}

/// @nodoc
class __$$MediaImplCopyWithImpl<$Res>
    extends _$MediaCopyWithImpl<$Res, _$MediaImpl>
    implements _$$MediaImplCopyWith<$Res> {
  __$$MediaImplCopyWithImpl(
    _$MediaImpl _value,
    $Res Function(_$MediaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Media
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? alt = null,
    Object? url = null,
    Object? filename = null,
    Object? mimeType = null,
    Object? filesize = null,
    Object? width = freezed,
    Object? height = freezed,
    Object? sizes = freezed,
  }) {
    return _then(
      _$MediaImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        alt: null == alt
            ? _value.alt
            : alt // ignore: cast_nullable_to_non_nullable
                  as String,
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
        filename: null == filename
            ? _value.filename
            : filename // ignore: cast_nullable_to_non_nullable
                  as String,
        mimeType: null == mimeType
            ? _value.mimeType
            : mimeType // ignore: cast_nullable_to_non_nullable
                  as String,
        filesize: null == filesize
            ? _value.filesize
            : filesize // ignore: cast_nullable_to_non_nullable
                  as int,
        width: freezed == width
            ? _value.width
            : width // ignore: cast_nullable_to_non_nullable
                  as int?,
        height: freezed == height
            ? _value.height
            : height // ignore: cast_nullable_to_non_nullable
                  as int?,
        sizes: freezed == sizes
            ? _value.sizes
            : sizes // ignore: cast_nullable_to_non_nullable
                  as MediaSizes?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MediaImpl implements _Media {
  const _$MediaImpl({
    required this.id,
    required this.alt,
    required this.url,
    required this.filename,
    required this.mimeType,
    required this.filesize,
    this.width,
    this.height,
    this.sizes,
  });

  factory _$MediaImpl.fromJson(Map<String, dynamic> json) =>
      _$$MediaImplFromJson(json);

  @override
  final String id;
  @override
  final String alt;
  @override
  final String url;
  @override
  final String filename;
  @override
  final String mimeType;
  @override
  final int filesize;
  @override
  final int? width;
  @override
  final int? height;
  @override
  final MediaSizes? sizes;

  @override
  String toString() {
    return 'Media(id: $id, alt: $alt, url: $url, filename: $filename, mimeType: $mimeType, filesize: $filesize, width: $width, height: $height, sizes: $sizes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MediaImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.alt, alt) || other.alt == alt) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.filename, filename) ||
                other.filename == filename) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType) &&
            (identical(other.filesize, filesize) ||
                other.filesize == filesize) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.sizes, sizes) || other.sizes == sizes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    alt,
    url,
    filename,
    mimeType,
    filesize,
    width,
    height,
    sizes,
  );

  /// Create a copy of Media
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MediaImplCopyWith<_$MediaImpl> get copyWith =>
      __$$MediaImplCopyWithImpl<_$MediaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MediaImplToJson(this);
  }
}

abstract class _Media implements Media {
  const factory _Media({
    required final String id,
    required final String alt,
    required final String url,
    required final String filename,
    required final String mimeType,
    required final int filesize,
    final int? width,
    final int? height,
    final MediaSizes? sizes,
  }) = _$MediaImpl;

  factory _Media.fromJson(Map<String, dynamic> json) = _$MediaImpl.fromJson;

  @override
  String get id;
  @override
  String get alt;
  @override
  String get url;
  @override
  String get filename;
  @override
  String get mimeType;
  @override
  int get filesize;
  @override
  int? get width;
  @override
  int? get height;
  @override
  MediaSizes? get sizes;

  /// Create a copy of Media
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MediaImplCopyWith<_$MediaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
