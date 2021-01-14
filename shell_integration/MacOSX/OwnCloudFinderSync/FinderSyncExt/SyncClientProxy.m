/*
 * Copyright (C) by Jocelyn Turcotte <jturcotte@woboq.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
 * for more details.
 */
#import <os/log.h>
#import "SyncClientProxy.h"

@protocol ServerProtocol <NSObject>
- (void)registerClient:(id)client;
@end

@interface SyncClientProxy () <GDUnixSocketClientDelegate>

@end

@implementation SyncClientProxy

- (instancetype)initWithDelegate:(id)arg1 serverName:(NSString*)serverName
{
	self = [super init];
	
	self.delegate = arg1;
	_serverName = serverName;
    
    NSLog(@"QQQ The code runs through here!");
    
    // os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "HELLO CONSOLE!");

	return self;
}

#pragma mark - Connection setup

- (void)start
{
	//if (_remoteEnd)
		//return;
    
    // NSLog(@"QQQ The code runs through here!");

	// Lookup the server connection
    
    /*
    _client.delegate = self;
    
    NSError *error;
    if ([_client connectWithAutoRead:YES error:&error]) {
        NSLog(@"Connected to %@", _serverName);
    } else {
        NSLog(@"Couldnt Connect to %@", _serverName);
    }*/
}

- (void)scheduleRetry
{
	[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(start) userInfo:nil repeats:NO];
}

- (void)connectionDidDie:(NSNotification*)notification
{
#pragma unused(notification)
	[_delegate connectionDidDie];
	
	[self scheduleRetry];
}

#pragma mark - Communication logic

- (void)sendMessage:(NSData*)msg
{
    [_client writeData: msg completion:nil];
}

- (void)unixSocketClient:(GDUnixSocketClient *)unixSocketClient didReceiveData:(NSData*)data {
	NSString *answer = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	// Cut the trailing newline. We always only receive one line from the client.
	answer = [answer substringToIndex:[answer length] - 1];
	NSArray *chunks = [answer componentsSeparatedByString: @":"];
	
	if( [[chunks objectAtIndex:0] isEqualToString:@"STATUS"] ) {
		NSString *result = [chunks objectAtIndex:1];
		NSString *path = [chunks objectAtIndex:2];
		if( [chunks count] > 3 ) {
			for( int i = 2; i < [chunks count]-1; i++ ) {
				path = [NSString stringWithFormat:@"%@:%@",
						path, [chunks objectAtIndex:i+1] ];
			}
		}
		[_delegate setResultForPath:path result:result];
	} else if( [[chunks objectAtIndex:0] isEqualToString:@"UPDATE_VIEW"] ) {
		NSString *path = [chunks objectAtIndex:1];
		[_delegate reFetchFileNameCacheForPath:path];
	} else if( [[chunks objectAtIndex:0 ] isEqualToString:@"REGISTER_PATH"] ) {
		NSString *path = [chunks objectAtIndex:1];
		[_delegate registerPath:path];
	} else if( [[chunks objectAtIndex:0 ] isEqualToString:@"UNREGISTER_PATH"] ) {
		NSString *path = [chunks objectAtIndex:1];
		[_delegate unregisterPath:path];
	} else if( [[chunks objectAtIndex:0 ] isEqualToString:@"GET_STRINGS"] ) {
		// BEGIN and END messages, do nothing.
	} else if( [[chunks objectAtIndex:0 ] isEqualToString:@"STRING"] ) {
		[_delegate setString:[chunks objectAtIndex:1] value:[chunks objectAtIndex:2]];
	} else if( [[chunks objectAtIndex:0 ] isEqualToString:@"GET_MENU_ITEMS"] ) {
		if ([[chunks objectAtIndex:1] isEqualToString:@"BEGIN"]) {
			[_delegate resetMenuItems];
		} else if ([[chunks objectAtIndex:1] isEqualToString:@"END"]) {
			// Don't do anything special, the askOnSocket call in FinderSync menuForMenuKind will return after this line
		}
	} else if( [[chunks objectAtIndex:0 ] isEqualToString:@"MENU_ITEM"] ) {
		NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
		[item setValue:[chunks objectAtIndex:1] forKey:@"command"]; // e.g. "COPY_PRIVATE_LINK"
		[item setValue:[chunks objectAtIndex:2] forKey:@"flags"]; // e.g. "d"
		[item setValue:[chunks objectAtIndex:3] forKey:@"text"]; // e.g. "Copy private link to clipboard"
		[_delegate addMenuItem:item];
	} else {
		NSLog(@"SyncState: Unknown command %@", [chunks objectAtIndex:0]);
	}
}

- (void)askOnSocket:(NSString*)path query:(NSString*)verb
{
	NSString *query = [NSString stringWithFormat:@"%@:%@\n", verb,path];
	
	@try {
		[self sendMessage:[query dataUsingEncoding:NSUTF8StringEncoding]];
	} @catch(NSException* e) {
		// Do nothing and wait for connectionDidDie
        NSLog(@"%@", e.debugDescription);
	}
}

- (void)askForIcon:(NSString*)path isDirectory:(BOOL)isDir
{
	NSString *verb = isDir ? @"RETRIEVE_FOLDER_STATUS" : @"RETRIEVE_FILE_STATUS";
	[self askOnSocket:path query:verb];
}

#pragma mark - GDUnixSocketClientDelegate

- (void)unixSocketClient:(GDUnixSocketClient *)unixSocketClient didFailToReadWithError:(NSError *)error {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
}

@end

