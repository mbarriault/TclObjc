//
//  TCLInterp.h
//  TclObjC
//
//  Created by Michael Barriault on 8/4/2013.
//
//

#import <Foundation/Foundation.h>
#import <Tcl/tcl.h>
#import "TCLObj.h"

#define INTERP_EXISTS if ( [TCLInterp sharedInterp].interp == nil ) { NSLog(@"No interpreter exists."); return TCL_ERROR; }

@interface TCLInterp : NSObject
+(instancetype) sharedInterp;
+(void) setSharedCInterp:(Tcl_Interp*)interp;
-(void) error:(NSString*)error;

-(int) providePackage:(NSString*)package;
-(int) providePackage:(NSString *)package version:(NSString*)version;
-(void) resetResult;
-(void) appendResult:(NSString*)result, ... NS_REQUIRES_NIL_TERMINATION;
-(void) setObjResult:(TCLObj*)obj;
-(void) setObjFromInt:(int)intValue;
-(void) setObjFromDouble:(double)doubleValue;
-(void) setObjFromString:(NSString*)stringValue;
-(void) createCommand:(NSString*)command withObject:(id)object;
-(void) createCommand:(NSString*)command selector:(SEL)sel withObject:(id)object;
-(void) createObject:(Class)class name:(NSString*)name;
-(void) createObject:(Class)class name:(NSString*)name initSelector:(SEL)sel withContext:(id)context;
-(void) createClass:(Class)class;

@property (readwrite) int error;
@property (readonly) Tcl_Interp* interp;
@property (strong) NSMutableDictionary* store;
@end
