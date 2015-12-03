//
//  AppDelegate.m
//  general
//
//  Created by NapoleonBai on 15/10/12.
//  Copyright © 2015年 NapoleonBai. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "GeTuiSdk.h"
#import "NBSystemConfig.h"

#define PUSH_APP_ID     @"XUlc5rANPd6Lr3bz6lCk32"
#define PUSH_APP_KEY    @"y4Lm4KPe5KAIdQbSq7ONmA"
#define PUSH_APP_SECRET @"H6llLeNmvj5lk4MI3kuLp7"

NSString* const NotificationCategoryIdent  = @"ACTIONABLE";
NSString* const NotificationActionOneIdent = @"ACTION_ONE";
NSString* const NotificationActionTwoIdent = @"ACTION_TWO";


@interface AppDelegate ()<GeTuiSdkDelegate>
{
    NSString *_deviceToken;
    AVAudioPlayer *myBackMusic;

}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    /*
    // [1]:使用APPID/APPKEY/APPSECRENT创建个推实例
    [self startSdkWith:PUSH_APP_ID appKey:PUSH_APP_KEY appSecret:PUSH_APP_SECRET];
    
    // [2]:注册APNS
    [self registerRemoteNotification];
    
    // [2-EXT]: 获取启动时收到的APN数据
    NSDictionary* message = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (message) {
        NSString *payloadMsg = [message objectForKey:@"payload"];
        NSString *record = [NSString stringWithFormat:@"[APN]%@, %@", [NSDate date], payloadMsg];
        
        NSLog(@"数据====>>>%@ ==== record: %@==",payloadMsg,record);
    }
    */
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
        
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // [EXT] APP进入后台时，通知个推SDK进入后台
    [GeTuiSdk enterBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    // [EXT] 重新上线
    [self startSdkWith:PUSH_APP_ID appKey:PUSH_APP_KEY appSecret:PUSH_APP_SECRET];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


/**
 *  个推相关设置
 */

- (void)registerRemoteNotification {
#ifdef __IPHONE_8_0
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        //IOS8 新的通知机制category注册
        UIMutableUserNotificationAction *action1;
        action1 = [[UIMutableUserNotificationAction alloc] init];
        [action1 setActivationMode:UIUserNotificationActivationModeBackground];
        [action1 setTitle:@"取消"];
        [action1 setIdentifier:NotificationActionOneIdent];
        [action1 setDestructive:NO];
        [action1 setAuthenticationRequired:NO];
        
        UIMutableUserNotificationAction *action2;
        action2 = [[UIMutableUserNotificationAction alloc] init];
        [action2 setActivationMode:UIUserNotificationActivationModeBackground];
        [action2 setTitle:@"回复"];
        [action2 setIdentifier:NotificationActionTwoIdent];
        [action2 setDestructive:NO];
        [action2 setAuthenticationRequired:NO];
        
        UIMutableUserNotificationCategory *actionCategory;
        actionCategory = [[UIMutableUserNotificationCategory alloc] init];
        [actionCategory setIdentifier:NotificationCategoryIdent];
        [actionCategory setActions:@[action1, action2]
                        forContext:UIUserNotificationActionContextDefault];
        
        NSSet *categories = [NSSet setWithObject:actionCategory];
        UIUserNotificationType types = (UIUserNotificationTypeAlert|
                                        UIUserNotificationTypeSound|
                                        UIUserNotificationTypeBadge);
        
        UIUserNotificationSettings *settings;
        settings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
#else
    UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert|
                                                                   UIRemoteNotificationTypeSound|
                                                                   UIRemoteNotificationTypeBadge);
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
#endif
    
}



- (void)startSdkWith:(NSString *)appID appKey:(NSString *)appKey appSecret:(NSString *)appSecret
{
    NSError *err = nil;
    
    //[1-1]:通过 AppId、 appKey 、appSecret 启动SDK
    [GeTuiSdk startSdkWithAppId:appID appKey:appKey appSecret:appSecret delegate:self error:&err];
    
    //[1-2]:设置是否后台运行开关
    [GeTuiSdk runBackgroundEnable:YES];
    //[1-3]:设置电子围栏功能，开启LBS定位服务 和 是否允许SDK 弹出用户定位请求
    //[GeTuiSdk lbsLocationEnable:YES andUserVerify:YES];
    
}

#pragma mark - background fetch  唤醒
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    //[5] Background Fetch 恢复SDK 运行
    NSLog(@"resume=======>>>>>");

    [GeTuiSdk resume];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    _deviceToken = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"deviceToken:%@", _deviceToken);
    // [3]:向个推服务器注册 deviceToken
    [GeTuiSdk registerDeviceToken:_deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    // [3-EXT]:如果APNS注册失败，通知个推服务器
    [GeTuiSdk registerDeviceToken:@""];
    NSLog(@"注册失败-->>>");
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userinfo {
    
    UIAlertView *aletview = [[UIAlertView alloc]initWithTitle:@"温馨提示,很难忘" message:userinfo delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [aletview show];
    
    
    // [4-EXT]:处理APN
    NSString *payloadMsg = [userinfo objectForKey:@"payload"];
    NSLog(@"===>>>>>>%@",userinfo);
    if (payloadMsg) {
        NSString *record = [NSString stringWithFormat:@"[APN]%@, %@", [NSDate date], payloadMsg];
        NSLog(@"数据===>>>%@",record);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {

    // [4-EXT]:处理APN
    NSString *payloadMsg = [userInfo objectForKey:@"payload"];
    
    UIAlertView *aletview = [[UIAlertView alloc]initWithTitle:@"温馨提示,didReceiveRemoteNotification" message:[NSString stringWithFormat:@"%@,,,%@",[userInfo allKeys],[userInfo allValues]] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [aletview show];
    /**
     *  aps:{alert:{body:str},sound:strname}
     */
    
    NSDictionary *aps = [userInfo objectForKey:@"aps"];
    NSNumber *contentAvailable = aps == nil ? nil : [aps objectForKeyedSubscript:@"content-available"];
    
    if (payloadMsg && contentAvailable) {
        NSString *record = [NSString stringWithFormat:@"[APN]%@, %@, [content-available: %@]", [NSDate date], payloadMsg, contentAvailable];
        NSLog(@"=====>>> %@",record);
    }
    completionHandler(UIBackgroundFetchResultNewData);
}

- (BOOL)setTags:(NSArray *)aTags error:(NSError **)error
{
    return [GeTuiSdk setTags:aTags];
}

#pragma mark - GexinSdkDelegate
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId
{
    NSLog(@"====>>clientId == %@ ",clientId);
    // [4-EXT-1]: 个推SDK已注册，返回clientId
    if (_deviceToken) {
        [GeTuiSdk registerDeviceToken:_deviceToken];
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    /**
     *  如果是本地通知,则会进入这里
     */
    
    NSLog(@"location ===>>>%@",notification.userInfo);
    UIAlertView *aletview = [[UIAlertView alloc]initWithTitle:@"温馨提示,进入这里" message:[NSString stringWithFormat:@"%@,,,%@",[notification.userInfo allKeys],[notification.userInfo allValues]] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [aletview show];

}

- (void)GeTuiSdkDidReceivePayload:(NSString *)payloadId andTaskId:(NSString *)taskId andMessageId:(NSString *)aMsgId fromApplication:(NSString *)appId
{
    // [4]: 收到个推消息
    NSData* payload = [GeTuiSdk retrivePayloadById:payloadId]; //根据 payloadId 取回 Payload
    
    NSString *payloadMsg = nil;
    if (payload) {
        payloadMsg = [[NSString alloc] initWithBytes:payload.bytes
                                              length:payload.length encoding:NSUTF8StringEncoding];
    }
    //这里可以获取得到
    NSString *record = [NSString stringWithFormat:@"%@, %@",[NSDate date], payloadMsg];
    NSLog(@"task id : %@, messageId:%@ === %@", taskId, aMsgId,record);
    
    
    NSData *jsonData = [payloadMsg dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    NSLog(@"dic ====%@====%@",dic,payloadMsg);
    
    
//    //创建音乐文件路径
//    NSString *musicFilePath = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"caf"];
//    
//    //判断文件是否存在
//    if ([[NSFileManager defaultManager] fileExistsAtPath:musicFilePath])
//    {
//        NSURL *musicURL = [NSURL fileURLWithPath:musicFilePath];
//        NSError *myError = nil;
//        //创建播放器
//        if (myBackMusic == nil)
//        {
//            myBackMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:&myError];
//            NSLog(@"error === %@",[myError description]);
//        }
//        [myBackMusic setVolume:1];   //设置音量大小
//        myBackMusic.numberOfLoops = 0;//设置音乐播放次数  -1为一直循环
//        [myBackMusic prepareToPlay];
//        
//        [myBackMusic play];       //播放
//    }
//    //设置锁屏仍能继续播放
//    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:nil];
//    [[AVAudioSession sharedInstance] setActive: YES error: nil];

    
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    NSDate *pushDate = [NSDate dateWithTimeIntervalSinceNow:0];
    
    if (notification != nil) {
        // 设置推送时间
        notification.fireDate = pushDate;
        // 设置时区
        notification.timeZone = [NSTimeZone defaultTimeZone];
        // 设置重复间隔
        notification.repeatInterval = kCFCalendarUnitDay;
        // 推送声音
        //notification.soundName = UILocalNotificationDefaultSoundName;
        
        notification.soundName =@"1.caf";//@"sms-received1.caf";
        
        // 推送内容
        if (dic) {
            notification.alertBody = [dic objectForKey:@"Content"];
            notification.userInfo = dic;
        }else{
            notification.alertBody = payloadMsg;
        }
        //显示在icon上的红色圈中的数子
        notification.applicationIconBadgeNumber = 1;
        //添加推送到UIApplication
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }

}

-(NSString*) formateTime:(NSDate*) date {
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSString* dateTime = [formatter stringFromDate:date];
    return dateTime;
}


static void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
}


@end
