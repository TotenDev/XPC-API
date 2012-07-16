//
// NSData+XPCAdds.h — XPC-API
// today is 7/16/12, it is now 5:15 PM
// created by TotenDev
// see LICENSE for details.
//

#import <Foundation/Foundation.h>
#include <xpc/xpc.h>

@interface NSData (XPCAdds)
// code and decode support for XPC_object_t
+ (NSData *)decodeDefaultXPCMessage:(xpc_object_t)message ;
- (void)encodeIntoXPCDictionary:(xpc_object_t *)dict ;
@end
