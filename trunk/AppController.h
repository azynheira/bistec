//
//  AppController.h
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

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>

#define	OPEN	1
#define	QUIT	2


@interface AppController : NSObject {
	QTMovie * theMovie;
	NSTimer * TCUpdateTimer;
	
	short action;
	
	BOOL saved;
	NSString * path;
	
	NSMutableArray * textList;
	NSMutableArray * TCInList;
	NSMutableArray * TCOutList;
	
	IBOutlet NSPanel * unsavedPanel;
	IBOutlet QTMovieView * movieCanvas;
	IBOutlet NSTextField * TCLabel;
	IBOutlet NSTextView * captionView;
	IBOutlet NSTextField * TCInLabel;
	IBOutlet NSTextField * TCOutLabel;
	IBOutlet NSTextView * subtitleField;
	IBOutlet NSTableView * subtitleList;
	IBOutlet NSPanel * timecodeShiftingPanel;
	IBOutlet NSTextField * allHoursField;
	IBOutlet NSTextField * allMinutesField;
	IBOutlet NSTextField * allSecondsField;
	IBOutlet NSTextField * allMillisecondsField;
	IBOutlet NSButton * allOk;
}

- (IBAction)loadMovie:(id)sender;
- (IBAction)addSubtitle:(id)sender;
- (IBAction)setTCIn:(id)sender;
- (IBAction)setTCOut:(id)sender;
- (IBAction)removeSubtitle:(id)sender;
- (IBAction)saveFile:(id)sender;
- (IBAction)openSRT:(id)sender;
- (IBAction)doTimecodeShifting:(id)sender;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
- (void)updateTC:(id)sender;
- (NSString *)TCForMilliseconds:(NSInteger)milliseconds;
- (void)saveSrtTo:(char*)aPath;

// delegate methods
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView;
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;
- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex;
- (void)textDidChange:(NSNotification *)aNotification;

@end
