import hilog from '@ohos.hilog';
import { TextureRegistry } from '@ohos/flutter_ohos';
import VideoOutput from './VideoOutput';
import { TextureUpdateCallback } from './TextureUpdateCallback';
import {ArkTSUtils} from "@kit.ArkTS"
/**
 * VideoOutputManager类管理多个VideoOutput实例
 */
export default class VideoOutputManager {
  private static readonly TAG: string = 'VideoOutputManager';
  private videoOutputs: Map<number, VideoOutput> = new Map();
  private textureRegistryReference: TextureRegistry;
  // private lock: Object = new Object();
  private lock = new ArkTSUtils.locks.AsyncLock();
  /**
   * 构造函数
   * @param textureRegistryReference 纹理注册表引用
   */
  constructor(textureRegistryReference: TextureRegistry) {
    this.textureRegistryReference = textureRegistryReference;
    hilog.info(0x0000, VideoOutputManager.TAG, 'VideoOutputManager initialized');
  }

  /**
   * 创建新的视频输出实例
   * @param handle 视频输出句柄
   * @param textureUpdateCallback 纹理更新回调
   */
  public async create(handle: number, textureUpdateCallback: TextureUpdateCallback): Promise<void> {


    await synchronized(this.lock, () => {
      try {
        if (!this.videoOutputs.has(handle)) {
          const videoOutput = new VideoOutput(this.textureRegistryReference, textureUpdateCallback);
          this.videoOutputs.set(handle, videoOutput);
          hilog.info(0x0000, VideoOutputManager.TAG, 'VideoOutput created for handle: %{public}d', handle);


        }
      } catch (error) {
        hilog.error(0x0000, VideoOutputManager.TAG, 'create error: %{public}s', (error as Error).toString());
      }
    });


  }

  /**
   * 设置视频输出表面大小
   * @param handle 视频输出句柄
   * @param width 宽度
   * @param height 高度
   */
  public async setSurfaceSize(handle: number, width: number, height: number): Promise<void> {
   await synchronized(this.lock, () => {
      try {
        const videoOutput = this.videoOutputs.get(handle);
        if (videoOutput) {
          videoOutput.setSurfaceSize(width, height);

          hilog.info(0x0000, VideoOutputManager.TAG, 'Surface size set for handle %{public}d: %{public}d x %{public}d', handle, width, height);
        }
      } catch (error) {
        hilog.error(0x0000, VideoOutputManager.TAG, 'setSurfaceSize error: %{public}s', (error as Error).toString());
      }
    });
  }

  /**
   * 释放视频输出资源
   * @param handle 视频输出句柄
   */
  public async dispose(handle: number): Promise<void> {
    await synchronized(this.lock, () => {
      try {
        const videoOutput = this.videoOutputs.get(handle);
        if (videoOutput) {
          videoOutput.dispose();
          this.videoOutputs.delete(handle);
          hilog.info(0x0000, VideoOutputManager.TAG, 'VideoOutput disposed for handle: %{public}d', handle);
        }
      } catch (error) {
        hilog.error(0x0000, VideoOutputManager.TAG, 'dispose error: %{public}s', (error as Error).toString());
      }
    });
  }
}

/**
 * 简单的同步锁实现
 * @param lock 锁对象
 * @param action 要执行的操作
 */
async function synchronized(lock: ArkTSUtils.locks.AsyncLock, action: () => void): Promise<void> {
  // 在TypeScript/ArkTS中模拟同步锁
  // action();
  await lock.lockAsync(action)
}