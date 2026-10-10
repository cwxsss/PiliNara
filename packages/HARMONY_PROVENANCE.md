# 鸿蒙适配源码来源

- media_kit / media_kit_video: Starfallan/media-kit native, commit 83dc986255a260932ccf3cfa865da31956050eb2。保留定制 NativePlayer 接口，新增 OHOS 库加载、事件循环及纹理后端。
- OHOS ArkTS 纹理插件及原生库: CPF-Flutter/fluttertpc_flutter_media_kit, commit d424290ea300c140a1f563f44a8f0461628a3aa4。原始许可证和 README 保留，设备兼容性尚未验收。
- path_provider / path_provider_ohos: CPF-Flutter/flutter_packages, br_path_provider-v2.1.5_ohos, commit d4e49daa0acbd0bc419d58b1da27d64d44fab54b。

本地源码固定在 packages 中，未替换原版页面、接口、字幕和弹幕逻辑。原生库来源已记录，未声明完成鸿蒙 7 播放验收。

- audio_service：原项目 bggRGjQaUbCoE/audio_service dev，解析 commit ac920683b8140134fe8af8f7d1d89f155a879e1d，保留 0.18.19 定制接口。
- audio_session：原项目 bggRGjQaUbCoE/audio_session dev，解析 commit c8c2143c1720292801f72867e29ddeb50c36134e，保留版本 0.2.4 和原 Android/Darwin 修复。OHOS core.dart / ohos.dart / 原生模块来自 CPF-Flutter/flutter_audio_session tag 0.2.2-ohos-1.0.0，commit bd97a32d519c94772a4693d92cca88b145c6f4f3。平台判断使用 OS 名称以保留官方 Flutter 编译兼容性。
- audio_service_ohos：CPF-Flutter/fluttertpc_audio_service，commit 89d712c150cd979692fb360fe698bd107c7eae47，仅使用原生 OHOS 子插件。
- material_ui：pub 1.6.0，原始内容校验见 tool/harmony/pubspec.upstream.lock。应用原项目 lib/scripts/material 补丁，再补全 OHOS 移动端 UI 分支。
- catcher_2：My-Responsitories/catcher_2 dev，使用本地浅克隆源保留原接口，未声称其含完整鸿蒙原生实现。

- cupertino_ui：pub 1.1.2，与迁移前本次已解析版本一致，保留许可证，补齐 17 处 OHOS 平台分支，使用 Android 同等行为。
- flutter_math_fork：pub 0.7.4，与迁移前本次已解析版本一致，保留许可证、字体及数学渲染逻辑，补齐 4 处平台分支。
- material_ui 的 selectable_text 追加 1 处空平台分支的 default，以保持 Android 的无操作行为。

- screen_brightness_ohos：pub 2.1.4，来源 https://pub.dev/packages/screen_brightness_ohos ，保留原许可证，修复系统亮度 EventChannel 错接应用亮度 handler。
- wakelock_plus：保留 pub 1.8.0 的 Dart 和其他平台源码；仅 OHOS 模块来自 CPF-Flutter/fluttertpc_wakelock_plus commit bed355f693e8090cd513995bb8feb55af8eaec2b，通道全名和 IsEnabledMessage 编码标签按现有 platform_interface 1.7.0 对齐，原生模块名统一为 wakelock_plus。
- connectivity_plus：保留 pub 7.3.1 的 Dart 和其他平台源码；仅 OHOS 模块来自 CPF-Flutter/flutter_plus_plugins tag connectivity_plus-7.0.0-ohos.1.0.0，commit 9514235dda402b432b860a31c69d4dc5153891f5；返回列表接口兼容现有 platform_interface 2.1.0。

- battery_plus：保留 pub 7.1.2 的 Dart 和其他平台源码；仅 OHOS 模块来自 CPF-Flutter/flutter_plus_plugins tag battery_plus-7.0.0-ohos-1.0.1，commit b8647bf46219d7d0a5235766aea0974d999f130f，通道与现有 platform_interface 2.0.1 保持一致。

- WebView：保留 flutter_inappwebview 6.1.5 的其他平台实现；OHOS、platform_interface 与 internal_annotations 来自 CPF-Flutter/flutter_inappwebview tag 6.1.5-ohos-1.0.0，commit 528fa913763148719cde7dae2dc22dc33f15da36。
- package_info_plus：保留 pub 10.2.2 的 Dart 与其他平台；OHOS 来自 CPF-Flutter/flutter_plus_plugins tag package_info_plus-9.0.0-ohos-1.0.0，commit bc4df814a726042a9dad1a267ebb1d2973544e24。
- native_device_orientation：保留原项目 commit 7be186c79adca7d3ff5abc34bc75d171c68c2694；OHOS 来自 CPF-Flutter/fluttertpc_native_device_orientation commit 2f2dc35912e46bc41368e2b9cbd6fe46837a67f4。
- app_links_ohos：harmonycandies/app_links_ohos 0.2.0，commit dc57b12b34e7e66fe90558be8f29c082c4d3dce0。
- url_launcher_ohos：pub 镜像归档 6.3.0，来源 openharmony-tpc/flutter_packages br_url_launcher-v6.3.0_ohos。原许可证保留。
- 本项目修复：OHOS 视频使用 video-params 源尺寸，按实际尺寸重建输出，避免输出尺寸反馈循环；HTTPS 媒体由校验证书的 Dart HttpClient 经本机随机令牌地址转发，不关闭 TLS 校验。
