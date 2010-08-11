//
//  NTUSemester.m
//  NTUAuth
//
//  Created by Jeremy Foo on 8/5/10.
//  Copyright 2010 ORNYX. All rights reserved.
//

#import "NTUSemester.h"
#import "NTUClass.h"
#import "NTUCourse.h"
#import "RegexKitLite.h"
#import "NSString+htmlentitiesaddition.h"

#define XHR_URL @"https://wish.wis.ntu.edu.sg/pls/webexe/aus_stars_check.check_subject_web2"
#define REGEX_TABLE @"<TABLE  border>\\s<TR>\\s<TD valign=\"BOTTOM\"><B>Course</B></TD>\\s<TD valign=\"BOTTOM\"><B>AU</B></TD>\\s<TD valign=\"BOTTOM\"><B>Course<BR>Type</B></TD>\\s<TD valign=\"BOTTOM\"><B>S/U Grade option</B></TD>\\s<TD valign=\"BOTTOM\"><B>General<BR>Prescribed<BR>Type</B></TD>\\s<TD valign=\"BOTTOM\"><B>Index<BR>Number</B></TD>\\s<TD valign=\"BOTTOM\"><B>Status</B></TD>\\s<TD valign=\"BOTTOM\"><B>Choice</B></TD>\\s<TD valign=\"BOTTOM\"><B>Class<BR>Type</B></TD>\\s<TD valign=\"BOTTOM\"><B>Group</B></TD>\\s<TD valign=\"BOTTOM\"><B>Day</B></TD>\\s<TD valign=\"BOTTOM\"><B>Time</B></TD>\\s<TD valign=\"BOTTOM\"><B>Venue</B></TD>\\s<TD valign=\"BOTTOM\"><B>Remark</B></TD>\\s</TR>([\\s\\S]*)</TABLE>"

#define REGEX_TABLE_ROW @"<TR><TD>([ ,/\\w-]*)</TD><TD>([ ,/\\w-]*)</TD><TD>([ ,/\\w-]*)</TD><TD>([ ,/\\w-]*)</TD><TD>([ ,/\\w-]*)</TD><TD>([ ,/\\w-]*)</TD><TD>([ ,/\\w-]*)</TD><TD>([ ,/\\w-]*)</TD><TD>([ ,/\\w-]*)</TD><TD>([ ,/\\w-]*)</TD><TD>([ ,/\\w-]*)</TD><TD>([ ,/\\w-]*)</TD><TD>([ ,/\\w-]*)</TD><TD>([ ,/\\w-]*)</TD></TR>"
@implementation NTUSemester

@synthesize name, year, semester, courses;

-(id)initWithName:(NSString *)semname year:(NSUInteger)semyear semester:(NSString *)semsem {
	if (self = [super init]) {
		name = [semname retain];
		year = semyear;
		semester = [semsem retain];
	}
	return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super init]) {
		name = [[aDecoder decodeObjectForKey:@"name"] retain];
		year = [aDecoder decodeIntForKey:@"year"];
		semester = [[aDecoder decodeObjectForKey:@"semester"] retain];
		courses = [[aDecoder decodeObjectForKey:@"courses"] retain];
	}
	return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:name forKey:@"name"];
	[aCoder encodeObject:semester forKey:@"semester"];
	[aCoder encodeObject:courses forKey:@"courses"];
	[aCoder encodeInt:year forKey:@"year"];
}

-(void)parse {
	if ([self auth]) {

		NSMutableDictionary *postvalues = [NSMutableDictionary dictionary];
		[postvalues setValue:@"" forKey:@"p2"];
		[postvalues setValue:[NSString stringWithFormat:@"%i",self.year] forKey:@"acad"];
		[postvalues setValue:self.semester forKey:@"semester"];
		
		NSString *html = [[NSString alloc] initWithData:[self sendAsyncXHRToURL:XHR_URL PostValues:postvalues] encoding:NSUTF8StringEncoding];
		NSArray *timetablelines = [[[[html stringByMatching:REGEX_TABLE capture:1] stringByReplacingOccurrencesOfString:@"\n" withString:@""] removeHTMLEntities] componentsMatchedByRegex:REGEX_TABLE_ROW];
		[html release];
		
		NSArray *timetableitems;
		NSMutableArray *t_courses = [NSMutableArray array];
		NSMutableArray *t_classes = nil;
		
		for (int i=0;i<[timetablelines count];i++) {
			timetableitems = [[timetablelines objectAtIndex:i] captureComponentsMatchedByRegex:REGEX_TABLE_ROW];
			
			// handle if its a row with course information
			if (![[timetableitems objectAtIndex:1] isEqualToString:@""]) {
				NTUCourse *t_course = [[NTUCourse alloc] initWithName:[timetableitems objectAtIndex:1]
														academicUnits:[[timetableitems objectAtIndex:2] intValue]
														   courseType:[timetableitems objectAtIndex:3]
															 suOption:[timetableitems objectAtIndex:4]
															gePreType:[timetableitems objectAtIndex:5]
														  indexNumber:[timetableitems objectAtIndex:6]
												   registrationStatus:[timetableitems objectAtIndex:7]
															   choice:[[timetableitems objectAtIndex:8] intValue]];
				[t_courses addObject:t_course];
				[t_course release], t_course = nil;
				t_classes = [NSMutableArray array];
			}
			
			// deal with class information
			NTUClass *t_class = [[NTUClass alloc] initWithType:[timetableitems objectAtIndex:9]
													classGroup:[timetableitems objectAtIndex:10]
														 venue:[timetableitems objectAtIndex:13]
														remark:[timetableitems objectAtIndex:14] 
														   day:[timetableitems objectAtIndex:11] 
														  time:[timetableitems objectAtIndex:12]];
			[t_classes addObject:t_class];		
			[t_class release], t_class = nil;	
			
			((NTUCourse *)[t_courses lastObject]).classes = t_classes;
		}
		courses = [t_courses retain];
		
	} else {
		NSLog(@"Could not auth");
	}
}

-(void)dealloc {
	[name release], name = nil;
	[semester release], semester = nil;
	[courses release], courses = nil;
	[super dealloc];
}

@end
