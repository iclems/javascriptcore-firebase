//
//  CWViewController.m
//  JavaScriptCore+FirebaseJS
//
//  Created by Clément Wehrung on 24/04/2014.
//  Copyright (c) 2014 Clement Wehrung. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import <Firebase/Firebase.h>

#import "CWViewController.h"

@interface CWViewController ()

@end

@implementation CWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [_webview loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"panelText" ofType:@"html"]]]];

}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"WebView loaded");
    
    self.context[@"console"][@"log"] = ^(JSValue *msg) {
        NSLog(@"JS: %@", msg);
    };
    
    self.context[@"ready"] = ^() {
        NSLog(@"Firepad Ready");
    };
    
    self.context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        NSLog(@"Exception: %@ - %@", context, exception);
    };
    
    [self startFirepad];
}

- (JSContext *)context
{
    return [_webview valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
}

- (void)startFirepad
{
    JSContext *ctx = self.context;
    
    self.context[@"ref"] = [[Firebase alloc] initWithUrl:@"https://firepad.firebaseio.com/demo/javascriptcore"];
    
    [ctx evaluateScript:@"var codeMirror = CodeMirror(document.getElementById('firepad'), { lineWrapping: true });"];
    [ctx evaluateScript:@"var firepad = Firepad.fromCodeMirror(ref, codeMirror, { });"];
    [ctx evaluateScript:@"firepad.on('ready', function() { console.log('ready'); if (ready) ready(); });"];
    [ctx evaluateScript:@"registerAllEntities(firepad);"];
}

@end
