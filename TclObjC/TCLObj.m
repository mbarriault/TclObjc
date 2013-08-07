//
//  TCLObj.m
//  TclObjC
//
//  Created by Michael Barriault on 8/4/2013.
//
//

#import "TCLObj.h"
#import "TCLInterp.h"

@implementation TCLObj

+(instancetype) obj {
    return [[TCLObj alloc] init];
}

+(instancetype) objWithCObj:(Tcl_Obj *)obj {
    return [[TCLObj alloc] initWithCObj:obj];
}

-(instancetype) init {
    return [self initWithCObj:Tcl_NewObj()];
}

-(instancetype) initWithCObj:(Tcl_Obj *)obj {
    if ( (self = [super init]) ) {
        _obj = obj;
    }
    return self;
}

-(int) intValue {
    int val = 0;
    if ( Tcl_GetIntFromObj([TCLInterp sharedInterp].interp, self.obj, &val) != TCL_OK )
        [[TCLInterp sharedInterp] error:@"Value not an integer."];
    return val;
}

-(void) setIntValue:(int)intValue {
    Tcl_SetIntObj(self.obj, intValue);
}

-(double) doubleValue {
    double val = 0;
    if ( Tcl_GetDoubleFromObj([TCLInterp sharedInterp].interp, self.obj, &val) != TCL_OK )
        [[TCLInterp sharedInterp] error:@"Value not a double."];
    return val;
}

-(void) setDoubleValue:(double)doubleValue {
    Tcl_SetDoubleObj(self.obj, doubleValue);
}

-(NSString*) stringValue {
    int len;
    const char* cstr = Tcl_GetStringFromObj(self.obj, &len);
    return [NSString stringWithUTF8String:cstr];
}

-(void) setStringValue:(NSString *)stringValue {
    Tcl_SetStringObj(self.obj, stringValue.UTF8String, (int)stringValue.length);
}

@end
