//
//  Firebase+JS.m
//
//  Created by Clément Wehrung on 09/12/2013.
//  Copyright (c) 2013 Clément Wehrung. All rights reserved.
//

#import "Firebase+JS.h"

#import <Firebase/Firebase.h>
#import <objc/runtime.h>

@implementation Firebase (JS)

+ (void)addJavaScriptBridge
{
    class_addProtocol([Firebase class], @protocol(FirebaseJSSupport));
    class_addProtocol([FDataSnapshot class], @protocol(FDataSnapshotJSSupport));
    class_addProtocol([FQuery class], @protocol(FQueryJSSupport));
    
    class_addProtocol([FMutableData class], @protocol(JSExport));
    class_addProtocol([FTransactionResult class], @protocol(JSExport));
}

- (void)remove
{
    [self removeValue];
}

- (Firebase *)push:(id)value
{
    Firebase *child = self.childByAutoId;
    if (value) [child setValue:value];
    return child;
}


- (JSValue *) onDisconnect
{
    JSContext *ctx = [JSContext currentContext];
    JSValue *onDisconnect = [JSValue valueWithNewObjectInContext:ctx];
    
    __weak Firebase *this = self;
    
    onDisconnect[@"remove"] = ^(void) {
        [this onDisconnectRemoveValue];
    };
    onDisconnect[@"set"] = ^(JSValue *value) {
        [this onDisconnectSetValue:value];
    };
    onDisconnect[@"update"] = ^(JSValue *value) {
        [this onDisconnectUpdateChildValues:value.toDictionary];
    };
    onDisconnect[@"cancel"] = ^() {
        [this cancelDisconnectOperations];
    };
    onDisconnect[@"setWithPriority"] = ^(JSValue *value, JSValue *priority) {
        [this onDisconnectSetValue:value andPriority:priority.toNumber];
    };
    
    return onDisconnect;
}

- (NSString *) toURL
{
    return [self description];
}

@end

@implementation FQuery (JS)

- (FEventType)eventTypeFromName:(NSString*)eventTypeName
{
    NSDictionary *types = @{ @"child_added": @(FEventTypeChildAdded),
                             @"child_removed": @(FEventTypeChildRemoved),
                             @"child_changed": @(FEventTypeChildChanged),
                             @"child_moved": @(FEventTypeChildMoved),
                             @"value": @(FEventTypeValue) };
    
    return (FEventType) [types[eventTypeName] intValue];
}

- (void) observeEventTypeName:(NSString *)eventTypeName withBlock:(JSValue *)jsBlock
{
    /* Should we try that?
    JSManagedValue *managedValue = [JSManagedValue managedValueWithValue:jsBlock];
    [jsBlock.context.virtualMachine addManagedReference:managedValue withOwner:jsBlock.context[@"window"]];
    */

    [self observeEventType:[self eventTypeFromName:eventTypeName] withBlock:^(FDataSnapshot *snapshot) {
        [jsBlock callWithArguments:@[snapshot]];
    }];
}

- (void) observeSingleEventOfTypeName:(NSString *)eventTypeName withBlock:(JSValue *)jsBlock
{
    [self observeSingleEventOfType:[self eventTypeFromName:eventTypeName] withBlock:^(FDataSnapshot *snapshot) {
        [jsBlock callWithArguments:@[snapshot]];
    }];
}

- (void) runTransactionWithUpdateFunction:(JSValue *)updateBlock completionBlock:(JSValue *)completionBlock applyLocally:(BOOL)applyLocally
{
    Firebase *firebase = (Firebase *)self;
    
    [firebase runTransactionBlock:^FTransactionResult *(FMutableData *currentData) {
        
        JSValue *returned = [updateBlock callWithArguments:@[currentData.value]];
        if (returned.isUndefined) {
            return [FTransactionResult abort];
        } else {
            currentData.value = returned.toObject;
            return [FTransactionResult successWithValue:currentData];
        }
        
    } andCompletionBlock:^(NSError *error, BOOL committed, FDataSnapshot *snapshot) {
        
        if (completionBlock) {
            [completionBlock callWithArguments:@[error ?: [NSNull null], @(committed), snapshot ?: [NSNull null]]];
        }
        
    } withLocalEvents:applyLocally];
}

@end

@implementation FDataSnapshot (JS)

- (id)val
{
    return self.value;
}

@end