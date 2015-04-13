//
//  ViewController.m
//  voice
//
//  Created by Asia wang on 15/4/13.
//  Copyright (c) 2015年 Asia wang. All rights reserved.
//

#import "ViewController.h"
#import "AudioToolbox/AudioToolbox.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface ViewController ()
@property (retain, nonatomic)   AVAudioRecorder     *recorder;
@property (nonatomic, copy) NSString *recordFilePath;
@property (nonatomic, copy) NSString *recordFileName;
@property (retain, nonatomic)   AVAudioPlayer           *player;
@property (nonatomic,weak) NSTimer *timer;
@property (nonatomic,assign)__block NSTimeInterval timeInterval;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.player = [[AVAudioPlayer alloc]init];
}

- (NSString*)getCurrentTimeString
{
    NSDateFormatter *dateformat=[[NSDateFormatter  alloc]init];
    [dateformat setDateFormat:@"yyyyMMddHHmmss"];
    return [dateformat stringFromDate:[NSDate date]];
}

- (NSString*)getPathByFileName:(NSString *)fileName ofType:(NSString *)type
{
    NSString* filePath = [[[self getCacheDirectory]stringByAppendingPathComponent:fileName]stringByAppendingPathExtension:type];
    return filePath;
}

- (NSString*)getCacheDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
}

- (NSDictionary*)getAudioRecorderSettingDict
{
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   [NSNumber numberWithFloat: 8000.0],AVSampleRateKey, //采样率
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,//采样位数 默认 16
                                   [NSNumber numberWithInt: 2], AVNumberOfChannelsKey,//通道的
                                   [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey
                                   //  数目                                 [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,//大端还是小端 是内存的组织方式
                                   //                                   [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,//采样信号是整数还是浮点数
                                                                      ,[NSNumber numberWithInt: AVAudioQualityMedium],AVEncoderAudioQualityKey,//音频编码质量
                                   [NSNumber numberWithInt:AVAudioQualityMedium], AVSampleRateConverterAudioQualityKey,
                                   [NSNumber numberWithInt:8], AVLinearPCMBitDepthKey
                                   ,nil];
    return recordSetting;
}


- (void)beginRecorder{
    if ([self.recorder isRecording]) {
        [self.recorder stop];
    }
    self.recordFileName = [self getCurrentTimeString];
    
    //设置文件名和录音路径
    self.recordFilePath = [self getPathByFileName:self.recordFileName ofType:@"wav"];
    
    //初始化录音
    self.recorder = [[AVAudioRecorder alloc]initWithURL:[NSURL URLWithString:self.recordFilePath]
                                               settings:[self getAudioRecorderSettingDict]
                                                  error:nil];
    self.recorder.meteringEnabled = YES;
    [self.recorder prepareToRecord];
    [self.recorder recordForDuration:60.0]; //录音时长
    
    //开始录音
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    //启动计时器
    self.timeInterval = 60;
    self.timer =  [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(currentRecordingLength) userInfo:nil repeats:YES];
    
    [self.recorder record];
}

- (void)currentRecordingLength{
    if (self.timeInterval == 0) {
        if (self.recorder.isRecording)
            
            [self.recorder stop];
        [self.timer invalidate];
    }
    self.timeInterval -= 0.5;
    NSLog(@"%f",self.timeInterval);
}


- (IBAction)start:(id)sender {
    [self beginRecorder];
}

- (IBAction)stop:(id)sender {
    if (self.recorder.isRecording)
        [self.recorder stop];
    [self.timer invalidate];

}
- (IBAction)play:(id)sender {
    if (self.recordFileName.length > 0){
        self.player = [self.player initWithContentsOfURL:[NSURL URLWithString:[self getPathByFileName:self.recordFileName ofType:@"wav"]] error:nil];
        [self.player play];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
