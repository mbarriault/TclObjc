//
//  TCLInterp.m
//  TclObjC
//
//  Created by Michael Barriault on 8/4/2013.
//
//

#import "TCLInterp.h"
#import "NSObject+Invocation.h"

@implementation TCLInterp

+(instancetype) sharedInterp {
    static dispatch_once_t once;
    static TCLInterp* sharedInterp;
    dispatch_once(&once, ^{
        sharedInterp = [[self alloc] init];
    });
    return sharedInterp;
}

+(void) setSharedCInterp:(Tcl_Interp *)interp {
    TCLInterp* sharedInterp = [self sharedInterp];
    sharedInterp->_interp = interp;
}

-(instancetype) init {
    if ( (self = [super init]) ) {
        _interp = nil;
        _objects = [NSArray array];
    }
    return self;
}

-(TCLObj*) objectAtIndexedSubscript:(NSUInteger)idx {
    id obj = self.objects[idx];
    if ( [obj isKindOfClass:[TCLObj class]] ) {
        return obj;
    }
    else {
        NSLog(@"Error, non-Tcl object found in interpreter");
        return nil;
    }
}

-(void) error:(NSString *)error {
    [self resetResult];
    [self appendResult:error, nil];
    _error = TCL_ERROR;
}

-(int) providePackage:(NSString *)package {
    return [self providePackage:package version:@"1"];
}

-(int) providePackage:(NSString *)package version:(NSString *)version {
    INTERP_EXISTS;
    if ( Tcl_PkgProvide(self.interp, package.UTF8String, version.UTF8String) == TCL_ERROR )
        return TCL_ERROR;
    else
        return TCL_OK;
}

-(void) resetResult {
    Tcl_ResetResult(self.interp);
}

-(void) appendResult:(NSString *)result, ... {
    va_list args;
    va_start(args, result);
    for ( NSString* arg = result; arg != nil; va_arg(args, NSString*) )
        Tcl_AppendResult(self.interp, arg.UTF8String);
    va_end(args);
}

-(void) setObjResult:(TCLObj *)obj {
    Tcl_SetObjResult(self.interp, obj.obj);
}

typedef struct {
    void* object;
    SEL sel;
} ObjCmd;

int RunObjCmd(ClientData data, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[]) {
    id oobj = (__bridge id)(((ObjCmd*)data)->object);
    SEL sel = ((ObjCmd*)data)->sel;
    NSMutableArray* args = [NSMutableArray arrayWithCapacity:objc-1];
    for ( int i=1; i<objc; ++i ) {
        [args addObject:[NSString stringWithCString:Tcl_GetStringFromObj(objv[i], NULL) encoding:NSASCIIStringEncoding]];
    }
    if ( [oobj respondsToSelector:sel] ) {
        @try {
            [oobj performSelector:sel withContext:args];
        }
        @catch (NSException *exception) {
            return TCL_ERROR;
        }
        @finally {
            return TCL_OK;
        }
    }
    else
        return TCL_ERROR;
}

void DeleteObjCmd(ClientData data) {
    CFBridgingRelease(((ObjCmd*)data)->object);
}

-(void) createCommand:(NSString*)command selector:(SEL)sel withObject:(id)object {
    ObjCmd* cmd = malloc(sizeof(ObjCmd));
    cmd->object = (void*)CFBridgingRetain(object);
    cmd->sel = sel;

    Tcl_CreateObjCommand(self.interp, command.UTF8String, RunObjCmd, cmd, DeleteObjCmd);
}

@end
