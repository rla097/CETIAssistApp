//
//  Validators.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import Foundation

struct Validators {
    
    /// Valida si un correo termina en @ceti.mx
    static func isValidCETIEmail(_ email: String) -> Bool {
        return email.lowercased().hasSuffix(ValidationRules.cetiDomain)
    }

    /// Valida si la contraseña cumple con el mínimo de caracteres
    static func isValidPassword(_ password: String) -> Bool {
        return password.count >= ValidationRules.minPasswordLength
    }

    /// Valida si ambas contraseñas coinciden
    static func passwordsMatch(_ password: String, _ confirmPassword: String) -> Bool {
        return password == confirmPassword
    }

    /// Verifica si una cadena es un correo electrónico válido (regex opcional)
    static func isEmailFormatValid(_ email: String) -> Bool {
        let emailRegex = #"^\S+@\S+\.\S+$"#
        return email.range(of: emailRegex, options: .regularExpression) != nil
    }
}
