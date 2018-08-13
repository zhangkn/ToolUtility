//
//  _net_package_info.m
//  consumer
//
//  Created by fallen.ink on 9/22/16.
//
//

#import "_net_package_info.h"

@implementation _NetPackageInfo
@synthesize packageURL, baseURL, resourceURLs, userData;

- (id)init {
    self = [super init];
    if (self != nil) {
        resourceURLs = [[NSArray alloc] init];
        userData = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)encodeWithCoder: (NSCoder *) coder {
    [coder encodeObject: packageURL			forKey: @"AFPkgInfo_packageURL"];
    [coder encodeObject: baseURL			forKey: @"AFPkgInfo_baseURL"];
    [coder encodeObject: resourceURLs		forKey: @"AFPkgInfo_resourceURLs"];
    [coder encodeObject: userData			forKey: @"AFPkgInfo_userData"];
}

- (id)initWithCoder: (NSCoder *) coder {
    self.packageURL			= [coder decodeObjectForKey: @"AFPkgInfo_packageURL"];
    self.baseURL			= [coder decodeObjectForKey: @"AFPkgInfo_baseURL"];
    self.resourceURLs		= [coder decodeObjectForKey: @"AFPkgInfo_resourceURLs"];
    self.userData			= [coder decodeObjectForKey: @"AFPkgInfo_userData"];
    return self;
}

- (NSString*)description {
    NSMutableString *s = [NSMutableString stringWithString:@"Cache information:\n"];
    [s appendFormat:@"packageURL: %@\n",		packageURL];
    [s appendFormat:@"baseURL: %@\n",			baseURL];
    [s appendFormat:@"resourceURLs: %@\n",		[resourceURLs description]];
    [s appendFormat:@"userData: %@\n",			[userData description]];
    return s;
}
@end
