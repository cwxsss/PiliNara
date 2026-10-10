
import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import VideoOutputManager from './VideoOutputManager';
import { Utils } from './Utils';
import { hilog } from '@kit.PerformanceAnalysisKit';

interface RectParams {
  left: number;
  top: number;
  width: number;
  height: number;
}
/**
 * MediaKitVideoPlugin实现Flutter与鸿蒙平台之间的视频播放通信
 */
export default class MediaKitVideoPlugin implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;
  private videoOutputManager: VideoOutputManager | null = null;
  private id:number=0
  private wid:number=0
  constructor() {}

  getUniqueClassName(): string {
    return "MediaKitVideoPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "com.alexmercerind/media_kit_video");
    this.channel.setMethodCallHandler(this);
    
    // 初始化VideoOutputManager
    this.videoOutputManager = new VideoOutputManager(binding.getTextureRegistry());
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null);
    }
    
    // 清理资源
    this.videoOutputManager = null;
  }

  async onMethodCall(call: MethodCall, result: MethodResult): Promise<void> {
    try {
      let args: Map<string, Object> = call.args as Map<string, Object>;
      switch (call.method) {
        case "VideoOutputManager.Create": {



          const handle: number = Number(args.get("handle"));

          hilog.info(0x0000, "MediaKitVideoPlugin", 'VideoOutputManager.Create: handle='+handle);


          if (this.videoOutputManager && this.channel) {


            await this.videoOutputManager.create(handle, {
              onTextureUpdate: (id: number, wid: number, width: number, height: number) => {

                this.id=id
                this.wid=wid
                const rect: RectParams = {
                  left: 0,
                  top: 0,
                  width: width,
                  height: height
                };
                // 向Flutter端发送纹理更新事件
                this.channel?.invokeMethod("VideoOutput.Resize", {
                  handle: handle,
                  id: id,
                  wid: wid,
                  rect: rect
                });
              }
            });

            result.success(null);
          } else {
            result.error("ERROR", "VideoOutputManager not initialized", null);
          }
          break;
        }
        case "VideoOutputManager.SetSurfaceSize": {
          const handle: number = Number(args.get("handle"));
          const width: number = Number(args.get("width"));
          const height: number = Number(args.get("height"));
          if (this.videoOutputManager) {
            await this.videoOutputManager.setSurfaceSize(handle, width, height);
            result.success(null);
          } else {
            result.error("ERROR", "VideoOutputManager not initialized", null);
          }
          break;
        }
        case "VideoOutputManager.Dispose": {
          const handle: number = Number(args.get("handle"));
          
          if (this.videoOutputManager) {
            await this.videoOutputManager.dispose(handle);
            result.success(null);
          } else {
            result.error("ERROR", "VideoOutputManager not initialized", null);
          }
          break;
        }
        case "Utils.IsEmulator": {
          result.success(Utils.isEmulator());
          break;
        }
        case "getPlatformVersion": {
          result.success("OpenHarmony ^ ^ ");
          break;
        }
        default: {
          result.notImplemented();
          break;
        }
      }
    } catch (error) {
      result.error("ERROR", error.toString(), null);
    }
  }
}