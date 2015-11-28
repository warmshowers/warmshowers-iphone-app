//
//  Copyright (C) 2015 Warm Showers Foundation
//  http://warmshowers.org/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "RHAboutViewController.h"

@interface RHAboutViewController ()
@property (nonatomic, strong) RHTableView *tableView;
-(RHTableViewCell *)headerCell;
// -(void)showMeTheApp:(NSString *)appid;
@end

@implementation RHAboutViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:NSLocalizedString(@"About", nil)];
    
    weakify(self);
    
    self.navigationItem.leftBarButtonItem = [[RHBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                           block:^{
                                                                                               strongify(self);
                                                                                               [self dismissViewControllerAnimated:YES completion:nil];
                                                                                           }];
    
    [self.tableView addSectionWithSectionHeaderText:nil];
    [self.tableView addCell:self.headerCell];
    
    [self.tableView addSectionWithSectionHeaderText:@"Warmshowers.org"];
    
    [self.tableView addCell:[RHTableViewCell cellWithLabelText:NSLocalizedString(@"Visit the Website", nil)
                                              detailLabelText:nil
                                               didSelectBlock:^(RHTableViewCell *cell) {
                                                   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://warmshowers.org"]];
                                               } style:UITableViewCellStyleDefault
                                                        image:nil
                                                accessoryType:UITableViewCellAccessoryDisclosureIndicator]
    ];
    
    [self.tableView addCell:[RHTableViewCell cellWithLabelText:NSLocalizedString(@"Contact Us", nil)
                                               detailLabelText:nil
                                                didSelectBlock:^(RHTableViewCell *cell) {
                                                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.warmshowers.org/contact"]];
                                                } style:UITableViewCellStyleDefault
                                                         image:nil
                                                 accessoryType:UITableViewCellAccessoryDisclosureIndicator]
     ];
    
    [self.tableView addSectionWithSectionHeaderText:@"Warm Showers Online"];
    
    
    [self.tableView addCell:[RHTableViewCell cellWithLabelText:NSLocalizedString(@"Follow us on Twitter", nil)
                                               detailLabelText:nil
                                                didSelectBlock:^(RHTableViewCell *cell) {
                                                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/warmshowers"]];
                                                } style:UITableViewCellStyleDefault
                                                         image:nil
                                                 accessoryType:UITableViewCellAccessoryDisclosureIndicator]
     ];
    
    [self.tableView addCell:[RHTableViewCell cellWithLabelText:NSLocalizedString(@"Like us on Facebook", nil)
                                               detailLabelText:nil
                                                didSelectBlock:^(RHTableViewCell *cell) {
                                                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/groups/135049549858210/"]];
                                                } style:UITableViewCellStyleDefault
                                                         image:nil
                                                 accessoryType:UITableViewCellAccessoryDisclosureIndicator]
     ];
    
    
    [self.tableView addCell:[RHTableViewCell cellWithLabelText:NSLocalizedString(@"Rate this App", nil)
                                               detailLabelText:nil
                                                didSelectBlock:^(RHTableViewCell *cell) {
                                                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/app/warmshowers/id359056872?mt=8"]];
                                                } style:UITableViewCellStyleDefault
                                                         image:nil
                                                 accessoryType:UITableViewCellAccessoryDisclosureIndicator]
     ];
    
    [self.tableView addSectionWithSectionHeaderText:@"Other Apps" footerText:NSLocalizedString(@"The Warm Showers and TrackMyTour apps developed by Christopher Meyer.", nil)];
    
    RHTableViewCell *tmtCell = [self.tableView addCell:[RHTableViewCell cellWithLabelText:@"TrackMyTour"
                                               detailLabelText:NSLocalizedString(@"A tracking app for bike touring.", nil)
                                                didSelectBlock:^(RHTableViewCell *cell) {
                                                     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://trackmytour.com/"]];
                                                } style:UITableViewCellStyleSubtitle
                                                         image:[UIImage imageNamed:@"trackmytour"]
                                                 accessoryType:UITableViewCellAccessoryDisclosureIndicator]
     ];
    
    [tmtCell setHeightBlock:^CGFloat{
        return 80;
    }];

}

-(void)loadView {
    self.tableView = [[RHTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.view = self.tableView;
}

-(RHTableViewCell *)headerCell {
    RHTableViewCell *cell = [[RHTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    
    [cell.imageView setImage:[UIImage imageNamed:@"WSIcon50"]];
    
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [cell.detailTextLabel setFont:[UIFont systemFontOfSize:14]];
    [cell.detailTextLabel setTextColor:[UIColor darkTextColor]];
    
    NSString *build_number  = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *short_version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
#ifdef DEBUG
    NSString *debug_string = @"D";
#else
    NSString *debug_string = @"";
#endif
    
    NSString *versionLabel = [NSString stringWithFormat:@" %@ %@ (%@)%@", NSLocalizedString(@"Version", nil), short_version, build_number, debug_string];
    
    NSString *appName = @"Warmshowers.org";
    
    [cell.textLabel setText:appName];
    [cell.detailTextLabel setText:versionLabel];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [cell setHeightBlock:^CGFloat{
        return 80.0f;
    }];
    
    return cell;
}

@end