# VideoEdit
######  AVAsset：素材库里的素材； 
###### AVAssetTrack：素材的轨道； 
###### AVMutableComposition ：一个用来合成视频的工程文件； 
###### AVMutableCompositionTrack ：工程文件中的轨道，有音频轨、视频轨等，里面可以插入各种对应的素材；

###### AVMutableVideoComposition：用来生成video的组合指令，包含多段instruction。可以决定最终视频的尺寸，裁剪需要在这里进行； 
###### AVMutableVideoCompositionInstruction：一个指令，决定一个timeRange内每个轨道的状态，包含多个layerInstruction； 
###### AVMutableVideoCompositionLayerInstruction：在一个指令的时间范围内，某个轨道的状态；
