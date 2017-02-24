//
//  Constants.h
//  ERPMobile
//
//  Created by Sameer Ghate on 30/08/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#ifndef ERPMobile_Constants_h
#define ERPMobile_Constants_h

#import "AppDelegate.h"
#import "PCCompanyModel.h"
#import "PCUserModel.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

typedef enum{
    TXTypePO,
    TXTypeSO,
    TXTypePayments,
    TXTypePI,
    TXTypeRB,
    TXTypePCR
}TXType;

typedef enum
{
    SalesTypeDomestic,
    SalesTypeExport
}SalesType;

#define DEFAULT_CURRENCY_CODE @"INR"

#define kStoryboard [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]]
#define kAppDelegate (AppDelegate*)[[UIApplication sharedApplication] delegate]

#define TimeStamp [NSString stringWithFormat:@"%f",[[NSDate new] timeIntervalSince1970] * 1000]

#define IS_REGISTRATION_COMPLETE_KEY @"isRegistrationCompleted"

//#define kAppBaseURL @"http://www.int-e-view.com:88/Service.svc/"
//#define kAppBaseURL @"http://115.115.180.253/pcsoftiev/service.svc/"
//#define kAppBaseURL @"http://115.115.180.253/getiev/Service.svc/"
// domain name
//#define kAppBaseURL @"http://www.ievmobile.com/getiev/Service.svc/"

#define kAppBaseURL @"http://www.ievmobile.com/SALEIEV/Service.svc/"

#define kCompanyBaseURL @"CompanyBaseURL"
#define kSelectedCompanyCode @"selectedCompanyCode"
#define kSelectedCompanyLongname @"selectedCompanyLongName"
#define kSelectedCompanyName @"selectedCompanyName"
#define kAccessCode @"accessCode"
#define kPhoneNumber @"phoneNumber"

#define kVerifyCodeURL @"http://www.ievmobile.com/SALEIEV/Service.svc/getserviceurl?scocd="

#define kLicenseAddURL @"http://www.ievmobile.com/SALEIEV/Service.svc/getupdatelic?scocd="

#define GET_PARTY_URL(scocd, partyst, doctype, docsr)  \
[NSString stringWithFormat:@"%@GetParty?scocd=%@&partyst=%@&doctype=%@&docsr=%@",kAppBaseURL,scocd,partyst,doctype,docsr];  \

#define GET_ITEM_URL(scocd,docsr,partyno,imloc) \
[NSString stringWithFormat:@"%@GetItem?scocd=%@&docsr=%@&doctype=%@&partyno=%@&imloc=%@&loctype=%@",kAppBaseURL,scocd,docsr,kDefaultDocType,partyno,imloc,kDefaultLocType];  \

#define GET_SUBMIT_ORDER_URL(scocd,userid,doctype,docsr,imloc,partyno,items,mobno) \
[NSString stringWithFormat:@"%@SubmitOrder1?scocd=%@&userid=%@&doctype=%@&docsr=%@&partyst=%@&partyno=%@&imloc=%@&items=%@&mobno=%@", kAppBaseURL,scocd, userid, doctype, docsr, kDefaultPartySt, partyno, imloc, items, mobno]; \

#define GET_DOC_SERIES(scocd,userid,doctype) \
[NSString stringWithFormat:@"%@GetDocSeries?scocd=%@&userid=%@&doctype=%@",kAppBaseURL,scocd,userid,doctype];  \

#define GET_ALL_ORDERS(scocd,userid) \
[NSString stringWithFormat:@"%@AllSo?scocd=%@&userid=%@",kAppBaseURL,scocd,userid];  \

#define GET_ORDER_DETAIL(scocd,userid,doctype,docno)   \
[NSString stringWithFormat:@"%@Sodtl?scocd=%@&userid=%@&doctype=%@&docno=%@",kAppBaseURL,scocd,userid,doctype,docno];  \

#define kDefaultPartySt @"D"
#define kDefaultLocType @"W"
#define kDefaultDocType @"49"

#define kCheckForDeviceAlreadyRegistered @""

#define kCompanyListService @"GetAllCompany"
#define kUsernamesService @"GetUser?scocd="
#define kCompanySalesService @"gettodayssale?scocd="
#define kUserLogoutService @"logout?scocd="

#define kInvoicesService @"GetInvoice?scocd="

#define kRejectionsService(selComp,value) @"GetRejection?scocd=("selComp")&Xvalue=("value")"

#define kAttendanceService @"GetAttendance?scocd=SE&rperson="
#define kCashFlowService @"GetCashFlow?scocd=SE&sDate=2014-04-15"

#define khttp_Method_POST @"POST"
#define khttp_Method_GET @"GET"
#define khttp_Method_PUT @"PUT"
#define khttp_Method_DELETE @"DELETE"
#endif

// Error Domains

#define kErrorDomainUnwantedOutput @"unwanted_output"
#define kErrorDomainDeviceErrors @"device_error_domain"
#define kErrorDomainBlankOutput @"blank_output"

// Connection Handlers Tag

#define kCheckDeviceRegisteredTag       100
#define kUpdateLicenseTag                    101
#define kRegisterDeviceTag                   102
#define kGetServiceURLTag                   103
#define kGetUserNamesListTag              104
#define kUpdateMobileNumberTag          105
#define kUpdateDeviceRegisterTag         106

#define kUserLoginTag 201

#define kDateFormat @"MM/dd/yyyy HH:mm:ss a"

// Settings

#define kPaymentAuthPwdEnabled @"AuthPwdEnabled"
