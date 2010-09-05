//
//  NTUClass.m
//  NTUAuth
//
//  Created by Jeremy Foo on 8/4/10.
//  Copyright 2010 ORNYX. All rights reserved.
//

#import "JONTUClass.h"
#import "RegexKitLite.h"

#define REGEX_TIME_SUBUNIT @"([0-9]{2})([0-9]{2})-([0-9]{2})([0-9]{2})"
#define REGEX_TIME_STRING @"([0-9]{4})-([0-9]{4})"
#define REGEX_RECURRENCE_THROUGH @"Wk([0-9]+)-([0-9]+)"

@implementation JONTUClass
@synthesize type, group, venue, remark;

-(id)initWithType:(NSString *)classtype classGroup:(NSString *)classgroup venue:(NSString *)classvenue remark:(NSString *)classremark day:(NSString *)classday time:(NSString *)classtime {
	if (self = [super init]) {
		type = [classtype retain];
		group = [classgroup retain];
		venue = [classvenue retain];
		remark = [classremark retain];
		__day = [classday retain];
		__time = [classtime retain];
	}
	return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super init]) {
		type = [[aDecoder decodeObjectForKey:@"type"] retain];
		group = [[aDecoder decodeObjectForKey:@"group"] retain];
		venue = [[aDecoder decodeObjectForKey:@"venue"] retain];
		remark = [[aDecoder decodeObjectForKey:@"remark"] retain];
		__day = [[aDecoder decodeObjectForKey:@"day"] retain];
		__time = [[aDecoder decodeObjectForKey:@"time"] retain];
	}
	return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:type forKey:@"type"];
	[aCoder encodeObject:group forKey:@"group"];
	[aCoder encodeObject:venue forKey:@"venue"];
	[aCoder encodeObject:remark forKey:@"remark"];
	[aCoder encodeObject:__day forKey:@"day"];
	[aCoder encodeObject:__time forKey:@"time"];
}

-(NSArray *)activeWeeks {
	NSArray *weeks = [remark captureComponentsMatchedByRegex:REGEX_RECURRENCE_THROUGH];
	if ([weeks count] == 0) {
		weeks = [[remark stringByReplacingOccurrencesOfString:@"Wk" withString:@""] componentsSeparatedByString:@","];
	} else {
		NSMutableArray *tempweeks = [NSMutableArray array];
		for (int i=[[weeks objectAtIndex:1] intValue];i<[[weeks objectAtIndex:2] intValue]+1;i++) {
			[tempweeks addObject:[NSNumber numberWithInt:i]];
		}
		weeks = tempweeks;
	}
	
	return weeks;
}

-(NSString *)fromTimeString {
	return [__time stringByMatching:REGEX_TIME_STRING capture:1];
}

-(NSString *)toTimeString {
	return [__time stringByMatching:REGEX_TIME_STRING capture:2];	
}

-(NSDateComponents *) fromTimeUsingCalendar:(NSCalendar *)currentCal {
	NSDateComponents *comp = [[NSDateComponents alloc] init];
	[comp setHour:[[__time stringByMatching:REGEX_TIME_SUBUNIT capture:1] integerValue]];
	[comp setMinute:[[__time stringByMatching:REGEX_TIME_SUBUNIT capture:2] integerValue]];
	
	[comp setWeekday:([self dayIndex] + [currentCal firstWeekday])];
	
	return [comp autorelease];
}
-(NSDateComponents *) toTimeUsingCalendar:(NSCalendar *)currentCal {
	NSDateComponents *comp = [[NSDateComponents alloc] init];
	[comp setHour:[[__time stringByMatching:REGEX_TIME_SUBUNIT capture:3] integerValue]];
	[comp setMinute:[[__time stringByMatching:REGEX_TIME_SUBUNIT capture:4] integerValue]];

	[comp setWeekday:([self dayIndex] + [currentCal firstWeekday])];
	
	return [comp autorelease];
}

-(NSUInteger)dayIndex {
	NSArray *weekdays = [NSArray arrayWithObjects:@"M",@"T",@"W",@"TH",@"F",nil];
	return [weekdays indexOfObject:__day];
}

-(void)dealloc {
	[type release], type = nil;
	[group release], group = nil;
	[venue release], venue = nil;
	[remark release], remark = nil;
	[__day release], __day = nil;
	[__time release], __time = nil;
	[super dealloc];
}

@end
