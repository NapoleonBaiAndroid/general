//
//  ViewController.m
//  general
//
//  Created by NapoleonBai on 15/10/12.
//  Copyright © 2015年 NapoleonBai. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "NBSystemConfig.h"
#import "NBSlideSwitchView.h"
#import "ChildTableViewController.h"

#import "NBFilterView.h"

#import "general-Swift.h"


@interface ViewController ()<SlideSwitchViewDelegate,NBFilterViewDataSource,NBFilterViewDelegate>{
    AVAudioPlayer *myBackMusic;
    NBSlideSwitchView *sliderView;
    NSMutableArray *vcArray;
    NSArray *dataArray;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
   // [self initView];
    dataArray = @[[[NBFilterModel alloc] initName:@"测试一" withId:@"adsfadf" defaultImage:@"icon_down" selectedImage:@"icon_up" tag:0 childArray:@[[[NBFilterModel alloc] initName:@"子控件1" withId:@"adsfadf" defaultImage:@"icon_un_agree" selectedImage:@"icon_agree" tag:0 childArray:nil],[[NBFilterModel alloc] initName:@"子控件2" withId:@"adsfadf" defaultImage:@"icon_un_agree" selectedImage:@"icon_agree" tag:0 childArray:nil],[[NBFilterModel alloc] initName:@"子控件3" withId:@"adsfadf" defaultImage:@"icon_un_agree" selectedImage:@"icon_agree" tag:0 childArray:nil],[[NBFilterModel alloc] initName:@"子控件4" withId:@"adsfadf" defaultImage:@"icon_un_agree" selectedImage:@"icon_agree" tag:0 childArray:nil],[[NBFilterModel alloc] initName:@"子控件5" withId:@"adsfadf" defaultImage:@"icon_un_agree" selectedImage:@"icon_agree" tag:0 childArray:nil],[[NBFilterModel alloc] initName:@"子控件6" withId:@"adsfadf" defaultImage:@"icon_un_agree" selectedImage:@"icon_agree" tag:0 childArray:nil],[[NBFilterModel alloc] initName:@"子控件7" withId:@"adsfadf" defaultImage:@"icon_un_agree" selectedImage:@"icon_agree" tag:0 childArray:nil],[[NBFilterModel alloc] initName:@"子控件8" withId:@"adsfadf" defaultImage:@"icon_un_agree" selectedImage:@"icon_agree" tag:0 childArray:nil]]],[[NBFilterModel alloc] initName:@"测试二" withId:@"adsfadf" defaultImage:@"icon_down" selectedImage:@"icon_up" tag:0 childArray:@[[[NBFilterModel alloc] initName:@"子控件1" withId:@"adsfadf" defaultImage:@"icon_un_agree" selectedImage:@"icon_agree" tag:0 childArray:nil],[[NBFilterModel alloc] initName:@"子控件2" withId:@"adsfadf" defaultImage:@"icon_un_agree" selectedImage:@"icon_agree" tag:0 childArray:nil],[[NBFilterModel alloc] initName:@"子控件3" withId:@"adsfadf" defaultImage:@"icon_un_agree" selectedImage:@"icon_agree" tag:0 childArray:nil],[[NBFilterModel alloc] initName:@"子控件4" withId:@"adsfadf" defaultImage:@"icon_un_agree" selectedImage:@"icon_agree" tag:0 childArray:nil]]],[[NBFilterModel alloc] initName:@"测试三" withId:@"adsfadf" defaultImage:@"icon_down" selectedImage:@"icon_up" tag:0 childArray:nil]];
    
    NBFilterView *filterView = [[NBFilterView alloc] initWithFrame:CGRectMake(0, 200, [UIScreen mainScreen].bounds.size.width, 50)];
    filterView.rowHeight = 40;
    [self.view addSubview:filterView];
    filterView.datasource = self;
    filterView.delegate = self;
    
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 250, self.view.bounds.size.width, 500)];
    bgView.backgroundColor = [UIColor redColor];
  //  [self.view addSubview:bgView];
}

- (NSInteger)numberOfSectionsForfilterView:(NBFilterView *)filterView{
    return dataArray.count;
}

- (NSInteger)filterView:(NBFilterView *)filterView numberInSection:(NSInteger)section{
    NBFilterModel *filterModel = dataArray[section];
    return filterModel.fChildArray.count;
}


- (NSInteger)filterView:(NBFilterView *)filterView numberOfColumnsInSection:(NSInteger)section{
    return 3;
}

- (UIEdgeInsets)filterView:(NBFilterView *)filterView paddingOfColumnsInSection:(NSInteger)section{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (UIView *)filterView:(NBFilterView *)filterView viewOfSection:(NSInteger)section{
    NBFilterModel *filterModel = dataArray[section];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.showsTouchWhenHighlighted = YES;
    
    [button setImage:[UIImage imageNamed:filterModel.fSelectedDetailImage] forState:UIControlStateSelected];
    [button setImage:[UIImage imageNamed:filterModel.fDefaultDetailImage] forState:UIControlStateNormal];
    //这样可以设置无论是否选中状态,高亮图片都是同一张
    [button setImage:[UIImage imageNamed:filterModel.fSelectedDetailImage] forState:(UIControlStateHighlighted|UIControlStateSelected)];
    
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button setTitle:filterModel.fName forState:UIControlStateNormal];
    
    return button;
}

- (UIView *)filterView:(NBFilterView *)filterView viewForRowAtIndexPath:(NBIndexPath)indexPath{
    
    NBFilterModel *filterModel = dataArray[indexPath.section];
    NBFilterModel *mModel = filterModel.fChildArray[indexPath.row];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.borderColor = [UIColor yellowColor].CGColor;
    button.layer.borderWidth = 1;
    button.layer.cornerRadius = 5;
    button.layer.masksToBounds = YES;
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button setTitle:mModel.fName forState:UIControlStateNormal];
    button.showsTouchWhenHighlighted = YES;
    
    return button;
}

- (void)filterView:(NBFilterView *)filterView didSelectedRowOfIndexPath:(NBIndexPath)indexPath{
    NSLog(@"=选中的是第===%ld===行 第=%ld=个",indexPath.section,indexPath.row);
}

- (void)initView{
    vcArray = @[].mutableCopy;
    NSArray *array = [[NSArray alloc]initWithObjects:@"好评",@"中评",@"差评",@"好评",@"中评",@"差评",@"好评",@"中评",@"差评",@"好评",@"好评",@"中评",@"差评",@"好评",@"中ass评",@"差评",@"好评",@"中阿斯顿飞评",@"差评",@"好评", nil];
    sliderView = [[NBSlideSwitchView alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64)];
    sliderView.tabItemSelectedBackgroundImage = [UIImage imageNamed:@"bg_scroll"];
    [self.view addSubview:sliderView];
    sliderView.isSlider = YES;
    sliderView.tabItemNormalColor = [UIColor blackColor];
    [sliderView setBackgroundColor:[UIColor whiteColor]];
    sliderView.tabItemSelectedColor = [UIColor redColor];
    
    //    __weak typeof(self) weakSelf = self;
    for (int i  =0; i< array.count ; i++ ) {
        ChildTableViewController *test = [[ChildTableViewController alloc]init];
        test.title = array[i];
        [vcArray addObject:test];
    }
    
    sliderView.slideSwitchViewDelegate =self;
    
    sliderView.titleArray = array.mutableCopy;
    
    [sliderView buildUI];
}

#pragma mark - 滑动tab视图代理方法
- (NSUInteger)numberOfTab:(NBSlideSwitchView *)view
{
    return vcArray.count;
}

- (UIViewController *)slideSwitchView:(NBSlideSwitchView *)view viewOfTab:(NSUInteger)number
{
    return vcArray[number];
}


- (void)slideSwitchView:(NBSlideSwitchView *)view didselectTab:(NSUInteger)number
{
//    CommentChildViewController *vc = nil;
//    currentID = number;
//    if (number == 0) {
//        vc = self.childVC1;
//    } else if (number == 1) {
//        vc = self.childVC2;
//    } else if (number == 2) {
//        vc = self.childVC3;
//    }
//    [vc viewDidCurrentView:number];
    NSLog(@"切换--->>>%ld",number);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    //[NBSystemConfig checkEnabledRemoteNotification];

    /*
    //创建音乐文件路径
    NSString *musicFilePath = [[NSBundle mainBundle] pathForResource:@"Chain_Hang_Low1" ofType:@"caf"];
    
    //判断文件是否存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:musicFilePath])
    {
        NSURL *musicURL = [NSURL fileURLWithPath:musicFilePath];
        NSError *myError = nil;
        //创建播放器
        if (myBackMusic == nil)
        {
            myBackMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:&myError];
            NSLog(@"error === %@",[myError description]);
        }
        [myBackMusic setVolume:1];   //设置音量大小
        myBackMusic.numberOfLoops = 1;//设置音乐播放次数  -1为一直循环
        [myBackMusic prepareToPlay];
        
        [myBackMusic play];       //播放
    }
    //设置锁屏仍能继续播放
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
*/
    CFCityPickerVC *city = [CFCityPickerVC new];
    city.hotCities = @[@"北京",@"上海",@"广州",@"成都",@"杭州",@"重庆",@"香港",@"广安"];
    //设置热门城市
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:city];
    nav.navigationBar.barStyle = UIBarStyleBlackTranslucent;

    //解析字典数据
    NSArray *cityModels = [self cityModelsPrepare];
    city.cityModels = cityModels;
    [self presentViewController:nav animated:YES completion:nil];
    //选中了城市
    city.selectedCityModel = ^(CityModel *cityModel){
        NSLog(@"你选中了城市===%@",cityModel.name);
    };
}


/** 这里是无关的解析业务 */

    /** 解析字典数据，由于swift中字典转模型工具不完善，这里先手动处理 */
- (NSArray *)cityModelsPrepare{
    NSURL *plistUrl = [[NSBundle mainBundle] URLForResource:@"City" withExtension:@"plist"];
    NSArray *cityArray = [NSArray arrayWithContentsOfURL:plistUrl];
    NSMutableArray *cityModels = @[].mutableCopy;
    for (NSDictionary *dict in cityArray) {
        CityModel *mModel  =  [self parse:dict];
        [cityModels addObject:mModel];
    }
    return cityModels;
}

- (CityModel *)parse:(NSDictionary *)dict{
    int mId = [dict[@"id"] intValue];
    int pId = [dict[@"pid"] intValue];
    NSString *name = dict[@"name"];
    NSString *spell = dict[@"spell"];
    
    CityModel *mCityModel = [[CityModel alloc]initWithId:mId pid:pId name:name spell:spell];
    
    NSArray *childArray = dict[@"children"];
    if (childArray) {
        NSMutableArray *childArrays = @[].mutableCopy;
        for (NSDictionary *childDict in childArray) {
            CityModel *mModel  =  [self parse:childDict];
            [childArrays addObject:mModel];
        }
        mCityModel.children = childArrays;
    }
    
    
    return mCityModel;
}


@end
