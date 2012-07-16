//
// XPCMessage.m — XPC-API
// today is 7/16/12, it is now 5:15 PM
// created by TotenDev
// see LICENSE for details.
//

#import "XPCMessage.h"
#import "XPCAPI.h"

@implementation XPCCallbackResponse
@synthesize callBackArgs, callBackStatus;

#pragma mark - NSCoding Protocol
- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeValueOfObjCType:@encode(int) at:&callBackStatus];
	[coder encodeObject:self.callBackArgs forKey:@"callBackArgs"];
}
- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super init])) {
		[aDecoder decodeValueOfObjCType:@encode(int) at:&callBackStatus];
		self.callBackStatus = callBackStatus ;
		self.callBackArgs = [[NSMutableArray alloc]initWithArray:[aDecoder decodeObjectForKey:@"callBackArgs"]];
		return self;
	}
	return NULL;
}

#pragma mark - Initializer
- (id)init {
    self = [super init];
    if (self) {
		self.callBackStatus = kCallBackStatusNoReponseYet ;
		self.callBackArgs = nil ;
    }
    return self;
}
+ (id)XPCCallbackWithStatus:(kCallBackStatus)responseStatus withArgs:(NSArray *)args {
	XPCCallbackResponse * callBack = [[XPCCallbackResponse alloc]init];
	if (args != nil) { callBack.callBackArgs = [[NSMutableArray alloc]initWithArray:args copyItems:NO]; }
	else { callBack.callBackArgs = [[NSMutableArray alloc]init]; }
	callBack.callBackStatus = responseStatus ;
	return callBack;
}
+ (id)XPCSuccessCallbackFromMethodResponse:(id)returnValue {
	XPCCallbackResponse * callBack = nil ;
	if (returnValue == nil || returnValue == NULL) {
		callBack = [XPCCallbackResponse XPCCallbackWithStatus:kCallBackSucessWithoutArgs withArgs:nil];
	}
	else if ([returnValue isMemberOfClass:[XPCCallbackResponse class]]) {
		NSMutableArray * _array = [[NSMutableArray alloc]initWithArray:((XPCCallbackResponse *)returnValue).callBackArgs copyItems:NO];
		callBack = [XPCCallbackResponse XPCCallbackWithStatus:((XPCCallbackResponse *)returnValue).callBackStatus withArgs:_array];
	}
	return callBack ;
}

#pragma mark - Helpers
+ (NSString *)stringFromCallBackType:(kCallBackStatus)callBack {
	switch (callBack) {
		case kCallBackErrored: { return @"callback errored"; } break;
		case kCallBackStatusNoReponseYet: { return @"callback not responded yet"; } break;
		case kCallBackSucessResponsed: { return @"callback responsed with args"; } break;
		case kCallBackSucessWithoutArgs: { return @"callback responsed without args"; } break;
		default: { return @"unknown callback type ,tell me :)" ; } break;
	}
}
@end



//XPCMessage Main Implementation
@implementation XPCMessage
@synthesize args ,bundleIdentifier ,method;

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeValueOfObjCType:@encode(SEL) at:&method];
	[coder encodeObject:self.args forKey:@"args"];
	[coder encodeObject:self.bundleIdentifier forKey:@"bundleIdentifier"];
}
- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super init])) {
		//Decode method (aka. Selector), it's a required value, so it should be a safe ivar !
		[aDecoder decodeValueOfObjCType:@encode(SEL) at:&method];
		self.method = method ;
		//decode arguments, it should be a safe ivar !
		self.args = [[NSMutableArray alloc]initWithArray:[aDecoder decodeObjectForKey:@"args"]];
		//decode bundleID , it should be a safe ivar !
		self.bundleIdentifier = [[NSString alloc]initWithString:[aDecoder decodeObjectForKey:@"bundleIdentifier"]];
		return self;
	}
	return NULL;
}

#pragma mark - Initialization Methods
- (id)init {
    if ((self = [super init])) {
		self.method = nil ;
		self.args = nil ;
		self.bundleIdentifier = nil ;
    }
    return self;
}
+ (id)XPCMessageWithMethod:(SEL)selector bundleIdentifier:(NSString *)bundle andOrderedArguments:(NSArray *)__args {
	XPCMessage * msg = [[XPCMessage alloc]init];
	//Check if have arguments
	if (__args != nil) { msg.args = [[NSMutableArray alloc]initWithArray:__args copyItems:NO]; }
	else { msg.args = [[NSMutableArray alloc]init]; }	
	//Check for required values
	if (selector && bundle) {
		msg.method = selector ;
		msg.bundleIdentifier = [[NSString alloc]initWithString:bundle];
		return msg;
	}
	return NULL;
}
@end
