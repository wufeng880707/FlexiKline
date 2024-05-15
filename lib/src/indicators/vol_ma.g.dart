// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vol_ma.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VolMaIndicator _$VolMaIndicatorFromJson(Map<String, dynamic> json) =>
    VolMaIndicator(
      key: json['key'] == null
          ? volMaKey
          : const ValueKeyConverter().fromJson(json['key'] as String),
      name: json['name'] as String? ?? 'VOLMA',
      height: (json['height'] as num?)?.toDouble() ?? defaultSubIndicatorHeight,
      tipsHeight: (json['tipsHeight'] as num?)?.toDouble() ??
          defaultIndicatorTipsHeight,
      padding: json['padding'] == null
          ? defaultIndicatorPadding
          : const EdgeInsetsConverter()
              .fromJson(json['padding'] as Map<String, dynamic>),
      calcParams: (json['calcParams'] as List<dynamic>?)
              ?.map((e) => MaParam.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [
            MaParam(
                count: 5,
                tips: TipsConfig(
                    label: 'MA5: ',
                    style: TextStyle(
                        fontSize: defaulTextSize,
                        color: Colors.orange,
                        overflow: TextOverflow.ellipsis,
                        height: defaultTipsTextHeight))),
            MaParam(
                count: 10,
                tips: TipsConfig(
                    label: 'MA10: ',
                    style: TextStyle(
                        fontSize: defaulTextSize,
                        color: Colors.blue,
                        overflow: TextOverflow.ellipsis,
                        height: defaultTipsTextHeight)))
          ],
      tipsPadding: json['tipsPadding'] == null
          ? defaultTipsPadding
          : const EdgeInsetsConverter()
              .fromJson(json['tipsPadding'] as Map<String, dynamic>),
      lineWidth:
          (json['lineWidth'] as num?)?.toDouble() ?? defaultIndicatorLineWidth,
      precision: (json['precision'] as num?)?.toInt() ?? 2,
    );

Map<String, dynamic> _$VolMaIndicatorToJson(VolMaIndicator instance) =>
    <String, dynamic>{
      'key': const ValueKeyConverter().toJson(instance.key),
      'name': instance.name,
      'height': instance.height,
      'tipsHeight': instance.tipsHeight,
      'padding': const EdgeInsetsConverter().toJson(instance.padding),
      'calcParams': instance.calcParams.map((e) => e.toJson()).toList(),
      'tipsPadding': const EdgeInsetsConverter().toJson(instance.tipsPadding),
      'lineWidth': instance.lineWidth,
      'precision': instance.precision,
    };
