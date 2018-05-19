//
//  ViewController.m
//  ZSMRecordPlayer
//
//  Created by Simon on 2018/5/19.
//  Copyright © 2018年 Simon. All rights reserved.
//

#import "ViewController.h"
#import <ZSMRecordManager/RecordingManager.h>
#import "RecordPlayer.h"

#define mScreenWidth        ([UIScreen mainScreen].bounds.size.width)
#define mScreenHeight       ([UIScreen mainScreen].bounds.size.height)

@interface ViewController ()

@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *powerLabel;

@property (strong, nonatomic) UIButton *againButton;
@property (strong, nonatomic) UIButton *recordButton;
@property (strong, nonatomic) UIButton *stopButton;

@property (nonatomic, strong) UIButton *jumpButton;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) RecordingManager *recordManager;
@property (nonatomic, strong) RecordPlayer *recordPlayer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUI];
}

- (void)dealloc {
    NSLog(@"这个界面释放了");
}


/** 私有方法 */
#pragma mark - Private Methods

- (void)setUI {
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(mScreenWidth/2-150, 170, 100, 50)];
    self.timeLabel.textColor = [UIColor redColor];
    self.timeLabel.backgroundColor = [UIColor whiteColor];
    self.timeLabel.text = @"00:00";
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.timeLabel];
    
    self.powerLabel = [[UILabel alloc] initWithFrame:CGRectMake(mScreenWidth/2+50, 170, 100, 50)];
    self.powerLabel.textColor = [UIColor redColor];
    self.powerLabel.backgroundColor = [UIColor whiteColor];
    self.powerLabel.text = @"0";
    self.powerLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.powerLabel];
    
    self.againButton = [[UIButton alloc] initWithFrame:CGRectMake(mScreenWidth/2-150, 300, 50, 50)];
    [self.againButton setTitle:@"重录" forState:UIControlStateNormal];
    [self.againButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    self.againButton.backgroundColor = [UIColor whiteColor];
    [self.againButton addTarget:self action:@selector(again:) forControlEvents:UIControlEventTouchUpInside];
    self.againButton.hidden = YES;
    [self.view addSubview:self.againButton];
    
    self.recordButton = [[UIButton alloc] initWithFrame:CGRectMake(mScreenWidth/2-25, 300, 50, 50)];
    [self.recordButton setTitle:@"录音" forState:UIControlStateNormal];
    [self.recordButton setTitle:@"暂停" forState:UIControlStateSelected];
    [self.recordButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    self.recordButton.backgroundColor = [UIColor whiteColor];
    [self.recordButton addTarget:self action:@selector(record:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.recordButton];
    
    self.stopButton = [[UIButton alloc] initWithFrame:CGRectMake(mScreenWidth/2+100, 300, 50, 50)];
    [self.stopButton setTitle:@"停止" forState:UIControlStateNormal];
    [self.stopButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    self.stopButton.backgroundColor = [UIColor whiteColor];
    [self.stopButton addTarget:self action:@selector(stop:) forControlEvents:UIControlEventTouchUpInside];
    self.stopButton.hidden = YES;
    [self.view addSubview:self.stopButton];
    
    self.jumpButton = [[UIButton alloc] initWithFrame:CGRectMake(mScreenWidth/2-150, 400, 50, 50)];
    [self.jumpButton setTitle:@"+5s" forState:UIControlStateNormal];
    [self.jumpButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    self.jumpButton.backgroundColor = [UIColor whiteColor];
    [self.jumpButton addTarget:self action:@selector(jump:) forControlEvents:UIControlEventTouchUpInside];
    self.jumpButton.hidden = YES;
    [self.view addSubview:self.jumpButton];
    
    self.playButton = [[UIButton alloc] initWithFrame:CGRectMake(mScreenWidth/2-25, 400, 50, 50)];
    [self.playButton setTitle:@"播放" forState:UIControlStateNormal];
    [self.playButton setTitle:@"暂停" forState:UIControlStateSelected];
    [self.playButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    self.playButton.backgroundColor = [UIColor whiteColor];
    [self.playButton addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    self.playButton.hidden = YES;
    [self.view addSubview:self.playButton];
    
    self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(mScreenWidth/2+100, 400, 50, 50)];
    [self.cancelButton setTitle:@"停止" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    self.cancelButton.backgroundColor = [UIColor whiteColor];
    [self.cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    self.cancelButton.hidden = YES;
    [self.view addSubview:self.cancelButton];
}

/** 按钮和手势的响应 */
#pragma mark - Event Response

- (void)again:(UIButton *)sender {
    
    [self.recordManager retRecord];
}

- (void)record:(UIButton *)sender {
    
    if (![RecordingManager checkPermission]) {
        
        __weak __typeof__(self) weakSelf = self;
        [RecordingManager promptAuthorizationCallBack:^(BOOL status) {
            
            if (status == YES) {
                
                [weakSelf canRecord:sender];
            }
        }];
        
    } else {
        
        [self canRecord:sender];
    }
}

- (void)canRecord:(UIButton *)sender {
    
    dispatch_async(dispatch_get_main_queue(), ^{
       
        if (self.againButton.hidden == YES) {
            
            [self.recordManager startReocrd];
            
            sender.selected = YES;
            
            self.againButton.hidden = NO;
            self.stopButton.hidden = NO;
            
        } else {
            
            if (sender.selected == YES) {
                
                [self.recordManager pauseRecord];
                
                sender.selected = NO;
                
            } else {
                
                [self.recordManager continueRecord];
                
                sender.selected = YES;
            }
        }
    });
}

- (void)stop:(UIButton *)sender {
    
    [self.recordManager stopRecord];
    
    self.playButton.hidden = NO;
}

- (void)jump:(UIButton *)sender {
    
    if (self.recordPlayer.playTotalTime > self.recordPlayer.playCurrentTime + 5) {
        
        [self.recordPlayer recordPlayAtTime:self.recordPlayer.playCurrentTime+5 toPlay:YES];
        
        self.playButton.selected = YES;
        
    } else {
        
        NSLog(@"不够五秒了");
    }
}

- (void)play:(UIButton *)sender {
    
    if (sender.selected == YES) {
        
        [self.recordPlayer pausePlayRecord];
        
        sender.selected = NO;
        
    } else {
        
        sender.selected = YES;
        
        if (self.jumpButton.hidden == YES) {
            
            [self.recordPlayer replaceOtherAudio:self.recordManager.filePath toPlay:YES];
            
        } else {
            
            [self.recordPlayer continuePlayRecord];
        }
    }
    
    self.jumpButton.hidden = NO;
    
    self.cancelButton.hidden = NO;
}

- (void)cancel:(UIButton *)sender {
    
    [self.recordPlayer stopPlayRecord];
    
    self.playButton.selected = NO;
}

/** 初始化 */
#pragma mark - Getter and Setter

- (RecordingManager *)recordManager {
    if (_recordManager == nil || [_recordManager isEqual:[NSNull null]]) {
        _recordManager = [[RecordingManager alloc] init];
        
        __weak __typeof__(self) weakSelf = self;
        _recordManager.recordingBlock = ^(NSTimeInterval currentTime, CGFloat progress, int audioDB) {
            
            NSString *time = [NSString stringWithFormat:@"%02d:%02d",(int)currentTime / 60,(int)currentTime % 60];
            weakSelf.timeLabel.text = time;
            
            weakSelf.powerLabel.text = [NSString stringWithFormat:@"%f",progress];
        };
    }
    return _recordManager;
}

- (RecordPlayer *)recordPlayer {
    if (_recordPlayer == nil || [_recordPlayer isEqual:[NSNull null]]) {
        _recordPlayer = [[RecordPlayer alloc] init];
        
        __weak __typeof__(self) weakSelf = self;
        
        _recordPlayer.playingBlock = ^(CGFloat progress, int playDB) {
            
            weakSelf.powerLabel.text = [NSString stringWithFormat:@"%f",progress];
        };
        
        _recordPlayer.progressBlock = ^(CGFloat progress, CGFloat currentTime, CGFloat totalTime) {
            
            NSString *time = [NSString stringWithFormat:@"%02d:%02d",(int)currentTime / 60,(int)currentTime % 60];
            weakSelf.timeLabel.text = time;
        };
        
        _recordPlayer.playOverBlock = ^{
            
            weakSelf.playButton.selected = NO;
        };
        
        _recordPlayer.playErrorBlock = ^{
            
            weakSelf.playButton.selected = NO;
            NSLog(@"播放出错了");
        };
        
        _recordPlayer.playPauseBlock = ^{
            
            weakSelf.playButton.selected = NO;
        };
    }
    return _recordPlayer;
}

@end
