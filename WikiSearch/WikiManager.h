//
//  WikiManager.h
//  WikiSearch
//
//  Created by Rameez Hussain on 17/10/15.
//  Copyright © 2015 Rameez Hussain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WikiManager : NSObject
+ (id) sharedManager;
- (void) performSearchWithString: (NSString *) searchString
                     withSuccess: (void (^)(id responseObject))success
                      andFailure: (void (^)(NSError *error))failure;
@end
