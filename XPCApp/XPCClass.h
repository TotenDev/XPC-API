//
// XPCClass.h — XPC-API
// today is 7/16/12, it is now 5:15 PM
// created by TotenDev
// see LICENSE for details.
//

#import <Foundation/Foundation.h>
#import "XPCAPI.h"

@interface XPCClass : NSObject

-(void) foo;
-(XPCCallbackResponse*) bar:(NSString*) parameter;

@end