//
//  JONTUSemesterDates.m
//  JONTUTimeTable
//
//  Created by Jeremy Foo on 9/1/10.
//  Copyright 2010 ORNYX. All rights reserved.
//

#import "JONTUSemesterDates.h"
#import "NSString+htmlentitiesaddition.h"
#import "RegexKitLite.h"

#define YEAR_URL @"http://www.ntu.edu.sg/Services/Academic/undergraduates/Academic%20Calendar/Pages/(year).aspx"
#define REGEX_TABLE_ROW @"<tr\\b[^>]*>(.*?)</tr>"
#define REGEX_TABLE_CELL @"<td\\b[^>]*>(.*?)</td>"
#define REGEX_STRIP_HTMLTAGS @"<(.|\\n)*?>"

@implementation JONTUSemesterDates
@synthesize year, semesters;

-(id)initWithYear:(NSUInteger)yr {
	if (self = [super init]) {
		year = yr;
		semesters = nil;
	}
	return self;
}

-(NSString *)matchedPrefixString:(NSString *)needle inArray:(NSArray *)haystack {
	for (NSString *toMatch in haystack) {
		if ([needle hasPrefix:toMatch])
			return toMatch;
	}
	return nil;
}

-(void)parse {
	
	NSMutableDictionary *sems = [NSMutableDictionary dictionary];
	NSArray *semesterNames = [NSArray arrayWithObjects:@"SEMESTER 1", @"SEMESTER 2", @"SPECIAL TERM II", @"SPECIAL TERM I", nil];
	
	NSString *toYearString = [NSString stringWithFormat:@"%i", year+1];
	NSString *page = [[NSString alloc] initWithData:[self sendSyncXHRToURL:[NSURL URLWithString:[YEAR_URL stringByReplacingOccurrencesOfString:@"(year)" withString:[NSString stringWithFormat:@"%i-%@", year, [toYearString stringByMatching:@"([0-9][0-9])$" capture:1]]]] 
																postValues:nil 
																 withToken:NO] 
										   encoding:NSASCIIStringEncoding];
	
	page = [[page removeHTMLEntities] stringByReplacingOccurrencesOfRegex:@"[\\n|\\t|\\r]" withString:@""];
	
	NSArray *rows = [page componentsMatchedByRegex:REGEX_TABLE_ROW];
	
	[page release];
	
	NSMutableDictionary *currentSemester = nil;
	NSString *currentSemesterName = nil;
	NSArray *rowcontents;
	NSString *testSemName;
	
	for (int i=0;i<[rows count];i++) {
		
		rowcontents = [[rows objectAtIndex:i] componentsMatchedByRegex:REGEX_TABLE_CELL];
		testSemName = [self matchedPrefixString:[[[rowcontents objectAtIndex:0] stringByReplacingOccurrencesOfRegex:REGEX_STRIP_HTMLTAGS withString:@""] uppercaseString]
											inArray:semesterNames];
		
		if ([[[[rowcontents objectAtIndex:0] stringByReplacingOccurrencesOfRegex:REGEX_STRIP_HTMLTAGS withString:@""] uppercaseString] hasPrefix:@"EVENTS"]) {
			NSLog(@"%@", currentSemesterName);
			[sems setObject:currentSemester forKey:currentSemesterName];
			i = [rows count];
			
		} else {
			// inspect for semester and setup
			if (testSemName) {
				if ((currentSemester) && (currentSemesterName)) {
					[sems setObject:currentSemester forKey:currentSemesterName];
				}				
				
				[currentSemesterName release], currentSemesterName = nil;
				currentSemesterName = testSemName;
				
				[currentSemester release], currentSemester = nil;
				currentSemester = [[NSMutableDictionary dictionary] retain];
				[currentSemester setObject:[[rowcontents objectAtIndex:1] stringByReplacingOccurrencesOfRegex:REGEX_STRIP_HTMLTAGS withString:@""] forKey:@"SEM_START"];
				[currentSemester setObject:[[rowcontents objectAtIndex:2] stringByReplacingOccurrencesOfRegex:REGEX_STRIP_HTMLTAGS withString:@""] forKey:@"SEM_END"];
				[currentSemester setObject:[[rowcontents objectAtIndex:3] stringByReplacingOccurrencesOfRegex:REGEX_STRIP_HTMLTAGS withString:@""] forKey:@"SEM_DURATION"];
				
				NSLog(@"Found %@", testSemName);
				
				rowcontents = [[rows objectAtIndex:++i] componentsMatchedByRegex:REGEX_TABLE_CELL];
				
			} 
			
			if ((currentSemester) && ([rowcontents count] == 4)) {
				// we already have a semster so we must parse data
				[currentSemester setObject:[[rowcontents objectAtIndex:1] stringByReplacingOccurrencesOfRegex:REGEX_STRIP_HTMLTAGS withString:@""] 
									forKey:[NSString stringWithFormat:@"%@_START", [[[rowcontents objectAtIndex:0] stringByReplacingOccurrencesOfRegex:REGEX_STRIP_HTMLTAGS withString:@""] uppercaseString]]];
				[currentSemester setObject:[[rowcontents objectAtIndex:2] stringByReplacingOccurrencesOfRegex:REGEX_STRIP_HTMLTAGS withString:@""] 
									forKey:[NSString stringWithFormat:@"%@_END", [[[rowcontents objectAtIndex:0] stringByReplacingOccurrencesOfRegex:REGEX_STRIP_HTMLTAGS withString:@""] uppercaseString]]];
				[currentSemester setObject:[[rowcontents objectAtIndex:3] stringByReplacingOccurrencesOfRegex:REGEX_STRIP_HTMLTAGS withString:@""] 
									forKey:[NSString stringWithFormat:@"%@_DURATION", [[[rowcontents objectAtIndex:0] stringByReplacingOccurrencesOfRegex:REGEX_STRIP_HTMLTAGS withString:@""] uppercaseString]]];
				
				NSLog(@"Found %@", [[rowcontents objectAtIndex:0] stringByReplacingOccurrencesOfRegex:REGEX_STRIP_HTMLTAGS withString:@""]);
			}
		}

	}
			
	
	[semesters release], semesters = nil;
	semesters = [sems retain];
	
}

-(void)dealloc {
	[semesters release], semesters = nil;
	[super dealloc];
}

@end
