//
//  AuthViewModel.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

enum UserRole {
    case alumno
    case profesor
}

class AuthViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var userRole: UserRole? = nil
    @Published var isLoading: Bool = true

    private var db = Firestore.firestore()
    private var authListener: AuthStateDidChangeListenerHandle?

    init() {
        listenToAuthState()
    }

    // Escuchar cambios en la sesión de Firebase Auth
    private func listenToAuthState() {
        isLoading = true

        authListener = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self else { return }
            self.user = user
            if let user = user {
                self.fetchUserRole(uid: user.uid)
            } else {
                self.userRole = nil
                self.isLoading = false
            }
        }
    }

    // Leer rol del usuario desde Firestore
    private func fetchUserRole(uid: String) {
        let docRef = db.collection("users").document(uid)

        docRef.getDocument { [weak self] document, error in
            guard let self = self else { return }

            if let document = document, document.exists {
                let data = document.data()
                if let role = data?["role"] as? String {
                    if role == "alumno" {
                        self.userRole = .alumno
                    } else if role == "profesor" {
                        self.userRole = .profesor
                    }
                }
            } else {
                print("⚠️ Usuario no encontrado en Firestore")
            }
            self.isLoading = false
        }
    }

    // Método para cerrar sesión (llamado desde la vista)
    func logout() {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.userRole = nil
        } catch {
            print("❌ Error al cerrar sesión: \(error.localizedDescription)")
        }
    }

    deinit {
        // Limpia el listener cuando se destruye el ViewModel
        if let handle = authListener {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
