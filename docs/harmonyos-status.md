# 鸿蒙迁移状态（2026-10-10）

本工程已生成 API 26 签名调试 HAP，并在鸿蒙 7 真机安装、启动；界面已显示。用户已确认视频真实画面恢复正常；声音、后台播放、登录及最终手势效果仍需进一步验收。当前仅调试包构建通过；Windows AOT 编译器与内核格式不匹配，profile 构建失败，release 未验证。

| 检查 | 实际结果 | 证据 |
|---|---|---|
| Windows 开发者模式 | AllowDevelopmentWithoutDevLicense=1；文件符号链接创建成功 | developer-mode-result.log、developer-mode-symlink.dart（本地忽略） |
| 依赖解析 | Flutter pub get --offline --no-example exit 0 | tool/harmony/pub-get-realpath.log |
| 应用 Dart 分析 | 0 errors，72 warnings/info；整体 exit 2 | tool/harmony/analysis-final-app.log |
| media_kit_video 分析 | 0 errors，66 warnings/info；整体 exit 2 | tool/harmony/analysis-video-fixed.log |
| 音频服务、音频会话及 media_kit 分析 | 0 errors，47 warnings/info；整体 exit 2 | tool/harmony/analysis-adapted-plugins.log |
| 主机平台分类 | Windows 主机检查通过；不是鸿蒙设备验证 | tool/harmony/platform_check.dart |
| SDK 补丁 | git apply --reverse --check exit 0；仅检查，未撤销补丁 | tool/harmony/flutter-sdk.patch |
| Flutter 测试 | 未通过；资源着色器包含路径失败，跳过无关资源后测试引擎报 Invalid SDK hash | tool/harmony/platform-test.log、platform-test-no-assets.log |
| 首次 HAP | 失败，D/E 盘映射导致插件 srcPath 跨盘；已统一真实 E 盘路径 | tool/harmony/hap-debug-build.log |
| 再次 HAP | 失败，旧 Hvigor 不接受 26.0.0 SDK 配置；本机 SDK 只有 API 24 | tool/harmony/hap-debug-realpath.log |
| hdc 设备 | 已通过用户提供的 Wi-Fi 调试地址连接；实查 HarmonyOS 7.0.0.109 / API 26 | hdc tconn、param get const.ohos.apiversion、const.product.software.version |
| 当前 HAP | 构建 exit 0；最终包含电量、联网、亮度及常亮插件；未签名 | tool/harmony/hap-debug-battery.log |
| 当前源码分析 | lib 与本轮 UI/系统插件：0 errors，15 warnings，2321 info；整体 exit 2 | tool/harmony/analysis-ui-system-plugins.log |

## 并行安装状态

已使用用户提供的 D:/下载/devecostudio-windows-26.0.0.851.zip 并行安装到 E:/deveco-26，安装程序退出码 0。安装程序 Authenticode 签名有效，签署方 Huawei Technologies Co., Ltd.。ZIP SHA-256：33CE2D302ECCCDBC27287BD6523BD32C6F4DA32C80D6C7F33057B83B1EEFB9D9。实查 product-info.json 为 26.0.0.851，SDK API 26 / 26.0.0.105，Java 25.0.2、Node 24.14.1 均可运行。旧 E:/deveco 6.1.1.300 与 SDK API 24 / 6.1.1.125 仍保留。

已处理新 Hvigor 的路径限制：Junction 英文入口仍会被真实路径解析影响，因此在 E:/pilinara-workspace 建立真实英文构建副本（包含当前源码、专用 Flutter SDK、依赖缓存）。tool/harmony/build-debug.ps1 从原项目安全同步代码，保留构建副本中的 IDE 签名配置，使用新 DevEco 自带 Java/Node；加入 jbr/bin 后解决 PackageHap 的 spawn java ENOENT。

已补齐本次 Dart 编译实际发现的 22 处 UI 平台分支；FlutterTask（含资源着色器）、ArkTS 和 HAP 打包均通过。Windows Flutter 测试引擎仍报 Invalid SDK hash；已记录并终止无法启动 isolate 的测试，不能声称测试通过。

最终未签名调试包：build/ohos/hap/entry-default-unsigned.hap，291282326 字节。已检查 HAP ZIP 内含 arm64 libflutter.so、libmpv.so.2、kernel_blob.bin、ets/modules.abc。仍需运行设备验证内核和媒体库兼容性。

用户已允许打开新 DevEco，并自行完成华为账号登录 / 自动签名。已启动 E:/deveco-26/bin/devecostudio64.exe，项目 E:/pilinara-workspace/PiliNara-upstream/ohos。当前自动签名配置数量为 0，尚未取得证书和 Profile；本机 UI 工具不支持 DevEco 原生窗口，已给出 File > Project Structure > Project > Signing Configs 操作路径。未读取私钥或密码，未在手机安装未签名包。

官方升级指南：https://developer.huawei.com/consumer/en/doc/harmonyos-releases/upgrade-adaptation
新版本工具说明：https://developer.huawei.com/consumer/cn/doc/doccenter-release-notes/deveco-studio-hmos-new-features-2600

## 剩余工作

1. 用户完成自动签名后，用 build-debug.ps1 -Sign 构建并安装真机；继续定位 Windows Flutter 测试引擎的 SDK hash 不一致。
2. 接入缺失的启动及系统插件，软件包与设备信息，以及 WebView / 登录 / 分享 / 文件 / 权限。支持清单见 tool/harmony/plugin-audit.json；该清单包含其他平台专用子包，不能把全部无 OHOS 声明的包数当成功能缺失数。
3. 鸿蒙 7 真机验证启动、登录、DASH 同步、播放、后台、亮度、常亮、电量和资源释放；构建成功不代表完整运行适配。

不将静态分析的 0 errors、源码生成或依赖解析当作整体适配完成。未暂存、提交、推送或发布。


## 2026-10-10 真机签名与启动验证

- 用户完成 DevEco 自动调试签名，签名配置数量为 1。签名构建退出码 0。
- 签名 HAP：`build/ohos/hap/entry-default-signed.hap`；SHA256：`A9A1A806F69FCC5AE0EEEA52E7B82A0D790C4DB753185450B75E41E4C6E8DB51`。
- 在已连接的 HarmonyOS 7 / API 26 手机上安装成功，EntryAbility 启动成功，进程持续存在。
- 启动日志确认 Dart 执行及音频会话创建，未出现 MissingPluginException、Unhandled Exception 或 Invalid SDK hash。存在系统可选库 libtransform_interaction_ext.z.so 加载错误，暂未证明影响界面。
- 首页显示、视频画面和声音、登录、后台播放仍待手机交互验证。签名凭据保留在独立构建目录，不复制至源码仓库。


## 2026-10-10 白屏与桌面图标修复

- 真机诊断确认启动白屏由 `LoginUtils.setWebCookie` 在 WebView 平台实现未注册时构造 CookieManager 引发断言，发生在 runApp 之前。现在先检查 `InAppWebViewPlatform.instance`，缺少实现时跳过 WebView Cookie 同步；HTTP 账户 Cookie 初始化仍保留。WebView 登录并未因此完成移植。
- 亮度插件使用 FlutterPluginBinding 的真实应用 Context，并通过 AbilityAware 保存窗口所属 Ability，修正 getContext(this) 和空 Ability 引发的参数错误。
- AppScope 和 EntryAbility 桌面图标采用本机 DevEco 分层图标模板，保留原 PNG 前景，添加纯白 SVG 背景；构建脚本补充同步 AppScope 资源，保留独立目录的签名配置。
- 签名构建退出码 0；覆盖安装成功。main.dart 与 login_utils.dart 静态分析 No issues found，git diff --check 通过。
- 解锁后启动日志已越过 Cookie 初始化、主题初始化及日志初始化，Catcher 配置完成。手机截图显示视频详情、封面与推荐列表，原启动白屏故障点解除。桌面图标实际观感及视频画面、声音仍需用户确认。
- 运行日志另有 package_info、app_links、native_device_orientation 缺失实现提示，后续适配尚未完成。


## 2026-10-10 视频播放真机排查（进行中）

- 首次持续加载的直接错误为 native FFmpeg HTTPS TLS 解密失败（SSL3_GET_RECORD: bad record mac），媒体 URL 已获取，纹理已创建。库内版本字符串为 OpenSSL 1.0.2u。
- 新增仅鸿蒙视频流使用的 HarmonyMediaRelay：Dart 默认校验 TLS 的 HttpClient 下载远端流，本机 loopback 监听随机端口，随机能力路由供 mpv 读取；保留 Range、If-Range、Referer、User-Agent、HEAD 和响应状态、长度、分段头。不向日志输出媒体 URL；播放器销毁时关闭转发与客户端。
- 独立 Dart 回归检查通过：Range、HEAD、完整数据、请求头、隐藏上游 URL、无效路由。真机响应为 206，用户确认已能加载，但播放断续。此结果不代表完整播放通过。
- 日志进一步发现 1920×1080 与 960×540 输出尺寸反复切换，并伴随 H.264 参考帧错误。第一次减少 vo 重建后用户看到纯色，真机截图证实。
- 正在改为监听源 video-params，避免 video-out-params 与 surface 尺寸互相反馈；仅真实几何变化时按播放库要求重新初始化输出，避免初始化 1×1 表面被拉伸。最终画面、声音和连续播放仍待验证。

- 用户已确认源视频尺寸修正版恢复正常视频画面。持续音频、后台播放及全屏等仍需独立验证。

## 后续插件集成（2026-10-10）

已接入 OHOS WebView（并启用原网页登录入口）、package_info_plus、native_device_orientation、app_links_ohos 与 url_launcher_ohos。实际注册 OHOS 原生插件增加到 16 个。签名调试 HAP 构建成功（hap-integrated-plugins.log，82.9 秒）；媒体转发独立回归通过 Range、HEAD、完整流、请求头、私有路由与非法路由验证。

新增包首次安装时无线调试 172.16.0.146:12345 已断开，重连失败，最新集成包尚未安装。此前视频修复包已由用户确认画面正常。网页登录、声音连续性、旋转及后台播放仍需真机验收；不应把编译成功当作完整验收。

## 视频进度拖动性能排查

无线调试恢复后，集成包安装及启动成功（进程 39904）；用户反馈视频页左右滑动和调节进度不流畅，尚未确认网页登录与声音验收。

AOT profile 构建尝试失败：Windows OHOS gen_snapshot 为 Dart 3.12.2，期望 kernel 130，而当前应用为 kernel 138。禁用动态图标裁剪后仍有该工具链错误，未生成或安装优化构建包。官方附件下载当前返回 401；不能声称 release/profile 可构建。

媒体转发原先运行于界面 Isolate，本次移到独立 Isolate，使 HTTP/TLS 与数据传输不占用界面事件处理。Range、HEAD、完整流、请求头与私有路由回归通过；实际拖动改善需安装后确认。

独立媒体 Isolate 修正版签名构建成功（42.8 秒），HAP SHA-256 为 830ABBADEB7BEF49B0797684CC4F62DA4E061C8D0EC50C7099FD40C49160B9ED。已覆盖安装成功，保留应用数据；自动启动因手机锁屏被拒绝。已开启日志采集并请求同视频拖动复测，尚未确认流畅度改善。静态检查为 0 errors / 0 warnings / 4 info。

用户进一步说明卡顿表现为横向滑动被误判为纵向，代码中原方向判定仅等待约 1 逻辑像素。已仅在鸿蒙使用 18 逻辑像素确认距离，横向允许 1.2 倍主轴优势，纵向需 1.5 倍，方向未明确时等待；确认后沿用原方向锁定流程，其他平台保持原规则。video_pan_regression.dart 覆盖初始抖动、水平偏移、上下拖动、反向与对角线，全部通过；view.dart 与 video_pan_axis.dart 静态分析 No issues found。签名构建 45.1 秒，HAP SHA-256 为 1882F526A1C82ABFF440C823E15A259995F9E8DA96B6D867C844BCA8CC545AA0；覆盖安装和启动成功（进程 57031），正在等待用户实际手感复测。

## 当前阶段交付

用户选择“先这样吧”，按当前版本收尾上传代码。最新方向判定修复包已安装并启动，但用户未确认最终手势体验，不能记为真机验收通过。已停止本轮持续日志采集。声音、后台播放、网页登录以及最终手势效果仍待验收；Windows AOT 工具链限制仍保留。

上传保留上游源码历史及 cwxsss/PiliNara 的初始化提交，主体许可证仍为上游 GPLv3。第三方原始源码含已有尾随空白，完整暂存 diff --check 因此未全量通过；应用与新增验证工具的差异格式检查通过。
