//
//  NBSystemConfig.h
//  general
//
//  Created by NapoleonBai on 15/10/14.
//  Copyright © 2015年 NapoleonBai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NBSystemConfig : NSObject

/**
 *  检查推送设置是否启用
 *
 *  @return YES or NO
 */
+ (BOOL)checkEnabledRemoteNotification;

/**
 *  检查相机是否启用
 *
 *  @return YES or NO
 */
+ (BOOL)checkEnabledCamera;

/**
 *  检查相册是否启用
 *
 *  @return YES or NO
 */
+ (BOOL)checkEnabledAlbum;

/**
 *  检查定位是否启用
 *
 *  @return YES or NO
 */
+ (BOOL)checkEnabledLocation;

@end
