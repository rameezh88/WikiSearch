//
//  WikiSearchResult.h
//  WikiSearch
//
//  Created by Rameez Hussain on 17/10/15.
//  Copyright © 2015 Rameez Hussain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WikiSearchResult : NSObject
@property (nonatomic, strong) NSString *text, *link;
+ (WikiSearchResult *) getSearchResultWithText: (NSString *) text andLink: (NSString *) link;
@end
