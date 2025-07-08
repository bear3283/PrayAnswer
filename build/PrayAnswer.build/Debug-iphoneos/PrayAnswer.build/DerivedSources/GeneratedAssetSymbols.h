#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"com.restart.PrayAnswer";

/// The "AnsweredColor" asset catalog color resource.
static NSString * const ACColorNameAnsweredColor AC_SWIFT_PRIVATE = @"AnsweredColor";

/// The "FamilyColor" asset catalog color resource.
static NSString * const ACColorNameFamilyColor AC_SWIFT_PRIVATE = @"FamilyColor";

/// The "HealthColor" asset catalog color resource.
static NSString * const ACColorNameHealthColor AC_SWIFT_PRIVATE = @"HealthColor";

/// The "NotAnsweredColor" asset catalog color resource.
static NSString * const ACColorNameNotAnsweredColor AC_SWIFT_PRIVATE = @"NotAnsweredColor";

/// The "OtherColor" asset catalog color resource.
static NSString * const ACColorNameOtherColor AC_SWIFT_PRIVATE = @"OtherColor";

/// The "PersonalColor" asset catalog color resource.
static NSString * const ACColorNamePersonalColor AC_SWIFT_PRIVATE = @"PersonalColor";

/// The "PrimaryColor" asset catalog color resource.
static NSString * const ACColorNamePrimaryColor AC_SWIFT_PRIVATE = @"PrimaryColor";

/// The "RelationshipColor" asset catalog color resource.
static NSString * const ACColorNameRelationshipColor AC_SWIFT_PRIVATE = @"RelationshipColor";

/// The "SecondaryColor" asset catalog color resource.
static NSString * const ACColorNameSecondaryColor AC_SWIFT_PRIVATE = @"SecondaryColor";

/// The "ThanksgivingColor" asset catalog color resource.
static NSString * const ACColorNameThanksgivingColor AC_SWIFT_PRIVATE = @"ThanksgivingColor";

/// The "VisionColor" asset catalog color resource.
static NSString * const ACColorNameVisionColor AC_SWIFT_PRIVATE = @"VisionColor";

/// The "WaitColor" asset catalog color resource.
static NSString * const ACColorNameWaitColor AC_SWIFT_PRIVATE = @"WaitColor";

/// The "WorkColor" asset catalog color resource.
static NSString * const ACColorNameWorkColor AC_SWIFT_PRIVATE = @"WorkColor";

#undef AC_SWIFT_PRIVATE
