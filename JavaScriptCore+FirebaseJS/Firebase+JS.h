//
//  Firebase+JS.h
//
//  Created by Clément Wehrung on 09/12/2013.
//  Copyright (c) 2013 Clément Wehrung. All rights reserved.
//

#import <Firebase/Firebase.h>
#import <JavaScriptCore/JavaScriptCore.h>

@interface Firebase (JS)

+ (void)addJavaScriptBridge;

@end

@protocol FirebaseJSSupport <JSExport>

- (Firebase *) parent;
- (Firebase *) root;
- (NSString *) name;
- (void) remove;
- (Firebase *) push:(id)value;
- (JSValue *) onDisconnect;
- (NSString *) toURL;

JSExportAs(startAt, - (FQuery *) queryStartingAtPriority:(id)startPriority andChildName:(NSString *)childName);
JSExportAs(child, - (Firebase *) childByAppendingPath:(NSString *)pathString);
JSExportAs(set, - (void) setValue:(id)value);
JSExportAs(update, - (void) updateChildValues:(NSDictionary *)values);
JSExportAs(on, - (void) observeEventTypeName:(NSString *)eventTypeName withBlock:(JSValue *)jsBlock );
JSExportAs(once, - (void) observeSingleEventOfTypeName:(NSString *)eventTypeName withBlock:(JSValue *)jsBlock );
JSExportAs(transaction, - (void) runTransactionWithUpdateFunction:(JSValue *)jsBlock completionBlock:(JSValue *)completionBlock applyLocally:(BOOL)applyLocally );

@end

@protocol FQueryJSSupport <JSExport>

JSExportAs(on, - (void) observeEventTypeName:(NSString *)eventTypeName withBlock:(JSValue *)jsBlock );
JSExportAs(once, - (void) observeSingleEventOfTypeName:(NSString *)eventTypeName withBlock:(JSValue *)jsBlock );

@end

@protocol FDataSnapshotJSSupport <JSExport>

- (id) val;
- (Firebase *) ref;
- (NSString *) name;

JSExportAs(child, - (FDataSnapshot *) childSnapshotForPath:(NSString *)childPathString );

@end