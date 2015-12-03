//
//  NBAlertController.m
//  NAPOLEONBAI INTEGRATED BASE PROJECT
//
//  Created by NapoleonBai on 15/7/6.
//  Copyright (c) 2015年 NapoleonBai. All rights reserved.
//

#import "NBAlertController.h"
#import <objc/runtime.h>

@implementation NBAlertController

static NBAlertController *mNBAlertController;

+ (instancetype)singleInstance{
    @synchronized(self){
        if (!mNBAlertController) {
            mNBAlertController = [[self alloc]init];
        }
    }
    return mNBAlertController;
}

- (void)showAlertView:(UIViewController *)viewController withTitle:(NSString *)title withMessage:(NSString *)message withCancelBtnTitle:(NSString *)cancelBtnTitle withOtherButtonTitle:(NSString *)otherBtnTitle withConfirmBlock:(confirm) confirm withCancelBlock:(cancle) cancle{
    confirmParam=confirm;
    cancleParam=cancle;
#ifdef __IPHONE_8_0
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
//    NSMutableAttributedString *hogan = [[NSMutableAttributedString alloc] initWithString:title];
//    [hogan addAttribute:NSFontAttributeName
//                  value:[UIFont systemFontOfSize:50.0]
//                  range:NSMakeRange(0, title.length)];
//    [hogan addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, title.length)];
//
//    [alertController setValue:hogan forKey:@"attributedTitle"];

    
        if (cancelBtnTitle) {
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelBtnTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                if (cancle) {
                    cancle();
                }
            }];
            
            unsigned int count = 0;
            Ivar *ivars = class_copyIvarList([UIAlertAction class], &count);
            for (int i = 0; i<count; i++) {
                // 取出成员变量
                Ivar ivar = *(ivars + i);
               // Ivar ivar = ivars[i];
                // 打印成员变量名字
                NSLog(@"%s------%s", ivar_getName(ivar),ivar_getTypeEncoding(ivar));
            }
            
            [cancelAction setValue:[UIColor redColor] forKey:@"_titleTextColor"];

            [alertController addAction:cancelAction];
        }
       
        if (otherBtnTitle) {
            UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherBtnTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                if (confirm) {
                    confirm();
                }
            }];
            [alertController addAction:otherAction];
        }
        
        [viewController presentViewController:alertController animated:YES completion:nil];
#else
    UIAlertView *titleAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:otherBtnTitle otherButtonTitles:cancelBtnTitle,nil];
        [titleAlert show];
#endif

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        if (confirmParam) {
            confirmParam();
        }
    }
    else{
        if (cancleParam) {
            cancleParam();
        }
    }
}

@end
