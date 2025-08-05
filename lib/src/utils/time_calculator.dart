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

/// 时间计算工具类
class TimeCalculator {
  /// 计算下一个月的更新时间
  static DateTime nextMonth(DateTime currentTime, bool isUtc) {
    // 计算下一个月的时间
    int nextYear = currentTime.year;
    int nextMonth = currentTime.month + 1;
    
    // 如果月份超过12，需要调整年份
    if (nextMonth > 12) {
      nextMonth = 1;
      nextYear++;
    }
    
    // 创建下一个月的时间，保持相同的日、时、分、秒
    final nextMonthDateTime = DateTime.utc(
      nextYear,
      nextMonth,
      currentTime.day,
      currentTime.hour,
      currentTime.minute,
      currentTime.second,
      currentTime.millisecond,
    );
    
    // 如果不是UTC时间，转换为本地时间
    return isUtc ? nextMonthDateTime : nextMonthDateTime.toLocal();
  }
  
  /// 计算下一个季度的更新时间
  static DateTime nextQuarter(DateTime currentTime, bool isUtc) {
    // 计算下一个季度的时间
    int nextYear = currentTime.year;
    int nextMonth = currentTime.month + 3;
    
    // 如果月份超过12，需要调整年份
    if (nextMonth > 12) {
      nextMonth = nextMonth - 12;
      nextYear++;
    }
    
    // 创建下一个季度的时间，保持相同的日、时、分、秒
    final nextQuarterDateTime = DateTime.utc(
      nextYear,
      nextMonth,
      currentTime.day,
      currentTime.hour,
      currentTime.minute,
      currentTime.second,
      currentTime.millisecond,
    );
    
    // 如果不是UTC时间，转换为本地时间
    return isUtc ? nextQuarterDateTime : nextQuarterDateTime.toLocal();
  }
  
  /// 计算下一年的更新时间
  static DateTime nextYear(DateTime currentTime, bool isUtc) {
    // 创建下一年的时间，保持相同的月、日、时、分、秒
    final nextYearDateTime = DateTime.utc(
      currentTime.year + 1,
      currentTime.month,
      currentTime.day,
      currentTime.hour,
      currentTime.minute,
      currentTime.second,
      currentTime.millisecond,
    );
    
    // 如果不是UTC时间，转换为本地时间
    return isUtc ? nextYearDateTime : nextYearDateTime.toLocal();
  }
  
  /// 计算下一个工作日的更新时间（跳过周末）
  static DateTime nextWorkDay(DateTime currentTime, bool isUtc) {
    DateTime nextDay = currentTime.add(const Duration(days: 1));
    
    // 跳过周末
    while (nextDay.weekday == DateTime.saturday || nextDay.weekday == DateTime.sunday) {
      nextDay = nextDay.add(const Duration(days: 1));
    }
    
    return isUtc ? nextDay.toUtc() : nextDay.toLocal();
  }
} 