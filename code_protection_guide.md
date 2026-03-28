# Flutter 代码保护与预编译分发指南

## 目录

- [概述](#概述)
- [方案对比](#方案对比)
- [方案 A: Kernel Binary (.dill)](#方案-a-kernel-binary-dill)
- [方案 B: AOT 编译（推荐）](#方案-b-aot-编译推荐)
- [FlexiKline 实施方案](#flexikline-实施方案)
- [完整实施步骤](#完整实施步骤)
- [最佳实践](#最佳实践)

---

## 概述

本文档介绍如何保护 FlexiKline 的核心代码，防止源码泄露，同时以二进制格式分发库，保护商业机密。

### 为什么需要代码保护？

- 🔒 **保护核心算法**：指标计算、绘制逻辑等商业机密
- 💼 **商业价值保护**：防止竞争对手直接复制核心功能
- 📦 **灵活分发**：可以提供试用版、完整版等不同版本
- ⚡ **性能优化**：预编译后性能更好

---

## 方案对比

### 快速对比表

| 对比维度 | 方案 A: .dill | 方案 B: AOT | 推荐 |
|---------|--------------|-------------|------|
| **安全性** | ⭐⭐ (低) | ⭐⭐⭐⭐⭐ (高) | **AOT** |
| **反编译难度** | 容易 | 非常困难 | **AOT** |
| **性能** | ⭐⭐⭐ (需VM) | ⭐⭐⭐⭐⭐ (原生) | **AOT** |
| **文件大小** | 小 (~MB) | 大 (~10MB+) | .dill |
| **编译速度** | 快 (秒级) | 慢 (分钟级) | .dill |
| **跨平台** | ✅ 一次编译 | ❌ 需分别编译 | .dill |
| **运行依赖** | 需要 Dart VM | 无依赖 | **AOT** |
| **调试友好** | 容易 | 困难 | .dill |
| **代码保护** | ❌ 不适合 | ✅ 适合 | **AOT** |

### 编译流程对比

```
方案 A (.dill):
Dart Source Code (.dart) 
    ↓ [dart compile kernel]
Kernel Binary (.dill)          ← 中间表示，易反编译
    ↓ [运行时 JIT/AOT]
Machine Code

方案 B (AOT):
Dart Source Code (.dart)
    ↓ [dart compile aot/flutter build]
Native Machine Code (.so/.framework/.dll)  ← 机器码，难以逆向
    ↓ [直接执行]
CPU 运行
```

---

## 方案 A: Kernel Binary (.dill)

### 什么是 Kernel Binary？

Kernel Binary (.dill) 是 Dart 的**中间表示**（Intermediate Representation），类似于 Java 的字节码。它包含完整的类型信息和抽象语法树（AST）结构。

### 生成方式

```bash
# 编译单个文件
dart compile kernel lib/flexi_kline.dart -o flexi_kline.dill

# 编译整个库
dart compile kernel lib/flexi_kline.dart \
  --packages=.packages \
  -o build/flexi_kline.dill
```

### 使用方式

```bash
# 运行 .dill 文件
dart run flexi_kline.dill
```

### 优点

✅ **编译速度快**：秒级完成编译  
✅ **文件体积小**：通常只有几 MB  
✅ **保留类型信息**：便于调试和错误追踪  
✅ **跨平台**：一次编译，多平台使用（只要有 Dart VM）  
✅ **快速迭代**：开发阶段可以快速测试

### 缺点

❌ **安全性极低**：可以被轻松反编译  
❌ **代码结构可见**：类名、函数名、变量名清晰可见  
❌ **需要 Dart VM**：运行时需要完整的 Dart 运行环境  
❌ **不适合商业分发**：无法保护知识产权

### 反编译示例

```bash
# 查看 .dill 文件中的符号
strings flexi_kline.dill | grep "class\|function"

# 输出示例（你的代码结构暴露无遗）：
# class FlexiKlineController
# class CandleIndicator
# function calculateMA
# function drawKline
```

### ⚠️ 适用场景

- ✅ 内部开发和测试
- ✅ 快速原型验证
- ✅ 开源项目
- ❌ **不适合商业产品分发**
- ❌ **不适合代码保护**

---

## 方案 B: AOT 编译（推荐）

### 什么是 AOT 编译？

AOT (Ahead-Of-Time) 编译是将 Dart 代码**直接编译为本地机器码**，无需 Dart VM 即可运行。这是真正意义上的代码保护方案。

### 生成方式

#### Android 平台

```bash
# 编译为 AAR (Android Archive)
flutter build aar --release

# 输出位置：
# build/host/outputs/repo/com/example/flexi_kline/flutter_release/1.0/
#   ├── flutter_release-1.0.aar
#   └── flutter_release-1.0.pom
```

AAR 文件内部包含：
- `.so` 文件（ARM/x86 机器码）
- Android 资源文件
- manifest 配置

#### iOS 平台

```bash
# 编译为 Framework
flutter build ios-framework --release

# 输出位置：
# build/ios/framework/Release/
#   ├── FlexiKline.framework/
#   │   ├── FlexiKline (二进制文件)
#   │   ├── Headers/
#   │   └── Info.plist
```

#### macOS/Linux/Windows

```bash
# 编译为可执行文件
dart compile exe lib/flexi_kline.dart -o flexi_kline

# 或编译为共享库
dart compile aot-snapshot lib/flexi_kline.dart -o flexi_kline.aot
```

### 优点

✅ **安全性极高**：机器码难以逆向工程  
✅ **性能最佳**：无 JIT 开销，直接运行机器码  
✅ **启动速度快**：无需预热，立即达到最佳性能  
✅ **无运行时依赖**：不需要 Dart VM  
✅ **真正的代码保护**：符合商业分发需求  
✅ **支持混淆**：可配合 ProGuard 进一步加密

### 缺点

❌ **编译时间长**：分钟级别  
❌ **文件体积大**：通常 10MB+  
❌ **平台相关**：需要为每个平台单独编译  
❌ **调试困难**：无法查看源码，错误追踪依赖符号表  
❌ **失去动态性**：无法热更新、无法反射

### 安全性验证

```bash
# 查看编译后的 .so 文件
strings build/app/intermediates/flutter/release/arm64-v8a/libapp.so

# 输出：只能看到一些字符串常量，无法还原代码逻辑
# _kDartIsolateSnapshotData
# _kDartVmSnapshotData
# Dart_PropagateError
```

### 额外保护措施

#### 1. 代码混淆

```bash
flutter build apk --release \
  --obfuscate \
  --split-debug-info=build/debug-info
```

#### 2. ProGuard (Android)

在 `android/app/build.gradle` 中：

```gradle
android {
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

#### 3. 字符串加密

```dart
// 敏感字符串不要硬编码
const String apiKey = String.fromEnvironment('API_KEY');
```

---

## FlexiKline 实施方案

### 代码分层策略

根据 FlexiKline 的代码结构，建议采用**混合保护策略**：

```
lib/
├── flexi_kline.dart              [公开] - 主导出文件
├── src/
    ├── config/                   [公开] - 配置类，用户需要自定义
    ├── model/                    [公开] - 数据模型，用户需要使用
    ├── view/                     [公开] - UI Widget，用户需要集成
    ├── kline_controller.dart     [公开] - 控制器 API
    │
    ├── core/                     [保护] - 核心绘制逻辑 → AOT
    │   ├── draw.dart            [保护] - 绘制算法
    │   ├── grid.dart            [保护] - 网格计算
    │   └── cross.dart           [保护] - 十字线逻辑
    │
    ├── indicators/               [保护] - 指标计算 → AOT
    │   ├── ma/                  [保护] - 移动平均线算法
    │   ├── macd/                [保护] - MACD 算法
    │   ├── kdj/                 [保护] - KDJ 算法
    │   └── trade_mark/          [保护] - 交易标记算法
    │
    └── framework/               [部分保护] - 框架核心
        ├── export.dart          [公开] - 公共接口
        └── internal/            [保护] - 内部实现 → AOT
```

### 保护策略说明

| 代码类型 | 处理方式 | 原因 |
|---------|---------|------|
| **UI Widget** | 📂 开源/正常分发 | 用户需要自定义样式和布局 |
| **配置类** | 📂 正常分发 | 用户需要配置参数 |
| **数据模型** | 📂 正常分发 | 用户需要操作数据 |
| **公共 API** | 📂 接口定义可见 | 方便集成和使用 |
| **核心绘制算法** | 🔒 **AOT 编译** | **商业核心，必须保护** |
| **指标计算逻辑** | 🔒 **AOT 编译** | **算法机密，关键保护** |
| **内部框架** | 🔒 **AOT 编译** | **架构设计，需要保护** |

---

## 完整实施步骤

### Step 1: 准备工作

#### 1.1 备份当前项目

```bash
# 创建备份
cp -r FlexiKlineFork_demo FlexiKlineFork_demo_backup

# 或使用 git
git checkout -b feature/binary-distribution
```

#### 1.2 分析依赖关系

```bash
# 检查 pubspec.yaml
flutter pub deps --tree

# 确保所有依赖都支持 AOT 编译
```

### Step 2: 创建 Flutter Module

```bash
# 在项目外部创建 module
cd ..
flutter create -t module flexi_kline_module

# 目录结构
flexi_kline_module/
├── .android/          # Android 宿主
├── .ios/              # iOS 宿主
├── lib/               # 核心代码
├── test/
└── pubspec.yaml
```

### Step 3: 迁移核心代码

```bash
# 复制需要保护的核心代码
cp -r FlexiKlineFork_demo/lib/src/core flexi_kline_module/lib/src/
cp -r FlexiKlineFork_demo/lib/src/indicators flexi_kline_module/lib/src/
cp -r FlexiKlineFork_demo/lib/src/framework/internal flexi_kline_module/lib/src/framework/

# 复制依赖配置
cp FlexiKlineFork_demo/pubspec.yaml flexi_kline_module/pubspec.yaml
```

### Step 4: 配置 pubspec.yaml

编辑 `flexi_kline_module/pubspec.yaml`：

```yaml
name: flexi_kline_core
description: FlexiKline core library (binary distribution)
version: 0.9.0
publish_to: none  # 不发布到 pub.dev

environment:
  sdk: ">=3.2.0 <4.0.0"
  flutter: ">=3.16.0"

dependencies:
  flutter:
    sdk: flutter
  decimal: ^2.3.3
  equatable: ^2.0.5
  json_annotation: ^4.9.0
  copy_with_extension: ^5.0.4

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.9
  json_serializable: ^6.8.0
  copy_with_extension_gen: ^5.0.4

flutter:
  module:
    androidX: true
    androidPackage: com.example.flexi_kline_core
    iosBundleIdentifier: com.example.flexiKlineCore
```

### Step 5: 编译为二进制

#### 5.1 编译 Android AAR

```bash
cd flexi_kline_module

# 清理构建缓存
flutter clean

# 编译 release 版本
flutter build aar --release

# 可选：编译 debug 和 profile 版本
flutter build aar --debug
flutter build aar --profile

# 输出位置
# build/host/outputs/repo/com/example/flexi_kline_core/flutter_release/
```

#### 5.2 编译 iOS Framework

```bash
# 编译 iOS Framework
flutter build ios-framework --release

# 可选：编译全部配置
flutter build ios-framework --cocoapods --xcframework

# 输出位置
# build/ios/framework/Release/
```

#### 5.3 验证编译产物

```bash
# 检查 AAR 文件
unzip -l build/host/outputs/repo/com/example/flexi_kline_core/flutter_release/1.0/flutter_release-1.0.aar

# 检查 Framework
ls -lh build/ios/framework/Release/FlexiKlineCore.framework/

# 验证机器码（应该看不到源代码）
strings build/ios/framework/Release/FlexiKlineCore.framework/FlexiKlineCore | less
```

### Step 6: 创建分发 Plugin

```bash
# 创建 Flutter Plugin 项目
cd ..
flutter create --template=plugin --platforms=android,ios flexi_kline_pro

cd flexi_kline_pro
```

#### 6.1 配置目录结构

```
flexi_kline_pro/
├── android/
│   ├── libs/                         # 存放 AAR 文件
│   │   └── flutter_release-1.0.aar
│   └── build.gradle                  # 配置依赖
│
├── ios/
│   ├── Frameworks/                   # 存放 Framework
│   │   └── FlexiKlineCore.framework/
│   └── flexi_kline_pro.podspec       # 配置依赖
│
├── lib/
│   ├── flexi_kline_pro.dart         # 主导出文件
│   ├── src/
│   │   ├── config/                  # 公开的配置类
│   │   ├── model/                   # 公开的数据模型
│   │   ├── view/                    # 公开的 UI Widget
│   │   └── kline_controller.dart    # 公开的 API
│   └── core_bridge.dart             # 与二进制的桥接层
│
└── pubspec.yaml
```

#### 6.2 复制编译产物

```bash
# 创建必要的目录
mkdir -p android/libs
mkdir -p ios/Frameworks

# 复制 Android AAR
cp ../flexi_kline_module/build/host/outputs/repo/com/example/flexi_kline_core/flutter_release/1.0/*.aar android/libs/

# 复制 iOS Framework
cp -r ../flexi_kline_module/build/ios/framework/Release/*.framework ios/Frameworks/
```

### Step 7: 配置 Android 集成

编辑 `android/build.gradle`：

```gradle
android {
    compileSdkVersion 34

    repositories {
        flatDir {
            dirs 'libs'
        }
    }
}

dependencies {
    // 依赖编译好的 AAR
    implementation(name: 'flutter_release-1.0', ext: 'aar')
    
    // Flutter 依赖
    implementation 'io.flutter:flutter_embedding_release:1.0.0-++'
}
```

### Step 8: 配置 iOS 集成

编辑 `ios/flexi_kline_pro.podspec`：

```ruby
Pod::Spec.new do |s|
  s.name             = 'flexi_kline_pro'
  s.version          = '0.9.0'
  s.summary          = 'FlexiKline Professional - Binary Distribution'
  s.description      = <<-DESC
A flexible and powerful K-line chart library for Flutter (Binary Distribution)
                       DESC
  s.homepage         = 'https://flexikline.github.io'
  s.license          = { :type => 'Commercial', :file => '../LICENSE' }
  s.author           = { 'FlexiKline Team' => 'support@flexikline.com' }
  s.source           = { :path => '.' }
  
  # 依赖预编译的 Framework
  s.vendored_frameworks = 'Frameworks/FlexiKlineCore.framework'
  
  # Flutter 依赖
  s.dependency 'Flutter'
  
  s.platform = :ios, '12.0'
  s.swift_version = '5.0'
end
```

### Step 9: 创建公共 API 层

编辑 `lib/flexi_kline_pro.dart`：

```dart
library flexi_kline_pro;

// 导出公开的配置类
export 'src/config/flexi_kline_config.dart';
export 'src/config/indicator_config.dart';
export 'src/config/chart_style.dart';

// 导出公开的模型
export 'src/model/kline_data.dart';
export 'src/model/minmax.dart';
export 'src/model/rect.dart';

// 导出公开的 Widget
export 'src/view/flexi_kline_widget.dart';

// 导出控制器
export 'src/kline_controller.dart';

// 导出常量
export 'src/constant.dart';

// ⚠️ 不导出以下内容（已编译为二进制）：
// ❌ src/core/          - 核心绘制逻辑
// ❌ src/indicators/    - 指标计算
// ❌ src/framework/internal/  - 内部框架
```

创建桥接层 `lib/core_bridge.dart`：

```dart
import 'package:flutter/services.dart';

/// 与预编译核心库的桥接层
class FlexiKlineCoreBridge {
  static const MethodChannel _channel = MethodChannel('flexi_kline_core');

  /// 初始化核心库
  static Future<void> initialize() async {
    await _channel.invokeMethod('initialize');
  }

  /// 计算指标（调用预编译的算法）
  static Future<Map<String, dynamic>> calculateIndicator({
    required String indicatorType,
    required List<dynamic> data,
    required Map<String, dynamic> params,
  }) async {
    return await _channel.invokeMapMethod('calculateIndicator', {
      'type': indicatorType,
      'data': data,
      'params': params,
    }) ?? {};
  }
}
```

### Step 10: 配置 pubspec.yaml

编辑 `pubspec.yaml`：

```yaml
name: flexi_kline_pro
description: FlexiKline Professional Edition - Binary Distribution
version: 0.9.0
homepage: https://flexikline.github.io
repository: https://github.com/FlexiKline/FlexiKline-Pro

# ⚠️ 设置为 none，不发布到 pub.dev（商业产品）
publish_to: none

environment:
  sdk: ">=3.2.0 <4.0.0"
  flutter: ">=3.16.0"

dependencies:
  flutter:
    sdk: flutter
  decimal: ^2.3.3
  equatable: ^2.0.5
  json_annotation: ^4.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

flutter:
  plugin:
    platforms:
      android:
        package: com.example.flexi_kline_pro
        pluginClass: FlexiKlineProPlugin
      ios:
        pluginClass: FlexiKlineProPlugin
```

### Step 11: 测试集成

#### 11.1 创建测试项目

```bash
# 创建测试 app
cd ..
flutter create flexi_kline_test_app
cd flexi_kline_test_app
```

#### 11.2 添加依赖

编辑 `pubspec.yaml`：

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # 使用本地路径引用（开发阶段）
  flexi_kline_pro:
    path: ../flexi_kline_pro
    
  # 或使用 Git 引用（生产环境）
  # flexi_kline_pro:
  #   git:
  #     url: https://github.com/your-org/flexi_kline_pro.git
  #     ref: v0.9.0
```

#### 11.3 编写测试代码

```dart
import 'package:flutter/material.dart';
import 'package:flexi_kline_pro/flexi_kline_pro.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化核心库
  await FlexiKlineCoreBridge.initialize();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('FlexiKline Pro Test')),
        body: FlexiKlineWidget(
          controller: FlexiKlineController(),
          config: FlexiKlineConfig.defaultConfig(),
        ),
      ),
    );
  }
}
```

#### 11.4 运行测试

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# 检查是否能正常运行，且无法看到核心实现代码
```

### Step 12: 版本管理

#### 12.1 创建版本标签

```bash
cd flexi_kline_pro

# 提交代码
git add .
git commit -m "feat: Release v0.9.0 with binary distribution"

# 创建标签
git tag -a v0.9.0 -m "Release version 0.9.0"

# 推送到远程
git push origin v0.9.0
```

#### 12.2 维护版本文档

创建 `CHANGELOG.md`：

```markdown
# Changelog

## [0.9.0] - 2026-01-31

### 新特性
- 🔒 核心算法采用 AOT 预编译，保护商业机密
- ⚡ 性能优化，绘制速度提升 30%
- 📦 支持二进制分发，易于集成

### 保护内容
- ✅ 核心绘制引擎
- ✅ 所有指标计算算法（MA, MACD, KDJ, etc）
- ✅ 内部框架实现

### 公开 API
- ✅ 配置类和数据模型
- ✅ UI Widget 和控制器
- ✅ 完整的文档和示例
```

---

## 最佳实践

### 1. 安全性最佳实践

#### ✅ 应该做的

- **分层保护**：只保护核心算法，保持 API 清晰
- **定期更新**：及时修复安全漏洞
- **访问控制**：使用许可证验证机制
- **加密通信**：敏感数据传输加密
- **代码混淆**：启用 `--obfuscate` 选项

#### ❌ 不应该做的

- 硬编码密钥或敏感信息
- 在日志中输出敏感数据
- 过度混淆导致调试困难
- 忽略平台特定的安全机制
- 将所有代码都编译为二进制（影响用户体验）

### 2. 性能优化

```bash
# 启用性能优化编译
flutter build aar --release \
  --target-platform android-arm,android-arm64,android-x64 \
  --obfuscate \
  --split-debug-info=build/debug-symbols
```

### 3. 分发策略

#### 策略 A：Git 私有仓库

**优点**：
- 版本控制方便
- 支持持续集成
- 团队协作友好

**配置方式**：

```yaml
dependencies:
  flexi_kline_pro:
    git:
      url: https://github.com/your-company/flexi_kline_pro.git
      ref: v0.9.0
      # 使用 Token 进行身份验证
      token: $GITHUB_TOKEN
```

#### 策略 B：私有 Pub 服务器

使用 [unpub](https://github.com/bytedance/unpub) 搭建私有服务器：

```bash
# 安装 unpub
docker run -d -p 4873:4873 --name unpub bytedance/unpub

# 配置客户端
flutter pub add flexi_kline_pro --hosted-url=http://your-server:4873
```

#### 策略 C：直接分发 AAR/Framework

适用于对安全性要求极高的场景：

1. 将 `.aar` 和 `.framework` 文件打包发送给客户
2. 客户手动集成到项目中
3. 通过许可证控制使用权限

### 4. 许可证保护

创建 `lib/src/license_validator.dart`：

```dart
import 'package:crypto/crypto.dart';
import 'dart:convert';

class LicenseValidator {
  static const String _publicKey = 'YOUR_PUBLIC_KEY';
  
  /// 验证许可证
  static Future<bool> validate(String licenseKey) async {
    try {
      // 1. 解析许可证
      final parts = licenseKey.split('.');
      if (parts.length != 3) return false;
      
      final payload = parts[1];
      final signature = parts[2];
      
      // 2. 验证签名
      final bytes = utf8.encode('$payload.$_publicKey');
      final digest = sha256.convert(bytes);
      
      if (base64Encode(digest.bytes) != signature) {
        return false;
      }
      
      // 3. 检查有效期
      final data = json.decode(utf8.decode(base64Decode(payload)));
      final expiry = DateTime.parse(data['expiry']);
      
      return DateTime.now().isBefore(expiry);
    } catch (e) {
      return false;
    }
  }
  
  /// 初始化时验证
  static Future<void> initialize(String licenseKey) async {
    if (!await validate(licenseKey)) {
      throw Exception('Invalid or expired license');
    }
  }
}
```

在用户初始化时调用：

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 验证许可证
  await LicenseValidator.initialize('YOUR_LICENSE_KEY');
  
  // 初始化核心库
  await FlexiKlineCoreBridge.initialize();
  
  runApp(MyApp());
}
```

### 5. 调试支持

虽然核心代码已编译，但仍需提供良好的调试体验：

#### 5.1 保留符号表

```bash
# 编译时保存符号表
flutter build aar --release \
  --split-debug-info=build/symbols/android

flutter build ios-framework --release \
  --split-debug-info=build/symbols/ios
```

#### 5.2 提供详细日志

```dart
import 'package:logging/logging.dart';

class FlexiKlineLogger {
  static final Logger _logger = Logger('FlexiKline');
  
  static void setup({Level level = Level.INFO}) {
    Logger.root.level = level;
    Logger.root.onRecord.listen((record) {
      print('[${record.level.name}] ${record.time}: ${record.message}');
    });
  }
  
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.severe(message, error, stackTrace);
  }
}
```

#### 5.3 错误上报

集成 Crashlytics 或 Sentry：

```dart
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'YOUR_SENTRY_DSN';
      options.environment = 'production';
    },
    appRunner: () => runApp(MyApp()),
  );
}
```

### 6. 持续集成

创建 `.github/workflows/build-binary.yml`：

```yaml
name: Build Binary Distribution

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: macos-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Build Android AAR
        run: flutter build aar --release
      
      - name: Build iOS Framework
        run: flutter build ios-framework --release
      
      - name: Create Release
        uses: actions/create-release@v1
        with:
          tag_name: ${{ github.ref }}
          release_name: Release ${{ github.ref }}
          body: |
            Binary distribution of FlexiKline
          draft: false
          prerelease: false
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Upload AAR
        uses: actions/upload-release-asset@v1
        with:
          upload_url: ${{ steps.create_release.outputs.upload_url }}
          asset_path: build/host/outputs/repo/com/example/flexi_kline_core/flutter_release/1.0/flutter_release-1.0.aar
          asset_name: flexi_kline-android-${{ github.ref }}.aar
          asset_content_type: application/zip
```

### 7. 文档和示例

#### 7.1 README.md

创建清晰的使用文档：

```markdown
# FlexiKline Pro

一个强大的 K 线图库（二进制分发版本）

## 快速开始

### 1. 添加依赖

\`\`\`yaml
dependencies:
  flexi_kline_pro:
    git:
      url: https://github.com/your-org/flexi_kline_pro.git
      ref: v0.9.0
\`\`\`

### 2. 初始化

\`\`\`dart
await FlexiKlineCoreBridge.initialize();
\`\`\`

### 3. 使用

\`\`\`dart
FlexiKlineWidget(
  controller: controller,
  config: config,
)
\`\`\`

## 许可证

本软件需要有效的许可证才能使用。请联系我们获取许可证。
```

#### 7.2 提供示例项目

在 `example/` 目录中提供完整的示例：

```
example/
├── lib/
│   ├── main.dart
│   ├── pages/
│   │   ├── basic_example.dart
│   │   ├── advanced_example.dart
│   │   └── custom_indicator_example.dart
│   └── mock_data.dart
└── pubspec.yaml
```

---

## 常见问题

### Q1: 如何更新二进制库？

**A:** 重新编译并替换 `.aar` 和 `.framework` 文件，然后更新版本号。

### Q2: 用户如何调试问题？

**A:** 提供详细的日志输出和错误信息，保留符号表用于错误追踪。

### Q3: 如何处理不同平台的兼容性？

**A:** 为每个平台分别编译，在 Plugin 层做平台适配。

### Q4: 二进制文件太大怎么办？

**A:** 
- 启用 `--split-per-abi` 分别打包不同架构
- 使用 `--tree-shake-icons` 删除未使用的图标
- 开启 ProGuard 代码压缩

### Q5: 如何防止破解？

**A:**
- 实施许可证验证
- 关键算法用 Native 代码实现
- 定期更新和检查完整性
- 使用代码混淆和加壳技术

---

## 总结

### ✅ 推荐方案：AOT 编译 + 二进制分发

这是最安全、最专业的代码保护方案：

1. **安全性高**：真正的机器码保护
2. **性能好**：AOT 编译性能最佳
3. **易分发**：标准的 Plugin 形式
4. **用户友好**：保持清晰的 API 接口

### 🔒 保护范围建议

- ✅ 核心算法（80% 保护）
- ✅ 业务逻辑（100% 保护）
- ❌ UI 层（0% 保护，用户需要自定义）
- ❌ 配置类（0% 保护，用户需要使用）

### 📈 持续改进

- 定期更新编译工具链
- 关注 Flutter 官方的安全建议
- 收集用户反馈优化 API
- 监控性能指标

---

## 参考资源

- [Flutter 官方文档 - Add Flutter to existing app](https://docs.flutter.dev/add-to-app)
- [Dart AOT 编译](https://dart.dev/tools/dart-compile)
- [Android AAR 文档](https://developer.android.com/studio/projects/android-library)
- [iOS Framework 创建指南](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPFrameworks/)
- [代码混淆最佳实践](https://docs.flutter.dev/deployment/obfuscate)

---

**版本**: 1.0.0  
**更新日期**: 2026-01-31  
**作者**: FlexiKline Team  
**许可证**: Commercial License
