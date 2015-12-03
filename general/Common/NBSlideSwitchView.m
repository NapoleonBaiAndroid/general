//
//  NBSlideSwitchView.m
//  NAPOLEONBAI INTEGRATED BASE PROJECT
//
//  Created by NapoleonBai on 15/8/28.
//  Copyright (c) 2015年 NapoleonBai. All rights reserved.
//

#import "NBSlideSwitchView.h"

static const CGFloat kHeightOfTopScrollView = 35.0f;//44.0f;
static CGFloat kWidthOfButtonMargin = 0; //这里可设置,也可不设置,因为本项目中,使用的是固定值的item,就暂时用了固定宽度,_topButtonWidth,可根据自身需要修改
static const CGFloat kFontSizeOfTabButton = 15.0f;
static const NSUInteger kTagOfRightSideButton = 999;


@implementation NBSlideSwitchView

#pragma mark - 初始化参数

- (void)initValues
{
    //创建顶部可滑动的tab
    _topScrollView = [UIScrollView new];
    //    _topScrollView.layer.borderColor = [[UIColor blackColor]CGColor];
    //    _topScrollView.layer.borderWidth = .2;
    //    _topScrollView.layer.cornerRadius = 5;
    //    _topScrollView.layer.masksToBounds = YES;
    
    _topScrollView.delegate = self;
    _topScrollView.backgroundColor = [UIColor clearColor];
    _topScrollView.pagingEnabled = NO;
    _topScrollView.showsHorizontalScrollIndicator = NO;
    _topScrollView.showsVerticalScrollIndicator = NO;
    _topScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self addSubview:_topScrollView];
    _userSelectedChannelID = 100;
    
    //创建主滚动视图
    _rootScrollView =[[UIScrollView alloc] init];
    NSLog(@"=====>>>>%f",self.bounds.size.height - kHeightOfTopScrollView-10);
    _rootScrollView.delegate = self;
    _rootScrollView.pagingEnabled = YES;
    _rootScrollView.userInteractionEnabled = YES;
    _rootScrollView.bounces = NO;
    _rootScrollView.scrollEnabled = _scrollEnabled;
    _rootScrollView.showsHorizontalScrollIndicator = NO;
    _rootScrollView.showsVerticalScrollIndicator = NO;
    _rootScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    _userContentOffsetX = 0;
    [_rootScrollView.panGestureRecognizer addTarget:self action:@selector(scrollHandlePan:)];
    [self addSubview:_rootScrollView];
    
    NSDictionary *dict = NSDictionaryOfVariableBindings(_rootScrollView,_topScrollView);
    [_rootScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_topScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *metrics = @{@"vHeight":[NSNumber numberWithFloat:kHeightOfTopScrollView]};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-5-[_topScrollView]-5-|" options:0 metrics:nil views:dict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[_rootScrollView]-0-|" options:0 metrics:nil views:dict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_topScrollView(vHeight)]-10-[_rootScrollView]-0-|" options:0 metrics:metrics views:dict]];
    
    _viewArray = [[NSMutableArray alloc] init];
    _titleArray = [NSMutableArray arrayWithCapacity:0];
    _isBuildUI = NO;
    self.isSlider = NO;
}

- (void)setScrollEnabled:(BOOL)scrollEnabled{
    _rootScrollView.scrollEnabled = scrollEnabled;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initValues];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initValues];
    }
    return self;
}

- (void)setTitleArray:(NSMutableArray *)titleArray{
    _titleArray = titleArray;
}

- (void)reloadData{
    [_topScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self createNameButtons];
}

#pragma mark getter/setter

- (void)setRigthSideButton:(UIButton *)rigthSideButton
{
    UIButton *button = (UIButton *)[self viewWithTag:kTagOfRightSideButton];
    [button removeFromSuperview];
    rigthSideButton.tag = kTagOfRightSideButton;
    _rigthSideButton = rigthSideButton;
    [self addSubview:_rigthSideButton];
    
}

#pragma mark - 创建控件

//当横竖屏切换时可通过此方法调整布局
- (void)layoutSubviews
{
    //创建完子视图UI才需要调整布局
    if (_isBuildUI) {
        //如果有设置右侧视图，缩小顶部滚动视图的宽度以适应按钮
        if (self.rigthSideButton.bounds.size.width > 0) {
            _rigthSideButton.frame = CGRectMake(self.bounds.size.width - self.rigthSideButton.bounds.size.width, 0,
                                                _rigthSideButton.bounds.size.width, _topScrollView.bounds.size.height);
            
            _topScrollView.frame = CGRectMake(0, 0,
                                              self.bounds.size.width  - self.rigthSideButton.bounds.size.width, kHeightOfTopScrollView);
        }
        
        //更新主视图的总宽度
        _rootScrollView.contentSize = CGSizeMake(self.bounds.size.width  * [_viewArray count], 0);
        
        //更新主视图各个子视图的宽度
        for (int i = 0; i < [_viewArray count]; i++) {
            UIViewController *listVC = _viewArray[i];
            listVC.view.frame = CGRectMake(0+self.bounds.size.width *i, 0,self.bounds.size.width , _rootScrollView.bounds.size.height);
        }
        
        //滚动到选中的视图
        [_rootScrollView setContentOffset:CGPointMake((_userSelectedChannelID - 100)*self.bounds.size.width , 0) animated:NO];
        
        //调整顶部滚动视图选中按钮位置
        UIButton *button = (UIButton *)[_topScrollView viewWithTag:_userSelectedChannelID];
        [self adjustScrollViewContentX:button];
    }
    [super layoutSubviews];
}

/*!
 * @method 创建子视图UI
 * @abstract
 * @discussion
 * @param
 * @result
 */
- (void)buildUI
{
    NSUInteger number = [self.slideSwitchViewDelegate numberOfTab:self];
    
    if (!self.isSlider) {
        _topButtonWidth = (self.bounds.size.width  -10) / number;
    }else{
        //允许滑动的情况
        kWidthOfButtonMargin = 30;
    }
    
    for (int i=0; i<number; i++) {
        UIViewController *vc = [self.slideSwitchViewDelegate slideSwitchView:self viewOfTab:i];
        [_viewArray addObject:vc];
        [_rootScrollView addSubview:vc.view];
        NSLog(@"%@",[vc.view class]);
    }
    [self createNameButtons];
    
    //选中第一个view
    if (self.slideSwitchViewDelegate && [self.slideSwitchViewDelegate respondsToSelector:@selector(slideSwitchView:didselectTab:)]) {
        [self.slideSwitchViewDelegate slideSwitchView:self didselectTab:_userSelectedChannelID - 100];
    }
    
    _isBuildUI = YES;
    
    //创建完子视图UI才需要调整布局
    [self setNeedsLayout];
}

/*!
 * @method 初始化顶部tab的各个按钮
 * @abstract
 * @discussion
 * @param
 * @result
 */
- (void)createNameButtons
{
    _shadowImageView = [[UIImageView alloc] init];
    [_shadowImageView setImage:_shadowImage];
    [_topScrollView addSubview:_shadowImageView];

    //顶部tabbar的总长度
    CGFloat topScrollViewContentWidth = kWidthOfButtonMargin;
    //每个tab偏移量
    CGFloat xOffset = kWidthOfButtonMargin;
    for (int i = 0; i < [_titleArray count]; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        //   CGSize textSize = [vc.title sizeWithFont:[UIFont systemFontOfSize:kFontSizeOfTabButton]
        //      constrainedToSize:CGSizeMake(_topScrollView.bounds.size.width, kHeightOfTopScrollView)
        //        lineBreakMode:NSLineBreakByTruncatingTail];
        CGSize textSize =  [_titleArray[i] boundingRectWithSize:
                            CGSizeMake(_topScrollView.bounds.size.width, CGFLOAT_MAX)
                                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                               attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:kFontSizeOfTabButton],NSFontAttributeName, nil] context:nil].size;
        //累计每个tab文字的长度
        topScrollViewContentWidth += kWidthOfButtonMargin+ (self.isSlider ? textSize.width : _topButtonWidth);
        //设置按钮尺寸
        [button setFrame:CGRectMake(xOffset,0,
                                    (self.isSlider ? textSize.width : _topButtonWidth), kHeightOfTopScrollView)];
        //计算下一个tab的x偏移量
        xOffset += (self.isSlider ? textSize.width : _topButtonWidth) + kWidthOfButtonMargin;
        
        [button setTag:i+100];
        if (i == 0) {
            _shadowImageView.frame = CGRectMake(kWidthOfButtonMargin, 0, (self.isSlider ? textSize.width : _topButtonWidth), _shadowImage.size.height);
            button.selected = YES;
        }
        
        [button setTitle:_titleArray[i] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:kFontSizeOfTabButton];
        [button setTitleColor:self.tabItemNormalColor forState:UIControlStateNormal];
        [button setTitleColor:self.tabItemSelectedColor forState:UIControlStateSelected];
        [button setBackgroundImage:self.tabItemNormalBackgroundImage forState:UIControlStateNormal];
        [button setBackgroundImage:self.tabItemSelectedBackgroundImage forState:UIControlStateSelected];
        [button addTarget:self action:@selector(selectNameButton:) forControlEvents:UIControlEventTouchUpInside];
        [_topScrollView addSubview:button];
    }
    
    //设置顶部滚动视图的内容总尺寸
    _topScrollView.contentSize = CGSizeMake(topScrollViewContentWidth, kHeightOfTopScrollView);
}


#pragma mark - 顶部滚动视图逻辑方法

/*!
 * @method 选中tab时间
 * @abstract
 * @discussion
 * @param 按钮
 * @result
 */
- (void)selectNameButton:(UIButton *)sender
{
    //如果点击的tab文字显示不全，调整滚动视图x坐标使用使tab文字显示全
    [self adjustScrollViewContentX:sender];
    
    //如果更换按钮
    if (sender.tag != _userSelectedChannelID) {
        //取之前的按钮
        UIButton *lastButton = (UIButton *)[_topScrollView viewWithTag:_userSelectedChannelID];
        lastButton.selected = NO;
        //赋值按钮ID
        _userSelectedChannelID = sender.tag;
    }
    
    //按钮选中状态
    if (!sender.selected) {
        sender.selected = YES;
        
        [UIView animateWithDuration:0.25 animations:^{
            
            [_shadowImageView setFrame:CGRectMake(sender.frame.origin.x, 0, sender.frame.size.width, _shadowImage.size.height)];
            
        } completion:^(BOOL finished) {
            if (finished) {
                //设置新页出现
                if (!_isRootScroll) {
                    [_rootScrollView setContentOffset:CGPointMake((sender.tag - 100)*self.bounds.size.width , 0) animated:YES];
                }
                _isRootScroll = NO;
                
                if (self.slideSwitchViewDelegate && [self.slideSwitchViewDelegate respondsToSelector:@selector(slideSwitchView:didselectTab:)]) {
                    [self.slideSwitchViewDelegate slideSwitchView:self didselectTab:_userSelectedChannelID - 100];
                }
            }
        }];
        
    }
    //重复点击选中按钮
    else {
        
    }
}

/*!
 * @method 调整顶部滚动视图x位置
 * @abstract
 * @discussion
 * @param
 * @result
 */
- (void)adjustScrollViewContentX:(UIButton *)sender
{
    //如果 当前显示的最后一个tab文字超出右边界
    if (sender.frame.origin.x - _topScrollView.contentOffset.x > self.bounds.size.width - (kWidthOfButtonMargin+sender.bounds.size.width)) {
        //向左滚动视图，显示完整tab文字
        [_topScrollView setContentOffset:CGPointMake(sender.frame.origin.x - (_topScrollView.bounds.size.width- (kWidthOfButtonMargin+sender.bounds.size.width)), 0)  animated:YES];
    }
    
    //如果 （tab的文字坐标 - 当前滚动视图左边界所在整个视图的x坐标） < 按钮的隔间 ，代表tab文字已超出边界
    if (sender.frame.origin.x - _topScrollView.contentOffset.x < kWidthOfButtonMargin) {
        //向右滚动视图（tab文字的x坐标 - 按钮间隔 = 新的滚动视图左边界在整个视图的x坐标），使文字显示完整
        [_topScrollView setContentOffset:CGPointMake(sender.frame.origin.x - kWidthOfButtonMargin, 0)  animated:YES];
    }
}

#pragma mark 主视图逻辑方法

//滚动视图开始时
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == _rootScrollView) {
        _userContentOffsetX = scrollView.contentOffset.x;
    }
}

//滚动视图结束
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _rootScrollView) {
        //判断用户是否左滚动还是右滚动
        if (_userContentOffsetX < scrollView.contentOffset.x) {
            _isLeftScroll = YES;
        }
        else {
            _isLeftScroll = NO;
        }
    }
}

//滚动视图释放滚动
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _rootScrollView) {
        _isRootScroll = YES;
        //调整顶部滑条按钮状态
        int tag = (int)scrollView.contentOffset.x/self.bounds.size.width +100;
        UIButton *button = (UIButton *)[_topScrollView viewWithTag:tag];
        [self selectNameButton:button];
    }
}

//传递滑动事件给下一层
-(void)scrollHandlePan:(UIPanGestureRecognizer*) panParam
{
    //当滑道左边界时，传递滑动事件给代理
    if(_rootScrollView.contentOffset.x <= 0) {
        if (self.slideSwitchViewDelegate
            && [self.slideSwitchViewDelegate respondsToSelector:@selector(slideSwitchView:panLeftEdge:)]) {
            [self.slideSwitchViewDelegate slideSwitchView:self panLeftEdge:panParam];
        }
    } else if(_rootScrollView.contentOffset.x >= _rootScrollView.contentSize.width - _rootScrollView.bounds.size.width) {
        if (self.slideSwitchViewDelegate
            && [self.slideSwitchViewDelegate respondsToSelector:@selector(slideSwitchView:panRightEdge:)]) {
            [self.slideSwitchViewDelegate slideSwitchView:self panRightEdge:panParam];
        }
    }
}


@end
