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

    var rawValue: String {
        switch self {
        case .alumno: return "alumno"
        case .profesor: return "profesor"
        }
    }

    init?(from string: String) {
        switch string.lowercased() {
        case "alumno": self = .alumno
        case "profesor": self = .profesor
        default: return nil
        }
    }
}

class AuthViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var userRole: UserRole? = nil
    @Published var isLoading: Bool = true

    private var db = FirebaseManager.shared.firestore
    private var auth = FirebaseManager.shared.auth
    private var authListener: AuthStateDidChangeListenerHandle?

    init() {
        listenToAuthState()
    }

    // Escuchar cambios de sesión
    private func listenToAuthState() {
        isLoading = true

        authListener = auth.addStateDidChangeListener { [weak self] auth, user in
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

            if let document = document, document.exists,
               let data = document.data(),
               let roleString = data["role"] as? String,
               let role = UserRole(from: roleString) {
                self.userRole = role
            } else {
                print("⚠️ Usuario no encontrado o sin rol válido")
            }

            self.isLoading = false
        }
    }

    // Registro de usuario
    func register(email: String, password: String, displayName: String, role: UserRole, completion: @escaping (Bool, Error?) -> Void) {
        auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(false, error)
                return
            }

            guard let user = result?.user else {
                completion(false, nil)
                return
            }

            // Guardar nombre en Firebase Auth
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            changeRequest.commitChanges { _ in }

            // Datos a guardar en Firestore
            let userData: [String: Any] = [
                "uid": user.uid,
                "email": email,
                "displayName": displayName,
                "role": role.rawValue
            ]

            self.db.collection("users").document(user.uid).setData(userData) { err in
                if let err = err {
                    print("❌ Error al guardar en Firestore: \(err.localizedDescription)")
                    completion(false, err)
                } else {
                    print("✅ Usuario registrado con éxito")
                    completion(true, nil)
                }
            }
        }
    }

    // Cerrar sesión
    func signOut() {
        do {
            try auth.signOut()
            self.user = nil
            self.userRole = nil
        } catch {
            print("❌ Error al cerrar sesión: \(error.localizedDescription)")
        }
    }

    deinit {
        if let handle = authListener {
            auth.removeStateDidChangeListener(handle)
        }
    }
}
