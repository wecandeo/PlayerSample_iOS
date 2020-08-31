//
//  Network.m
//  samplePlayer
//
//  Created by 서상민 on 2020/08/24.
//  Copyright © 2020 ScenappsM. All rights reserved.
//

#import "Network.h"

@implementation Network

- (void)fetchData:(struct RequestInfo)info viewController:(UIViewController *)view completionHandler:(void (^)(NSString * _Nonnull, Boolean))completion {
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLComponents* components = [[NSURLComponents alloc] initWithString:info.url];
    NSMutableArray* querys = [NSMutableArray array];
    for (NSString* key in info.body) {
        [querys addObject:[NSURLQueryItem queryItemWithName:key value:[info.body objectForKey:key]]];
    }
    [components setQueryItems:querys];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[components URL]];
    [request setHTTPMethod:@"GET"];
    
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
            return;
        }
        
        NSHTTPURLResponse* res = (NSHTTPURLResponse*) response;
        if (res.statusCode != 200) {
            NSLog(@"Response StatusCode Not 200");
            return;
        }
        
        NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        
        NSError* err;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingFragmentsAllowed error:&err];
        NSString* url = [[json objectForKey:@"VideoDetail"] objectForKey:@"videoUrl"];
        NSString* opt = [[[json objectForKey:@"VideoDetail"] objectForKey:@"videoInfo"] objectForKey:@"opt"];
        
        if (!opt) {
            //Live
            NSString* errCode = [[[json objectForKey:@"VideoDetail"] objectForKey:@"errorInfo"] objectForKey:@"errorCode"];
            NSString* errMsg = [[[json objectForKey:@"VideoDetail"] objectForKey:@"errorInfo"] objectForKey:@"errorMessage"];
            
            if (![errCode isEqualToString:@"None"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController* control = [UIAlertController alertControllerWithTitle:@"안내" message:errMsg preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                    [control addAction:action];
                    [view presentViewController:control animated:NO completion:nil];
                });
            } else {
                completion(url, false);
            }
            
        } else {
            //Video
            completion(url, [opt isEqualToString:@"WIDEVINE_DRM"]);
        }
    }];
    [task resume];
}

@end
