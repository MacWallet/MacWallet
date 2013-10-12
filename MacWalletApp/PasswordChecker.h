//
//  PasswordChecker.h
//  MacWallet
//
//  Created by Jonas Schnelli on 11.10.13.
//  Copyright (c) 2013 include7 AG. All rights reserved.
//

@interface PasswordChecker : NSObject

typedef enum PasswordStrengthType {
    PasswordStrengthTypeInacceptable,
    PasswordStrengthTypeWeak,
    PasswordStrengthTypeModerate,
    PasswordStrengthTypeStrong
}PasswordStrengthType;

+ (PasswordStrengthType)checkPasswordStrength:(NSString *)password;

@end
