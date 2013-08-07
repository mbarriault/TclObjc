//
//  TestLib.m
//  TclObjC
//
//  Created by Michael Barriault on 8/4/2013.
//
//

#import "TCLInterp.h"
#import "TCLObj.h"

@interface Foo : NSObject
-(int) bar:(NSString*)val;
@end

@implementation Foo

-(int) bar:(NSString*)val {
    TCLObj* obj = [TCLObj obj];
    obj.stringValue = val;
    [TCLInterp sharedInterp].objResult = obj;
    return TCL_OK;
}

-(int) huh {
    [TCLInterp sharedInterp].objResult = [TCLObj objWithCObj:Tcl_NewStringObj("HUH?!", -1)];
    return TCL_ERROR;
}

-(int) twoargs:(NSString*)arg1 and:(NSString*)arg2 {
    NSLog(@"%@ %@", arg1, arg2);
    return TCL_OK;
}

-(int) blankargs:(NSString*)arg1 :(NSString*)arg2 {
    NSLog(@"BLANK %@ %@", arg1, arg2);
    return TCL_OK;
}

@end

int Testlib_Init(Tcl_Interp* interp) {
    [TCLInterp setSharedCInterp:interp];
    [[TCLInterp sharedInterp] providePackage:@"TestLib"];
    Foo* foo = [[Foo alloc] init];
    CFBridgingRetain(foo);
//    [[TCLInterp sharedInterp] createCommand:@"foobar" selector:@selector(bar:) withObject:foo];
    [[TCLInterp sharedInterp] createObject:[Foo class]];
    return TCL_OK;
}