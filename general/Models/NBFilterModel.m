//
//  NBFilterModel.m
//  general
//
//  Created by NapoleonBai on 15/11/17.
//  Copyright © 2015年 NapoleonBai. All rights reserved.
//

#import "NBFilterModel.h"

@implementation NBFilterModel


- (instancetype)initName:(NSString *)name withId:(NSString *)fId defaultImage:(NSString *)defaultImage selectedImage:(NSString *)selectedImage tag:(NSUInteger)tag childArray:(NSArray *)childArray{
    if (self = [super init]) {
        self.fName = name;
        self.fId= fId;
        self.fTag = tag;
        self.fDefaultDetailImage = defaultImage;
        self.fSelectedDetailImage = selectedImage;
        self.fChildArray = childArray;
    }
    return self;
}
@end
