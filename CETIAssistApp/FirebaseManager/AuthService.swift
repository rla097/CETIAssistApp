//
//  AuthService.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthService {

    static let shared = AuthService()

    private let auth = FirebaseManager.shared.auth
    private let firestore = FirebaseManager.shared.firestore

    // MARK: - Registro
    func registerUser(email: String, password: String, role: String, completion: @escaping (Result<Void, Error>) -> Void) {
        auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let user = result?.user else {
                completion(.failure(NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Usuario no encontrado."])))
                return
            }

            let userData: [String: Any] = [
                "uid": user.uid,
                "email": email,
                "role": role,
                "createdAt": Timestamp(date: Date())
            ]

            self.firestore.collection("users").document(user.uid).setData(userData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }

    // MARK: - Login
    func loginUser(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    // MARK: - Logout
    func logoutUser(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try auth.signOut()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
}
