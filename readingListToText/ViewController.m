//  ViewController.m
//  readingListToText
//
//  Created by David P. Oster on 9/5/24.

#import "ViewController.h"

#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@interface ViewController ()
@property NSDictionary *bookmarks;
@property NSArray *readingList;
@property NSOpenPanel *openPanel;
@property IBOutlet NSTextView *textView;
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  NSURL *instructions = [NSBundle.mainBundle URLForResource:@"directions" withExtension:@"rtf"];
  NSAttributedString *as = [[NSAttributedString alloc] initWithURL:instructions options:@{} documentAttributes:NULL error:NULL];
  [self.textView.textStorage appendAttributedString:as];
  self.openPanel = [NSOpenPanel openPanel];
  [self.openPanel setAllowedContentTypes:@[UTTypePropertyList]];
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    NSModalResponse response = [self.openPanel runModal];
    if (NSModalResponseOK == response) {
      NSURL *url = self.openPanel.URL;
      self.bookmarks = [NSDictionary dictionaryWithContentsOfURL:url];
      if (self.bookmarks) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSMutableArray *readings = [NSMutableArray array];
        NSArray<NSDictionary *> *topChildren = self.bookmarks[@"Children"];
        for(NSDictionary *outerItem in topChildren) {
          if ([outerItem[@"Title"] isEqual:@"com.apple.ReadingList"]) {
            NSArray<NSDictionary *> *children = outerItem[@"Children"];
            for(NSDictionary *item in children) {
              NSMutableDictionary *readingItem = [NSMutableDictionary dictionary];
              NSDictionary *title = item[@"URIDictionary"];
              readingItem[@"title"] = title[@"title"];
              readingItem[@"URL"] = item[@"URLString"];
              NSDictionary *meta = item[@"ReadingList"];
              readingItem[@"added"] = [formatter stringFromDate: meta[@"DateAdded"] ];
              readingItem[@"snippet"] = meta[@"PreviewText"];
              [readings addObject:readingItem];
            }
            self.readingList = readings;
            NSData *data = [NSJSONSerialization dataWithJSONObject:readings options:NSJSONWritingPrettyPrinted error:NULL];
            if (data) {
              self.textView.string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
            break;
          }
        }
      }
    }
  });

  NSString *path = [NSHomeDirectory() stringByAppendingPathComponent: @"Library/Safari/Bookmarks.plist"];
  self.bookmarks = [NSDictionary dictionaryWithContentsOfFile:path];
  if (self.bookmarks) {
  }

  // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
  [super setRepresentedObject:representedObject];

  // Update the view, if already loaded.
}


@end
