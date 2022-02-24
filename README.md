# **WECANDEO Player**

## **공통**

- 해당 SDK는 iOS 8.0 이상부터 지원합니다.
- 해당 SDK는 Simulator에서는 지원하지 않습니다. Device를 통해 사용해 주세요.
<hr/>

## **사전에 조회할 값**

- WECANDEO Player를 사용하기 위해서는 활성화 된 WECANDEO 계정이 있어야 합니다.<br> 먼저 [WECANDEO 홈페이지](https://www.wecandeo.com)에서 계정을 생성하고 플랜(Trial, Standard, Enterprise)에 [가입](https://www.wecandeo.com/pricing/videopack/edition/)하여 계정을 활성화 합니다.<br> 활성화 된 계정에 이용중인 상품이 VideoPack인 경우 VOD Player를, LivePack인 경우 Live Player를 사용할 수 있습니다.

- [WECANDEO API](https://support.wecandeo.com/#apis)를 사용하여 필요한 값을 조회합니다.
  - [WECANDEO API](https://support.wecandeo.com/#apis)를 사용하기 위해 필요한 API Key는 활성화 된 계정의 CMS에서 확인 가능합니다. [ CMS > 계정관리 > 개발자  API ]

- VOD Player
  - videoKey: [동영상 배포 코드 조회 API](https://support.wecandeo.com/reference/videopack-api-video-data-retrieve-video-pub-code)를 호출하면 videoKey를 확인할 수 있습니다.
  - DRM 재생을 위한 값
    - gid : [ CMS > 부가서비스 > Wecandeo DRM ] 메뉴에서 `gid`를 확인할 수 있습니다.
    - secretKey : [ CMS > 부가서비스 > Wecandeo DRM ] 메뉴에서 `secretKey`를 확인할 수 있습니다.
    - packageId : [배포 패키지 목록 조회 API](https://support.wecandeo.com/reference/videopack-api-package-package-list)를 호출하면 `packageId`를 확인할 수 있습니다.
    - videoId : [동영상 목록 - 배포 패키지별 조회 API](https://support.wecandeo.com/reference/videopack-api-video-data-retrieve-video-list-package)를 호출하면 `videoId`를 확인할 수 있습니다. 
    - client : 추가적인 사용자 암호화키, 사용자가 임의의 값으로 설정
  - **DRM 기능을 사용하기 위해서는 사용 가능한 플랜(Enterprise)에 가입되어 있어야 하며,<br> 관리자를 통해 해당 기능이 활성화 되어 있어야 합니다.**
- Live Player
  - liveKey : [ CMS > 라이브 채널 > 채널 리스트 > 채널 선택 > 배포 코드 ] 메뉴에서 `liveKey`를 확인할 수 있습니다.

<hr/>

## **Embed Framework**
- Xcode의 [Framework... ] 항목에 “WecandeoSDK.framework”를 추가합니다.
    - “WecandeoSDK.framework>Frameworks” 경로에서 아래의 framework 추가
        - “widevine_cdm_sdk_dev.framework”
        - “widevine_cdm_sdk_insecure_dev.framework”
        - “widevine_cdm_sdk_release.framework”
    <br> <br> ![embedFramework](/image/embedFramework.png)

<hr/>

## **ATS**
- iOS9 이상에서는 ATS(App Transport Security) 기능이 제공됩니다.<br> ATS 기능 활성화 시, HTTP 방식이 제한되어 정상적으로 영상이 재생되지 않습니다.<br> 따라서 Info.plist 파일에 아래의 항목을 추가 적용하여 사용 바랍니다.
    <br><br> ![ATS](/image/ATS.png)

## **Bitcode**
- iOS9 이상에서는 LLVM 컴파일러에서 Bitcode를 생성을 지원합니다.<br> 해당 SDK는 Bitcode를 지원하지 않으며, Bitcode를 활성화 시 영상이 정상적으로 재생되지 않습니다.<br> 따라서 Target > Build Setting > Build Options > Enable Bitcode를 “NO”로 설정하여 사용 바랍니다.
    <br> <br> ![Bitcode](/image/bitcode.png)

<hr/>

## **WCPlayer**
- (PlayerController *)setPlayerControlWithGid:(NSString *)gId packageId:(NSString *)pId videoId:(NSString *)vId videoKey:(NSString *)videoKey hMac:(NSString *)hMac
    - DRM Player 객체 생성
        - gId : 발급받은 gid 값
        - pId : 발급받은 package id 값
        - vId : 발급받은 video Id 값
        - videoKey : 발급받은 video Key 값
        - hMac : 생성된 HMAC 값
- (PlayerController *)setPlayerControl:(NSString *) videoUrl
    - Non DRM Player 객체 생성
        - videoUrl : 영상 재생 URL
- (BOOL)isPlaying
    - 재생여부
- (void)play
    - 재생 
- (void)pause
    - 일시정지
- (void)stop
    - 정지
- (CMTime)duration
    - 전체시간 확인
- (CMTime)currentTime
    - 현재시간 확인
- (void)moveSeek:(Float64)sec completionHandler:(void (^)(BOOL) finished)
    - sec초로 이동
- (void)backwawrd:(CGFloat)sec
    - sec초 뒤로 이동 
- (void)forwawrd:(CGFloat)sec
    - sec초 앞으로 이동
- (BOOL)isMute
    - 음소거 여부 확인
- (void)mute
    - 음소거
- (void)unMute
    - 음소거 해제
- (CGFloat)getVolume
    - 음량값
- (void)setVolume:(CGFloat)volume
    - 음량조절
- (void)setVideoGravity:(AVLayerVideoGravity)gravity
    - gravity 설정
- (AVLayerVideoGravity)getVideoGravity
    - 설정된 gravity 조회

### **WCPlayerDelegate**
- (void)didPlayerItemStatusReadyToPlay
    - 재생준비 완료
- (void)playerTimeObserver:(CMTime)time
    - 재생 중 1초간격으로 호출
- (void)didPlayerItemStatusCompleted
    - 재생 완료

## **WCScretKey**
- (NSString *)hmacWithGid:(NSString *)gid scretKey:(NSString *)scretKey client:(NSString *)client
    - hmac 조회
        - gid : 발급받은 gid값
        - scretKey : 발급받은 SecretKey(HMAC) 값
        - client : 회사도메인
