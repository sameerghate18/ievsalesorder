//
//  PCViewController.m
//  ERPMobile
//
//  Created by Sameer Ghate on 09/08/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import "PCViewController.h"
#import "SVProgressHUD.h"
#import "PCUserLoginViewController.h"
#import "PCCompanyModel.h"
#import "PCUserModel.h"
#import "AppDelegate.h"
#import "ConnectionHandler.h"

typedef enum {
    DATA_TYPE_COMPANYLIST,
    DATA_TYPE_USERLIST
}DATA_TYPE;

@interface PCViewController () <NSURLConnectionDelegate, UITableViewDataSource, UITableViewDelegate, ConnectionHandlerDelegate>
{
    NSMutableData *recievedData;
    NSMutableArray *companyList;
    NSMutableArray *usersList;
    DATA_TYPE dataType;
    NSMutableString *dataTypeURL;
    NSString *selectedCompany;
}

@property (nonatomic, weak) IBOutlet UITableView *companyTableview;

@property (nonatomic, weak) IBOutlet UIButton *backButton;

@property (nonatomic, weak) IBOutlet UIImageView *bgImageView;

@end

@implementation PCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
//    self.navigationController.navigationBarHidden = TRUE;
    
    self.navigationItem.hidesBackButton = YES;
//    self.navigationItem.title = @"Select your company";
    
    
    
    dataType = DATA_TYPE_COMPANYLIST;
    [self pullData];
}

-(void)viewWillAppear:(BOOL)animated
{    
    BOOL isRegistered = [[NSUserDefaults standardUserDefaults] boolForKey:IS_REGISTRATION_COMPLETE_KEY];
    
    if (isRegistered) {
        _backButton.hidden = TRUE;
    }
    else {
        _backButton.hidden = FALSE;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)pullData
{
    [SVProgressHUD showWithStatus:@"Please wait" maskType:SVProgressHUDMaskTypeBlack];
    
    NSString *urlString;
    
    if (dataType == DATA_TYPE_COMPANYLIST) {
        dataTypeURL = [NSMutableString stringWithString:kCompanyListService];
        
        urlString = kGetAllCompanyURL;//@"http://www.ievmobile.com/SALEIEV/Service.svc/getallcompany";
        
    }
//    else if (dataType == DATA_TYPE_USERLIST) {
//        urlString = [[NSString alloc] initWithFormat:@"%@/%@%@",appDel.baseURL,kUsernamesService,dataTypeURL];
//    }
    
    ConnectionHandler *handler = [[ConnectionHandler alloc] init];
    handler.delegate = self;
    
    
    [handler fetchDataForPOSTURL:urlString body:nil completion:^(id responseData, NSError *error) {
        
        if (!companyList) {
            companyList = [[NSMutableArray alloc] init];
        }
        
        [companyList removeAllObjects];
        
        __block NSString *errorString;
        
        NSError *jsonerror = nil;
        NSArray *companyJsonArray = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonerror];
        
            for (NSDictionary *dict in companyJsonArray) {
                PCCompanyModel *cMod = [[PCCompanyModel alloc] init];
                [cMod setValuesForKeysWithDictionary:dict];
                [companyList addObject:cMod];
            }
            
            NSArray *sortedArray;
            sortedArray = [companyList sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                NSString *first = [(PCCompanyModel*)a NAME];
                NSString *second = [(PCCompanyModel*)b NAME];
                return [first compare:second];
            }];
            
            [companyList removeAllObjects];
            [companyList addObjectsFromArray:[sortedArray copy]];
            
            if (companyList.count == 0) {
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No companies found." message:@"Could not find list of companies." preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [alert addAction:[UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self pullData];
                }]];
                [self presentViewController:alert animated:YES completion:nil];
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showSuccessWithStatus:@"Done"];
                [_companyTableview reloadInputViews];
                [_companyTableview reloadData];
            });
    }];
}

-(void)connectionHandler:(ConnectionHandler*)conHandler didRecieveData:(NSData*)data
{
    
    if (dataType == DATA_TYPE_COMPANYLIST) {
        
        if (!companyList) {
            companyList = [[NSMutableArray alloc] init];
        }
        
        [companyList removeAllObjects];
        
        NSError *error = nil;;
        __block NSString *errorString;
        
        id output = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        
        if ([output isKindOfClass:[NSArray class]]) {
            
            for (NSDictionary *dict in output) {
                PCCompanyModel *cMod = [[PCCompanyModel alloc] init];
                [cMod setValuesForKeysWithDictionary:dict];
                [companyList addObject:cMod];
            }
            
            NSArray *sortedArray;
            sortedArray = [companyList sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                NSString *first = [(PCCompanyModel*)a NAME];
                NSString *second = [(PCCompanyModel*)b NAME];
                return [first compare:second];
            }];
            
            [companyList removeAllObjects];
            [companyList addObjectsFromArray:[sortedArray copy]];
            
            if (companyList.count == 0) {
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No companies found." message:@"Could not find list of companies." preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [alert addAction:[UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self pullData];
                }]];
                [self presentViewController:alert animated:YES completion:nil];
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showSuccessWithStatus:@"Done"];
                [_companyTableview reloadInputViews];
                [_companyTableview reloadData];
            });
            
        }
        else if ([output isKindOfClass:[NSString class]])   {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [SVProgressHUD dismiss];
                errorString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                errorString = [errorString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                errorString = [errorString substringWithRange:NSMakeRange(1, errorString.length-2)];
                errorString = [errorString capitalizedString];
                
                if ([errorString  caseInsensitiveCompare:@"IEV C003"] == NSOrderedSame) {
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sign in" message:@"Invalid connection string to connect to company.\nPlease try again." preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            });
        }
        
    }
    else if (dataType == DATA_TYPE_USERLIST) {
        
        if (!usersList) {
            usersList = [[NSMutableArray alloc] init];
        }
        
        NSError *error = nil;
        NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        
        for (NSDictionary *dict in arr) {
            
            PCUserModel *uMod = [[PCUserModel alloc] init];
            [uMod setValuesForKeysWithDictionary:dict];
            [usersList addObject:uMod];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"Done"];
            
            PCUserLoginViewController *uvc = [kStoryboard instantiateViewControllerWithIdentifier:@"PCUserLoginViewController"];
            [uvc setUsersList:usersList];
            [uvc setSeletedCompany:selectedCompany];
            [self.navigationController pushViewController:uvc animated:NO];
        });
        
    }
    
    
    
    
}

-(void)connectionHandler:(ConnectionHandler*)conHandler errorRecievingData:(NSError*)error
{
    if ([error code] == -5000) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [SVProgressHUD dismiss];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"IEV" message:@"Internet connection appears to be unavailable.\nPlease check your connection and try again." preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [alert addAction:[UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self pullData];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        });
        return;
    }
    
    
    [SVProgressHUD dismiss];
//    [SVProgressHUD showErrorWithStatus:@"Error getting data"];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error." message:@"Could not fetch data from server." preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self pullData];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
    
    if (dataType == DATA_TYPE_COMPANYLIST) {
        
    }
    else if (dataType == DATA_TYPE_USERLIST) {
        
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return companyList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell.textLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    PCCompanyModel *mod = [companyList objectAtIndex:indexPath.row];
    
    cell.textLabel.text = mod.NAME;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    dataType = DATA_TYPE_USERLIST;
    
    PCCompanyModel *mod = [companyList objectAtIndex:indexPath.row];
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDel setSelectedCompany:mod];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:mod.CO_CD forKey:kSelectedCompanyCode];
    [defaults setValue:mod.LONG_CO_NM forKey:kSelectedCompanyLongname];
    [defaults setValue:mod.NAME forKey:kSelectedCompanyName];
    [defaults synchronize];
    
    selectedCompany = mod.LONG_CO_NM;
    dataTypeURL = [NSMutableString stringWithString:mod.CO_CD];
    
    // SALES IEV
    PCUserLoginViewController *uvc = [kStoryboard instantiateViewControllerWithIdentifier:@"PCUserLoginViewController"];
    [uvc setSeletedCompany:selectedCompany];
    [self.navigationController pushViewController:uvc animated:NO];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100 || alertView.tag == 101) {
        if (buttonIndex == 1) {
            [self pullData];
        }
    }
}
@end
