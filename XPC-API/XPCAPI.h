//
// XPCAPI.h — XPC-API
// today is 7/16/12, it is now 5:15 PM
// created by TotenDev
// see LICENSE for details.
//

#import <xpc/xpc.h>
#import "XPCMessage.h"
#import "XPCConnection.h"
#define XPCLogging 1
//XPC
#define XPCLog(s, ...)(XPCLogging?NSLog( @"**XPC** %@", [NSString stringWithFormat:(s), ##__VA_ARGS__]):nil)