//
//  UnifiedNativeAdFeedVideoTableViewController.m
//  GDTMobApp
//
//  Created by qpwang on 2019/5/18.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "UnifiedNativeAdFeedVideoTableViewController.h"
#import "GDTUnifiedNativeAd.h"
#import "UnifiedNativeAdFeedVideoCell.h"
#import "UnifiedNativeAdImageCell.h"
#import "UnifiedNativeAdThreeImageCell.h"
#import "GDTAppDelegate.h"

@interface UnifiedNativeAdFeedVideoTableViewController () <GDTUnifiedNativeAdDelegate, GDTUnifiedNativeAdViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) GDTUnifiedNativeAd *unifiedNativeAd;
@property (nonatomic, strong) NSArray *adDataArray;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation UnifiedNativeAdFeedVideoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.unifiedNativeAd = [[GDTUnifiedNativeAd alloc] initWithAppId:self.appId placementId:self.placementId];
    self.unifiedNativeAd.minVideoDuration = self.minVideoDuration;
    self.unifiedNativeAd.maxVideoDuration = self.maxVideoDuration;
    self.unifiedNativeAd.delegate = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[UnifiedNativeAdFeedVideoCell class] forCellReuseIdentifier:@"UnifiedNativeAdFeedVideoCell"];
    [self.tableView registerClass:[UnifiedNativeAdImageCell class] forCellReuseIdentifier:@"UnifiedNativeAdImageCell"];
    [self.tableView registerClass:[UnifiedNativeAdThreeImageCell class] forCellReuseIdentifier:@"UnifiedNativeAdThreeImageCell"];
    [self.tableView reloadData];
    [self.unifiedNativeAd loadAdWithAdCount:10];
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    self.unifiedNativeAd.minVideoDuration = self.minVideoDuration;
//    self.unifiedNativeAd.maxVideoDuration = self.maxVideoDuration;
//    [self.unifiedNativeAd loadAdWithAdCount:10];
//}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.adDataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GDTUnifiedNativeAdDataObject *dataObject = self.adDataArray[indexPath.row];
    if (dataObject.isVideoAd) {
        return [UnifiedNativeAdFeedVideoCell cellHeightWithUnifiedNativeAdDataObject:dataObject];
    } else if (dataObject.isThreeImgsAd) {
        return [UnifiedNativeAdThreeImageCell cellHeightWithUnifiedNativeAdDataObject:dataObject];
    } else {
        return [UnifiedNativeAdImageCell cellHeightWithUnifiedNativeAdDataObject:dataObject];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GDTUnifiedNativeAdDataObject *dataObject = self.adDataArray[indexPath.row];
    NSLog(@"eCPM:%ld eCPMLevel:%@ videoDuration:%lf", [dataObject eCPM], [dataObject eCPMLevel], [dataObject duration]);
    if (dataObject.isVideoAd) {
        dataObject.videoConfig = self.videoConfig;
        UnifiedNativeAdFeedVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UnifiedNativeAdFeedVideoCell"];
        [cell setupWithUnifiedNativeAdDataObject:dataObject delegate:self vc:self];
        return cell;
    } else if (dataObject.isThreeImgsAd) {
        UnifiedNativeAdThreeImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UnifiedNativeAdThreeImageCell"];
        [cell setupWithUnifiedNativeAdDataObject:dataObject delegate:self vc:self];
        return cell;
    } else {
        UnifiedNativeAdImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UnifiedNativeAdImageCell"];
        [cell setupWithUnifiedNativeAdDataObject:dataObject delegate:self vc:self];
        return cell;
    }
}

#pragma mark - GDTUnifiedNativeAdDelegate
- (void)gdt_unifiedNativeAdLoaded:(NSArray<GDTUnifiedNativeAdDataObject *> *)unifiedNativeAdDataObjects error:(NSError *)error
{
    if (!error && unifiedNativeAdDataObjects.count > 0) {
        NSLog(@"成功请求到广告数据");
        self.adDataArray = unifiedNativeAdDataObjects;
        [self.tableView reloadData];
        return;
    }
    
    if (error.code == 5004) {
        NSLog(@"没匹配的广告，禁止重试，否则影响流量变现效果");
    } else if (error.code == 5005) {
        NSLog(@"流量控制导致没有广告，超过日限额，请明天再尝试");
    } else if (error.code == 5009) {
        NSLog(@"流量控制导致没有广告，超过小时限额");
    } else if (error.code == 5006) {
        NSLog(@"包名错误");
    } else if (error.code == 5010) {
        NSLog(@"广告样式校验失败");
    } else if (error.code == 3001) {
        NSLog(@"网络错误");
    } else if (error.code == 5013) {
        NSLog(@"请求太频繁，请稍后再试");
    } else if (error) {
        NSLog(@"ERROR: %@", error);
    }
}

#pragma mark - GDTUnifiedNativeAdViewDelegate
- (void)gdt_unifiedNativeAdViewDidClick:(GDTUnifiedNativeAdView *)unifiedNativeAdView
{
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"%@ 广告被点击", unifiedNativeAdView.dataObject);
}

- (void)gdt_unifiedNativeAdViewWillExpose:(GDTUnifiedNativeAdView *)unifiedNativeAdView
{
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"广告被曝光");
}

- (void)gdt_unifiedNativeAdDetailViewClosed:(GDTUnifiedNativeAdView *)unifiedNativeAdView
{
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"广告详情页已关闭");
}

- (void)gdt_unifiedNativeAdViewApplicationWillEnterBackground:(GDTUnifiedNativeAdView *)unifiedNativeAdView
{
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"广告进入后台");
}

- (void)gdt_unifiedNativeAdDetailViewWillPresentScreen:(GDTUnifiedNativeAdView *)unifiedNativeAdView
{
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"广告详情页面即将打开");
}

- (void)gdt_unifiedNativeAdView:(GDTUnifiedNativeAdView *)unifiedNativeAdView playerStatusChanged:(GDTMediaPlayerStatus)status userInfo:(NSDictionary *)userInfo
{
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"视频广告状态变更");
    switch (status) {
        case GDTMediaPlayerStatusInitial:
            NSLog(@"视频初始化");
            break;
        case GDTMediaPlayerStatusLoading:
            NSLog(@"视频加载中");
            break;
        case GDTMediaPlayerStatusStarted:
            NSLog(@"视频开始播放");
            break;
        case GDTMediaPlayerStatusPaused:
            NSLog(@"视频暂停");
            break;
        case GDTMediaPlayerStatusStoped:
            NSLog(@"视频停止");
            break;
        case GDTMediaPlayerStatusError:
            NSLog(@"视频播放出错");
        default:
            break;
    }
    if (userInfo) {
        long videoDuration = [userInfo[kGDTUnifiedNativeAdKeyVideoDuration] longValue];
        NSLog(@"视频广告长度为 %ld s", videoDuration);
    }
}

#pragma mark - property getter
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.frame = self.view.bounds;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.accessibilityIdentifier = @"tableView_id";
    }
    return _tableView;
}
@end
