//
//  LoginView.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Iniciar Sesión")
                .font(.largeTitle)
                .bold()

            TextField("Correo institucional", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)

            SecureField("Contraseña", text: $password)
                .textContentType(.password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button(action: login) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Iniciar Sesión")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }

            Spacer()
        }
        .padding()
    }

    private func login() {
        guard email.lowercased().hasSuffix("@ceti.mx") else {
            errorMessage = "El correo debe terminar en @ceti.mx"
            return
        }

        guard !password.isEmpty else {
            errorMessage = "La contraseña no puede estar vacía"
            return
        }

        isLoading = true
        errorMessage = nil

        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                isLoading = false

                if let error = error {
                    errorMessage = "Error al iniciar sesión: \(error.localizedDescription)"
                } else {
                    errorMessage = nil
                    // El cambio de vista será manejado por AuthViewModel automáticamente
                }
            }
        }
    }
}
