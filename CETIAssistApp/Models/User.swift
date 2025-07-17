//
//  User.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import Foundation

struct AppUser: Identifiable {
    let id: String      // UID de Firebase Auth
    let email: String
    let role: String    // "alumno" o "profesor"
}
