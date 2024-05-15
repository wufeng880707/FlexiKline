// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'candle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CandleIndicator _$CandleIndicatorFromJson(Map<String, dynamic> json) =>
    CandleIndicator(
      key: json['key'] == null
          ? candleKey
          : const ValueKeyConverter().fromJson(json['key'] as String),
      name: json['name'] as String? ?? 'Candle',
      height: (json['height'] as num).toDouble(),
      tipsHeight: (json['tipsHeight'] as num?)?.toDouble() ??
          defaultIndicatorTipsHeight,
      padding: json['padding'] == null
          ? const EdgeInsets.only(bottom: 15)
          : const EdgeInsetsConverter()
              .fromJson(json['padding'] as Map<String, dynamic>),
      high: json['high'] == null
          ? const MarkConfig(
              spacing: 2,
              line: LineConfig(
                  type: LineType.solid,
                  color: Colors.black,
                  length: 20,
                  width: 0.5))
          : MarkConfig.fromJson(json['high'] as Map<String, dynamic>),
      low: json['low'] == null
          ? const MarkConfig(
              spacing: 2,
              line: LineConfig(
                  type: LineType.solid,
                  color: Colors.black,
                  length: 20,
                  width: 0.5))
          : MarkConfig.fromJson(json['low'] as Map<String, dynamic>),
      last: json['last'] == null
          ? const MarkConfig(
              show: true,
              spacing: 100,
              line: LineConfig(
                  type: LineType.dashed,
                  color: Colors.black,
                  width: 0.5,
                  dashes: [3, 3]),
              text: TextAreaConfig(
                  style: TextStyle(
                      fontSize: defaulTextSize,
                      color: Colors.white,
                      overflow: TextOverflow.ellipsis,
                      height: defaultTextHeight,
                      textBaseline: TextBaseline.alphabetic),
                  background: Colors.grey,
                  padding: defaultTextPading,
                  border: BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.all(Radius.circular(10))))
          : MarkConfig.fromJson(json['last'] as Map<String, dynamic>),
      latest: json['latest'] == null
          ? const MarkConfig(
              show: true,
              spacing: 1,
              line: LineConfig(
                  type: LineType.dashed,
                  color: Colors.black,
                  width: 0.5,
                  dashes: [3, 3]),
              text: TextAreaConfig(
                  style: TextStyle(
                      fontSize: defaulTextSize,
                      color: Colors.black,
                      overflow: TextOverflow.ellipsis,
                      height: defaultTextHeight),
                  textAlign: TextAlign.end,
                  background: Colors.white,
                  padding: defaultTextPading,
                  border: BorderSide(color: Colors.black, width: 0.5),
                  borderRadius: BorderRadius.all(Radius.circular(2))))
          : MarkConfig.fromJson(json['latest'] as Map<String, dynamic>),
      prettyLatest: json['prettyLatest'] == null
          ? const TextAreaConfig(
              style: TextStyle(
                  fontSize: defaulTextSize,
                  color: Colors.white,
                  overflow: TextOverflow.ellipsis,
                  height: defaultTextHeight),
              textAlign: TextAlign.end,
              padding: defaultTextPading,
              borderRadius: BorderRadius.all(Radius.circular(2)))
          : TextAreaConfig.fromJson(
              json['prettyLatest'] as Map<String, dynamic>),
      showCountDown: json['showCountDown'] as bool? ?? true,
      countDown: json['countDown'] == null
          ? const TextAreaConfig(
              style: TextStyle(
                  fontSize: defaulTextSize,
                  color: Colors.black,
                  overflow: TextOverflow.ellipsis,
                  height: defaultTextHeight),
              textAlign: TextAlign.center,
              background: Colors.grey,
              padding: defaultTextPading,
              border: BorderSide(color: Colors.black, width: 0.5),
              borderRadius: BorderRadius.all(Radius.circular(2)))
          : TextAreaConfig.fromJson(json['countDown'] as Map<String, dynamic>),
      timeTick: json['timeTick'] == null
          ? const TextAreaConfig(
              style: TextStyle(
                  fontSize: defaulTextSize,
                  color: Colors.black,
                  overflow: TextOverflow.ellipsis,
                  height: defaultTextHeight),
              textWidth: 80)
          : TextAreaConfig.fromJson(json['timeTick'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CandleIndicatorToJson(CandleIndicator instance) =>
    <String, dynamic>{
      'key': const ValueKeyConverter().toJson(instance.key),
      'name': instance.name,
      'height': instance.height,
      'tipsHeight': instance.tipsHeight,
      'padding': const EdgeInsetsConverter().toJson(instance.padding),
      'high': instance.high.toJson(),
      'low': instance.low.toJson(),
      'last': instance.last.toJson(),
      'latest': instance.latest.toJson(),
      'prettyLatest': instance.prettyLatest?.toJson(),
      'showCountDown': instance.showCountDown,
      'countDown': instance.countDown.toJson(),
      'timeTick': instance.timeTick.toJson(),
    };
