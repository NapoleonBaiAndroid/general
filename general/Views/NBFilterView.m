//
//  NBFilterView.m
//  general
//
//  Created by NapoleonBai on 15/11/17.
//  Copyright © 2015年 NapoleonBai. All rights reserved.
//

#import "NBFilterView.h"

#define TAG_OF_TITLEBUTTON 1000
#define TAG_OF_SUBTITLEBUTTON 2000

@interface NBFilterView()
@property(nonatomic,strong)UIView *currentSelectedButton;
@property(nonatomic,weak)UIWindow *keyWindow;
@property(nonatomic,strong)UIView *childView;

@property(nonatomic,assign)UIEdgeInsets paddingOfSubTitleView;//子View间距
@property(nonatomic,assign)NSUInteger numberOfColumnsInRow;//每行显示多少个

@end

@implementation NBFilterView

- (instancetype)init{
    self = [self initWithFrame:CGRectZero];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initData];
    }else
        return  nil;
    return self;
}

- (void)initData{
    //设置默认行高
    self.rowHeight = 44;
}

- (UIEdgeInsets)paddingOfSubTitleView{
    _paddingOfSubTitleView = UIEdgeInsetsMake(5, 5, 5, 0);
    if(self.datasource){
        _paddingOfSubTitleView = [self.datasource filterView:self paddingOfColumnsInSection:[self getCurrentSection]];
    }
    return _paddingOfSubTitleView;
}

- (NSUInteger)numberOfColumnsInRow{
    if (_numberOfColumnsInRow==0) {
        _numberOfColumnsInRow = 3;//默认为3
        if (self.datasource) {
            _numberOfColumnsInRow = [self.datasource filterView:self numberOfColumnsInSection:[self getCurrentSection]];
        }
    }
    return _numberOfColumnsInRow;
}


- (NSInteger)getCurrentSection{
    return self.currentSelectedButton.tag - TAG_OF_TITLEBUTTON;
}

- (UIWindow *)keyWindow{
    if (!_keyWindow) {
        _keyWindow = [UIApplication sharedApplication].keyWindow;
    }
    return _keyWindow;
}

- (void)showSectionTitles{
    if (self.datasource) {
        float sectionsCount = [self.datasource numberOfSectionsForfilterView:self] * 1.0f;
        float buttonWidth = self.bounds.size.width / sectionsCount;
        for (int i = 0;i<sectionsCount ;i++) {
            UIView *headerView = [self.datasource filterView:self viewOfSection:i];
            headerView.tag = i+TAG_OF_TITLEBUTTON;
            headerView.frame = CGRectMake(i*buttonWidth, 0, buttonWidth, self.bounds.size.height);
            [self addSubview:headerView];
            [headerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTitles:)]];
        }
    }
}

- (void)setDataource:(id<NBFilterViewDataSource>)datasource{
    _datasource = datasource;
    [self reloadData];
}

- (void)reloadData{
    [self showSectionTitles];
}

- (void)clickTitles:(UITapGestureRecognizer *)tap{
    //这里的逻辑需要更改
    if (self.currentSelectedButton == tap.view) {
        return;
    }
    if (self.currentSelectedButton) {
        ((UIButton *)self.currentSelectedButton).selected = NO;
    }
    ((UIButton *)tap.view).selected = !((UIButton *)tap.view).isSelected;
    if (((UIButton *)tap.view).isSelected) {
        self.currentSelectedButton = tap.view;
    }
    [self showChildView:[self.datasource rowDatasOfSection:tap.view.tag - TAG_OF_TITLEBUTTON filterView:self]];
}

- (void)clickSubTitles:(UITapGestureRecognizer *)tap{
    if (self.delegate) {
        NBIndexPath indexPath;
        indexPath.section = self.currentSelectedButton.tag - TAG_OF_TITLEBUTTON;
        indexPath.row = tap.view.tag - TAG_OF_SUBTITLEBUTTON;
        [self.delegate filterView:self didSelectedRowOfIndexPath:indexPath];
    }
}


- (void)showChildView:(NSArray *)dataArray{
    [self.childView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (!self.childView) {
        CGRect rect=[self convertRect: self.bounds toView:self.keyWindow];
        self.childView = [[UIView alloc] initWithFrame:CGRectMake(0, rect.origin.y + rect.size.height, rect.size.width, ceilf(dataArray.count / (self.numberOfColumnsInRow / 1.0)) *50)];
        self.childView.backgroundColor = [UIColor greenColor];
        [self.keyWindow addSubview:self.childView];
    }

    CGRect frame = self.childView.frame;
    if (frame.size.height != ceilf(dataArray.count / (self.numberOfColumnsInRow / 1.0)) *(self.rowHeight + self.paddingOfSubTitleView.top + self.paddingOfSubTitleView.bottom)) {
        frame.size.height =  ceilf(dataArray.count / (self.numberOfColumnsInRow / 1.0)) *(self.rowHeight + self.paddingOfSubTitleView.top + self.paddingOfSubTitleView.bottom);
        self.childView.frame = frame;
    }
    
    //得到每个控件宽度
    float buttonWidth = (self.childView.bounds.size.width - self.numberOfColumnsInRow*(self.paddingOfSubTitleView.left + self.paddingOfSubTitleView.right)) / self.numberOfColumnsInRow;
    for (int i = 0;i<[self.datasource filterView:self numberInSection:self.currentSelectedButton.tag - TAG_OF_TITLEBUTTON] ;i++) {
        
        NBIndexPath indexPath;
        indexPath.section = self.currentSelectedButton.tag - TAG_OF_TITLEBUTTON;
        indexPath.row = i;
        UIView *view = [self.datasource filterView:self viewForRowAtIndexPath:indexPath];
        view.tag = i + TAG_OF_SUBTITLEBUTTON;
        view.frame = CGRectMake(self.paddingOfSubTitleView.left + i%self.numberOfColumnsInRow*(buttonWidth+self.paddingOfSubTitleView.left+self.paddingOfSubTitleView.right),self.paddingOfSubTitleView.top + i/self.numberOfColumnsInRow * (self.rowHeight+self.paddingOfSubTitleView.bottom+self.paddingOfSubTitleView.top), buttonWidth, self.rowHeight);
        [self.childView addSubview:view];
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickSubTitles:)]];
    }
}

@end
