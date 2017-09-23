//
//  TryCatch.m
//  Sonarus
//
//  Created by Christopher Arciniega on 4/19/17.
//  Copyright © 2017 HQZenithLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TryCatch.h"

@implementation TryCatch

+(void)try:(void (^)(void))try catch:(void (^)(NSException *))catch finally:(void (^)())finally{
    @try {
        try ? try() : nil;
    }
    @catch (NSException *exception) {
        catch ? catch(exception) : nil;
    }
    @finally {
        finally ? finally() : nil;
    }
}

@end
