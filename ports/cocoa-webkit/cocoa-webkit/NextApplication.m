//
//  NextApplication.m
//  next-cocoa
//
//  Created by John Mercouris on 3/25/18.
//  Copyright © 2018 Next. All rights reserved.
//

#import "NextApplication.h"

#include <xmlrpc-c/base.h>
#include <xmlrpc-c/client.h>
#include <xmlrpc-c/config.h>

#define NAME "Next"
#define VERSION "0.1"

@implementation NextApplication

static void
reportIfFaultOccurred (xmlrpc_env * const envP) {
    if (envP->fault_occurred) {
        fprintf(stderr, "ERROR: %s (%d)\n",
                envP->fault_string, envP->fault_code);
    }
}

- (void)sendEvent:(NSEvent *)event
{
    if ([event type] == NSEventTypeKeyDown) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSEventModifierFlags modifierFlags = [event modifierFlags];
            char characterCodePressed = [[event charactersIgnoringModifiers] characterAtIndex: 0];
            bool controlPressed = (modifierFlags & NSEventModifierFlagControl);
            bool alternatePressed = (modifierFlags & NSEventModifierFlagOption);
            bool commandPressed = (modifierFlags & NSEventModifierFlagCommand);

            xmlrpc_env env;
            xmlrpc_value * resultP;
            xmlrpc_bool consumed;
            const char * const serverUrl = "http://localhost:8081/RPC2";
            const char * const methodName = "PUSH-KEY-CHORD";
            
            // Initialize our error-handling environment.
            xmlrpc_env_init(&env);
            
            // Start up our XML-RPC client library.
            xmlrpc_client_init2(&env, XMLRPC_CLIENT_NO_FLAGS, NAME, VERSION, NULL, 0);
            reportIfFaultOccurred(&env);
            
            // Make the remote procedure call
            resultP = xmlrpc_client_call(&env, serverUrl, methodName,
                                         "(bbbi)",
                                         (xmlrpc_bool) controlPressed,
                                         (xmlrpc_bool) alternatePressed,
                                         (xmlrpc_bool) commandPressed,
                                         (xmlrpc_int) characterCodePressed);
            reportIfFaultOccurred(&env);
            
            xmlrpc_read_bool(&env, resultP, &consumed);
            reportIfFaultOccurred(&env);
            xmlrpc_client_cleanup();
        });
        return;
    } else {
        [super sendEvent:event];
    }
}

@end
