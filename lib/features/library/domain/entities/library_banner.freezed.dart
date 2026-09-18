// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'library_banner.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LibraryBanner {

 String get id; String get title;/// Banner artwork; `null` until the image is added.
 String? get imageAsset;
/// Create a copy of LibraryBanner
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LibraryBannerCopyWith<LibraryBanner> get copyWith => _$LibraryBannerCopyWithImpl<LibraryBanner>(this as LibraryBanner, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LibraryBanner;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LibraryBanner&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.imageAsset, _this.imageAsset) || other.imageAsset == _this.imageAsset));
}


@override
int get hashCode {
  final _this = this as LibraryBanner;
  return Object.hash(runtimeType,_this.id,_this.title,_this.imageAsset);
}

@override
String toString() {
  final _this = this as LibraryBanner;
  return 'LibraryBanner(id: ${_this.id}, title: ${_this.title}, imageAsset: ${_this.imageAsset})';
}


}

/// @nodoc
abstract mixin class $LibraryBannerCopyWith<$Res>  {
  factory $LibraryBannerCopyWith(LibraryBanner value, $Res Function(LibraryBanner) _then) = _$LibraryBannerCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? imageAsset
});




}
/// @nodoc
class _$LibraryBannerCopyWithImpl<$Res>
    implements $LibraryBannerCopyWith<$Res> {
  _$LibraryBannerCopyWithImpl(this._self, this._then);

  final LibraryBanner _self;
  final $Res Function(LibraryBanner) _then;

/// Create a copy of LibraryBanner
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? imageAsset = freezed,}) {
  return _then(LibraryBanner(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,imageAsset: freezed == imageAsset ? _self.imageAsset : imageAsset // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LibraryBanner].
extension LibraryBannerPatterns on LibraryBanner {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LibraryBanner value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LibraryBanner() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LibraryBanner value)  $default,){
final _that = this;
switch (_that) {
case _LibraryBanner():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LibraryBanner value)?  $default,){
final _that = this;
switch (_that) {
case _LibraryBanner() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? imageAsset)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LibraryBanner() when $default != null:
return $default(_that.id,_that.title,_that.imageAsset);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? imageAsset)  $default,) {final _that = this;
switch (_that) {
case _LibraryBanner():
return $default(_that.id,_that.title,_that.imageAsset);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? imageAsset)?  $default,) {final _that = this;
switch (_that) {
case _LibraryBanner() when $default != null:
return $default(_that.id,_that.title,_that.imageAsset);case _:
  return null;

}
}

}

/// @nodoc


class _LibraryBanner implements LibraryBanner {
  const _LibraryBanner({required this.id, required this.title, this.imageAsset});
  

@override final  String id;
@override final  String title;
/// Banner artwork; `null` until the image is added.
@override final  String? imageAsset;

/// Create a copy of LibraryBanner
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LibraryBannerCopyWith<_LibraryBanner> get copyWith => __$LibraryBannerCopyWithImpl<_LibraryBanner>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LibraryBanner&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.imageAsset, imageAsset) || other.imageAsset == imageAsset));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,title,imageAsset);
}

@override
String toString() {
    return 'LibraryBanner(id: $id, title: $title, imageAsset: $imageAsset)';
}


}

/// @nodoc
abstract mixin class _$LibraryBannerCopyWith<$Res> implements $LibraryBannerCopyWith<$Res> {
  factory _$LibraryBannerCopyWith(_LibraryBanner value, $Res Function(_LibraryBanner) _then) = __$LibraryBannerCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? imageAsset
});




}
/// @nodoc
class __$LibraryBannerCopyWithImpl<$Res>
    implements _$LibraryBannerCopyWith<$Res> {
  __$LibraryBannerCopyWithImpl(this._self, this._then);

  final _LibraryBanner _self;
  final $Res Function(_LibraryBanner) _then;

/// Create a copy of LibraryBanner
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? imageAsset = freezed,}) {
  return _then(_LibraryBanner(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,imageAsset: freezed == imageAsset ? _self.imageAsset : imageAsset // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
