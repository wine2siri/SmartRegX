# 小白正则 - 构建发布自检清单

## 历史构建失败经验教训

### 1. Dart 包名规范冲突
**现象**：`flutter create . --platforms android` 报错 `SmartRegX is not a valid Dart package name`  
**原因**：GitHub 仓库名含大写字母，`flutter create` 从目录名推断包名，但 Dart 要求全小写  
**解决**：在 `pubspec.yaml` 中显式指定 `name: xiaobai_regex`，且不再依赖 `flutter create` 自动生成平台文件  
**自检**：✅ 包名必须全小写，可用下划线，不可含大写或连字符

### 2. Gradle DSL 语法混用
**现象**：`.gradle.kts`（Kotlin DSL）文件中出现 35 个编译错误，如 `Unresolved reference: def`  
**原因**：在 `.gradle.kts` 文件中混用了 Groovy 语法（`def`、`assert`、闭包写法等）  
**解决**：改用 `.gradle`（Groovy DSL）文件，语法统一  
**自检**：✅ `.gradle.kts` 用 Kotlin 语法，`.gradle` 用 Groovy 语法，不可混用

### 3. 缺少 Android 平台文件
**现象**：CI 中 `flutter build apk` 失败，找不到 Android 配置  
**原因**：项目初始未包含 `android/` 目录，CI 环境无法构建  
**解决**：手动创建完整的 Android 项目结构并提交到仓库  
**自检**：✅ 确保仓库包含完整的平台目录（android/、web/ 等）

### 4. 缺少应用图标资源
**现象**：`AAPT: error: resource mipmap/ic_launcher not found`  
**原因**：AndroidManifest 引用了 `@mipmap/ic_launcher` 但未提供对应资源文件  
**解决**：创建 drawable 矢量图标 + adaptive-icon（API 26+），AndroidManifest 改用 `@drawable/ic_launcher`  
**自检**：✅ AndroidManifest 中引用的每个资源都必须存在对应文件

### 5. flutter analyze 代码质量问题
**现象**：CI 中代码分析不通过  
**原因**：未使用的 import、多余的非空断言、未使用的字段  
**解决**：提交前运行 `flutter analyze` 并修复所有警告  
**自检**：✅ 提交前必须执行 `flutter analyze` 确保零警告零错误

### 6. Node.js 版本弃用警告
**现象**：GitHub Actions 中 Node.js 20 弃用警告  
**原因**：actions/checkout@v4、actions/setup-java@v4 仍运行在 Node.js 20 上  
**解决**：在 workflow 中设置 `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true`  
**自检**：✅ 在 workflow 顶级 env 中添加 Node24 环境变量

---

## 发布前自检清单

### 代码质量
- [ ] `flutter analyze` 零错误零警告
- [ ] `flutter test` 全部通过
- [ ] 无未使用的 import 和变量
- [ ] pubspec.yaml 包名全小写

### 平台文件完整性
- [ ] `android/` 目录完整（build.gradle、settings.gradle、AndroidManifest.xml、MainActivity.kt、资源文件）
- [ ] `web/` 目录完整（index.html、manifest.json、icons/）
- [ ] AndroidManifest 中引用的所有资源文件都存在
- [ ] Gradle 文件语法正确（.gradle 用 Groovy，.gradle.kts 用 Kotlin）

### CI/CD 配置
- [ ] workflow 中设置 `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true`
- [ ] Flutter 版本与本地开发一致
- [ ] 构建产物路径正确
- [ ] artifact 上传路径正确

### 版本发布
- [ ] pubspec.yaml 中 version 已更新
- [ ] CHANGELOG 或 Release Notes 已编写
- [ ] Git tag 已打上（如 v1.0.0）
- [ ] GitHub Release 已创建并附带构建产物
