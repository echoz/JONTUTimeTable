//
//  NTUSemester.h
//  NTUAuth
//
//  Created by Jeremy Foo on 8/5/10.
//  Copyright 2010 ORNYX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTUAuth.h"

@interface NTUSemester : NTUAuth <NSCoding> {
	NSString *name;
	NSUInteger year;
	NSString *semester;
	NSArray *courses;
}

@property (readonly) NSString *name;
@property (readonly) NSUInteger year;
@property (readonly) NSString *semester;
@property (readonly) NSArray *courses;
-(id)initWithName:(NSString *)semname year:(NSUInteger)semyear semester:(NSString *)semester;
-(void)parse;
@end
