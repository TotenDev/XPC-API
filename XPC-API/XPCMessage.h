//
// XPCMessage.h — XPC-API
// today is 7/16/12, it is now 5:15 PM
// created by TotenDev
// see LICENSE for details.
//

#import <Foundation/Foundation.h>
#import "XPCAPI.h"

//XPC Response status 
typedef enum {
	kCallBackStatusNoReponseYet = 99,
	kCallBackErrored = 0 ,
	kCallBackSucessWithoutArgs = 1 ,
	kCallBackSucessResponsed = 2 
}kCallBackStatus ;




#pragma mark - XPCMessage
@interface XPCMessage : NSObject <NSCoding>
@property (nonatomic,strong)    NSString * bundleIdentifier ; /*REQUIRED VALUE*/
@property (nonatomic,assign)    SEL method ; /*REQUIRED VALUE*/
@property (nonatomic,strong)    NSMutableArray * args; /*OPTIONAL VALUE*/
// Initializer
+ (id)XPCMessageWithMethod:(SEL)selector bundleIdentifier:(NSString *)bundle andOrderedArguments:(NSArray *)__args ;
@end




#pragma mark - XPCCallbackResponse
@interface XPCCallbackResponse : NSObject <NSCoding>
@property (nonatomic,assign)	kCallBackStatus callBackStatus ;
@property (nonatomic,strong)	NSMutableArray * callBackArgs;
// Initializers
+ (id)XPCCallbackWithStatus:(kCallBackStatus)responseStatus withArgs:(NSArray *)args ;
+ (id)XPCSuccessCallbackFromMethodResponse:(id)returnValue ; //return success response with function return value
//Helper 
+ (NSString *)stringFromCallBackType:(kCallBackStatus)callBack ;
@end
