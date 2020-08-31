//
//  Network.h
//  samplePlayer
//
//  Created by 서상민 on 2020/08/24.
//  Copyright © 2020 ScenappsM. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

struct RequestInfo {
    NSString* url;
    NSDictionary* body;
};

@interface Network : NSObject

- (void)fetchData:(struct RequestInfo) info viewController:(UIViewController*)view completionHandler:(void (^)(NSString* url, Boolean isDRM))completion;

@end

NS_ASSUME_NONNULL_END
