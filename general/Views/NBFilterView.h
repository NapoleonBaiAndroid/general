//
//  NBFilterView.h
//  general
//
//  Created by NapoleonBai on 15/11/17.
//  Copyright © 2015年 NapoleonBai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NBFilterModel.h"

@protocol NBFilterViewDelegate,NBFilterViewDataSource;


/**
 布局方式(拓展用)
 */
typedef enum : NSUInteger {
    HorizontalLayout,
    VerticalLayout,
} FliterFlowLayout;

/**
 *  存储数据的section以及row,标记数据
 */
typedef struct {
    NSInteger section;
    NSInteger row;
}NBIndexPath;


/**
 *  目标:筛选器视图,完成不同情况的选择筛选,支持两级筛选(类似于分组UITableView)
    原理:一期:通过UIButton制作点击按钮,设置TitleView<UIButton>以及SubTitleView<UIButton>,点击SubTitleView完成选择,实现回传
    步骤:1.初始化当前视图,根据设置的titleArray(title所有数据)来完成对titleView的设置;(暂时只支持固定大小,不支持滚动)
        2.实现TitleVeiw的点击事件,同时,根据不同的点击,显示对应的SubTitleView等
        3.实现SubTitleView的点击,回传选中的值即可
    附加:1.手动设置每行显示多少列(也就是多少个subTitleView)
        2.手动设置列距和行距
        3.手动设置显示数据
    拓展:1.自定义显示TitleView
        2.自定义显示SubTitleView
        3.SubTitleView的复用
        4.其他等
 */

@interface NBFilterView : UIView

/**
 *  datasource协议代理
 */
@property (nonatomic, weak, setter = setDataource:) id<NBFilterViewDataSource> datasource;

/**
 *  delegate代理
 */
@property (nonatomic,weak ,setter= setDelegate:) id<NBFilterViewDelegate> delegate;


/**
 *  布局方式,默认为水平(拓展用)
 */
@property(nonatomic,assign)FliterFlowLayout flowLayout;

/**
 *  设置行高
 */
@property(nonatomic,assign)float rowHeight;


- (void)reloadData;

@end

@protocol NBFilterViewDelegate <NSObject>

@optional
/**
 *  点击选项时执行
 *
 *  @param filterView 当前筛选器实例
 *  @param indexPath  当前选中的视图位置信息
 */
- (void)filterView:(NBFilterView *)filterView didSelectedRowOfIndexPath:(NBIndexPath)indexPath;

@end


@protocol NBFilterViewDataSource <NSObject>
@optional
/**
 *  获取section显示的数据
 *
 *  @param filterView 当前筛选器实例
 *
 *  @return 显示的数据数组
 */
- (NSArray *)sectionDatasForFilterView:(NBFilterView *)filterView;

/**
 *  获取当前组的数据
 *
 *  @param sections   当前选中分组
 *  @param filterView 当前筛选器实例
 *
 *  @return 当前组数据
 */
- (NSArray *)rowDatasOfSection:(NSInteger)section filterView:(NBFilterView *)filterView;

@required
/**
 *  当前分组下元素之间的距离
 *
 *  @param filterView 当前筛选器实例
 *  @param section    当前分组
 *
 *  @return 距离
 */
- (UIEdgeInsets)filterView:(NBFilterView *)filterView paddingOfColumnsInSection:(NSInteger)section;

/**
 *  获取当前筛选器有多少个分组
 *
 *  @param filterView 当前筛选器实例
 *
 *  @return 分组数量
 */
- (NSInteger)numberOfSectionsForfilterView:(NBFilterView *)filterView;


/**
 *
 *  获取每个分组下面有多少个数据
 *  @param filterView 当前筛选器实例
 *  @param section    当前分组
 *
 *  @return 数据量
 */
- (NSInteger)filterView:(NBFilterView *)filterView numberInSection:(NSInteger)section;

/**
 *  获取当前筛选器中每个分组显示多少列
 *
 *  @param filterView 当前筛选器实例
 *  @param section    当前分组
 *
 *  @return 列数量
 */
- (NSInteger)filterView:(NBFilterView *)filterView numberOfColumnsInSection:(NSInteger)section;

/**
 *  根据IndexPath获取当前显示的视图
 *
 *  @param filterView 当前筛选器实例
 *  @param indexPath  当前位置
 *
 *  @return 设置视图控件
 */
- (UIView *)filterView:(NBFilterView *)filterView viewForRowAtIndexPath:(NBIndexPath)indexPath;

/**
 *  根据分组信息来获取得到组Title视图
 *
 *  @param filterView 当前筛选器实例
 *  @param section    当前分组
 *
 *  @return 组显示的View
 */
- (UIView *)filterView:(NBFilterView *)filterView viewOfSection:(NSInteger)section;

@end

