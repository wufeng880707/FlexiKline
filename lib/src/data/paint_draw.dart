// Copyright 2024 Andy.Zhao
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

part of 'kline_data.dart';

mixin PaintDrawData on BaseData {
  bool get canPaintChart {
    return isNotEmpty && list.checkIndex(start); // && list.checkIndex(end);
  }

  void ensureStartAndEndIndex(
    int startIndex,
    int maxCandleCount,
  ) {
    start = startIndex;
    end = startIndex + maxCandleCount;
  }

  Range get computableRange => Range(0, length);

  Range get paintIndexRange => Range(start, end);

  Range? get paintTimeRange {
    if (checkStartAndEnd(start, end)) {
      return Range(list[start].ts, list[end].ts);
    }
    return null;
  }

  /// 将[ts]转换为当前KlineData数据列表的下标和剩余偏移率
  /// 如果ts > 最新价, 将为负
  double? timestampToIndex(int ts) {
    if (list.isEmpty || !spec.interval.isValid) return null;
    final timespans = spec.interval.milliseconds;
    final first = list.first;
    final last = list.last;
    if (ts > first.ts) {
      // 超出蜡烛数据时间范围, 不予考虑交易时间问题
      final distance = first.ts - ts;
      final value = distance / timespans;
      return value; // 比最新一根更晚，返回负数（0 + value）
    } else if (ts <= last.ts) {
      // 超出蜡烛数据时间范围, 不予考虑交易时间问题
      final distance = last.ts - ts;
      final value = distance / timespans;
      return list.length - 1 + value;
    } else {
      // 数据按 ts 降序，二分定位不晚于 ts 的锚点，再按 interval 换算 patch。
      final distance = first.ts - ts;
      final indexValue = distance / timespans;
      final index = indexValue.truncate();
      final patch = indexValue - index;

      int i = _indexAtOrBeforeDesc(ts) ?? 0;
      return i + patch;
    }
  }

  /// 降序 ts 列表中二分查找不晚于 [ts]（即 ts >= list[i].ts 且最大）的下标。
  /// ts 严格晚于全部数据时返回 null（由调用方决定回退值）。
  int? _indexAtOrBeforeDesc(int ts) {
    final items = list;
    var low = 0;
    var high = items.length - 1;
    if (items[low].ts < ts) return null;
    while (low < high) {
      final mid = low + ((high - low + 1) >> 1);
      if (items[mid].ts <= ts) {
        high = mid - 1;
      } else {
        low = mid;
      }
    }
    return low;
  }

  /// 将[indexValue]转换为以当前KlineData数据范围为基础的timestamp
  int? indexToTimestamp(double indexValue) {
    if (list.isEmpty || !spec.interval.isValid) return null;
    final timespans = spec.interval.milliseconds;
    final index = indexValue.toInt();
    final patchTs = ((indexValue - index) * timespans).truncate();
    if (index < 0) {
      return list.first.ts - index * timespans - patchTs;
    } else if (index >= list.length - 1) {
      return list.last.ts - (index + 1 - list.length) * timespans - patchTs;
    } else {
      return list[index].ts - patchTs;
    }
  }
}
