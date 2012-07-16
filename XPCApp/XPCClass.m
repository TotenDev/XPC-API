//
// XPCClass.m — XPC-API
// today is 7/16/12, it is now 5:15 PM
// created by TotenDev
// see LICENSE for details.
//

#import "XPCClass.h"

@implementation XPCClass

-(void) foo{
    NSLog(@"FOO from XPC Call");
}

-(XPCCallbackResponse*) bar:(NSString*) parameter{
	NSLog(@"BAR from XPC Call");
    XPCCallbackResponse *response = [[XPCCallbackResponse alloc] init];
    response.callBackArgs = [NSMutableArray arrayWithObject:parameter];
    return  response;
}

@end