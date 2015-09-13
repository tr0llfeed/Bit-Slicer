/*
 * Copyright (c) 2013 Mayur Pawashe
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

#import <Foundation/Foundation.h>
#import "ZGMemoryTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZGRegion : NSObject
{
@public
	// For fast access
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-interface-ivars"
	ZGMemoryAddress _address;
	ZGMemorySize _size;
	void * _Nullable _bytes;
#pragma clang diagnostic pop
}

+ (NSArray *)regionsFromProcessTask:(ZGMemoryMap)processTask;
+ (NSArray *)submapRegionsFromProcessTask:(ZGMemoryMap)processTask;
+ (NSArray *)submapRegionsFromProcessTask:(ZGMemoryMap)processTask region:(ZGRegion *)region;

- (id)initWithAddress:(ZGMemoryAddress)address size:(ZGMemorySize)size protection:(ZGMemoryProtection)protection;
- (id)initWithAddress:(ZGMemoryAddress)address size:(ZGMemorySize)size;

@property (nonatomic, readonly) ZGMemoryAddress address;
@property (nonatomic, readonly) ZGMemorySize size;
@property (nonatomic, readonly) ZGMemoryProtection protection;
@property (nonatomic, readonly, nullable) void *bytes;

@end

NS_ASSUME_NONNULL_END
