//
//  NBFilterModel.h
//  general
//
//  Created by NapoleonBai on 15/11/17.
//  Copyright © 2015年 NapoleonBai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NBFilterModel : NSObject

@property(strong,nonatomic) NSString *fName;
@property(strong,nonatomic) NSString *fId;
@property(assign,nonatomic) NSUInteger fTag;
@property(strong,nonatomic) NSString *fDefaultDetailImage;
@property(strong,nonatomic) NSString *fSelectedDetailImage;
@property(strong,nonatomic) NSArray *fChildArray;


- (instancetype)initName:(NSString *)name withId:(NSString *)fId defaultImage:(NSString *)defaultImage selectedImage:(NSString *)selectedImage tag:(NSUInteger)tag childArray:(NSArray *)childArray;

@end
