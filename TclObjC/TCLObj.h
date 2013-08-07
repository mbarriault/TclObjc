//
//  TCLObj.h
//  TclObjC
//
//  Created by Michael Barriault on 8/4/2013.
//
//

#import <Foundation/Foundation.h>
#import <Tcl/tcl.h>

@interface TCLObj : NSObject
+(instancetype) obj;
+(instancetype) objWithCObj:(Tcl_Obj*)obj;
-(instancetype) initWithCObj:(Tcl_Obj*)obj;
@property (readonly) Tcl_Obj* obj;
@property (readwrite) int intValue;
@property (readwrite) double doubleValue;
@property (readwrite) NSString* stringValue;
@end
