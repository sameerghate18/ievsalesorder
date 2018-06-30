//
//  PCUserLoginViewController.m
//  ERPMobile
//
//  Created by Sameer Ghate on 31/08/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import "PCUserLoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PCUserModel.h"
#import "PCHomeViewController.h"
#import "AppDelegate.h"
#import "ConnectionHandler.h"
#import "SVProgressHUD.h"
#import "PCUserModel.h"
#import "PCDeviceRegisterModel.h"
#import "PCDeviceRegisterCheckModel.h"
#import "PCUpdateMobileNumberViewController.h"
#import "PCSideMenuTableViewController.h"

@interface PCUserLoginViewController () <UITableViewDelegate,UITableViewDataSource, UITextFieldDelegate, ConnectionHandlerDelegate,PCUpdateMobileNumberViewControllerDelegate>
{
    IBOutlet UITextField *usernameTF, *passwordTF, *nameTF;
    IBOutlet UIButton *loginButton;
    AppDelegate *appDel;
    NSString *usernameString;
    NSString *passwordString;
}

@property (nonatomic, weak) IBOutlet UITableView *usersTableview;

@end

@implementation PCUserLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.navigationController.view.backgroundColor =
//    [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-568h@2x.png"]];
    
    [self setTitle:[self.seletedCompany stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];

    usernameTF.layer.cornerRadius = 5.0f;
    passwordTF.layer.cornerRadius = 5.0f;
    loginButton.layer.cornerRadius = 10.0f;
    [loginButton setClipsToBounds:YES];
    usernameTF.layer.borderColor = (__bridge CGColorRef)([UIColor blackColor]);
    passwordTF.layer.borderColor = (__bridge CGColorRef)([UIColor blackColor]);
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    
    appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [self checkForUsageValidity];
}

-(void)checkForUsageValidity
{
    
    [SVProgressHUD showWithStatus:@"Validating..." maskType:SVProgressHUDMaskTypeBlack];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    ConnectionHandler *registerDeviceConnection = [[ConnectionHandler alloc] init];
//    registerDeviceConnection.delegate = self;
    registerDeviceConnection.tag = kCheckDeviceRegisteredTag;
    
    NSString *urlString = [NSString stringWithFormat:@"%@isregisterDevice?scocd=%@&DeviceId=%@&MobNo=%@",
                           kAppBaseURL,
                           [defaults valueForKey:kAccessCode],
                           appDel.appUniqueIdentifier,
                           [defaults valueForKey:kPhoneNumber]];
    
//    [registerDeviceConnection fetchDataForURL:urlString body:nil completion:NULL];
    
    [registerDeviceConnection fetchDataForPOSTURL:urlString body:nil completion:^(id responseData, NSError *error) {
        
        NSError *jsonerror = nil;
        NSArray *opArray = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonerror];
        
        if (!jsonerror) {
            
            if (opArray.count > 0) {
                
                NSDictionary *dict = [opArray objectAtIndex:0];
                
                PCDeviceRegisterCheckModel *model = [[PCDeviceRegisterCheckModel alloc] init];
                [model setValuesForKeysWithDictionary:dict];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [SVProgressHUD dismiss];
                    
                    if ([model.IsDeviceRegistered isEqualToString:@"YES"] && [model.IsMobileRegistered isEqualToString:@"YES"]) {
                        
                        if ([model.IsActive isEqualToString:@"A"]) {
                            // registered and active.
                            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IS_REGISTRATION_COMPLETE_KEY];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        }
                        else {
                            // registered but not active.
                            
                            NSMutableDictionary* details = [NSMutableDictionary dictionary];
                            [details setValue:@"Your limited use of IEV services for this device has ended.\nPlease contact PCSOFT ERP Solutions for enabling IEV services." forKey: NSLocalizedDescriptionKey];
                            NSError *error_device = [NSError errorWithDomain:kErrorDomainDeviceErrors code:-5002 userInfo:details];
                            [self connectionHandler:nil errorRecievingData:error_device];
                        }
                    }
                    else if ([model.IsDeviceRegistered isEqualToString:@"YES"] && [model.IsMobileRegistered isEqualToString:@"NO"]) {
                        
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"IEV" message:@"Your mobile number is not registered. App will now register your mobile number?" preferredStyle:(UIAlertControllerStyle)UIAlertControllerStyleAlert];
                        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

                                PCUpdateMobileNumberViewController *updateMobVC = [kStoryboard instantiateViewControllerWithIdentifier:@"PCUpdateMobileNumberViewController"];
                                updateMobVC.accessCode = [defaults valueForKey:kAccessCode];
                                updateMobVC.phoneNumber = [defaults valueForKey:kPhoneNumber];
                                updateMobVC.delegate = self;
                                [self presentViewController:updateMobVC animated:YES completion:NULL];
                        }]];
                        
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                    else if ([model.IsDeviceRegistered isEqualToString:@"NO"] && [model.IsMobileRegistered isEqualToString:@"YES"]) {
                        
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"IEV" message:@"You have not registered your device. App will now proceed with registration." preferredStyle:(UIAlertControllerStyle)UIAlertControllerStyleAlert];
                        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            [self updateDeviceRegistration];
                        }]];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                    else {
                    }
                });
            }
        }
        
    }];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)goBack:(id)sender
{
    
    BOOL isRegistered = [[NSUserDefaults standardUserDefaults] boolForKey:IS_REGISTRATION_COMPLETE_KEY];
    
    if (isRegistered) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

-(IBAction)login:(id)sender
{
    usernameString = [NSString stringWithString:usernameTF.text];
    passwordString = [NSString stringWithString:passwordTF.text];
    
    usernameString = [usernameString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    passwordString = [passwordString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (usernameString.length>0 || passwordString.length>0) {
        [self webauthenticate:usernameString password:passwordString];
    }
    else    {
        UIAlertController *blankFieldsAlert = [UIAlertController alertControllerWithTitle:@"Login" message:@"Username and password cannot be left blank." preferredStyle:UIAlertControllerStyleAlert];
        
        [blankFieldsAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        
        [self presentViewController:blankFieldsAlert animated:YES completion:NULL];
    }
}

-(void)webauthenticate:(NSString*)username password:(NSString*)password
{
    [SVProgressHUD showWithStatus:@"Verifying"];
    
    ConnectionHandler *loginCheck = [[ConnectionHandler alloc] init];
//    loginCheck.delegate = self;
    loginCheck.tag = kUserLoginTag;
    
    //authenticate?scocd=SE&userid=00126&pass=V
    NSString *url = [NSString stringWithFormat:@"%@/authenticate?scocd=%@&userid=%@&pass=%@",appDel.baseURL,appDel.selectedCompany.CO_CD,username,password];
    
//    [loginCheck fetchDataForURL:url body:nil completion:NULL];
    
    [loginCheck fetchDataForPOSTURLwithStringOutput:url completion:^(id responseData, NSError *error) {
        
        NSString *outputString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        
        outputString = [outputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (outputString.length > 0) {
            outputString = [outputString substringWithRange:NSMakeRange(1, outputString.length-2)];
            outputString = [outputString capitalizedString];
        }
        
        __block BOOL loginFound = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([outputString  caseInsensitiveCompare:@"IEVC001"] == NSOrderedSame) {
                
                loginFound =  NO;
                
                [SVProgressHUD dismiss];
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sign in" message:@"Invalid user name provided.\nPlease try again." preferredStyle:(UIAlertControllerStyle)UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }]];
                [self presentViewController:alert animated:YES completion:nil];
            }
            else if ([outputString caseInsensitiveCompare:@"IEVC002"] == NSOrderedSame) {
                
                loginFound =  NO;
                
                [SVProgressHUD dismiss];
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sign in" message:@"Invalid password.\nPlease try again." preferredStyle:(UIAlertControllerStyle)UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }]];
                [self presentViewController:alert animated:YES completion:nil];
            }
            else if ([outputString caseInsensitiveCompare:@"IEVC003"] == NSOrderedSame) {
                
                loginFound =  NO;
                
                [SVProgressHUD dismiss];
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sign in" message:@"Your login has been locked for this device.\nPlease contact PCSOFT ERP Solutions to access again." preferredStyle:(UIAlertControllerStyle)UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }]];
                [self presentViewController:alert animated:YES completion:nil];
            }
            else {
                
                [SVProgressHUD showSuccessWithStatus:@"Verified"];
                
                appDel.userLoggedIn = YES;
                
                NSString *name = [outputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                PCUserModel *loggedInUserModel = [[PCUserModel alloc] init];
                
                [loggedInUserModel setUSER_ID:usernameString];
                [loggedInUserModel setUSER_NAME:name];
                [loggedInUserModel setUSER_PSWD:passwordString];
                
                [appDel setLoggedUser:loggedInUserModel];
                
                [appDel setSelectedUserName:name];
                
                usernameTF.text = @"";
                passwordTF.text = @"";
                
                [self performSelector:@selector(pushToHomePage) withObject:nil afterDelay:0.5];
                
                loginFound =  YES;
                
            }
        });
        
        if (!loginFound) {
            
        }
    }];
}

-(void)connectionHandler:(ConnectionHandler*)conHandler didRecieveData:(NSData*)data
{
    switch (conHandler.tag) {
        case kUserLoginTag:
        {
            
            NSString *outputString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            outputString = [outputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            if (outputString.length > 0) {
                outputString = [outputString substringWithRange:NSMakeRange(1, outputString.length-2)];
                outputString = [outputString capitalizedString];
            }
            
            __block BOOL loginFound = NO;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ([outputString  caseInsensitiveCompare:@"IEV001"] == NSOrderedSame) {
                    
                    loginFound =  NO;
                    
                    [SVProgressHUD dismiss];
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sign in" message:@"Invalid user name provided.\nPlease try again." preferredStyle:(UIAlertControllerStyle)UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    }]];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                else if ([outputString caseInsensitiveCompare:@"IEV002"] == NSOrderedSame) {
                    
                    loginFound =  NO;
                    
                    [SVProgressHUD dismiss];
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sign in" message:@"Invalid password.\nPlease try again." preferredStyle:(UIAlertControllerStyle)UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    }]];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                else if ([outputString caseInsensitiveCompare:@"IEV003"] == NSOrderedSame) {
                    
                    loginFound =  NO;
                    
                    [SVProgressHUD dismiss];
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sign in" message:@"Your login has been locked for this device.\nPlease contact PCSOFT ERP Solutions to access again." preferredStyle:(UIAlertControllerStyle)UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    }]];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                else {
                    
                    [SVProgressHUD showSuccessWithStatus:@"Verified"];
                    
                    appDel.userLoggedIn = YES;
                    
                    NSString *name = [outputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    
                    PCUserModel *loggedInUserModel = [[PCUserModel alloc] init];
                    
                    [loggedInUserModel setUSER_ID:usernameString];
                    [loggedInUserModel setUSER_NAME:name];
                    [loggedInUserModel setUSER_PSWD:passwordString];
                    
                    [appDel setLoggedUser:loggedInUserModel];
                    
                    [appDel setSelectedUserName:name];
                    
                    usernameTF.text = @"";
                    passwordTF.text = @"";
                    
                    [self performSelector:@selector(pushToHomePage) withObject:nil afterDelay:0.5];
                    
                    loginFound =  YES;
                    
                }
            });
            
            if (!loginFound) {
                
            }
            
        }
            
            break;
            
        case kCheckDeviceRegisteredTag:
        {
            NSError *error = nil;
            NSArray *opArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            
            if (!error) {
                
                if (opArray.count > 0) {
                    
                    NSDictionary *dict = [opArray objectAtIndex:0];
                    
                    PCDeviceRegisterCheckModel *model = [[PCDeviceRegisterCheckModel alloc] init];
                    [model setValuesForKeysWithDictionary:dict];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [SVProgressHUD dismiss];
                        
                        if ([model.IsDeviceRegistered isEqualToString:@"YES"] && [model.IsMobileRegistered isEqualToString:@"YES"]) {
                            
                            if ([model.IsActive isEqualToString:@"A"]) {
                                // registered and active.
                                
                                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IS_REGISTRATION_COMPLETE_KEY];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                                
                            }
                            else {
                                // registered but not active.
                                
                                NSMutableDictionary* details = [NSMutableDictionary dictionary];
                                [details setValue:@"Your limited use of IEV services for this device has ended.\nPlease contact PCSOFT ERP Solutions for enabling IEV services." forKey: NSLocalizedDescriptionKey];
                                NSError *error_device = [NSError errorWithDomain:kErrorDomainDeviceErrors code:-5002 userInfo:details];
                                
                                [self connectionHandler:nil errorRecievingData:error_device];
                            }
                        }
                        else if ([model.IsDeviceRegistered isEqualToString:@"YES"] && [model.IsMobileRegistered isEqualToString:@"NO"]) {
                            
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"IEV" message:@"Your mobile number is not registered. App will now register your number." preferredStyle:(UIAlertControllerStyle)UIAlertControllerStyleAlert];
                            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                
                                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                PCUpdateMobileNumberViewController *updateMobVC = [kStoryboard instantiateViewControllerWithIdentifier:@"PCUpdateMobileNumberViewController"];
                                updateMobVC.accessCode = [defaults valueForKey:kAccessCode];
                                updateMobVC.phoneNumber = [defaults valueForKey:kPhoneNumber];
                                updateMobVC.delegate = self;
                                [self presentViewController:updateMobVC animated:YES completion:NULL];
                                
                            }]];
                            [self presentViewController:alert animated:YES completion:nil];
                        }
                        else if ([model.IsDeviceRegistered isEqualToString:@"NO"] && [model.IsMobileRegistered isEqualToString:@"YES"]) {
                            
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"IEV" message:@"You have not registered your device. App will now proceed with device registration." preferredStyle:(UIAlertControllerStyle)UIAlertControllerStyleAlert];
                            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                
                                [self updateDeviceRegistration];
                            }]];
                            [self presentViewController:alert animated:YES completion:nil];
                        }
                        else {
                        }
                    });
                }
            }
            
        }
            break;
            
        case kUpdateDeviceRegisterTag:
            break;
            
        default:
            break;
    }

}

-(void)updateDeviceRegistration {
    
    ConnectionHandler *updateDevieRegHandler = [[ConnectionHandler alloc] init];
    updateDevieRegHandler.delegate = self;
    updateDevieRegHandler.tag = kUpdateDeviceRegisterTag;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    
    NSString *urlString = [NSString stringWithFormat:@"%@updatedeviceid?scocd=%@&deviceid=%@&mobno=%@",
                           kAppBaseURL,
                           [defaults valueForKey:kAccessCode],
                           appDel.appUniqueIdentifier,
                           [defaults valueForKey:kPhoneNumber]];
    
//    [updateDevieRegHandler fetchDataForURL:urlString body:nil completion:NULL];
    
    [updateDevieRegHandler fetchDataForURL:urlString body:nil completion:^(NSData *responseData, NSError *error) {
        
        if (error) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Device Register" message:@"Device Registration failed. Please try again later." preferredStyle:(UIAlertControllerStyle)UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self updateDeviceRegistration];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else {
            NSString *outputString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            outputString = [outputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
           
            if (outputString.length > 0) {
                outputString = [outputString substringWithRange:NSMakeRange(1, outputString.length-2)];
            }
            
            if ([outputString caseInsensitiveCompare:@"true"] == NSOrderedSame) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Device Register" message:@"Device registration successfully done" preferredStyle:(UIAlertControllerStyle)UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    }]];
                    [self presentViewController:alert animated:YES completion:nil];
                });
            }
        }
        
    }];
    
}

-(void)pushToHomePage
{
    /*
    UITabBarController *homeVC = (UITabBarController*)[kStoryboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    homeVC.delegate = appDel;
    appDel.window.rootViewController = homeVC;
    [appDel.window makeKeyAndVisible];
     */
    
    PCSideMenuTableViewController *sideView = (PCSideMenuTableViewController*) appDel.slideViewController.leftViewController;
    [sideView setuserName];
    
    PCHomeViewController *homeVC = [kStoryboard instantiateViewControllerWithIdentifier:@"PCHomeViewController"];
    
    [self.navigationController pushViewController:homeVC animated:YES];
}

-(void)connectionHandler:(ConnectionHandler*)conHandler errorRecievingData:(NSError*)error
{
    if ([error code] == -5000) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [SVProgressHUD dismiss];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"IEV" message:@"Internet connection appears to be unavailable.\nPlease check your connection and try again." preferredStyle:(UIAlertControllerStyle)UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        });
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [SVProgressHUD dismiss];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"IEV" message:[error localizedDescription] preferredStyle:(UIAlertControllerStyle)UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            if ([error code] == -5002) {
                [self backToRegistration];
            }
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    });
    return;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _usersList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
        [cell.textLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return TRUE;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == usernameTF) {
        nameTF.text = @"";
        passwordTF.text = @"";
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{

}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 1000:
            if (buttonIndex == 0) {
                [self backToRegistration];
            }
            break;
            
        case 102:
            if (buttonIndex == 0) {
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                
                PCUpdateMobileNumberViewController *updateMobVC = [kStoryboard instantiateViewControllerWithIdentifier:@"PCUpdateMobileNumberViewController"];
                
                updateMobVC.accessCode = [defaults valueForKey:kAccessCode];
                
                updateMobVC.phoneNumber = [defaults valueForKey:kPhoneNumber];
                
                updateMobVC.delegate = self;
                
                [self presentViewController:updateMobVC animated:YES completion:NULL];
                
            }
            else if (buttonIndex == 1) {
                
            }
            break;
            
        case 103:
//            if (buttonIndex == 0) {
            
                [self updateDeviceRegistration];
//            }
//            else if (buttonIndex == 1) {
//                
//            }
            break;
    }
}

- (void)backToRegistration
{
    appDel.loggedUser = nil;
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:IS_REGISTRATION_COMPLETE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UINavigationController *registrationNavController = [kStoryboard instantiateViewControllerWithIdentifier:@"RootNavController"];;
    
    [appDel instantiateAppFlowWithNavController:registrationNavController];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
