//
//  RegisterView.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var displayName: String = ""
    @State private var selectedRole: UserRole? = nil

    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("Crear cuenta")
                .font(.largeTitle)
                .bold()

            TextField("Nombre completo", text: $displayName)
                .autocapitalization(.words)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)

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

            SecureField("Confirmar contraseña", text: $confirmPassword)
                .textContentType(.password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)

            HStack {
                Button(action: {
                    selectedRole = .alumno
                }) {
                    Text("Alumno")
                        .foregroundColor(selectedRole == .alumno ? .white : .blue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedRole == .alumno ? Color.blue : Color.clear)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                }

                Button(action: {
                    selectedRole = .profesor
                }) {
                    Text("Profesor")
                        .foregroundColor(selectedRole == .profesor ? .white : .blue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedRole == .profesor ? Color.blue : Color.clear)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                }
            }

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button(action: register) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Registrarse")
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

    private func register() {
        // Validaciones
        guard email.lowercased().hasSuffix("@ceti.mx") else {
            errorMessage = "El correo debe terminar en @ceti.mx"
            return
        }

        guard !password.isEmpty else {
            errorMessage = "La contraseña no puede estar vacía"
            return
        }

        guard password.count >= 6 else {
            errorMessage = "La contraseña debe tener al menos 6 caracteres"
            return
        }

        guard password == confirmPassword else {
            errorMessage = "Las contraseñas no coinciden"
            return
        }

        guard !displayName.isEmpty else {
            errorMessage = "Por favor ingresa tu nombre"
            return
        }

        guard let selectedRole = selectedRole else {
            errorMessage = "Debes seleccionar si eres alumno o profesor"
            return
        }

        isLoading = true
        errorMessage = nil

        authViewModel.register(email: email, password: password, displayName: displayName, role: selectedRole) { success, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorMessage = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}
