//
// XPCConnection.h — XPC-API
// today is 7/16/12, it is now 5:15 PM
// created by TotenDev
// see LICENSE for details.
//

#import <Foundation/Foundation.h>

@class XPCMessage;
@class XPCCallbackResponse;

@interface XPCConnection : NSObject
#pragma mark - Messages
// Just send a message
+ (void)callXPCWithMessage:(XPCMessage *)msg ;
// Send a message and notify when arrives
+ (void)callXPCWithMessage:(XPCMessage *)msg notifingWhenArrives:(void (^)(BOOL sucess))arrived ;
// Send a message with parameters and and notify when arrives
+ (void)callXPCWithMessage:(XPCMessage *)msg notifingWhenArrives:(void (^)(BOOL sucess))arrived withCallBackResponse:(void (^) (XPCCallbackResponse * callBack))callBackBlock ;

#pragma mark - Receiving
//Decode XPCMessage and AFTER SEND REPLY !!
+ (void)decodeMessage:(xpc_object_t)message withClientInstance:(id)instance ;
@end


