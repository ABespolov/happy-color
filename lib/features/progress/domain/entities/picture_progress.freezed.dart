// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'picture_progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PictureProgress {

 String get id;@JsonKey(name: 'dir') String get assetDir;/// Indices of the regions that are already colored.
 Set<int> get filled;/// Regions in the picture; 0 until it has been opened once.
@JsonKey(name: 'regions') int get regionCount; bool get starred;
/// Create a copy of PictureProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PictureProgressCopyWith<PictureProgress> get copyWith => _$PictureProgressCopyWithImpl<PictureProgress>(this as PictureProgress, _$identity);

  /// Serializes this PictureProgress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PictureProgress;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PictureProgress&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.assetDir, _this.assetDir) || other.assetDir == _this.assetDir)&&const DeepCollectionEquality().equals(other.filled, _this.filled)&&(identical(other.regionCount, _this.regionCount) || other.regionCount == _this.regionCount)&&(identical(other.starred, _this.starred) || other.starred == _this.starred));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PictureProgress;
  return Object.hash(runtimeType,_this.id,_this.assetDir,const DeepCollectionEquality().hash(_this.filled),_this.regionCount,_this.starred);
}

@override
String toString() {
  final _this = this as PictureProgress;
  return 'PictureProgress(id: ${_this.id}, assetDir: ${_this.assetDir}, filled: ${_this.filled}, regionCount: ${_this.regionCount}, starred: ${_this.starred})';
}


}

/// @nodoc
abstract mixin class $PictureProgressCopyWith<$Res>  {
  factory $PictureProgressCopyWith(PictureProgress value, $Res Function(PictureProgress) _then) = _$PictureProgressCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'dir') String assetDir, Set<int> filled,@JsonKey(name: 'regions') int regionCount, bool starred
});




}
/// @nodoc
class _$PictureProgressCopyWithImpl<$Res>
    implements $PictureProgressCopyWith<$Res> {
  _$PictureProgressCopyWithImpl(this._self, this._then);

  final PictureProgress _self;
  final $Res Function(PictureProgress) _then;

/// Create a copy of PictureProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? assetDir = null,Object? filled = null,Object? regionCount = null,Object? starred = null,}) {
  return _then(PictureProgress(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,assetDir: null == assetDir ? _self.assetDir : assetDir // ignore: cast_nullable_to_non_nullable
as String,filled: null == filled ? _self.filled : filled // ignore: cast_nullable_to_non_nullable
as Set<int>,regionCount: null == regionCount ? _self.regionCount : regionCount // ignore: cast_nullable_to_non_nullable
as int,starred: null == starred ? _self.starred : starred // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PictureProgress].
extension PictureProgressPatterns on PictureProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PictureProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PictureProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PictureProgress value)  $default,){
final _that = this;
switch (_that) {
case _PictureProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PictureProgress value)?  $default,){
final _that = this;
switch (_that) {
case _PictureProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'dir')  String assetDir,  Set<int> filled, @JsonKey(name: 'regions')  int regionCount,  bool starred)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PictureProgress() when $default != null:
return $default(_that.id,_that.assetDir,_that.filled,_that.regionCount,_that.starred);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'dir')  String assetDir,  Set<int> filled, @JsonKey(name: 'regions')  int regionCount,  bool starred)  $default,) {final _that = this;
switch (_that) {
case _PictureProgress():
return $default(_that.id,_that.assetDir,_that.filled,_that.regionCount,_that.starred);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'dir')  String assetDir,  Set<int> filled, @JsonKey(name: 'regions')  int regionCount,  bool starred)?  $default,) {final _that = this;
switch (_that) {
case _PictureProgress() when $default != null:
return $default(_that.id,_that.assetDir,_that.filled,_that.regionCount,_that.starred);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PictureProgress extends PictureProgress {
  const _PictureProgress({required this.id, @JsonKey(name: 'dir') required this.assetDir,  Set<int> filled = const <int>{}, @JsonKey(name: 'regions') this.regionCount = 0, this.starred = false}): _filled = filled,super._();
  factory _PictureProgress.fromJson(Map<String, dynamic> json) => _$PictureProgressFromJson(json);

@override final  String id;
@override@JsonKey(name: 'dir') final  String assetDir;
/// Indices of the regions that are already colored.
 final  Set<int> _filled;
/// Indices of the regions that are already colored.
@override@JsonKey() Set<int> get filled {
  if (_filled is EqualUnmodifiableSetView) return _filled;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_filled);
}

/// Regions in the picture; 0 until it has been opened once.
@override@JsonKey(name: 'regions') final  int regionCount;
@override@JsonKey() final  bool starred;

/// Create a copy of PictureProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PictureProgressCopyWith<_PictureProgress> get copyWith => __$PictureProgressCopyWithImpl<_PictureProgress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PictureProgressToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PictureProgress&&(identical(other.id, id) || other.id == id)&&(identical(other.assetDir, assetDir) || other.assetDir == assetDir)&&const DeepCollectionEquality().equals(other.filled, _filled)&&(identical(other.regionCount, regionCount) || other.regionCount == regionCount)&&(identical(other.starred, starred) || other.starred == starred));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,assetDir,const DeepCollectionEquality().hash(_filled),regionCount,starred);
}

@override
String toString() {
    return 'PictureProgress(id: $id, assetDir: $assetDir, filled: $filled, regionCount: $regionCount, starred: $starred)';
}


}

/// @nodoc
abstract mixin class _$PictureProgressCopyWith<$Res> implements $PictureProgressCopyWith<$Res> {
  factory _$PictureProgressCopyWith(_PictureProgress value, $Res Function(_PictureProgress) _then) = __$PictureProgressCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'dir') String assetDir, Set<int> filled,@JsonKey(name: 'regions') int regionCount, bool starred
});




}
/// @nodoc
class __$PictureProgressCopyWithImpl<$Res>
    implements _$PictureProgressCopyWith<$Res> {
  __$PictureProgressCopyWithImpl(this._self, this._then);

  final _PictureProgress _self;
  final $Res Function(_PictureProgress) _then;

/// Create a copy of PictureProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? assetDir = null,Object? filled = null,Object? regionCount = null,Object? starred = null,}) {
  return _then(_PictureProgress(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,assetDir: null == assetDir ? _self.assetDir : assetDir // ignore: cast_nullable_to_non_nullable
as String,filled: null == filled ? _self._filled : filled // ignore: cast_nullable_to_non_nullable
as Set<int>,regionCount: null == regionCount ? _self.regionCount : regionCount // ignore: cast_nullable_to_non_nullable
as int,starred: null == starred ? _self.starred : starred // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
