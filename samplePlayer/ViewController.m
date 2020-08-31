//
//  ViewController.m
//  DRMPlayer
//
//  Created by mgoon on 2017. 12. 15..
//  Copyright © 2017년 ScenappsM. All rights reserved.
//

#import "ViewController.h"

#import <WecandeoSDK/WecandeoSDK.h>
#import "Network.h"

@interface ViewController () <WCPlayerDelegate> {
    Boolean isVod;
}

@property (strong, nonatomic) WCPlayer *player;
@property (strong, nonatomic) PlayerController *controller;
@property (assign, nonatomic) CGFloat currentVol;

@property (weak, nonatomic) IBOutlet UIButton *btPause;
@property (weak, nonatomic) IBOutlet UIButton *btRetry;
@property (weak, nonatomic) IBOutlet UIButton *btRewind;
@property (weak, nonatomic) IBOutlet UIButton *btForward;
@property (weak, nonatomic) IBOutlet UILabel *playerStatus;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UISlider *seekbar;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    isVod = true;
    [self initController];
    struct RequestInfo reqInfo = [self reqestInfo];
    
    [[Network alloc] fetchData:reqInfo viewController:self completionHandler:^(NSString * _Nonnull url, Boolean isDRM) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isDRM) {
                [self initDRMPlayer];
            } else {
                [self initNonDRMPlayer:url];
            }
            
            [self.controller.view setTranslatesAutoresizingMaskIntoConstraints:NO];
            [self.view addSubview:self.controller.view];
            
            [self.controller.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
            [self.controller.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
            [self.controller.view.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor].active = YES;
            [self.controller.view.heightAnchor constraintEqualToAnchor:self.controller.view.widthAnchor multiplier:0.5625].active = YES;
            
            [self.playerStatus setText:@"플레이어 상태"];
        });
    }];
}

- (struct RequestInfo)reqestInfo {
    struct RequestInfo reqInfo;
    
    if (isVod) {
        // Video
        reqInfo.url = @"https://api.wecandeo.com/v1/new/player/video.json";
        reqInfo.body = @{
            @"k": @"Vod 영상의 Video Key",
            @"dev": @"2"
        };
    } else {
        // Live
        reqInfo.url = @"https://api.wecandeo.com/live/new/player/info.json";
        reqInfo.body = @{@"k": @"Live영상 Video Key"};
    }
    
    return reqInfo;
}

- (void)initController {
    [_btPause setHidden:!isVod];
    [_btRetry setHidden:!isVod];
    [_btRewind setHidden:!isVod];
    [_btForward setHidden:!isVod];
}

- (void)initDRMPlayer {
    WCScretKey *scretKey = [[WCScretKey alloc] init];
    NSString *hmac = [scretKey hmacWithGid:@"WecandeoDRM gid" scretKey:@"WecandeoDRM scretKey" client:@"hmac 추가할 문자열"];
    
    self.player = [[WCPlayer alloc] init];
    [self.player setDelegate:self];
    self.controller = [self.player setPlayerControlWithGid:@"WecandeoDRM gid"
                                                 packageId:@"DRM 영상의 배포패키지 Id"
                                                   videoId:@"DRM 영상의 Video Id"
                                                  videoKey:@"DRM 영상의 Video Key"
                                                      hMac:hmac];
}

- (void)initNonDRMPlayer:(NSString* )url {
    self.player = [[WCPlayer alloc] init];
    [self.player setDelegate:self];
    
    self.controller = [self.player setPlayerControl:url];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didPlayerItemStatusReadyToPlay {
    self.currentVol = [self.player getVolume];
    
    [self.playerStatus setText: ([self.player isPlaying]) ?  @"재생" : @"플레이어 재생준비 완료"];
}

- (void)didPlayerItemStatusCompleted {
    [self retryCallback:nil];
}

- (void)playerTimeObserver:(CMTime)time {
    [self playTime:time];
}

- (NSString*)convertTimer:(int) t {
    int hour = (int) t / 3600;
    int min = (int) (t % 3600 / 60);
    int sec = (int) (t % 3600 % 60);
    
    if (hour == 0) {
        return [NSString stringWithFormat:@"%02d:%02d", min, sec];
    } else {
        return [NSString stringWithFormat:@"%02d:%02d:%02d", hour, min, sec];
    }
}

- (void)playTime:(CMTime) time {
    int current = (int) CMTimeGetSeconds(time);
    int duration = (int) CMTimeGetSeconds([self.player duration]);
    
    NSString* c = [self convertTimer:current];
    NSString* d = [self convertTimer:duration];
    
    self.timeLabel.text = [NSString stringWithFormat:@"%@ / %@", c, d];
    
    self.seekbar.maximumValue = 1;
    self.seekbar.value = CMTimeGetSeconds(time) / CMTimeGetSeconds([self.player duration]);
}

- (IBAction)playCallback:(UIButton *)sender {
    [self.player play];
    
    [self.playerStatus setText:@"재생"];
}

- (IBAction)pauseCallback:(UIButton *)sender {
    [self.player pause];
    
    [self.playerStatus setText:@"일시정지"];
}

- (IBAction)stopCallback:(UIButton *)sender {
    [self.player stop];
    
    [self.playerStatus setText:@"정지"];
}

- (IBAction)retryCallback:(id)sender {
    [self.controller.view removeFromSuperview];
    
    self.controller = nil;
    self.player = nil;
    
    [self viewDidLoad];
}

- (IBAction)muteCallback:(id)sender {
    [self.player mute];
    
    [self.playerStatus setText:@"음소거"];
}

- (IBAction)volumeUpCallback:(id)sender {
    self.currentVol += 0.1;
    
    if (self.currentVol >= 1.0) {
        self.currentVol = 1.0;
    }
    
    if ([self.player isMute]) {
        [self.player unMute];
    }
    
    [self.player setVolume:self.currentVol];
    
    [self.playerStatus setText:[NSString stringWithFormat:@"볼륨 %f", self.currentVol]];
}

- (IBAction)volumeDownCallback:(id)sender {
    self.currentVol -= 0.1;
    
    if (self.currentVol <= 0.0) {
        self.currentVol = 0.0;
    }
    
    if ([self.player isMute]) {
        [self.player unMute];
    }
    
    [self.player setVolume:self.currentVol];
    
    [self.playerStatus setText:[NSString stringWithFormat:@"볼륨 %f", self.currentVol]];
}

- (IBAction)rewindCallback:(id)sender {
    [self.player backwawrd:10];
    
    [self.playerStatus setText:@"뒤로 10초 이동"];
}

- (IBAction)forwardCallback:(id)sender {
    [self.player forwawrd:10];
    
    [self.playerStatus setText:@"앞으로 10초 이동"];
}

- (void)changedFullScreen {
    NSNumber *changeOrientaion;
    UIInterfaceOrientation orientation = UIApplication.sharedApplication.statusBarOrientation;
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            changeOrientaion = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            changeOrientaion = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
            break;
        default:
            break;
    }
    
    [UIDevice.currentDevice setValue:changeOrientaion forKey:@"orientation"];
}

- (IBAction)fullScreenCallback:(UIButton *)sender {
    [self changedFullScreen];
}

- (IBAction)seekbarCallback:(UISlider *)sender {
    if ([self.player isPlaying]) {
        [self.player pause];
    }
    
    Float64 duration = CMTimeGetSeconds([self.player duration]);
    Float64 elapsedTime = duration * sender.value;
    [self playTime:CMTimeMakeWithSeconds(elapsedTime, NSEC_PER_SEC)];
    
    [self.player moveSeek:elapsedTime
        completionHandler:^(BOOL finished) {
        NSLog(@"moveSeek Finished: %@", finished ? @"YES" : @"NO");
        if (finished) {
            if (![self.player isPlaying]) {
                [self.player play];
            }
        }
    }];
}

@end
