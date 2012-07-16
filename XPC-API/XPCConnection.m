//
// XPCConnection.m — XPC-API
// today is 7/16/12, it is now 5:15 PM
// created by TotenDev
// see LICENSE for details.
//

#include <xpc/xpc.h>
#import "XPCAPI.h"
#import "XPCConnection.h"
#import "NSData+XPCAdds.h"

//Private Interface
@interface XPCConnection (/*private*/)
#pragma mark - Internal - XPC Client Helper 
//called by "decodeMessage:withClientInstance:"
+ (void)sendServerReplyWithOriginalObject:(xpc_object_t)event withCallBack:(XPCCallbackResponse *)response ;
@end



//Main Implementation
@implementation XPCConnection
#pragma mark - Handlers
//Handler
void (^xpcEventHandler)(xpc_object_t) = ^(xpc_object_t object) {
	//Error handler
	if (object == XPC_ERROR_CONNECTION_INTERRUPTED) XPCLog(@"XPC_ERROR_CONNECTION_INTERRUPTED");
	else if (object == XPC_ERROR_CONNECTION_INVALID) XPCLog(@"XPC_ERROR_CONNECTION_INVALID");
	else if (object == XPC_ERROR_KEY_DESCRIPTION) XPCLog(@"XPC_ERROR_KEY_DESCRIPTION"); 
	else if (object == XPC_ERROR_TERMINATION_IMMINENT) XPCLog(@"XPC_ERROR_TERMINATION_IMMINENT");   
	else XPCLog(@"UNKNOWN EVENT TYPE RECIVED");
};
//Reply message
void (^ replyMessage)(xpc_object_t) = ^(xpc_object_t reply) {
	XPCLog(@"Reply recived");
	if (xpc_get_type(reply) == XPC_TYPE_DICTIONARY) {
		XPCLog(@"Message by reply: %s",xpc_dictionary_get_string(reply, "str"));
	} else {
		if (xpc_get_type(reply) == XPC_TYPE_ERROR) {
			NSString * errString = [NSString stringWithCString:xpc_dictionary_get_string(reply, XPC_ERROR_KEY_DESCRIPTION) encoding:NSUTF8StringEncoding];
			XPCLog(@"Error reply recived: %@",errString);
		} else {
			XPCLog(@"reply recived but couldn't decode message!");
		}
	}
};

#pragma mark - Initializers
+ (void)callXPCWithMessage:(XPCMessage *)msg { [XPCConnection callXPCWithMessage:msg notifingWhenArrives:^(BOOL sucess) {}]; }
+ (void)callXPCWithMessage:(XPCMessage *)msg notifingWhenArrives:(void (^)(BOOL sucess))arrived {
	[XPCConnection callXPCWithMessage:msg notifingWhenArrives:^(BOOL sucess) {arrived (sucess);}
                 withCallBackResponse:^(XPCCallbackResponse *callBack) {
	 XPCLog(@"Internal callback %@ -- %@",callBack.callBackArgs,[XPCCallbackResponse stringFromCallBackType:callBack.callBackStatus]);
	}];
}
//Encode XPCMessage and send it to XPCClient 
//Send call back and notifies when it arrives to XPCClient!
+ (void)callXPCWithMessage:(XPCMessage *)msg notifingWhenArrives:(void (^)(BOOL sucess))arrived withCallBackResponse:(void (^) (XPCCallbackResponse * callBack))callBackBlock {
	//Create connection
	xpc_connection_t con = xpc_connection_create([msg.bundleIdentifier cStringUsingEncoding:NSUTF8StringEncoding], NULL);
	//Set event handler
	xpc_connection_set_event_handler(con,xpcEventHandler);
	//resume even if you want to start
	xpc_connection_resume(con);
	XPCLog(@"Connection name %s",xpc_connection_get_name(con));
	
	//Encode Object
	NSData * ___data = [NSKeyedArchiver archivedDataWithRootObject:msg];
	//Create message Objects
	xpc_object_t dict = xpc_dictionary_create(NULL, NULL, 0);
	[___data encodeIntoXPCDictionary:&dict];
	 
	//Send message with reply and passing a queue that will be waiting for that reply !
	xpc_connection_send_message_with_reply(con, dict, dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^(xpc_object_t object) {
		xpc_type_t type = xpc_get_type(object);
		if (type == XPC_TYPE_DICTIONARY) {
			NSData * dataObj = [NSData decodeDefaultXPCMessage:object];
			XPCCallbackResponse * callBack = [NSKeyedUnarchiver unarchiveObjectWithData:dataObj];
			dispatch_async(dispatch_get_main_queue(), ^{ callBackBlock(callBack); });
		}
		else {
			if (type == XPC_TYPE_ERROR) {
				NSString * errString = [NSString stringWithCString:xpc_dictionary_get_string(object, XPC_ERROR_KEY_DESCRIPTION) encoding:NSUTF8StringEncoding];
				XPCLog(@"Error reply recived: %@",errString);
				XPCCallbackResponse * callBack = [XPCCallbackResponse XPCCallbackWithStatus:kCallBackErrored withArgs:[NSArray arrayWithObject:errString]];
				dispatch_async(dispatch_get_main_queue(), ^{ callBackBlock(callBack); });
			}
			else XPCLog(@"reply recived but couldn't decode message!");
		}
	});
	
	//Send barrier so when message arrives it call our handler
	xpc_connection_send_barrier(con, ^(void) { arrived(YES); });
	//release xpc objects
	xpc_release(con);
	xpc_release(dict);	
}


#pragma mark - XPC Client Helper 
//Decode XPCMessage and AFTER SEND REPLY !!
+ (void)decodeMessage:(xpc_object_t)message withClientInstance:(id)instance {
	//start decoding message
	NSData * data = [NSData decodeDefaultXPCMessage:message];
	XPCMessage * clear_message = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	XPCCallbackResponse * callBack = nil ;

	//Check if have method/target to call
	if (clear_message.method != nil && [instance respondsToSelector:clear_message.method]) {
		//if no args in method !
		if ([clear_message.args count] == 0) {
			XPCLog(@"Calling %@ without arguments...",NSStringFromSelector(clear_message.method));
			//invoke and get return value
			__unsafe_unretained id returnValue = nil ;
			if (![[NSString stringWithCString:[[instance methodSignatureForSelector:clear_message.method]methodReturnType] encoding:NSUTF8StringEncoding] isEqualTo:@"v"]) {
				returnValue = [instance performSelector:clear_message.method];
				XPCLog(@"Method will return an object.");
			}
			else {
				[instance performSelector:clear_message.method];
				XPCLog(@"Method won't return an object.");
			}
			//populate callBack
			callBack = [XPCCallbackResponse XPCSuccessCallbackFromMethodResponse:returnValue];
		}
		//if have some args in method
		else {
			XPCLog(@"Calling '%@' with arguments '%@' ",NSStringFromSelector(clear_message.method),clear_message.args);
			//Invocation
			NSInvocation * leInvocation = [NSInvocation invocationWithMethodSignature:[instance methodSignatureForSelector:clear_message.method]];
			[leInvocation setTarget:instance];
			[leInvocation setSelector:clear_message.method];
			//Populate ARGs
			int sum = 0 ;
			while (sum != [clear_message.args count]) {
				NSObject * object = [clear_message.args objectAtIndex:sum] ;
				// +2 pois o primeiro argumento de um metodo é self(1) e o segundo é o nosso (2) "[self paoCom:ovo];"
				[leInvocation setArgument:&object atIndex:(sum+2)];
				sum++ ;
			}
			//Set returnValue 
			__unsafe_unretained XPCCallbackResponse * returnValue = nil ;
			//Invoke
			[leInvocation invoke];
			//'v' from 'void' !
			if (![[NSString stringWithCString:[[leInvocation methodSignature]methodReturnType] encoding:NSUTF8StringEncoding] isEqualTo:@"v"]) {
				[leInvocation getReturnValue:&returnValue];
			}
			//Populate callBack
			callBack = [XPCCallbackResponse XPCSuccessCallbackFromMethodResponse:returnValue];
		}
		XPCLog(@"Method performed !");
	}
	//
	else callBack = [XPCCallbackResponse XPCCallbackWithStatus:kCallBackErrored withArgs:[NSArray arrayWithObject:@"Method in 'XPCMessage' is nil or instance in client side doesn't responds to this method !"]];

	//Send callBack
	if (callBack != nil) [XPCConnection sendServerReplyWithOriginalObject:message withCallBack:callBack];

}
//Send server Reply
+ (void)sendServerReplyWithOriginalObject:(xpc_object_t)event withCallBack:(XPCCallbackResponse *)response {
	//Create connection to reply
	xpc_connection_t remote = NULL ;
	remote = xpc_dictionary_get_remote_connection(event);
	//create reply dict by original dict
	xpc_object_t replyMessage = xpc_dictionary_create_reply(event);
	//Encode Object
	NSData * ___data = [NSKeyedArchiver archivedDataWithRootObject:response];
	[___data encodeIntoXPCDictionary:&replyMessage];
	//
	xpc_connection_send_message(remote, replyMessage);
	xpc_release(replyMessage);
}
@end