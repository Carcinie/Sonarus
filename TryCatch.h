//
//  TryCatch.h
//  Sonarus
//
//  Created by Christopher Arciniega on 4/19/17.
//  Copyright © 2017 HQZenithLabs. All rights reserved.
//

@interface TryCatch : NSObject

+ (void)try:(void(^)(void))try catch:(void(^)(NSException*exception))catch finally:(void(^)()) finally;

@end /* TryCatch_h */
