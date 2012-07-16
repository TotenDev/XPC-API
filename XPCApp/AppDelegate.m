//
// AppDelegate.m — XPC-API
// today is 7/16/12, it is now 5:15 PM
// created by TotenDev
// see LICENSE for details.
//

#import "AppDelegate.h"
#import "XPCAPI.h"


@implementation AppDelegate
@synthesize window = _window;
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{
    
    // send two XPC messsages:
    // - without parameters, just calls and wait for proof of delivery
    [self sendXPCMessageWithoutParameters];
    // - with a parameter, calls and show response
    [self sendXPCMessageUsingParameters];
    
}
-(void) sendXPCMessageWithoutParameters{
    
    XPCMessage *aXPCMessage = [XPCMessage XPCMessageWithMethod:@selector(foo)
											  bundleIdentifier:@"com.totendev.XPC-API.client"
										   andOrderedArguments:nil];
    
    [XPCConnection callXPCWithMessage:aXPCMessage
                  notifingWhenArrives:^(BOOL sucess) {
                      // proof of delivery
                      NSLog(@"sendXPCMessageWithoutParameters Done!");
                  }];
    
}
-(void) sendXPCMessageUsingParameters{
    
    // prepare message, using a NSString as parameter
    XPCMessage *aXPCMessage = [XPCMessage XPCMessageWithMethod:@selector(bar:)
                                              bundleIdentifier:@"com.totendev.XPC-API.client"
                                           andOrderedArguments:[NSArray arrayWithObject:@"sendXPCMessageUsingParameters Object"]];
    // send message
    [XPCConnection callXPCWithMessage:aXPCMessage
                  notifingWhenArrives:^(BOOL sucess) {
                      // proof of delivery
                      NSLog(@"sendXPCMessageUsingParameters Done!");
                  } withCallBackResponse:^(XPCCallbackResponse *response) {
                      // response
                      NSLog(@"Got response! %@", response.callBackArgs);
                  }];
    
}
@end