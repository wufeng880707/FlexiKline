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

import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

class Item implements Comparable<Item> {
  Item(this.name, this.weight);

  final String name;
  final int weight;

  @override
  int compareTo(Item other) {
    return weight.compareTo(other.weight);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is Item) {
      return other.runtimeType == runtimeType && other.name == other.name;
    }
    return false;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() {
    return 'Item($name, $weight)';
  }
}

void main() {
  final stopwatch = Stopwatch();
  setUp(() {
    stopwatch.reset();
    stopwatch.start();
  });

  tearDown(() {
    stopwatch.stop();
    debugPrint('spent:${stopwatch.elapsedMicroseconds}');
  });

  // test('SplayTreeSet', () {
  //   SplayTreeSet set = SplayTreeSet();
  //   set.add(Item('zp3', 3));
  //   set.add(Item('zp0', 0));
  //   set.add(Item('zp2', 0));
  //   set.add(Item('zp1', 0));
  //   set.add(Item('zp-1', -1));

  //   set.add(Item('zp-4', 0));
  //   printIterable(set);
  // });

  // test('SplayTreeMap', () {
  //   SplayTreeMap map = SplayTreeMap<String, Item>();
  //   map['zp3'] = Item('zp3', 3);
  //   map['zp0'] = Item('zp0', 0);
  //   map['zp2'] = Item('zp2', 0);
  //   map['zp1'] = Item('zp1', 0);
  //   map['zp-1'] = Item('zp-1', -1);

  //   map['zp4'] = Item('zp-4', 0);
  //   printMap(map);
  // });

  // test('LinkedHashSet', () {
  //   LinkedHashSet set = LinkedHashSet();
  //   set.add(Item('zp-1', -1));
  //   set.add(Item('zp0', 0));
  //   set.add(Item('zp1', 1));
  //   set.add(Item('zp2', 2));

  //   set.remove(set.first);
  //   printIterable(set);
  // });

  test('merger addAll', () {
    final list1 = List.filled(100000000, fillData1);
    final list2 = List.filled(100000000, fillData2);

    debugPrint('merger add');
    final newList = List.of(list1, growable: true)..addAll(list2);

    assert(newList.length == 200000000);
  });

  test('merger ...', () {
    final list1 = List.filled(100000000, fillData1);
    final list2 = List.filled(100000000, fillData2);

    debugPrint('merger ...');
    final newList = List.of([...list1, ...list2]);

    assert(newList.length == 200000000);
  });
}

const fillData1 = 'AAABBBCCC';
const fillData2 = 'XXXYYYZZZ';
