/*
 * This file is part of Bit Slicer.
 *
 * Bit Slicer is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 
 * Bit Slicer is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 
 * You should have received a copy of the GNU General Public License
 * along with Bit Slicer.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * Created by Mayur Pawashe on 10/13/10.
 * Copyright 2010 zgcoder. All rights reserved.
 */

#import "ZGTimer.h"

@implementation ZGTimer

- (id)initWithTimeInterval:(NSTimeInterval)timeInterval
					target:(id)theTarget
				  selector:(SEL)theSelector
{
	self = [super init];
	
	if (self)
	{
		target = theTarget;
		selector = theSelector;
		timer = [[NSTimer scheduledTimerWithTimeInterval:timeInterval
												  target:self
												selector:@selector(invoke)
												userInfo:nil
												 repeats:YES] retain];
	}
	
	return self;
}

- (void)invoke
{
	[target performSelector:selector
				 withObject:timer];
}

- (void)invalidate
{
	[timer invalidate];
	[timer release];
	timer = nil;
}

@end
