//
//  AppController.m
//  Bistec
//
//  Created by Joan Dolz Sánchez on 08/10/08.
//  Copyright 2008 Joan Dolz. All rights reserved.
//

/***************************************************************************
 
 This file is part of Bistec.
 
 Bistec is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 Bistec is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with Bistec.  If not, see <http://www.gnu.org/licenses/>.
 
 ***************************************************************************/

#import "AppController.h"
#include <math.h>
#include <stdlib.h>

@implementation AppController

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	TCUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateTC:) userInfo:nil repeats:YES];
	[TCUpdateTimer fire];
	textList = [[NSMutableArray alloc] init];
	TCInList = [[NSMutableArray alloc] init];
	TCOutList = [[NSMutableArray alloc] init];
	[textList retain];
	[TCInList retain];
	[TCOutList retain];
	saved = YES;
	action = 0;
}

-(IBAction) loadMovie:(id)sender
{
	NSOpenPanel * thePanel = [NSOpenPanel openPanel];
	[thePanel runModal];
	if([thePanel filename])
	{
		theMovie = [QTMovie movieWithFile:[thePanel filename] error:nil];
		[movieCanvas setMovie:theMovie];
	}
}

-(void) updateTC:(id)sender
{
	if(theMovie)
	{
		[TCLabel setStringValue:[self TCForMilliseconds:[theMovie currentTime].timeValue/0.6]];
		[TCLabel display];
	}
}

-(IBAction) addSubtitle:(id)sender
{
	[textList addObject:[NSString stringWithString:@""]];
	[TCInList addObject:[NSNumber numberWithInt:[theMovie currentTime].timeValue/0.6]]; 
	[TCOutList addObject:[NSNumber numberWithInt:[theMovie currentTime].timeValue/0.6+1000]];
	[subtitleList reloadData];
	[subtitleList selectRowIndexes:[NSIndexSet indexSetWithIndex:[textList count]-1] byExtendingSelection:NO];
	[subtitleField setString:[textList objectAtIndex:[textList count]-1]];
	[TCInLabel setStringValue:[self TCForMilliseconds:[[TCInList objectAtIndex:[textList count]-1] intValue]]];
	[TCOutLabel setStringValue:[self TCForMilliseconds:[[TCOutList objectAtIndex:[textList count]-1] intValue]]];
	[[subtitleField window] makeFirstResponder:subtitleField];
	saved = NO;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	//printf("%u,%u,%u\n",[textList count],[TCInList count],[TCOutList count]);
	return [textList count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{	
	//NSLog([textList objectAtIndex:rowIndex]);
	if([[textList objectAtIndex:rowIndex] isNotEqualTo:[NSString stringWithString:@""]])
		return [textList objectAtIndex:rowIndex];
	return [NSString stringWithString:@"--empty caption--"];
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
	if([subtitleList selectedRow]!=rowIndex)
	{
		[subtitleField setString:[textList objectAtIndex:rowIndex]];
		[TCInLabel setStringValue:[self TCForMilliseconds:[[TCInList objectAtIndex:rowIndex] intValue]]];
		[TCOutLabel setStringValue:[self TCForMilliseconds:[[TCOutList objectAtIndex:rowIndex] intValue]]];
		[[subtitleField window] makeFirstResponder:subtitleField];
		return YES;
	}
	return NO;
}

- (NSString *)TCForMilliseconds:(NSInteger)milliseconds
{
	int seconds = 0,minutes=0,hours=0;
	
	while(milliseconds>=1000)
	{
		milliseconds -= 1000;
		seconds++;
	}
	
	while(seconds>=60)
	{
		seconds -= 60;
		minutes++;
	}
	
	while(minutes>=60)
	{
		minutes -= 60;
		hours++;
	}
	
	NSString * secondss, * minutess, * hourss, * millisecondss;
	
	if(seconds<10)
		secondss = [NSString stringWithFormat:@"0%u",seconds];
	else
		secondss = [NSString stringWithFormat:@"%u",seconds];
	
	if(minutes<10)
		minutess = [NSString stringWithFormat:@"0%u",minutes];
	else
		minutess = [NSString stringWithFormat:@"%u",minutes];
	
	if(hours<10)
		hourss = [NSString stringWithFormat:@"0%u",hours];
	else
		hourss = [NSString stringWithFormat:@"%u",hours];
	
	if(milliseconds<100)
		millisecondss = [NSString stringWithFormat:@"0%u",milliseconds];
	else
		millisecondss = [NSString stringWithFormat:@"%u",milliseconds];
	
	if(milliseconds<10)
		millisecondss = [NSString stringWithFormat:@"00%u",milliseconds];
	
	NSString * timeCode = [NSString stringWithFormat:@"%@:%@:%@,%@",hourss,minutess,secondss,millisecondss];
	return timeCode;
}

- (void)textDidChange:(NSNotification *)aNotification
{
	//printf("%u\n",[subtitleList selectedRow]);
	NSString * temp = [NSString stringWithString:[subtitleField string]];
	[textList replaceObjectAtIndex:[subtitleList selectedRow] withObject:[NSString stringWithString:[subtitleField string]]];
	[subtitleList reloadData];
	[subtitleField setString:temp];
	saved = NO;
}

- (IBAction)setTCIn:(id)sender
{
	[TCInList replaceObjectAtIndex:[subtitleList selectedRow] withObject:[NSNumber numberWithInt:[theMovie currentTime].timeValue/0.6]];
	[TCInLabel setStringValue:[self TCForMilliseconds:[[TCInList objectAtIndex:[subtitleList selectedRow]] intValue]]];
	[TCOutLabel setStringValue:[self TCForMilliseconds:[[TCOutList objectAtIndex:[subtitleList selectedRow]] intValue]]];
	saved = NO;
}

- (IBAction)setTCOut:(id)sender
{
	[TCOutList replaceObjectAtIndex:[subtitleList selectedRow] withObject:[NSNumber numberWithInt:[theMovie currentTime].timeValue/0.6]];
	[TCInLabel setStringValue:[self TCForMilliseconds:[[TCInList objectAtIndex:[subtitleList selectedRow]] intValue]]];
	[TCOutLabel setStringValue:[self TCForMilliseconds:[[TCOutList objectAtIndex:[subtitleList selectedRow]] intValue]]];
	saved = NO;
}

- (IBAction)removeSubtitle:(id)sender
{
	[subtitleField setString:@""];
	[textList removeObjectAtIndex:[subtitleList selectedRow]];
	[TCInList removeObjectAtIndex:[subtitleList selectedRow]];
	[TCOutList removeObjectAtIndex:[subtitleList selectedRow]];
	[TCInLabel setStringValue:@"00:00:00:00"];
	[TCOutLabel setStringValue:@"00:00:00:00"];
	saved = NO;
}

- (IBAction)saveFile:(id)sender
{
	NSString * savePath;
	
	if(!saved)
	{
		if(!path)
		{
			NSSavePanel * panel = [NSSavePanel savePanel];
			[panel runModal];
			
			if([panel filename])
				savePath = [NSString stringWithString:[panel filename]];
		}
		else
			savePath = [NSString stringWithString:path];
		
		if(savePath)
		{
			[self saveSrtTo:[savePath cStringUsingEncoding:NSUTF8StringEncoding]];
			if(!saved)
			{
				NSLog(@"Error occurred while saving!");
				exit;
			} // HANDLE FILE SAVING ERROR HERE
			
			switch (action) {
				case OPEN:
					[self openSRT:self];
					break;
				case QUIT:
					[[NSApplication sharedApplication] terminate:self];
					break;
				default:
					break;
			}
		}
	}
}

- (void)saveSrtTo:(char*)aPath
{
	FILE * fp = fopen(aPath, "w");
	//printf("Saving to %s\n",aPath);
	
	if(fp)
	{
		int i;
		NSString * sub = [NSString stringWithString:@""];
		for(i=0;i<[textList count];i++)
		{
			sub = [NSString stringWithFormat:@"%u\n%s --> %s\n%s\n\n\n",i+1,[[self TCForMilliseconds:[[TCInList objectAtIndex:i] intValue]] cStringUsingEncoding:NSUTF8StringEncoding],[[self TCForMilliseconds:[[TCOutList objectAtIndex:i] intValue]] cStringUsingEncoding:NSUTF8StringEncoding],[[textList objectAtIndex:i] cStringUsingEncoding:NSUTF8StringEncoding]];
			fwrite([sub cStringUsingEncoding:NSUTF8StringEncoding], [sub length], 1, fp);
		}
		fclose(fp);
		saved = YES;
		//NSLog(@"Saved.");
	}
	else
	{
		perror("Could not save");
		saved = NO;
	}
}

- (IBAction)openSRT:(id)sender
{
	if(!saved)
	{
		action = OPEN;
		[unsavedPanel makeKeyAndOrderFront:self];
		exit;
	}
	
	NSOpenPanel * panel = [NSOpenPanel openPanel];
	[panel runModal];
	int endOfFile=0, milliseconds=0, seconds=0, minutes=0, hours=0;
	char * buffer = (char *)malloc(sizeof(char)*3);
	
	textList = [[NSMutableArray alloc] init];
	TCInList = [[NSMutableArray alloc] init];
	TCOutList = [[NSMutableArray alloc] init];
	
	if([panel filename])
	{
		FILE * fp = fopen([[panel filename] cStringUsingEncoding:NSUTF8StringEncoding],"r");
		if(fp)
		{
			NSString * text = [NSString stringWithString:@""];
			char a[1]="0",b[1]="0",*tcin=(char *)malloc(sizeof(char)*13),*tcout=(char *)malloc(sizeof(char)*13);
			NSString * smilliseconds = [NSString stringWithString:@""], * sseconds = [NSString stringWithString:@""], * sminutes = [NSString stringWithString:@""], * shours = [NSString stringWithString:@""];
			fseek(fp,0,SEEK_END);
			endOfFile = ftell(fp);
			rewind(fp);
			while(ftell(fp)<endOfFile)
			{
				free(tcin);
				free(tcout); // And stay DOWN!
				tcin=(char *)malloc(sizeof(char)*13);
				tcout=(char *)malloc(sizeof(char)*13);
				while(b[0]!='\n')
					fread(b, 1, 1, fp);
				fread(tcin,12,1,fp);
				fseek(fp,5,SEEK_CUR);
				fread(tcout,12,1,fp);
				fseek(fp,1,SEEK_CUR);
				text = @"";
				while(1)
				{
					fread(b,1,1,fp);
					if(b[0]=='\n' && a[0]=='\n')
						break;
					text = [text stringByAppendingString:[NSString stringWithFormat:@"%c",b[0]]];
					a[0]=b[0];
				}
				fseek(fp,3,SEEK_CUR);
				
				//printf("Got TCs: %s | %s\n",tcin,tcout);
				//NSLog(text);
				
				// Get TCs from tcin and tcout (char *)
				
				buffer[0] = tcin[0];
				buffer[1] = tcin[1];
				buffer[2] = '\0';
				hours = atoi(buffer);
				
				buffer[0] = tcin[3];
				buffer[1] = tcin[4];
				buffer[2] = '\0';
				minutes = atoi(buffer);
				
				buffer[0] = tcin[6];
				buffer[1] = tcin[7];
				buffer[2] = '\0';
				seconds = atoi(buffer);
				
				buffer[0] = tcin[9];
				buffer[1] = tcin[10];
				buffer[2] = tcin[11];
				milliseconds = atoi(buffer);
				
				if(hours<10)
					shours = [NSString stringWithFormat:@"0%u",hours];
				else
					shours = [NSString stringWithFormat:@"%u",hours];
				
				if(minutes<10)
					sminutes = [NSString stringWithFormat:@"0%u",minutes];
				else
					sminutes = [NSString stringWithFormat:@"%u",minutes];
				
				if(seconds<10)
					sseconds = [NSString stringWithFormat:@"0%u",seconds];
				else
					sseconds = [NSString stringWithFormat:@"%u",seconds];
				
				smilliseconds = [NSString stringWithFormat:@"%u",milliseconds];
				
				if(milliseconds<100)
					smilliseconds = [NSString stringWithFormat:@"0%u",milliseconds];
				if(milliseconds<10)
					smilliseconds = [NSString stringWithFormat:@"00%u",milliseconds];
				
				//NSLog(smilliseconds);
				
				[TCInList addObject:[NSString stringWithFormat:@"%@:%@:%@,%@",shours,sminutes,sseconds,smilliseconds]];
				
				buffer[0] = tcout[0];
				buffer[1] = tcout[1];
				buffer[2] = '\0';
				hours = atoi(buffer);
				
				buffer[0] = tcout[3];
				buffer[1] = tcout[4];
				buffer[2] = '\0';
				minutes = atoi(buffer);
				
				buffer[0] = tcout[6];
				buffer[1] = tcout[7];
				buffer[2] = '\0';
				seconds = atoi(buffer);
				
				buffer[0] = tcout[9];
				buffer[1] = tcout[10];
				buffer[2] = tcout[11];
				milliseconds = atoi(buffer);
				
				if(hours<10)
					shours = [NSString stringWithFormat:@"0%u",hours];
				else
					shours = [NSString stringWithFormat:@"%u",hours];
				
				if(minutes<10)
					sminutes = [NSString stringWithFormat:@"0%u",minutes];
				else
					sminutes = [NSString stringWithFormat:@"%u",minutes];
				
				if(seconds<10)
					sseconds = [NSString stringWithFormat:@"0%u",seconds];
				else
					sseconds = [NSString stringWithFormat:@"%u",seconds];
				
				smilliseconds = [NSString stringWithFormat:@"%u",milliseconds];
				
				if(milliseconds<100)
					smilliseconds = [NSString stringWithFormat:@"0%u",milliseconds];
				if(milliseconds<10)
					smilliseconds = [NSString stringWithFormat:@"00%u",milliseconds];
				
				//NSLog(smilliseconds);
				
				[TCOutList addObject:[NSString stringWithFormat:@"%@:%@:%@,%@",shours,sminutes,sseconds,smilliseconds]];
				
				
				// Get subtitle caption from text (NSString *)
				
				[textList addObject:[NSString stringWithString:text]];
				
				[subtitleList reloadData];
			}
		}else
			perror("Could not open");
	}
}

@end
