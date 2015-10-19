//
//  WikiSearchResult.m
//  WikiSearch
//
//  Created by Rameez Hussain on 17/10/15.
//  Copyright © 2015 Rameez Hussain. All rights reserved.
//

#import "WikiSearchResult.h"

@implementation WikiSearchResult

+ (WikiSearchResult *) getSearchResultWithText: (NSString *) text andLink: (NSString *) link {
    WikiSearchResult *searchResult = [WikiSearchResult new];
    searchResult.text = text;
    searchResult.link = link;
    return searchResult;
}

@end
