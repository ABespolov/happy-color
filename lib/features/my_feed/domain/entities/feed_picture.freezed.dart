// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feed_picture.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FeedPicture {

 String get id; String get assetDir;
/// Create a copy of FeedPicture
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedPictureCopyWith<FeedPicture> get copyWith => _$FeedPictureCopyWithImpl<FeedPicture>(this as FeedPicture, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FeedPicture;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedPicture&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.assetDir, _this.assetDir) || other.assetDir == _this.assetDir));
}


@override
int get hashCode {
  final _this = this as FeedPicture;
  return Object.hash(runtimeType,_this.id,_this.assetDir);
}

@override
String toString() {
  final _this = this as FeedPicture;
  return 'FeedPicture(id: ${_this.id}, assetDir: ${_this.assetDir})';
}


}

/// @nodoc
abstract mixin class $FeedPictureCopyWith<$Res>  {
  factory $FeedPictureCopyWith(FeedPicture value, $Res Function(FeedPicture) _then) = _$FeedPictureCopyWithImpl;
@useResult
$Res call({
 String id, String assetDir
});




}
/// @nodoc
class _$FeedPictureCopyWithImpl<$Res>
    implements $FeedPictureCopyWith<$Res> {
  _$FeedPictureCopyWithImpl(this._self, this._then);

  final FeedPicture _self;
  final $Res Function(FeedPicture) _then;

/// Create a copy of FeedPicture
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? assetDir = null,}) {
  return _then(FeedPicture(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,assetDir: null == assetDir ? _self.assetDir : assetDir // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FeedPicture].
extension FeedPicturePatterns on FeedPicture {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedPicture value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedPicture() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedPicture value)  $default,){
final _that = this;
switch (_that) {
case _FeedPicture():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedPicture value)?  $default,){
final _that = this;
switch (_that) {
case _FeedPicture() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String assetDir)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedPicture() when $default != null:
return $default(_that.id,_that.assetDir);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String assetDir)  $default,) {final _that = this;
switch (_that) {
case _FeedPicture():
return $default(_that.id,_that.assetDir);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String assetDir)?  $default,) {final _that = this;
switch (_that) {
case _FeedPicture() when $default != null:
return $default(_that.id,_that.assetDir);case _:
  return null;

}
}

}

/// @nodoc


class _FeedPicture implements FeedPicture {
  const _FeedPicture({required this.id, required this.assetDir});
  

@override final  String id;
@override final  String assetDir;

/// Create a copy of FeedPicture
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedPictureCopyWith<_FeedPicture> get copyWith => __$FeedPictureCopyWithImpl<_FeedPicture>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedPicture&&(identical(other.id, id) || other.id == id)&&(identical(other.assetDir, assetDir) || other.assetDir == assetDir));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,assetDir);
}

@override
String toString() {
    return 'FeedPicture(id: $id, assetDir: $assetDir)';
}


}

/// @nodoc
abstract mixin class _$FeedPictureCopyWith<$Res> implements $FeedPictureCopyWith<$Res> {
  factory _$FeedPictureCopyWith(_FeedPicture value, $Res Function(_FeedPicture) _then) = __$FeedPictureCopyWithImpl;
@override @useResult
$Res call({
 String id, String assetDir
});




}
/// @nodoc
class __$FeedPictureCopyWithImpl<$Res>
    implements _$FeedPictureCopyWith<$Res> {
  __$FeedPictureCopyWithImpl(this._self, this._then);

  final _FeedPicture _self;
  final $Res Function(_FeedPicture) _then;

/// Create a copy of FeedPicture
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? assetDir = null,}) {
  return _then(_FeedPicture(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,assetDir: null == assetDir ? _self.assetDir : assetDir // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
