//
//  pipe-roundtrip.m
//  MulleObjCOSFoundation
//
//  Copyright (c) 2026 Nat! - Mulle kybernetiK.
//  All rights reserved.
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
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>

#include <stdio.h>


int   main( int argc, const char * argv[])
{
   NSPipe        *pipe;
   NSPipe        *other;
   NSFileHandle  *reader;
   NSFileHandle  *writer;
   NSData        *data;
   NSData        *got;
   int           distinct;
   int           equal;
   int           fdsDiffer;
   int           handles;

   pipe   = [NSPipe pipe];
   reader = [pipe fileHandleForReading];
   writer = [pipe fileHandleForWriting];

   handles   = (reader != nil && writer != nil);
   fdsDiffer = ([pipe _fileDescriptorForReading] != [pipe _fileDescriptorForWriting]);

   data = [@"PIPE_ROUNDTRIP" dataUsingEncoding:NSUTF8StringEncoding];
   [writer writeData:data];
   [writer closeFile];

   got   = [reader readDataToEndOfFile];
   equal = [got isEqualToData:data];

   other    = [NSPipe pipe];
   distinct = (pipe != other);

   mulle_printf( "handles=%d\n", handles ? 1 : 0);
   mulle_printf( "fds-differ=%d\n", fdsDiffer ? 1 : 0);
   mulle_printf( "equal=%d\n", equal ? 1 : 0);
   mulle_printf( "distinct=%d\n", distinct ? 1 : 0);
   return( 0);
}
