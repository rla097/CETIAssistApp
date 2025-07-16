//
//  RegisterView.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var selectedRole: UserRole? = nil

    @State private var errorMessage: String?
    @State private var isLoading: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Crear cuenta")
                    .font(.largeTitle)
                    .bold()

                TextField("Nombre completo", text: $name)
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
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                SecureField("Confirmar contraseña", text: $confirmPassword)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                Picker("Rol", selection: $selectedRole) {
                    Text("Selecciona un rol").tag(nil as UserRole?)
                    Text("Alumno").tag(UserRole.alumno as UserRole?)
                    Text("Profesor").tag(UserRole.profesor as UserRole?)
                }
                .pickerStyle(SegmentedPickerStyle())

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
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
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
    }

    private func register() {
        // Validaciones básicas
        guard !name.isEmpty else {
            errorMessage = "El nombre no puede estar vacío."
            return
        }

        guard email.lowercased().hasSuffix("@ceti.mx") else {
            errorMessage = "El correo debe ser institucional (@ceti.mx)."
            return
        }

        guard !password.isEmpty, password == confirmPassword else {
            errorMessage = "Las contraseñas no coinciden o están vacías."
            return
        }

        guard let role = selectedRole else {
            errorMessage = "Debes seleccionar un rol."
            return
        }

        isLoading = true
        errorMessage = nil

        // Crear cuenta en FirebaseAuth
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Error al registrar: \(error.localizedDescription)"
                    isLoading = false
                }
                return
            }

            guard let user = result?.user else {
                DispatchQueue.main.async {
                    errorMessage = "Error inesperado al crear el usuario."
                    isLoading = false
                }
                return
            }

            // Guardar datos en Firestore
            let db = Firestore.firestore()
            let userData: [String: Any] = [
                "name": name,
                "email": email,
                "role": role == .alumno ? "alumno" : "profesor",
                "createdAt": Timestamp()
            ]

            db.collection("users").document(user.uid).setData([
                "name": name,
                "email": email,
                "role": role == .alumno ? "alumno" : "profesor",
                "createdAt": Timestamp()
            ]) { error in
                DispatchQueue.main.async {
                    isLoading = false
                    if let error = error {
                        errorMessage = "Error al guardar en Firestore: \(error.localizedDescription)"
                    } else {
                        errorMessage = nil
                        // El cambio de pantalla lo maneja automáticamente AuthViewModel
                    }
                }
            }
        }
    }
}
