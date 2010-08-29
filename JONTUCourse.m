//
//  NTUCourse.m
//  NTUAuth
//
//  Created by Jeremy Foo on 8/4/10.
//  Copyright 2010 ORNYX. All rights reserved.
//

#import "JONTUCourse.h"


@implementation JONTUCourse

@synthesize name, au, type, su, gepre, index, status, choice, classes;

-(id)initWithName:(NSString *)coursename academicUnits:(NSUInteger) acadunit courseType:(NSString *)coursetype suOption:(NSString *)suopt gePreType:(NSString *)gepretype
	  indexNumber:(NSString *)indexNumber registrationStatus:(NSString *)regstat choice:(NSUInteger) coursechoice {
	
	if (self = [super init]) {
		name = [coursename retain];
		au = acadunit;
		type = [coursetype retain];
		su = [suopt retain];
		gepre = [gepretype retain];
		index = [indexNumber retain];
		status = [regstat retain];
		choice = coursechoice;
		classes = [[NSArray array] retain];
	}
	
	return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super init]) {
		name = [[aDecoder decodeObjectForKey:@"name"] retain];
		au = [aDecoder decodeIntForKey:@"acadunit"];
		type = [[aDecoder decodeObjectForKey:@"type"] retain];
		su = [[aDecoder decodeObjectForKey:@"su"] retain];
		gepre = [[aDecoder decodeObjectForKey:@"gepre"] retain];
		index = [[aDecoder decodeObjectForKey:@"index"] retain];
		status = [[aDecoder decodeObjectForKey:@"status"] retain];
		choice = [aDecoder decodeIntForKey:@"choice"];
		classes = [[aDecoder decodeObjectForKey:@"classes"] retain];
	}
	return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:name forKey:@"name"];
	[aCoder encodeObject:type forKey:@"type"];
	[aCoder encodeObject:su forKey:@"su"];
	[aCoder encodeObject:gepre forKey:@"gepre"];
	[aCoder encodeObject:index forKey:@"index"];
	[aCoder encodeObject:status forKey:@"status"];
	[aCoder encodeObject:name forKey:@"name"];
	[aCoder encodeInt:au forKey:@"acadunit"];
	[aCoder encodeInt:choice forKey:@"choice"];

}

-(NSString *)description {
	return [NSString stringWithFormat:@"<NTUCourse: %@ with %i classes>",self.name, [self.classes count]];
}

-(NSUInteger)classesCount {
	return [self.classes count];
}

-(void)dealloc {
	[name release], name = nil;
	[type release], type = nil;
	[su release], su = nil;
	[gepre release], gepre = nil;
	[index release], index = nil;
	[status release], status = nil;
	[classes release], classes = nil;
	[super dealloc];
}

@end
