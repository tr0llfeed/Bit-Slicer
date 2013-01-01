/*
 * Created by Mayur Pawashe on 12/31/12.
 *
 * Copyright (c) 2012 zgcoder
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * Neither the name of the project's author nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "ZGProcessList.h"
#import "ZGRunningProcess.h"
#import <sys/types.h>
#import <sys/sysctl.h>

@interface ZGProcessList ()
{
	NSMutableArray *_runningProcesses;
}

@end

@implementation ZGProcessList

#pragma mark Setter & Accessors

// http://stackoverflow.com/questions/477204/key-value-observing-a-to-many-relationship-in-cocoa
// KVO with a one-to-many relationship

- (NSArray *)runningProcesses
{
	return [_runningProcesses copy];
}

- (void)setRunningProcesses:(NSArray *)runningProcesses
{
	if (![_runningProcesses isEqualToArray:runningProcesses])
	{
		_runningProcesses = [runningProcesses mutableCopy];
	}
}

#pragma mark KVO Optimizations

// Implementing methods that should optimize our KVO model according to apple's documentation

- (NSUInteger)countOfRunningProcesses
{
	return _runningProcesses.count;
}

- (id)objectInRunningProcessesAtIndex:(NSUInteger)index
{
	return [_runningProcesses objectAtIndex:index];
}

- (NSArray *)runningProcessesAtIndexes:(NSIndexSet *)indexes
{
	return [_runningProcesses objectsAtIndexes:indexes];
}

#pragma mark Birth

+ (id)sharedProcessList
{
	static dispatch_once_t predicate;
	static id sharedProcessList = nil;
	
	dispatch_once(&predicate, ^{
		sharedProcessList = [[[self class] alloc] init];
	});
	return sharedProcessList;
}

- (id)init
{
	self = [super init];
	if (self)
	{
		_runningProcesses = [[NSMutableArray alloc] init];
		[self receiveList:nil];
		NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(receiveList:) userInfo:nil repeats:YES];
		[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
	}
	return self;
}

#pragma mark Process Retrieval

// http://stackoverflow.com/questions/7729245/can-i-use-sysctl-to-retrieve-a-process-list-with-the-user
// http://www.nightproductions.net/dsprocessesinfo_m.html
- (void)receiveList:(NSTimer *)timer
{
    struct kinfo_proc *processList = NULL;
    size_t length = 0;
	
    static const int name[] = { CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0 };
	
    // Call sysctl with a NULL buffer to get proper length
    if (sysctl((int *)name, (sizeof(name) / sizeof(*name)) - 1, NULL, &length, NULL, 0) != 0) return;
	
    // Allocate buffer
    processList = malloc(length);
    if (!processList) return;
	
    // Get the actual process list
    if (sysctl((int *)name, (sizeof(name) / sizeof(*name)) - 1, processList, &length, NULL, 0) != 0)
	{
		free(processList);
		return;
	}
	
	NSMutableArray *newRunningProcesses = [[NSMutableArray alloc] init];
	
    int processCount = length / sizeof(struct kinfo_proc);
    for (int processIndex = 0; processIndex < processCount; processIndex++)
	{
        uid_t uid = processList[processIndex].kp_eproc.e_ucred.cr_uid;
		pid_t processID = processList[processIndex].kp_proc.p_pid;
		
		// I want user processes and I don't want zombies!
		// Also don't get a process if it's still being created by fork() or if the pid is -1
		if (processID != -1 && uid == getuid() && !(processList[processIndex].kp_proc.p_stat & SZOMB) && !(processList[processIndex].kp_proc.p_stat & SIDL))
		{	
			ZGRunningProcess *runningProcess = [[ZGRunningProcess alloc] init];
			runningProcess.name = @(processList[processIndex].kp_proc.p_comm);
			runningProcess.processIdentifier = processID;
			[newRunningProcesses addObject:runningProcess];
		}
    }
	
	NSMutableArray *currentProcesses = [self mutableArrayValueForKey:@"runningProcesses"];
	
	if (![currentProcesses isEqualToArray:newRunningProcesses])
	{
		// Remove old processes
		NSMutableArray *processesToRemove = [[NSMutableArray alloc] init];
		
		for (id process in currentProcesses)
		{
			if (![newRunningProcesses containsObject:process])
			{
				[processesToRemove addObject:process];
			}
		}
		
		[currentProcesses removeObjectsInArray:processesToRemove];
		
		// Add new processes
		NSMutableArray *processesToAdd = [[NSMutableArray alloc] init];
		
		for (id process in newRunningProcesses)
		{
			if (![currentProcesses containsObject:process])
			{
				[processesToAdd addObject:process];
			}
		}
		
		[currentProcesses addObjectsFromArray:processesToAdd];
	}
	
	free(processList);
}

@end
