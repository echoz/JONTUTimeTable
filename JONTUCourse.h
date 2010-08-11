//
//  NTUCourse.h
//  NTUAuth
//
//  Created by Jeremy Foo on 8/4/10.
//  Copyright 2010 ORNYX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JONTUCourse : NSObject <NSCoding> {
	NSString *name;
	NSUInteger au;
	NSString *type;
	NSString *su;
	NSString *gepre;
	NSString *index;
	NSString *status;
	NSUInteger choice;
	
	NSArray *classes;
}

@property (readonly) NSString *name;
@property (readonly) NSUInteger au;
@property (readonly) NSString *type;
@property (readonly) NSString *su;
@property (readonly) NSString *gepre;
@property (readonly) NSString *index;
@property (readonly) NSString *status;
@property (readonly) NSUInteger choice;
@property (nonatomic, retain) NSArray *classes;

-(id)initWithName:(NSString *)coursename academicUnits:(NSUInteger) acadunit courseType:(NSString *)coursetype suOption:(NSString *)suopt gePreType:(NSString *)gepretype indexNumber:(NSString *)indexNumber registrationStatus:(NSString *)regstat choice:(NSUInteger) coursechoice;
@end
