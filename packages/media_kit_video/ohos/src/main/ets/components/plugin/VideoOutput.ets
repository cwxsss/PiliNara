import hilog from '@ohos.hilog';
import { TextureRegistry, SurfaceTextureEntry } from '@ohos/flutter_ohos';
import { TextureUpdateCallback } from './TextureUpdateCallback';
import { ArkTSUtils } from '@kit.ArkTS';

/**
 * VideoOutput类管理视频输出表面和纹理注册
 */
export default class VideoOutput {
  private static readonly TAG: string = 'VideoOutput';
  private id: number = 0;
  private wid: number = 0;
  private surfaceTextureEntry: SurfaceTextureEntry | null = null;
  private textureUpdateCallback: TextureUpdateCallback;
  private textureRegistry: TextureRegistry;
  private width:number=1
  private height:number=1
  // private lock: Object = new Object();
  private lock = new ArkTSUtils.locks.AsyncLock();

  /**
   * 构造函数
   * @param textureRegistry 纹理注册表引用
   * @param textureUpdateCallback 纹理更新回调
   */
  constructor(textureRegistry: TextureRegistry, textureUpdateCallback: TextureUpdateCallback) {
    this.textureRegistry = textureRegistry;
    this.textureUpdateCallback = textureUpdateCallback;
    this.registerSurfaceProducer();
  }

  /**
   * 注册表面生产者
   */
  private registerSurfaceProducer(): void {
    synchronized(this.lock, () => {
      try {
        // 注册纹理并获取SurfaceTextureEntry
        this.surfaceTextureEntry = this.textureRegistry.registerTexture(this.textureRegistry.getTextureId());
        if (this.surfaceTextureEntry) {
          this.id = this.surfaceTextureEntry.getTextureId();
          // 在鸿蒙平台，我们使用surfaceId作为wid
          this.wid = this.surfaceTextureEntry.getSurfaceId();
          
          // // 通知纹理更新
          this.textureUpdateCallback.onTextureUpdate(
            this.id,
            this.wid,
            this.width, // 初始宽度
            this.height  // 初始高度
          );
          
          hilog.info(0x0000, VideoOutput.TAG, 'Surface registered successfully: id=%{public}d, wid=%{public}d', this.id, this.wid);
        }
      } catch (error) {
        hilog.error(0x0000, VideoOutput.TAG, 'registerSurfaceProducer error: %{public}s', (error as Error).toString());
      }
    });
  }

  /**
   * 设置表面大小
   * @param width 宽度
   * @param height 高度
   */
  public setSurfaceSize(width: number, height: number): void {
    synchronized(this.lock, () => {
      try {
        if (this.surfaceTextureEntry) {
          // 通知纹理大小调整
          this.textureRegistry.notifyTextureResizing(this.id,width, height);
          
          // 更新纹理信息
          this.textureUpdateCallback.onTextureUpdate(
            this.id,
            this.wid,
            width,
            height
          );
          hilog.info(0x0000, VideoOutput.TAG, 'Surface size set: %{public}d x %{public}d', width, height);
        }
      } catch (error) {
        hilog.error(0x0000, VideoOutput.TAG, 'setSurfaceSize error: %{public}s', (error as Error).toString());
      }
    });
  }

  /**
   * 释放资源
   */
  public dispose(): void {
    synchronized(this.lock, () => {
      try {
        if (this.surfaceTextureEntry) {
          // 通知纹理清理
          this.textureUpdateCallback.onTextureUpdate(
            this.id,
            0, // 清除wid
            0,
            0
          );
          
          // 释放表面纹理条目
          this.surfaceTextureEntry.release();
          this.surfaceTextureEntry = null;
          
          hilog.info(0x0000, VideoOutput.TAG, 'Surface disposed successfully: id=%{public}d', this.id);
        }
      } catch (error) {
        hilog.error(0x0000, VideoOutput.TAG, 'dispose error: %{public}s', (error as Error).toString());
      }
    });
  }
}

/**
 * 简单的同步锁实现
 * @param lock 锁对象
 * @param action 要执行的操作
 * @returns 操作结果
 */
 async function synchronized<T>(lock: ArkTSUtils.locks.AsyncLock, action: () => T): Promise<void> {
   await lock.lockAsync(()=>{
     action()
   })
  // 在TypeScript/ArkTS中模拟同步锁
  // return action();

}


