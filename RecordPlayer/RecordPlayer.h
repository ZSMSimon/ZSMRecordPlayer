//
//  RecordPlayer.h
//  ZSMRecordPlayer
//
//  Created by Simon on 2018/5/19.
//  Copyright © 2018年 Simon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, RecordPlayState) {
    RecordPlayStateReady,      // 准备播放
    RecordPlayStatePlaying,    // 播放中
    RecordPlayStatePause,      // 播放暂停
    RecordPlayStateStopped,    // 停止播放
    RecordPlayStateError       // 播放出错
};

/** 录音时间和录音音波强度回调 */
typedef void(^PlayCallBackBlock)(CGFloat,int);

typedef void(^PlayProgressBlock)(CGFloat,CGFloat,CGFloat);

@interface RecordPlayer : NSObject

/** 音频路径 */
@property (nonatomic, strong, readonly) NSString *filePath;

/** 播放总时间 */
@property (nonatomic, assign, readonly) CGFloat playTotalTime;

/** 播放当前时间 */
@property (nonatomic, assign, readonly) CGFloat playCurrentTime;

/**播放的数据源*/
@property (nonatomic, strong, readonly) NSData *playData;

/** 当前播放的音量 可设置范围为0至1.0 默认为1.0 */
@property (nonatomic, assign, readonly) CGFloat playVolume;

/** 播放速度 可设置范围为0.5至2.0  默认为1.0*/
@property (nonatomic, assign, readonly) CGFloat playRate;

/** 播放声道 -1.0 是左声道, 0.0 居中, 1.0 右声道 */
@property (nonatomic, assign, readonly) CGFloat playPan;

/** 音频声波状态 */
@property (nonatomic, assign, readonly) CGFloat powerProgress;

/** 音频的分贝 */
@property (nonatomic, assign, readonly) int playDB;

/** 播放状态 */
@property (nonatomic, assign, readonly) RecordPlayState recordPlayState;

/** 播放完Block */
@property (nonatomic, copy) void(^playOverBlock)(void);

/** 播放失败Block */
@property (nonatomic, copy) void(^playErrorBlock)(void);

/** 播放中断Block */
@property (nonatomic, copy) void(^playPauseBlock)(void);

/** 音频强度和声波状态block */
@property (nonatomic, copy) PlayCallBackBlock playingBlock;

/**
 更换新的音频播放 (如果以前没有音频，会直接加载)
 
 @param filePath 音频路径（字符串）
 @param isPlay 是否直接播放
 */
- (void)replaceOtherAudio:(NSString *)filePath toPlay:(BOOL)isPlay;

/**
 播放进度
 1、进度比例
 2、当前播放时间
 3、总播放时间
 */
@property (nonatomic, copy) PlayProgressBlock progressBlock;

/**
 播放
 */
- (void)playRecord;

/**
 继续播放
 */
- (void)continuePlayRecord;

/**
 跳转到指定位置播放
 
 @param time 指定时间
 @param isPlay 是否直接播放
 */
- (void)recordPlayAtTime:(NSTimeInterval)time toPlay:(BOOL)isPlay;

/**
 跳转指定比例播放
 
 @param progress 指定比例 (progress区间为0-1)
 @param isPlay 是否直接播放
 */
- (void)recordPlayAtProgress:(CGFloat)progress toPlay:(BOOL)isPlay;

/**
 暂停播放
 */
- (void)pausePlayRecord;

/**
 停止播放
 */
- (void)stopPlayRecord;

/**
 设置音量 (区间0.0-1.0)
 */
- (void)changeVolume:(CGFloat)volume;

/**
 设置播放速度（区间0.5-2.0）
 */
- (void)changeRate:(CGFloat)rate;

/**
 设置播放声道（区间-1.0-1.0）
 */
- (void)changePan:(CGFloat)pan;

/**
 声波强度转分贝
 
 @param power 声波强度
 @return 分贝
 */
+ (int)dbAudioPowerConversion:(CGFloat)power;

@end
