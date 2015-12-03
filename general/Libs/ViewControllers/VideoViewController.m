//
//  VideoViewController.m
//  general
//
//  Created by NapoleonBai on 15/12/3.
//  Copyright © 2015年 NapoleonBai. All rights reserved.
//

#import "VideoViewController.h"


#import <AVFoundation/AVFoundation.h>

#define kRecordAudioFile @"myRecord.caf"


#import <FreeStreamer/FSAudioStream.h>
#import "lame.h"


@interface VideoViewController ()<AVAudioRecorderDelegate>{

    AVAudioPlayer *audioPlayer;
}

@property (nonatomic,strong) AVAudioRecorder *audioRecorder;//音频录音机
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;//音频播放器，用于播放录音文件
@property (nonatomic,strong) NSTimer *timer;//录音声波监控（注意这里暂时不对播放进行监控）

@property (weak, nonatomic) IBOutlet UIButton *record;//开始录音
@property (weak, nonatomic) IBOutlet UIButton *pause;//暂停录音
@property (weak, nonatomic) IBOutlet UIButton *resume;//恢复录音
@property (weak, nonatomic) IBOutlet UIButton *stop;//停止录音
@property (weak, nonatomic) IBOutlet UIProgressView *audioPower;//音频波动


@property (nonatomic,strong) FSAudioStream *audioStream;

@end


@implementation VideoViewController

#pragma mark - 控制器视图方法
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setAudioSession];
}

#pragma mark - 私有方法
/**
 *  设置音频会话
 */
-(void)setAudioSession{
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    //设置为播放和录音状态，以便可以在录制完之后播放录音
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
}

/**
 *  取得录音文件保存路径
 *
 *  @return 录音文件路径
 */
-(NSURL *)getSavePath{
    NSURL *url=[NSURL URLWithString:[NSTemporaryDirectory() stringByAppendingString:kRecordAudioFile]];//[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
   // urlStr=[urlStr stringByAppendingPathComponent:kRecordAudioFile];
    NSLog(@"file path:%@",[url absoluteString]);
  //  NSURL *url=[NSURL fileURLWithPath:urlStr];
    return url;
}


-(NSURL *)getMp3Path{
    NSURL *url=[NSURL URLWithString:[NSTemporaryDirectory() stringByAppendingString:@"myRecord.mp3"]];//[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    // urlStr=[urlStr stringByAppendingPathComponent:kRecordAudioFile];
    NSLog(@"mp3 file path:%@",[url absoluteString]);
    //  NSURL *url=[NSURL fileURLWithPath:urlStr];
    return url;
    return url;
}

/**
 *  取得录音文件设置
 *
 *  @return 录音设置
 */
-(NSDictionary *)getAudioSetting{
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    
    //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM
    [dicM setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）, 采样率必须要设为11025才能使转化成mp3格式后不会失真
    [dicM setValue:[NSNumber numberWithFloat:11025.0] forKey:AVSampleRateKey];
    //录音通道数  1 或 2 ，要转换成mp3格式必须为双通道
    [dicM setValue:@2 forKey:AVNumberOfChannelsKey];
    //线性采样位数  8、16、24、32
    [dicM setValue:@16 forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [dicM setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    //设置浮点数采样
   // [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];

    return dicM;
}

/**
 *  获得录音机对象
 *
 *  @return 录音机对象
 */
-(AVAudioRecorder *)audioRecorder{
    if (!_audioRecorder) {
        //创建录音文件保存路径
        NSURL *url=[self getSavePath];
        //创建录音格式设置
        NSDictionary *setting=[self getAudioSetting];
        //创建录音机
        NSError *error=nil;
        _audioRecorder=[[AVAudioRecorder alloc]initWithURL:url settings:setting error:&error];
        _audioRecorder.delegate=self;
        _audioRecorder.meteringEnabled=YES;//如果要监控声波则必须设置为YES
        if (error) {
            NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioRecorder;
}

/**
 *  创建播放器
 *
 *  @return 播放器
 */
-(AVAudioPlayer *)audioPlayer{
    if (!_audioPlayer) {
        NSURL *url=[self getSavePath];
        NSError *error=nil;
        _audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        _audioPlayer.numberOfLoops=0;
        [_audioPlayer prepareToPlay];
        if (error) {
            NSLog(@"创建播放器过程中发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioPlayer;
}

/**
 *  录音声波监控定制器
 *
 *  @return 定时器
 */
-(NSTimer *)timer{
    if (!_timer) {
        _timer=[NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(audioPowerChange) userInfo:nil repeats:YES];
    }
    return _timer;
}

/**
 *  录音声波状态设置
 */
-(void)audioPowerChange{
    [self.audioRecorder updateMeters];//更新测量值
    float power= [self.audioRecorder averagePowerForChannel:0];//取得第一个通道的音频，注意音频强度范围时-160到0
    CGFloat progress=(1.0/160.0)*(power+160.0);
    [self.audioPower setProgress:progress];
}
#pragma mark - UI事件
/**
 *  点击录音按钮
 *
 *  @param sender 录音按钮
 */
- (IBAction)recordClick:(UIButton *)sender {
    if (![self.audioRecorder isRecording]) {
        [self.audioRecorder record];//首次使用应用时如果调用record方法会询问用户是否允许使用麦克风
        self.timer.fireDate=[NSDate distantPast];
    }
}

/**
 *  点击暂定按钮
 *
 *  @param sender 暂停按钮
 */
- (IBAction)pauseClick:(UIButton *)sender {
    if ([self.audioRecorder isRecording]) {
        [self.audioRecorder pause];
        self.timer.fireDate=[NSDate distantFuture];
    }
}

/**
 *  点击恢复按钮
 *  恢复录音只需要再次调用record，AVAudioSession会帮助你记录上次录音位置并追加录音
 *
 *  @param sender 恢复按钮
 */
- (IBAction)resumeClick:(UIButton *)sender {
    [self recordClick:sender];
}

/**
 *  点击停止按钮
 *
 *  @param sender 停止按钮
 */
- (IBAction)stopClick:(UIButton *)sender {

    [self.audioRecorder stop];
    
    self.timer.fireDate=[NSDate distantFuture];
    self.audioPower.progress=0.0;
}

#pragma mark - 录音机代理方法
/**
 *  录音完成，录音完成后播放录音
 *
 *  @param recorder 录音机对象
 *  @param flag     是否成功
 */
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    if (![self.audioPlayer isPlaying]) {
        [self.audioPlayer play];
    }
    NSLog(@"录音完成!");
}


/**
 *  取得本地文件路径
 *
 *  @return 文件路径
 */
-(NSURL *)getFileUrl{
    NSString *urlStr=[[NSBundle mainBundle]pathForResource:@"takemetoyourheart.mp3" ofType:nil];
    NSURL *url=[NSURL fileURLWithPath:urlStr];
    return url;
}
-(NSURL *)getNetworkUrl{
    NSString *urlStr=@"http://192.168.0.192:8090/gqfshop/upload/image/TakeMeToYourHeart.mp3";
    NSURL *url=[NSURL URLWithString:urlStr];
    return url;
}

/**
 *  创建FSAudioStream对象
 *
 *  @return FSAudioStream对象
 */
-(FSAudioStream *)audioStream{
    if (!_audioStream) {
        NSURL *url=[self getNetworkUrl];
        FSStreamConfiguration *configuration = [FSStreamConfiguration new];
        configuration.cacheEnabled = YES;
        
        //创建FSAudioStream对象
        _audioStream=[[FSAudioStream alloc]initWithConfiguration:configuration];
        _audioStream.url = url;
        _audioStream.onFailure=^(FSAudioStreamError error,NSString *description){
            NSLog(@"播放过程中发生错误，错误信息：%@ ====%d",description,error);
        };
        _audioStream.onCompletion=^(){
            NSLog(@"播放完成!");
        };
        [_audioStream setVolume:0.5];//设置声音
    }
    return _audioStream;
}

- (IBAction)onLineMusic:(id)sender {
   // [self transformCAFToMP3];
    if (self.audioStream.isPlaying) {
        [self.audioStream pause];
    }else{
        [self.audioStream play];
    }
}



- (void)transformCAFToMP3 {
    @try {
        int read, write;
        
        FILE *pcm = fopen([[[self getSavePath] absoluteString] cStringUsingEncoding:1], "rb");   //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                                   //skip file header
        FILE *mp3 = fopen([[[self getMp3Path] absoluteString] cStringUsingEncoding:1], "wb"); //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 11025.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        NSLog(@"MP3生成成功: %@",[self getMp3Path]);
 //       [self.audioStream play];
//        if (!audioPlayer) {
//            audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[self getMp3Path] error:nil];
//        }
//        
//        [audioPlayer prepareToPlay];
//        audioPlayer.volume = 1;
//        [audioPlayer play];

    }
}




@end
