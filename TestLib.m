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

@interface Bar : NSObject
@property (readwrite) int x;
@end;

@implementation Foo

-(int) bar:(NSString*)val {
    TCLObj* obj = [TCLObj obj];
    obj.stringValue = val;
    [TCLInterp sharedInterp].objResult = obj;
    return TCL_OK;
}

-(int) huh {
    [TCLInterp sharedInterp].objResult = [TCLObj objWithCObj:Tcl_NewStringObj("HUH?!", -1)];
    return TCL_OK;
}

-(int) other {
    return 37;
}

-(int) twoargs:(NSString*)arg1 and:(NSString*)arg2 {
    NSLog(@"%@ %@", arg1, arg2);
    return TCL_OK;
}

-(int) blankargs:(NSString*)arg1 :(NSString*)arg2 {
    NSLog(@"BLANK %@ %@", arg1, arg2);
    return TCL_OK;
}

-(Foo*) getself {
    return self;
}

-(void) somefunc {
    // does nothing
}

-(NSString*) astring {
    return @"HOHO";
}

-(NSValue*) avalue {
    NSValue* val = [NSValue valueWithSize:NSMakeSize(1., 1.)];
    return val;
}

-(int) up:(int)x {
    return x+1;
}

-(float) sinf:(float)x {
    return sinf(x);
}

-(double) sin:(double)x {
    return sin(x);
}

-(NSString*) dobar:(Bar*)bar {
    return [NSString stringWithFormat:@"String with %d", bar.x];
}

-(Bar*) newbar {
    return [[Bar alloc] init];
}

@end

@implementation Bar
-(NSString*) description {
    return [@(self.x) description];
}
@end

int Testlib_Init(Tcl_Interp* interp) {
    [TCLInterp setSharedCInterp:interp];
    [[TCLInterp sharedInterp] providePackage:@"TestLib"];
    Foo* foo = [[Foo alloc] init];
    CFBridgingRetain(foo);
    [[TCLInterp sharedInterp] createCommand:@"foobar" selector:@selector(bar:) withObject:foo];
    [[TCLInterp sharedInterp] createObject:[Foo class] name:@"foo"];
    [[TCLInterp sharedInterp] createObject:[Bar class] name:@"bar"];
    return TCL_OK;
}
