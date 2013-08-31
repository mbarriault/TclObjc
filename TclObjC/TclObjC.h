//
//  TclObjC.h
//  TclObjC
//
//  Created by Michael Barriault on 7/24/2013.
//
//

#import <Foundation/Foundation.h>
#import "TCLInterp.h"

@interface TclObjC : NSObject

-(void) create:(NSString *)classString named:(NSString *)name;

@end
