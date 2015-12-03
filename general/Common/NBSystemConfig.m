//
//  NBSystemConfig.m
//  general
//
//  Created by NapoleonBai on 15/10/14.
//  Copyright © 2015年 NapoleonBai. All rights reserved.
//

#import "NBSystemConfig.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"

#import "NBAlertController.h"

#ifdef __IPHONE_9_0

#import <Photos/Photos.h>

#endif

NSString * const SETTING_ENABLEED_PUSH     = @"通知";
NSString * const SETTING_ENABLEED_CAMERA   = @"相机";
NSString * const SETTING_ENABLEED_ALBUM    = @"照片";
NSString * const SETTING_ENABLEED_LOCATION = @"位置";

@implementation NBSystemConfig

/**
 *  是否启用了通知栏
 *
 *  @return YES or NO
 */
+ (BOOL)checkEnabledRemoteNotification{
#ifdef __IPHONE_8_0
    /**
     *  iOS 8.0及以上进入
     */
    UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
    if (UIUserNotificationTypeNone == setting.types) {
        //通知没有启用
        [self openSetting:SETTING_ENABLEED_PUSH];
        return NO;
    }
#else
    /**
     *  iOS 8以下进入判断
     */
    UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    if(UIRemoteNotificationTypeNone == type){
        //通知没有启用
        [self openSetting:SETTING_ENABLEED_PUSH];
        return NO;
    }
#endif
    return YES;
}

/**
 *  检查是否启用了相机
 *
 *  @return YES or NO
 */
+ (BOOL)checkEnabledCamera{
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        //相机没有启用
        [self openSetting:SETTING_ENABLEED_CAMERA];
        return NO;
    }
    return YES;
}
/**
 *  检查相册是否启用
 *
 *  @return YES or NO
 */
+ (BOOL)checkEnabledAlbum{
#ifdef __IPHONE_9_0
    PHAuthorizationStatus authorStatus = [PHPhotoLibrary authorizationStatus];
    if(authorStatus == PHAuthorizationStatusRestricted || authorStatus == PHAuthorizationStatusDenied){
        //相册没有启用
        [self openSetting:SETTING_ENABLEED_ALBUM];
        return NO;
    }
#else
    ALAuthorizationStatus authorStatus = [ALAssetsLibrary authorizationStatus];
    if(authorStatus == ALAuthorizationStatusRestricted || authorStatus == ALAuthorizationStatusDenied){
        //相册没有启用
        [self openSetting:SETTING_ENABLEED_ALBUM];
        return NO;
    }
#endif
    return YES;
}

/**
 *  检查定位是否启用
 *
 *  @return YES or NO
 */
+ (BOOL)checkEnabledLocation{
    CLAuthorizationStatus authorStatus = [CLLocationManager authorizationStatus];
#ifdef __IPHONE_8_0
    if (authorStatus == kCLAuthorizationStatusAuthorizedAlways
         || authorStatus == kCLAuthorizationStatusAuthorizedWhenInUse
         || authorStatus == kCLAuthorizationStatusNotDetermined) {
            //定位功能可用
            return YES;
        }
#else
    if (authorStatus == kCLAuthorizationStatusAuthorized
         || authorStatus == kCLAuthorizationStatusNotDetermined) {
            //定位功能可用
            return YES;
    }
#endif
    [self openSetting:SETTING_ENABLEED_LOCATION];
    return NO;
}

/**
 *  打开(提示)设置界面启用该功能
 *
 *  @param functionName 功能名称
 */
+ (void)openSetting:(NSString *)functionName{
#ifdef __IPHONE_8_0
    //先提示用户是否要跳转,然后再处理
    [[NBAlertController singleInstance] showAlertView:[UIApplication sharedApplication].keyWindow.rootViewController withTitle:@"温馨提示" withMessage:@"立即去设置该功能吧" withCancelBtnTitle:@"暂不设置" withOtherButtonTitle:@"立即设置" withConfirmBlock:^{
        //跳转到设置界面,iOS8以上支持
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    } withCancelBlock:^{
        
    }];
#else
    /**
     *  跳转到其他界面展示或直接提示
     */
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *productName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString *message = [NSString stringWithFormat:@"[%@]功能未启用,请到系统设置应用里面打开应用程序[%@],启用[%@]功能",functionName,productName,functionName];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alertView show];
#endif
}

@end
