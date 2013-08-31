//
//  TCLInterp.m
//  TclObjC
//
//  Created by Michael Barriault on 8/4/2013.
//
//

#import "TCLInterp.h"
#import "NSObject+Invocation.h"
#import "TclObjC.h"

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
    [sharedInterp createObject:[TclObjC class] name:@"objc"];
}

-(instancetype) init {
    if ( (self = [super init]) ) {
        _interp = nil;
        _store = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void) error:(NSString *)error {
    [self resetResult];
    TCLObj* ret = [TCLObj obj];
    ret.stringValue = error;
    [self setObjResult:ret];
    _error = TCL_ERROR;
}

-(int) providePackage:(NSString *)package {
    return [self providePackage:package version:@"1"];
}

-(int) providePackage:(NSString *)package version:(NSString *)version {
    INTERP_EXISTS;
    if ( Tcl_PkgProvide(self.interp, [package cStringUsingEncoding:NSASCIIStringEncoding], [version cStringUsingEncoding:NSASCIIStringEncoding]) == TCL_ERROR )
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
        Tcl_AppendResult(self.interp, [arg cStringUsingEncoding:NSASCIIStringEncoding], NULL);
    va_end(args);
}

-(void) setObjResult:(TCLObj *)obj {
    Tcl_SetObjResult(self.interp, obj.obj);
}

typedef struct {
    void* name;
    void* object;
    SEL sel;
    void* parent;
} ObjCmd;

int RunObjCmd(ClientData data, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[]) {
    id oobj = (__bridge id)(((ObjCmd*)data)->object);
    SEL sel = ((ObjCmd*)data)->sel;
    NSMutableArray* args;
    if ( sel != nil ) {
        args = [NSMutableArray arrayWithCapacity:objc-1];
        for ( int i=1; i<objc; ++i ) {
            [args addObject:[NSString stringWithCString:Tcl_GetStringFromObj(objv[i], NULL) encoding:NSASCIIStringEncoding]];
        }
    }
    else {
        NSMutableString* selString = [NSMutableString string];
        args = [NSMutableArray arrayWithCapacity:objc];
        for ( int i=1; i<objc; ++i ) {
            [selString appendString:[NSString stringWithCString:Tcl_GetStringFromObj(objv[i], NULL) encoding:NSASCIIStringEncoding]];
            ++i;
            if ( i != objc ) {
                [selString appendString:@":"];
                [args addObject:[NSString stringWithCString:Tcl_GetStringFromObj(objv[i], NULL) encoding:NSASCIIStringEncoding]];
            }
        }
        NSLog(@"Selector: %@ | Args %@", selString, args);
        sel = NSSelectorFromString(selString);
    }
    if ( [oobj respondsToSelector:sel] ) {
//        void* res = NULL;
        @try {
            [oobj performSelector:sel withContext:args];
//            if ( [(__bridge id)res isKindOfClass:[NSObject class]] ) {
//
//            }
        }
        @catch (NSException *exception) {
            TCLObj* obj = [TCLObj obj];
            obj.stringValue = [NSString stringWithFormat:@"Selector %@ raised exception %@", NSStringFromSelector(sel), exception.description];
            [[TCLInterp sharedInterp] setObjResult:obj];
            return TCL_ERROR;
        }
        @finally {
            int ret = [TCLInterp sharedInterp].error;
            [TCLInterp sharedInterp].error = TCL_OK;;
            return ret;
        }
    }
    else {
        TCLObj* obj = [TCLObj obj];
        obj.stringValue = [NSString stringWithFormat:@"Object doesn't respond to selector %@", NSStringFromSelector(sel)];
        [[TCLInterp sharedInterp] setObjResult:obj];
        return TCL_ERROR;
    }
}

void DeleteObjCmd(ClientData data) {
    NSString* name = (__bridge NSString*)(((ObjCmd*)data)->name);
    TCLInterp* parent = (__bridge TCLInterp*)(((ObjCmd*)data)->parent);
    if ( parent != nil && [parent.store objectForKey:name] != nil )
        [parent.store removeObjectForKey:name];
    CFBridgingRelease(((ObjCmd*)data)->object);
}

-(void) createCommand:(NSString *)command withObject:(id)object {
    [self createCommand:command selector:nil withObject:object];
}

-(void) createCommand:(NSString*)command selector:(SEL)sel withObject:(id)object {
    ObjCmd* cmd = malloc(sizeof(ObjCmd));
    cmd->object = (void*)CFBridgingRetain(object);
    cmd->sel = sel;
    cmd->parent = (__bridge void*)self;

    Tcl_CreateObjCommand(self.interp, [command cStringUsingEncoding:NSASCIIStringEncoding], RunObjCmd, cmd, DeleteObjCmd);
}

-(void) createObject:(Class)class name:(NSString*)name {
    [self createObject:class name:name initSelector:@selector(init) withContext:nil];
}

-(void) createObject:(Class)class name:(NSString*)name initSelector:(SEL)sel withContext:(id)context {
    id obj = [class alloc];
    if ( [obj respondsToSelector:sel] ) {
        [obj performSelector:sel withContext:context];
        [self.store setObject:obj forKey:name];
        [self createCommand:name withObject:obj];
    }
    else {
        [self error:@"Invalid initializer"];
    }
}

-(void) createClass:(Class)class {
    [self createCommand:NSStringFromClass(class) withObject:class];
}

@end
