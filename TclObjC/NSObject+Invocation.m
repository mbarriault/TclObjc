//
//  NSObject+Invocation.m
//  TclObjC
//
//  Created by Michael Barriault on 8/4/2013.
//
//

// Adapted from http://excitabyte.wordpress.com/2009/07/07/spawning-threads-using-selectors-with-multiple-parameters/

#import "NSObject+Invocation.h"

@implementation NSObject (Invocation)

-(void) performSelector:(SEL)aSelector withContext:(id)context {
    NSInvocation* invocation;
    if ( [context isKindOfClass:[NSArray class]] ) {
        NSMethodSignature* signature = [self methodSignatureForSelector:aSelector];
        invocation = [NSInvocation invocationWithMethodSignature:signature];
        NSArray* parameterValues = (NSArray*)context;
        NSUInteger parameterCount = parameterValues.count;

        NSUInteger argumentCount = signature.numberOfArguments - 2;
        if ( parameterCount == argumentCount ) {
            invocation.target = self;
            invocation.selector = aSelector;
            NSUInteger i, count = parameterCount;

            for ( i=0; i<count; ++i ) {
                id currentValue = [parameterValues objectAtIndex:i];
                if ( [currentValue isKindOfClass:[NSValue class]] ) {
                    void* bufferForValue;
                    [currentValue getValue:&bufferForValue];
                    [invocation setArgument:bufferForValue atIndex:(i+2)];
                }
                else {
                    [invocation setArgument:&currentValue atIndex:(i+2)];
                }
            }
        }
        [invocation performSelector:@selector(invoke) withObject:nil];
    }
    else {
        [self performSelector:aSelector withObject:context];
    }
}

@end
