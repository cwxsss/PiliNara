# PiliNara Flutter 鸿蒙迁移

路线：保留 Flutter 原版界面、业务与资源；ArkTS 用于原生插件桥接，目标 HarmonyOS 7 / SDK 26.0.0。

基线：上游 1807e22，版本 2.1.5+1。当前项目专用 Flutter SDK 为 oh-flutter/flutter_flutter tag 3.47.5-ohos-1.0.0，commit 39481acce8b9e6bb902714e6705c8baf75662d49，工具报告 Dart 3.13.3。原项目通用框架补丁已合并到该 SDK；可复现补丁为 tool/harmony/flutter-sdk.patch。原版 Flutter SDK 也需要上游自身的 lib/scripts/patch.ps1 所列补丁。

## 已实施

- 生成 ohos 工程，保持 Flutter 页面、接口、字幕和弹幕代码。
- 鸿蒙进入移动端生命周期，Android JNI SDK 等级查询仅在 Android 执行。
- 保留定制 media_kit 接口，加入 OHOS 原生库加载、Isolate 事件循环、纹理输出和释放；表面尺寸调整不重置播放进度。
- 为本地 Material 组件、文本编辑和纵向滑块补全平台分支，鸿蒙沿用现有移动交互。
- 保留定制 audio_service 0.18.19 / audio_session 0.2.4 的原平台代码，新增鸿蒙音频服务与会话接口。
- 使用计时器等价的 Future<void>.delayed 兼容当前鸿蒙 SDK 平台摘要缺失的 Future.pause。
- 接入鸿蒙亮度、屏幕常亮、网络类型及电量原生插件，保留当前 Dart 接口；配置后台音频模式与权限。
- 补齐本轮实际编译发现的 Cupertino / 数学组件平台分支。
- 固定相关依赖源码到 packages，来源见 packages/HARMONY_PROVENANCE.md。

## 尚未验收

- 网页登录、版本信息、旋转与链接跳转已接入并通过签名构建，仍待真机逐项验收。权限、文件选择、分享、下载等功能也需继续验证。
- DASH 音视频同步、弹幕字幕、倍速、画质、后台音频和纹理释放需要设备测试。
- API 26 签名 HAP 构建已通过；此前版本已安装于鸿蒙 7 真机，用户确认视频画面正常。最新插件包因无线调试断开尚未安装。
- Windows Flutter 测试引擎仍无法加载内核（Invalid SDK hash）。

## 工具链与证据

原项目保留在 E:/文档/日常项目/PiliNara-upstream。新 Hvigor 不接受中文项目路径，实际构建使用 E:/pilinara-workspace/PiliNara-upstream 的完整英文副本。新 DevEco 在 E:/deveco-26（26.0.0.851 / SDK API 26）；旧 E:/deveco 保留。

使用 PowerShell 7 执行 tool/harmony/build-debug.ps1，可同步原项目代码并构建未签名调试包；签名配置在英文副本的 ohos 工程中由 DevEco 生成，脚本不会覆盖该配置。签名就绪后加 -Sign；依赖已解析且未变化时可加 -SkipPub。

详细验证结果与安装状态见 docs/harmonyos-status.md。源码生成、依赖解析、静态检查、编译、签名和设备运行是不同层级证据。

## 性能验证构建

脚本支持 -BuildMode debug/profile/release，并保留动态图标（--no-tree-shake-icons）。当前 Windows OHOS AOT 编译器与应用内核版本不匹配，profile 尝试失败，release 尚未验证。请先配置与 SDK 同批次的宿主 AOT 编译器，不能直接使用旧 gen_snapshot。
