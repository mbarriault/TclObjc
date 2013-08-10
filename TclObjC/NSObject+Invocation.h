//
//  NSObject+Invocation.h
//  TclObjC
//
//  Created by Michael Barriault on 8/4/2013.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (Invocation)
-(void*) performSelector:(SEL)aSelector withContext:(id)context;
@end
