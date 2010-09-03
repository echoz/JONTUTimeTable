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
	NSArray *semesterNames = [NSArray arrayWithObjects:@"SEMESTER 1", @"SEMESTER 2", @"SPECIAL TERM I", @"SPECIAL TERM II", nil];
	
	NSString *toYearString = [NSString stringWithFormat:@"%i", year+1];
	NSString *page = [[NSString alloc] initWithData:[self sendSyncXHRToURL:[NSURL URLWithString:[YEAR_URL stringByReplacingOccurrencesOfString:@"(year)" withString:[NSString stringWithFormat:@"%i-%@", year, [toYearString stringByMatching:@"([0-9][0-9])$" capture:1]]]] 
																postValues:nil 
																 withToken:NO] 
										   encoding:NSUTF8StringEncoding];
	
	page = [[page removeHTMLEntities] stringByReplacingOccurrencesOfRegex:@"[\\n|\\t|\\r]" withString:@""];
	
	NSArray *rows = [page captureComponentsMatchedByRegex:REGEX_TABLE_ROW];
	
	NSLog(@"%@",rows);
	
	[page release];
	
	NSMutableDictionary *currentSemester = nil;
	NSString *currentSemesterName = nil;
	int previousFoundIndex = -1;
	
	for (int i=0;i<[rows count];i++) {
		
		NSArray *rowcontents = [[rows objectAtIndex:i] captureComponentsMatchedByRegex:REGEX_TABLE_CELL];
		
			
		NSString *testSemName = [self matchedPrefixString:[[[rowcontents objectAtIndex:1] stringByReplacingOccurrencesOfRegex:REGEX_STRIP_HTMLTAGS withString:@""] uppercaseString]
											inArray:semesterNames];
		
		// inspect for semester and setup
		if (testSemName) {
			if ((currentSemester) && (currentSemesterName)) {
				[sems setObject:currentSemester forKey:currentSemesterName];
			}				
			
			[currentSemesterName release], currentSemesterName = nil;
			currentSemesterName = testSemName;
			
			[currentSemester release], currentSemester = nil;
			currentSemester = [NSMutableDictionary dictionary];
			[currentSemester setObject:[[rowcontents objectAtIndex:2] stringByReplacingOccurrencesOfRegex:REGEX_STRIP_HTMLTAGS withString:@""] forKey:@"SEM_START"];
			[currentSemester setObject:[[rowcontents objectAtIndex:3] stringByReplacingOccurrencesOfRegex:REGEX_STRIP_HTMLTAGS withString:@""] forKey:@"SEM_END"];
			[currentSemester setObject:[[rowcontents objectAtIndex:4] stringByReplacingOccurrencesOfRegex:REGEX_STRIP_HTMLTAGS withString:@""] forKey:@"SEM_DURATION"];
			
			previousFoundIndex = i;
			
			NSLog(@"Found %@", testSemName);
			
		} 
		
		if ((previousFoundIndex - i) == 0) {
			// we already have a semster so we must parse data
			[currentSemester setObject:[[rowcontents objectAtIndex:2] stringByReplacingOccurrencesOfRegex:REGEX_STRIP_HTMLTAGS withString:@""] 
								forKey:[NSString stringWithFormat:@"%@_START", [[[rowcontents objectAtIndex:1] stringByReplacingOccurrencesOfRegex:REGEX_STRIP_HTMLTAGS withString:@""] uppercaseString]]];
			[currentSemester setObject:[[rowcontents objectAtIndex:3] stringByReplacingOccurrencesOfRegex:REGEX_STRIP_HTMLTAGS withString:@""] 
								forKey:[NSString stringWithFormat:@"%@_END", [[[rowcontents objectAtIndex:1] stringByReplacingOccurrencesOfRegex:REGEX_STRIP_HTMLTAGS withString:@""] uppercaseString]]];
			[currentSemester setObject:[[rowcontents objectAtIndex:4] stringByReplacingOccurrencesOfRegex:REGEX_STRIP_HTMLTAGS withString:@""] 
								forKey:[NSString stringWithFormat:@"%@_DURATION", [[[rowcontents objectAtIndex:1] stringByReplacingOccurrencesOfRegex:REGEX_STRIP_HTMLTAGS withString:@""] uppercaseString]]];
			
			previousFoundIndex = i;
			
			NSLog(@"Found %@", [[rowcontents objectAtIndex:1] stringByReplacingOccurrencesOfRegex:REGEX_STRIP_HTMLTAGS withString:@""]);
			
		}
				

	}
	
	if ((currentSemester) && (currentSemesterName)) {
		[sems setObject:currentSemester forKey:currentSemesterName];
	}
		
	
	[semesters release];
	semesters = [sems retain];
	
}

-(void)dealloc {
	[semesters release], semesters = nil;
	[super dealloc];
}

@end
