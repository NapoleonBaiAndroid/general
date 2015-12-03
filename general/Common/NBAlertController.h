//
//  NBAlertController.h
//  NAPOLEONBAI INTEGRATED BASE PROJECT
//
//  Created by NapoleonBai on 15/7/6.
//  Copyright (c) 2015年 NapoleonBai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^confirm)();
typedef void (^cancle)();

@interface NBAlertController : NSObject<UIAlertViewDelegate>{
    confirm confirmParam;
    cancle  cancleParam;
}

+ (instancetype)singleInstance;

- (void)showAlertView:(UIViewController *)viewController withTitle:(NSString *)title withMessage:(NSString *)message withCancelBtnTitle:(NSString *)cancelBtnTitle withOtherButtonTitle:(NSString *)otherBtnTitle withConfirmBlock:(confirm) confirm withCancelBlock:(cancle) cancle;
@end
