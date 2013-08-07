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
    TCLObj* obj = [[TCLObj alloc] init];
    obj.intValue = 5;
    [[TCLInterp sharedInterp] setObjResult:obj];
    NSLog(@"%@", val);
    return TCL_OK;
}

@end

int Testlib_Init(Tcl_Interp* interp) {
    [TCLInterp setSharedCInterp:interp];
    [[TCLInterp sharedInterp] providePackage:@"TestLib"];
    Foo* foo = [[Foo alloc] init];
    CFBridgingRetain(foo);
    [[TCLInterp sharedInterp] createCommand:@"foobar" selector:@selector(bar:) withObject:foo];
    return TCL_OK;
}