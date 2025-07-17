//
//  CETIAssistAppApp.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import SwiftUI
import Firebase

@main
struct CETIAssistApp: App {
    @StateObject private var authViewModel = AuthViewModel()

    init() {
        FirebaseApp.configure() // ✅ SOLO AQUÍ
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isLoading {
                    LoadingView()
                } else if authViewModel.user == nil {
                    WelcomeView()
                        .environmentObject(authViewModel)
                } else {
                    switch authViewModel.userRole {
                    case .alumno:
                        StudentHomeView()
                            .environmentObject(authViewModel)
                    case .profesor:
                        ProfessorHomeView()
                            .environmentObject(authViewModel)
                    case .none:
                        LoadingView()
                    }
                }
            }
        }
    }
}
