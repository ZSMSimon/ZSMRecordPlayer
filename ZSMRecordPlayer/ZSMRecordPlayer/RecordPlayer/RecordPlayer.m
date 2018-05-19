//
//  RecordPlayer.m
//  ZSMRecordPlayer
//
//  Created by Simon on 2018/5/19.
//  Copyright © 2018年 Simon. All rights reserved.
//

#import "RecordPlayer.h"

@interface RecordPlayer ()<AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioSession *audioSession;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer; //音频播放器

@property (nonatomic, strong) NSTimer *timer;

/** 音频路径 */
@property (nonatomic, strong, readwrite) NSString *filePath;

/** 录音播放总时间 */
@property (nonatomic, assign, readwrite) CGFloat playTotalTime;

/** 录音播放当前时间 */
@property (nonatomic, assign, readwrite) CGFloat playCurrentTime;

/**播放的数据源*/
@property (nonatomic, strong, readwrite) NSData *playData;

/** 当前录音播放的音量 */
@property (nonatomic, assign, readwrite) CGFloat playVolume;

/** 播放速度 */
@property (nonatomic, assign, readwrite) CGFloat playRate;

/** 播放声道 */
@property (nonatomic, assign, readwrite) CGFloat playPan;

/** 音频声波状态 */
@property (nonatomic, assign, readwrite) CGFloat powerProgress;

/** 音频的分贝 */
@property (nonatomic, assign, readwrite) int playDB;

/** 录音播放状态 */
@property (nonatomic, assign, readwrite) RecordPlayState recordPlayState;

@end

@implementation RecordPlayer

#pragma mark - 初始化

- (instancetype)init {
    
    if ([super init]) {
        [self audioSession];
    }
    
    return self;
}

- (AVAudioSession *)audioSession {
    
    if (_audioSession == nil) {
        _audioSession = [AVAudioSession sharedInstance];
        
        NSError *sessionError;
        [_audioSession setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
        [_audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&sessionError];
        
        if (_audioSession == nil) {
            NSLog(@"Error creating session: %@",[sessionError description]);
        }else {
            [_audioSession setActive:YES error:nil];
        }
    }
    
    return _audioSession;
}

- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    }
    return _timer;
}

- (void)dealloc {
    if (self.timer) {
        
        //计时器停止
        [self.timer invalidate];
        
        //释放定时器
        self.timer = nil;
    }
}

- (CGFloat)playTotalTime {
    
    if (self.audioPlayer) {
        return self.audioPlayer.duration;
    }
    
    return 0;
}

- (CGFloat)playCurrentTime {
    
    if (self.audioPlayer) {
        return self.audioPlayer.currentTime;
    }
    
    return 0;
}

- (CGFloat)playVolume {
    
    if (self.audioPlayer) {
        return self.audioPlayer.volume;
    }
    
    return 1.0;
}

- (CGFloat)playRate {
    
    if (self.audioPlayer) {
        return self.audioPlayer.rate;
    }
    
    return 1.0;
}

- (CGFloat)playPan {
    if (self.audioPlayer) {
        return self.audioPlayer.pan;
    }
    
    return 0.0;
}

- (NSString *)filePath {
    if (_filePath == nil || [_filePath isEqual:[NSNull null]]) {
        _filePath = @"";
    }
    return _filePath;
}

- (NSData *)playData {
    if (_playData == nil || [_playData isEqual:[NSNull null]]) {
        _playData = [NSData data];
    }
    return _playData;
}

//播放录音
- (void)playRecord {
    
    if ([self.audioPlayer isPlaying]) {
        
        self.recordPlayState = RecordPlayStatePlaying;
        
        return;
    }
    
    if (self.filePath == nil || self.filePath.length == 0) {
        
        self.recordPlayState = RecordPlayStateError;
        
        return;
    }
    
    [self.audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    self.audioPlayer.numberOfLoops = 0;
    
    BOOL prepare = [self.audioPlayer prepareToPlay];
    
    if (prepare == YES) {
        
        [self.audioPlayer play];
        
        self.recordPlayState = RecordPlayStatePlaying;
    }
    
    self.timer.fireDate = [NSDate distantPast];
}

//更新播放进度
- (void)updateProgress {
    
    if (self.playingBlock) {
        
        [self.audioPlayer updateMeters];
        
        CGFloat power = [self.audioPlayer averagePowerForChannel:0]; //取得第一个通道的音频，注意音频强度范围时-160到0
        
        self.playDB = [RecordPlayer dbAudioPowerConversion:power];
        
        self.powerProgress = (1.0/160)*(power+160);
        
        self.playingBlock(self.powerProgress, self.playDB);
    }
    
    if (self.progressBlock) {
        
        CGFloat progress = self.audioPlayer.currentTime / self.audioPlayer.duration;
        
        CGFloat currentTime = self.audioPlayer.currentTime;
        
        CGFloat duration = self.audioPlayer.duration;
        
        self.progressBlock(progress, currentTime, duration);
    }
}

//暂停播放录音
- (void)pausePlayRecord {
    
    if ([self.audioPlayer isPlaying]) {
        
        [self.audioPlayer pause];
        
        self.recordPlayState = RecordPlayStatePause;
        
        self.timer.fireDate = [NSDate distantFuture];
        
    } else {
        
        return;
    }
}

//继续播放
- (void)continuePlayRecord {
    
    if ([self.audioPlayer isPlaying]) {
        
        self.recordPlayState = RecordPlayStatePlaying;
        
        return;
        
    } else {
        
        [self.audioPlayer play];

        self.recordPlayState = RecordPlayStatePlaying;
        
        self.timer.fireDate = [NSDate distantPast];
    }
}

//跳转到指定位置播放
- (void)recordPlayAtTime:(NSTimeInterval)time toPlay:(BOOL)isPlay {
    
    self.audioPlayer.currentTime = time;
    
    if (isPlay == YES) {
        
        [self.audioPlayer play];
        
        self.recordPlayState = RecordPlayStatePlaying;
        
        self.timer.fireDate = [NSDate distantPast];
        
    } else {
        
        [self.audioPlayer pause];
        
        self.recordPlayState = RecordPlayStatePause;
        
        self.timer.fireDate = [NSDate distantFuture];
    }
}

//跳转指定比例播放
- (void)recordPlayAtProgress:(CGFloat)progress toPlay:(BOOL)isPlay {
    
    CGFloat time = self.audioPlayer.duration * progress;
    
    self.audioPlayer.currentTime = time;
    
    if (isPlay == YES) {
        
        [self.audioPlayer play];
        
        self.recordPlayState = RecordPlayStatePlaying;
        
        self.timer.fireDate = [NSDate distantPast];
    } else {
        
        [self.audioPlayer pause];
        
        self.recordPlayState = RecordPlayStatePause;
        
        self.timer.fireDate = [NSDate distantFuture];
    }
}

//停止播放录音
- (void)stopPlayRecord {
    
    if ([self.audioPlayer isPlaying]) {
        
        [self.audioPlayer stop];
        
        self.recordPlayState = RecordPlayStateStopped;
        
        self.timer.fireDate = [NSDate distantFuture];
        
    } else {
        
        return;
    }
}

//设置音量（区间0.0-1.0）
- (void)changeVolume:(CGFloat)volume {
    
    if (volume >= 0 && volume <= 1.0) {
        
        self.playVolume = volume;
        
        [self.audioPlayer setVolume:volume];
    } else {
        NSLog(@"请设置播放声音为0.0 到 1.0之间的值");
    }
}

//设置播放速度（区间0.5-2.0）
- (void)changeRate:(CGFloat)rate {
    
    if (rate >= 0.5 && rate <= 1.0) {
        
        self.playRate = rate;
        
        [self.audioPlayer setRate:rate];
    } else {
        
        NSLog(@"请设置播放速度为0.5 到 2.0之间的值");
    }
}

//设置播放声道（区间-1.0-1.0）
- (void)changePan:(CGFloat)pan {
    
    if (pan >= -1.0 && pan <= 1.0) {
        
        self.playPan = pan;
        
        [self.audioPlayer setPan:pan];
    } else {
        
        NSLog(@"请设置声道为-1.0 到 1.0之间的值");
    }
}

//更换新的音频播放
- (void)replaceOtherAudio:(NSString *)filePath toPlay:(BOOL)isPlay {
    
    self.filePath = filePath;
    
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:nil];
    
    self.audioPlayer.delegate = self;
    
    self.audioPlayer.meteringEnabled = YES;
    
    [self.audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    self.audioPlayer.numberOfLoops = 0;
    
    self.playData = self.audioPlayer.data;
    
    BOOL prepare = [self.audioPlayer prepareToPlay];
    
    if (prepare == YES) {
        
        self.recordPlayState = RecordPlayStateReady;
        
        if (isPlay == YES) {
            
            [self.audioPlayer play];
            
            self.recordPlayState = RecordPlayStatePlaying;
            
            self.timer.fireDate = [NSDate distantPast];
        }
    }
}

//音频播放完成
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (self.playOverBlock) {
        self.playOverBlock();
    }
    
    [self stopPlayRecord];
}

//音频解码发生错误
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error {
    if (self.playErrorBlock) {
        self.playErrorBlock();
    }
    
    [self stopPlayRecord];
    
    self.recordPlayState = RecordPlayStateError;
}

//声波强度转分贝
+ (int)dbAudioPowerConversion:(CGFloat)power {
    
    // 关键代码
    power = power + 160 - 50;
    
    int dB = 0;
    if (power < 0.f) {
        dB = 0;
    }
    else if (power < 40.f) {
        dB = (int)(power * 0.875);
    }
    else if (power < 100.f) {
        dB = (int)(power - 15);
    }
    else if (power < 110.f) {
        dB = (int)(power * 2.5 - 165);
    }
    else {
        dB = 110;
    }
    
    return dB;
}

@end

