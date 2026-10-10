/**
 * This file is a part of media_kit (https://github.com/media-kit/media-kit).
 * <p>
 * Copyright © 2021 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
 * All rights reserved.
 * Use of this source code is governed by MIT license that can be found in the LICENSE file.
 */

/**
 * TextureUpdateCallback 接口定义了纹理更新回调方法
 */
export interface TextureUpdateCallback {
  onTextureUpdate:(id: number, wid: number, width: number, height: number) => void;
}