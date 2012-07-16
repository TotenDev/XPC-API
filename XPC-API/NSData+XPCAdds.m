//
// NSData+XPCAdds.m — XPC-API
// today is 7/16/12, it is now 5:15 PM
// created by TotenDev
// see LICENSE for details.
//

#import "NSData+XPCAdds.h"

#define NSDataXPCAddsDataArrayKey @"data_array"
#define NSDataXPCAddsDataLengthKey @"data_length"

@implementation NSData (XPCAdds)
+ (NSData *)decodeDefaultXPCMessage:(xpc_object_t)message {
	size_t dataLength = xpc_dictionary_get_uint64(message, 
													[NSDataXPCAddsDataLengthKey cStringUsingEncoding:NSUTF8StringEncoding]);
	const void * dataBytes = xpc_dictionary_get_data(message,
													[NSDataXPCAddsDataArrayKey cStringUsingEncoding:NSUTF8StringEncoding],
													&dataLength);
	return [NSData dataWithBytes:dataBytes length:dataLength];
}
- (void)encodeIntoXPCDictionary:(xpc_object_t *)dict {
	xpc_object_t data = xpc_data_create([self bytes], [self length]);
	//Setting an unkown type requires manual memory management
	xpc_dictionary_set_value(*dict, 
							 [NSDataXPCAddsDataArrayKey cStringUsingEncoding:NSUTF8StringEncoding]
							 ,data);
	xpc_dictionary_set_int64(*dict,
							 [NSDataXPCAddsDataLengthKey cStringUsingEncoding:NSUTF8StringEncoding],
							 [self length]);
	xpc_release(data);
}
@end
