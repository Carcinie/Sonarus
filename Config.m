//
//  Config.m
//  Sonarus
//
//  Created by Christopher Arciniega on 4/19/17.
//  Copyright © 2017 HQZenithLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Config.h"

@implementation Config

- (char*)getClientID{
    return kClientId;
}
- (char*)getCallBackURL{
    return kCallbackURL;
}
- (char*)getTokenSwapService{
    return nil;
}
- (char*)getTokenRefreshService{
    return nil;
}
- (char*)getSessionUserDefaultsKey{
    return kSessionUserDefaultsKey;
}


@end
