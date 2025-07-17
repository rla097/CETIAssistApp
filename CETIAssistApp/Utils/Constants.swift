//
//  Constants.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import Foundation

enum FirestoreCollections {
    static let users = "users"
    static let availability = "availability"
    static let reservations = "reservations"
}

enum ValidationRules {
    static let cetiDomain = "@ceti.mx"
    static let minPasswordLength = 6
}

enum AppStrings {
    static let invalidEmail = "El correo debe terminar en @ceti.mx"
    static let passwordTooShort = "La contraseña debe tener al menos 6 caracteres"
    static let passwordsDoNotMatch = "Las contraseñas no coinciden"
    static let loginFailed = "Error al iniciar sesión"
    static let registerFailed = "Error al registrarse"
}
