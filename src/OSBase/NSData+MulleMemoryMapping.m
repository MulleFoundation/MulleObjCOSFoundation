//
//  NSData+MulleMemoryMapping.m
//  MulleObjCOSFoundation
//
//  Copyright (c) 2020 Nat! - Mulle kybernetiK.
//  All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  Neither the name of Mulle kybernetiK nor the names of its contributors
//  may be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
#import "NSData+MulleMemoryMapping.h"

// other files in this library

// other libraries of MulleObjCBaseFoundation
#import "NSString+OSBase.h"

// std-c and dependencies
#import "import-private.h"


// only for NSData so far, not for NSMutableData
@interface _MulleObjCMemoryMappedData : NSData
{
   struct mulle_mmap   _info;
}
@end


@implementation _MulleObjCMemoryMappedData

- (id) initWithContentsOfMappedFile:(NSString *) path
{
   _mulle_mmap_init( &self->_info, mulle_mmap_read);
   if( _mulle_mmap_map_file( &self->_info,
                            [path fileSystemRepresentation]))
   {
      [self release];
      return( nil);
   }

   return( self);
}


- (void) finalize
{
   _mulle_mmap_done( &self->_info);
   [super finalize];
}


- (void *) bytes
{
   return( _mulle_mmap_get_bytes( &self->_info));
}


- (NSUInteger) length
{
   return( (NSUInteger) _mulle_mmap_get_length( &self->_info));
}


- (struct mulle_data) mulleCData
{
   struct mulle_data   data;

   data = mulle_data_make( _mulle_mmap_get_bytes( &self->_info),
                           _mulle_mmap_get_length( &self->_info));
   return( data);
}

@end


@interface NSData( Future) < MulleObjCFuture>

- (instancetype) initWithContentsOfFile:(NSString *) path;

@end


@implementation NSData( MulleMemoryMapping)

- (instancetype) initWithContentsOfMappedFile:(NSString *) path;
{
   return( [[_MulleObjCMemoryMappedData alloc] initWithContentsOfMappedFile:path]);
}


+ (instancetype) dataWithContentsOfMappedFile:(NSString *) path
{
   return( [[[self alloc] initWithContentsOfMappedFile:path] autorelease]);
}

@end


@implementation NSMutableData( MulleMemoryMapping)

- (instancetype) initWithContentsOfMappedFile:(NSString *) path;
{
   return( [self initWithContentsOfFile:path]);
}

@end
