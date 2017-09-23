//
//  Config.h
//  Sonarus
//
//  Created by Christopher Arciniega on 4/19/17.
//  Copyright © 2017 HQZenithLabs. All rights reserved.
//

#ifndef Config_h
#define Config_h

#define kClientId "dfcfa1cd5aab4254b7332ae6911aeffb"
#define kCallbackURL "sonarus://"
#define kTokenSwapServiceURL "http://localhost:123/swap"
#define kTokenRefreshServiceURL "http://localhost:123/refresh"
#define kSessionUserDefaultsKey "SpotifySession"

@interface Config : NSObject
- (char*)getClientID;
- (char*)getCallBackURL;
- (char*)getTokenSwapService;
- (char*)getTokenRefreshService;
- (char*)getSessionUserDefaultsKey;
@end

#endif /* Config_h */
