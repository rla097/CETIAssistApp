//
//  AuthViewModel.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

// MARK: - Roles
enum UserRole: Equatable {
    case alumno
    case profesor

    var rawValue: String {
        switch self {
        case .alumno:  return "alumno"
        case .profesor:return "profesor"
        }
    }

    init?(from raw: String) {
        switch raw.lowercased() {
        case "alumno":   self = .alumno
        case "profesor": self = .profesor
        default:         return nil
        }
    }
}

// MARK: - ViewModel
@MainActor
final class AuthViewModel: ObservableObject {

    // Firebase
    private let auth = FirebaseManager.shared.auth
    private let db   = FirebaseManager.shared.firestore

    private var authListener: AuthStateDidChangeListenerHandle?

    // Estado expuesto a la UI
    @Published var user: FirebaseAuth.User?
    @Published var userRole: UserRole?
    @Published var professorSubjects: [String] = []      // NEW: materias del profesor

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Init
    init() {
        // Listener de sesión
        authListener = auth.addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            self.user = user

            // Si hay usuario, trae su documento; si no, limpia estado.
            if let uid = user?.uid {
                Task { await self.loadUserDocument(uid: uid) }
            } else {
                self.userRole = nil
                self.professorSubjects = []
            }
        }
    }

    deinit {
        if let handle = authListener {
            auth.removeStateDidChangeListener(handle)
        }
    }

    // MARK: - Helpers
    private func loadUserDocument(uid: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let snapshot = try await db.collection("users").document(uid).getDocument()
            guard let data = snapshot.data() else {
                self.userRole = nil
                self.professorSubjects = []
                self.isLoading = false
                return
            }

            if let roleString = data["role"] as? String,
               let role = UserRole(from: roleString) {
                self.userRole = role
            } else {
                self.userRole = nil
            }

            // NEW: materias si es profesor
            if self.userRole == .profesor {
                self.professorSubjects = (data["subjects"] as? [String]) ?? []
            } else {
                self.professorSubjects = []
            }

            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.userRole = nil
            self.professorSubjects = []
            self.isLoading = false
        }
    }

    // MARK: - Login
    func login(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        isLoading = true
        errorMessage = nil

        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            Task { @MainActor in
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false, error)
                    return
                }
                // El listener de sesión se encargará de cargar el user doc
                completion(true, nil)
            }
        }
    }

    // MARK: - Registro
    /// Registro de usuario.
    /// `subjects` se usa SOLO si `role == .profesor`.
    func register(
        email: String,
        password: String,
        displayName: String,
        role: UserRole,
        subjects: [String] = [],                         // NEW
        completion: @escaping (Bool, Error?) -> Void
    ) {
        isLoading = true
        errorMessage = nil

        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }

            if let error = error {
                Task { @MainActor in
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    completion(false, error)
                }
                return
            }

            guard let user = result?.user else {
                Task { @MainActor in
                    self.isLoading = false
                    let err = NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No se pudo crear el usuario"])
                    self.errorMessage = err.localizedDescription
                    completion(false, err)
                }
                return
            }

            // Actualizar displayName
            let changeReq = user.createProfileChangeRequest()
            changeReq.displayName = displayName
            changeReq.commitChanges { _ in
                // Ignoramos error de displayName no crítico
            }

            // Datos a guardar en Firestore
            var userData: [String: Any] = [
                "uid": user.uid,
                "email": email,
                "displayName": displayName,
                "role": role.rawValue
            ]

            // NEW: guardar materias si es profesor
            if role == .profesor {
                userData["subjects"] = subjects
            }

            self.db.collection("users").document(user.uid).setData(userData) { err in
                Task { @MainActor in
                    self.isLoading = false
                    if let err = err {
                        self.errorMessage = err.localizedDescription
                        completion(false, err)
                    } else {
                        // Refrescar estado local
                        self.user = user
                        self.userRole = role
                        self.professorSubjects = (role == .profesor) ? subjects : []
                        completion(true, nil)
                    }
                }
            }
        }
    }

    // MARK: - Logout
    func signOut() {
        do {
            try auth.signOut()
            self.user = nil
            self.userRole = nil
            self.professorSubjects = []   // limpiar
        } catch {
            print("❌ Error al cerrar sesión: \(error.localizedDescription)")
        }
    }
}
