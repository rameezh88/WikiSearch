//
//  WikiManager.m
//  WikiSearch
//
//  Created by Rameez Hussain on 17/10/15.
//  Copyright © 2015 Rameez Hussain. All rights reserved.
//

#import "WikiManager.h"
#import "AFHTTPRequestOperation.h"

const NSString *baseUrl = @"https://en.wikipedia.org/w/api.php?action=opensearch&format=json&search=";

@interface WikiManager ()

@property (nonatomic, strong) NSOperationQueue *activeRequests;

@end

@implementation WikiManager

+ (id)sharedManager {
    static WikiManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

#pragma mark - Private methods.

- (void) performSearchWithString:(NSString *)searchString withSuccess:(void (^)(id))success andFailure:(void (^)(NSError *))failure {
    NSString *clientsURLString = [NSString stringWithFormat:@"%s%@", [baseUrl UTF8String], searchString];
    NSURL *clientsURL = [NSURL URLWithString:[clientsURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *clientsRequest = [NSURLRequest requestWithURL:clientsURL];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:clientsRequest];
    AFHTTPResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer = responseSerializer;
    [self performOperation:operation withSuccess:success andFailure:failure];
}

#pragma mark - Convenience methods for API calls.

- (void) performUnqueuedOperation: (AFHTTPRequestOperation *) operation withSuccess: (void (^)(id))success andFailure:(void (^)(NSError *))failure {
    [self performOperation:operation withSuccess:success andFailure:failure queued:NO];
}

- (void) performOperation: (AFHTTPRequestOperation *) operation withSuccess: (void (^)(id))success andFailure:(void (^)(NSError *))failure {
    [self performOperation:operation withSuccess:success andFailure:failure queued:YES];
}

- (void) performOperation: (AFHTTPRequestOperation *) operation withSuccess: (void (^)(id))success andFailure:(void (^)(NSError *))failure queued: (BOOL) queued {
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
    
    if (queued) {
        [self addRequestOperation:operation];
    }
    
    [operation start];
}

- (void) addRequestOperation: (NSOperation *) request {
    if (!self.activeRequests) {
        self.activeRequests = [NSOperationQueue new];
    }
    [self cancelOtherRequests];
    [self.activeRequests addOperation:request];
}

- (void) cancelOtherRequests {
    if ([self.activeRequests operationCount] == 0) return;
    [self.activeRequests cancelAllOperations];
}


@end
