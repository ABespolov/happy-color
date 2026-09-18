// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'library_picture.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LibraryPicture {

 String get id;/// Folder with the files written by `tools/generate_picture.py`.
 String get assetDir;
/// Create a copy of LibraryPicture
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LibraryPictureCopyWith<LibraryPicture> get copyWith => _$LibraryPictureCopyWithImpl<LibraryPicture>(this as LibraryPicture, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LibraryPicture;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LibraryPicture&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.assetDir, _this.assetDir) || other.assetDir == _this.assetDir));
}


@override
int get hashCode {
  final _this = this as LibraryPicture;
  return Object.hash(runtimeType,_this.id,_this.assetDir);
}

@override
String toString() {
  final _this = this as LibraryPicture;
  return 'LibraryPicture(id: ${_this.id}, assetDir: ${_this.assetDir})';
}


}

/// @nodoc
abstract mixin class $LibraryPictureCopyWith<$Res>  {
  factory $LibraryPictureCopyWith(LibraryPicture value, $Res Function(LibraryPicture) _then) = _$LibraryPictureCopyWithImpl;
@useResult
$Res call({
 String id, String assetDir
});




}
/// @nodoc
class _$LibraryPictureCopyWithImpl<$Res>
    implements $LibraryPictureCopyWith<$Res> {
  _$LibraryPictureCopyWithImpl(this._self, this._then);

  final LibraryPicture _self;
  final $Res Function(LibraryPicture) _then;

/// Create a copy of LibraryPicture
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? assetDir = null,}) {
  return _then(LibraryPicture(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,assetDir: null == assetDir ? _self.assetDir : assetDir // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LibraryPicture].
extension LibraryPicturePatterns on LibraryPicture {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LibraryPicture value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LibraryPicture() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LibraryPicture value)  $default,){
final _that = this;
switch (_that) {
case _LibraryPicture():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LibraryPicture value)?  $default,){
final _that = this;
switch (_that) {
case _LibraryPicture() when $default != null:
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
case _LibraryPicture() when $default != null:
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
case _LibraryPicture():
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
case _LibraryPicture() when $default != null:
return $default(_that.id,_that.assetDir);case _:
  return null;

}
}

}

/// @nodoc


class _LibraryPicture implements LibraryPicture {
  const _LibraryPicture({required this.id, required this.assetDir});
  

@override final  String id;
/// Folder with the files written by `tools/generate_picture.py`.
@override final  String assetDir;

/// Create a copy of LibraryPicture
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LibraryPictureCopyWith<_LibraryPicture> get copyWith => __$LibraryPictureCopyWithImpl<_LibraryPicture>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LibraryPicture&&(identical(other.id, id) || other.id == id)&&(identical(other.assetDir, assetDir) || other.assetDir == assetDir));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,assetDir);
}

@override
String toString() {
    return 'LibraryPicture(id: $id, assetDir: $assetDir)';
}


}

/// @nodoc
abstract mixin class _$LibraryPictureCopyWith<$Res> implements $LibraryPictureCopyWith<$Res> {
  factory _$LibraryPictureCopyWith(_LibraryPicture value, $Res Function(_LibraryPicture) _then) = __$LibraryPictureCopyWithImpl;
@override @useResult
$Res call({
 String id, String assetDir
});




}
/// @nodoc
class __$LibraryPictureCopyWithImpl<$Res>
    implements _$LibraryPictureCopyWith<$Res> {
  __$LibraryPictureCopyWithImpl(this._self, this._then);

  final _LibraryPicture _self;
  final $Res Function(_LibraryPicture) _then;

/// Create a copy of LibraryPicture
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? assetDir = null,}) {
  return _then(_LibraryPicture(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,assetDir: null == assetDir ? _self.assetDir : assetDir // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
