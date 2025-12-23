//
//  Validators.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import Foundation

struct Validators {

    static func isValidCETIEmail(_ email: String) -> Bool {
        return email.lowercased().hasSuffix(ValidationRules.cetiDomain)
    }

    static func isValidPassword(_ password: String) -> Bool {
        return password.count >= ValidationRules.minPasswordLength
    }

    static func passwordsMatch(_ password: String, _ confirmPassword: String) -> Bool {
        return password == confirmPassword
    }

    static func isEmailFormatValid(_ email: String) -> Bool {
        let emailRegex = #"^\S+@\S+\.\S+$"#
        return email.range(of: emailRegex, options: .regularExpression) != nil
    }
}
