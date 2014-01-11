//
// Copyright (c) Zach Wily
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without modification, 
// are permitted provided that the following conditions are met:
// 
// - Redistributions of source code must retain the above copyright notice, this 
//     list of conditions and the following disclaimer.
// 
// - Redistributions in binary form must reproduce the above copyright notice, this
//     list of conditions and the following disclaimer in the documentation and/or 
//     other materials provided with the distribution.
// 
// - Neither the name of Zach Wily nor the names of its contributors may be used to 
//     endorse or promote products derived from this software without specific prior 
//     written permission.
// 
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR 
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON 
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "ZWGalleryAlbum.h"
#import "ZWGalleryItem.h"
#import "ZWMutableURLRequest.h"

#import <SystemConfiguration/SystemConfiguration.h>

#define BUFSIZE 1024

@implementation ZWGalleryAlbum

#pragma mark -

- (id)initWithTitle:(NSString*)newTitle name:(NSString*)newName gallery:(ZWGallery*)newGallery {
    return [self initWithTitle:newTitle name:newName summary:nil nestedIn:nil gallery:newGallery];
}

+ (ZWGalleryAlbum*)albumWithTitle:(NSString*)newTitle name:(NSString*)newName gallery:(ZWGallery*)newGallery {
    return [[ZWGalleryAlbum alloc] initWithTitle:newTitle name:newName gallery:newGallery];
}

- (id)initWithTitle:(NSString*)newTitle name:(NSString*)newName summary:(NSString*)newSummary nestedIn:(ZWGalleryAlbum*)newParent gallery:(ZWGallery*)newGallery
{
    title = newTitle;
    name = newName;
    gallery = newGallery;
    summary = newSummary;
    parent = newParent;
    items = [NSMutableArray array];
    
    return self;
}

- (ZWGalleryAlbum*)albumWithTitle:(NSString*)newTitle name:(NSString*)newName summary:(NSString*)newSummary nestedIn:(ZWGalleryAlbum*)newParent gallery:(ZWGallery*)newGallery
{
    return [[ZWGalleryAlbum alloc] initWithTitle:newTitle name:newName summary:newSummary nestedIn:parent gallery:newGallery];
}

//- (void)dealloc
//{
//    [title release];
//    [name release];
//    [summary release];
//    [gallery release];
//    [parent release];
//    [children release];
//    [items release];
//    
//    [super dealloc];
//}

#pragma mark NSComparison

- (BOOL)isEqual:(id)otherAlbum 
{
    return ([gallery isEqual:[otherAlbum gallery]] && [name isEqual:[otherAlbum name]]);
}

#pragma mark Accessors

- (id)delegate {
    return delegate;
}

- (void)setDelegate:(id)newDelegate {
    delegate = newDelegate;
}

- (NSString*)title {
    return title;
}

- (void)setTitle:(NSString*)newTitle
{
    title = newTitle;
}

- (NSString*)name 
{
    return name;
}

- (void)setName:(NSString*)newName
{
    name = newName;
}

- (NSString*)summary
{
    return summary;
}

- (void)setSummary:(NSString*)newSummary
{
    summary = newSummary;
}

- (ZWGallery*)gallery
{
    return gallery;
}

- (void)setGallery:(ZWGallery*)newGallery
{
   gallery = newGallery;
}

- (void)setParent:(ZWGalleryAlbum*)newParent {
    parent = newParent;
}

- (ZWGalleryAlbum*)parent {
    return parent;
}

- (void)addChild:(ZWGalleryAlbum*)child {
    if (children == nil) {
        children = [NSMutableArray array];
    }
    [children addObject:child];
}

- (NSArray*)children {
    return children;
}

- (void)setCanAddItem:(BOOL)newCanAddItem {
    canAddItem = newCanAddItem;
}

- (BOOL)canAddItem {
    return canAddItem;
}

#pragma mark -

- (BOOL)canAddItemToAlbumOrSub {
    if (canAddItem)
        return TRUE;
    if (children == nil) 
        return FALSE;
    
    NSEnumerator *enumerator = [children objectEnumerator];
    id album;
    while (album = [enumerator nextObject]) {
        if ([album canAddItemToAlbumOrSub]) 
            return TRUE;
    }
    return FALSE;
}

- (void)setCanAddSubAlbum:(BOOL)newCanAddSubAlbum {
    canAddSubAlbum = newCanAddSubAlbum;
}

- (BOOL)canAddSubAlbum {
    return canAddSubAlbum;
}

- (BOOL)canAddSubToAlbumOrSub
{
    if (canAddSubAlbum)
        return TRUE;
    if (children == nil)
        return FALSE;
    NSEnumerator *enumerator = [children objectEnumerator];
    id album;
    while (album = [enumerator nextObject]) {
        if ([album canAddSubToAlbumOrSub]) 
            return TRUE;
    }
    return FALSE;
}

- (int)depth {
    int d = 0;
    ZWGalleryAlbum* cur_parent = parent;
    while (cur_parent) {
        cur_parent = [cur_parent parent];
        d++;
    }
    return d;
}

- (void)cancelOperation
{
    cancelled = YES;
}

- (ZWGalleryRemoteStatusCode)addItemSynchronously:(ZWGalleryItem *)item 
{
    cancelled = NO;
    
    /*
    ZWMutableURLRequest *theRequest = [ZWMutableURLRequest requestWithURL:[gallery fullURL]
                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                          timeoutInterval:60.0];
    [theRequest setValue:@"iPhotoToGallery" forHTTPHeaderField:@"User-Agent"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setEncoding:[self sniffedEncoding]];
    [theRequest setVariation:ZSURLMultipartVariation];
    
    if ([self isGalleryV2]) 
        [theRequest addString:@"remote:GalleryRemote" forName:@"g2_controller"];
    
    [theRequest addString:@"add-item" forName:[
    */
    
    CFHTTPMessageRef messageRef = CFHTTPMessageCreateRequest(kCFAllocatorDefault, CFSTR("POST"), (__bridge CFURLRef)[gallery fullURL], kCFHTTPVersion1_1);
    
    /*
	 * gf: 2/27/2008: The initial login to a gallery (ZWGallery doLogin) uses NSURLRequest. Since this
	 * connection uses CFHTTPMessage (in order to monitor progress; see below), and since CFHTTPMessage
	 * (apparently) doesn't handle user@pass in URLs automagically, we may need to add authentication
	 * credentials. We have to pull them out of the URL (if they're there).
	 *
	 * Note the warning in the CF Network Programming Guide: "Do not apply credentials to the HTTP request
	 * before receiving a server challenge. The server may have changed since the last time you authenticated
	 * and you could create a security risk." Unfortunately, doing this right would require a more elaborate
	 * reworking of the upload loop (below) than I have time or understanding to create.
	 */
	NSURL *fullURL = [gallery fullURL];
	NSString *user = [fullURL user];
	NSString *password = [fullURL password];
	NSLog(@"addItemSynchronously: user=%@, password=%@, url=%@", user, password, fullURL);
    NSLog(@"addItemSynchronously: item.caption=%@, item.description=%@, item.filename=%@, item.imageType=%@", [item caption], [item description], [item filename], [item imageType]);
    
    
    
	if (user != nil) {
		NSLog(@"addItemSynchronously: adding basic authentication");
		Boolean result = CFHTTPMessageAddAuthentication(messageRef,		// request
														nil,			// authenticationFailureResponse
														(__bridge CFStringRef)user,
														(__bridge CFStringRef)password,
														kCFHTTPAuthenticationSchemeBasic,
														FALSE);			// forProxy
		if (result) {
			NSLog(@"addItemSynchronously: added authentication");
		} else {
			NSLog(@"addItemSynchronously: failed to add authentication!");
		}
	}
    
    NSString *boundary = @"--------iPhotoToGallery012nklfad9s0an3flakn3lkghkdshlafk3ln2lghroqyoi-----";
    // the actual boundary lines can to start with an extra 2 hyphens, so we'll make a string to hold that too
    NSString *boundaryNL = [[@"--" stringByAppendingString:boundary] stringByAppendingString:@"\r\n"];
    NSData *boundaryData = [NSData dataWithData:[boundaryNL dataUsingEncoding:NSASCIIStringEncoding]];
    
    CFHTTPMessageSetHeaderFieldValue(messageRef, CFSTR("Content-Type"), (__bridge CFStringRef)[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary]);
    CFHTTPMessageSetHeaderFieldValue(messageRef, CFSTR("User-Agent"), CFSTR("iPhotoToGallery 2014.01"));
    CFHTTPMessageSetHeaderFieldValue(messageRef, CFSTR("Connection"), CFSTR("close"));
    
    // don't forget the cookies!
    NSHTTPCookieStorage *cookieStore = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSDictionary *cookiesInfo = [NSHTTPCookie requestHeaderFieldsWithCookies:[cookieStore cookiesForURL:[gallery fullURL]]];
    CFHTTPMessageSetHeaderFieldValue(messageRef, CFSTR("Cookie"), (__bridge CFStringRef)[cookiesInfo objectForKey:@"Cookie"]);
    
    NSMutableData *requestData = [NSMutableData data];
	
	if ([gallery isGalleryV2]) {
		[requestData appendData:boundaryData];
		[requestData appendData:[@"Content-Disposition: form-data; name=\"g2_controller\"\r\n\r\nremote:GalleryRemote\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
	}
    
    // command
    [requestData appendData:boundaryData];
	if ([gallery isGalleryV2])
		[requestData appendData:[@"Content-Disposition: form-data; name=\"g2_form[cmd]\"\r\n\r\nadd-item\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
	else
	    [requestData appendData:[@"Content-Disposition: form-data; name=\"cmd\"\r\n\r\nadd-item\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    // protocol_version
    [requestData appendData:boundaryData];
	if ([gallery isGalleryV2])
		[requestData appendData:[@"Content-Disposition: form-data; name=\"g2_form[protocol_version]\"\r\n\r\n2.1\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
	else
		[requestData appendData:[@"Content-Disposition: form-data; name=\"protocol_version\"\r\n\r\n2.1\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    // album name
    [requestData appendData:boundaryData];
	if ([gallery isGalleryV2])
		[requestData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"g2_form[set_albumName]\"\r\n\r\n%@\r\n", name] dataUsingEncoding:[gallery sniffedEncoding]]];
	else
		[requestData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"set_albumName\"\r\n\r\n%@\r\n", name] dataUsingEncoding:[gallery sniffedEncoding]]];
	// caption
    if ([item caption]) {
        [requestData appendData:boundaryData];
		if ([gallery isGalleryV2])
			[requestData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"g2_form[caption]\"\r\n\r\n%@\r\n", [item caption]] dataUsingEncoding:[gallery sniffedEncoding]]];
		else
			[requestData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"caption\"\r\n\r\n%@\r\n", [item caption]] dataUsingEncoding:[gallery sniffedEncoding]]];
    }
	// the description
    if ([item description] && ([gallery majorVersion] >= 2) && ([gallery minorVersion] >= 3)) {
        [requestData appendData:boundaryData];
		if ([gallery isGalleryV2])
			[requestData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"g2_form[extrafield.Description]\"\r\n\r\n%@\r\n", [item description]] dataUsingEncoding:[gallery sniffedEncoding]]];
		else
			[requestData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"extrafield.Description\"\r\n\r\n%@\r\n", [item description]] dataUsingEncoding:[gallery sniffedEncoding]]];
    }
    // the file
    [requestData appendData:boundaryData];
	if ([gallery isGalleryV2])
		[requestData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"g2_userfile\"; filename=\"%@\"\r\nContent-Type: %@\r\n\r\n", [item filename], [item imageType]] dataUsingEncoding:[gallery sniffedEncoding]]];
	else
		[requestData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@\"\r\nContent-Type: %@\r\n\r\n", [item filename], [item imageType]] dataUsingEncoding:[gallery sniffedEncoding]]];
    [requestData appendData:[item data]];
    // closing
    [requestData appendData:[@"\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    [requestData appendData:boundaryData];
    
    CFHTTPMessageSetBody(messageRef, (__bridge CFDataRef)requestData);
    
    CFReadStreamRef readStream = CFReadStreamCreateForHTTPRequest(kCFAllocatorDefault, messageRef);
    // make sure the proxy information is set on the stream
    CFDictionaryRef proxyDict = SCDynamicStoreCopyProxies(NULL);
    CFReadStreamSetProperty(readStream, kCFStreamPropertyHTTPProxy, proxyDict);
    CFReadStreamSetProperty(readStream, kCFStreamPropertyHTTPShouldAutoredirect, kCFBooleanTrue);
    
    CFReadStreamOpen(readStream);

    // TODO: change this from polling to using callbacks (polling was just plain easier...)
    // I have to use CFNetwork so I can get some information on upload progress
    BOOL done = FALSE;
    unsigned long bytesSentSoFar = 0;
    NSMutableData *data = [NSMutableData data];
    while (!done && !cancelled) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
        
        if (CFReadStreamHasBytesAvailable(readStream)) {
            UInt8 buf[BUFSIZE];
            CFIndex bytesRead = CFReadStreamRead(readStream, buf, BUFSIZE);
            if (bytesRead < 0) {
                // uh-oh - this returns without releasing our CF objects
                return ZW_GALLERY_UNKNOWN_ERROR;
            } else if (bytesRead == 0) {
                done = YES;
            } else {
                [data appendBytes:buf length:bytesRead];
            }
        }
        
        if (CFReadStreamGetStatus(readStream) == kCFStreamStatusAtEnd || CFReadStreamGetStatus(readStream) == kCFStreamStatusClosed)
            done = YES;
        
        // This is why we're using CFStream - we need to find out how much we've uploaded at any given point.
        CFNumberRef bytesWrittenRef = (CFNumberRef)CFReadStreamCopyProperty(readStream, kCFStreamPropertyHTTPRequestBytesWrittenCount);
        unsigned long bytesWritten = [(__bridge NSNumber *)bytesWrittenRef unsignedLongValue];
        CFRelease(bytesWrittenRef);
        
        if (bytesSentSoFar != bytesWritten) {
            bytesSentSoFar = bytesWritten;
            [delegate album:self item:item updateBytesSent:bytesWritten]; 
        }
    }
    
    CFRelease(messageRef);
    CFRelease(readStream);
    
    if (cancelled)
        return ZW_GALLERY_OPERATION_DID_CANCEL;
    
    NSDictionary *galleryResponse = [[self gallery] parseResponseData:data];
    if (galleryResponse == nil) {
        return ZW_GALLERY_PROTOCOL_ERROR;
    }
    
    ZWGalleryRemoteStatusCode status = (ZWGalleryRemoteStatusCode)[[galleryResponse objectForKey:@"statusCode"] intValue];
    
    [items addObject:item];
    
    return status;
}


@end
