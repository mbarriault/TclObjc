//
//  TclObjC.m
//  TclObjC
//
//  Created by Michael Barriault on 7/24/2013.
//
//

#import "TclObjC.h"

@implementation TclObjC

-(void) create:(NSString *)classString named:(NSString *)name {
    Class class = NSClassFromString(classString);
    NSLog(@"Creating %@ %@", classString, name);
    [[TCLInterp sharedInterp] createObject:class name:name];
}

@end
