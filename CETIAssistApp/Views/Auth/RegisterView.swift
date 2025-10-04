//
//  RegisterView.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    // Campos de registro
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var displayName: String = ""
    @State private var selectedRole: UserRole = .alumno

    // Materias (solo profesor)
    @State private var subjects: [String] = []
    @State private var newSubject: String = ""

    // Estado de UI
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Crear cuenta")
                    .font(.largeTitle).bold()

                if let error = errorMessage ?? authViewModel.errorMessage, !error.isEmpty {
                    ErrorBanner(text: error)
                }

                Group {
                    TextField("Nombre para mostrar", text: $displayName)
                        .textContentType(.name)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)

                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)

                    SecureField("Contraseña", text: $password)
                        .textContentType(.newPassword)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)

                    SecureField("Confirmar contraseña", text: $confirmPassword)
                        .textContentType(.newPassword)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                }

                // Rol
                VStack(alignment: .leading, spacing: 8) {
                    Text("Rol").font(.headline)
                    Picker("Rol", selection: $selectedRole) {
                        Text("Alumno").tag(UserRole.alumno)
                        Text("Profesor").tag(UserRole.profesor)
                    }
                    .pickerStyle(.segmented)
                }

                // Materias (solo si Profesor)
                if selectedRole == .profesor {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Materias que ofreces").font(.headline)

                        HStack(spacing: 8) {
                            TextField("Añadir materia (p. ej. Cálculo)", text: $newSubject)
                                .textInputAutocapitalization(.words)
                                .autocorrectionDisabled()
                                .padding(12)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(10)

                            Button {
                                addSubject()
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                            }
                            .disabled(newSubject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            .buttonStyle(.plain)
                            .accessibilityLabel("Agregar materia")
                        }

                        if subjects.isEmpty {
                            Text("Agrega al menos una materia para poder publicar asesorías.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        } else {
                            // Lista simple con opción de borrar
                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(subjects, id: \.self) { s in
                                    HStack {
                                        Text(s)
                                            .font(.subheadline)
                                        Spacer()
                                        Button(role: .destructive) {
                                            withAnimation { subjects.removeAll { $0 == s } }
                                        } label: {
                                            Image(systemName: "trash")
                                        }
                                        .buttonStyle(.borderless)
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(Color(.tertiarySystemBackground))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                }

                // Botón crear cuenta
                Button {
                    register()
                } label: {
                    HStack {
                        if isLoading { ProgressView().tint(.white) }
                        Text("Crear cuenta").bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isRegisterDisabled ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(isRegisterDisabled)

                // Volver
                Button(role: .cancel) {
                    dismiss()
                } label: {
                    Text("Cancelar")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .padding(.top, 4)

                Spacer(minLength: 16)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var isRegisterDisabled: Bool {
        if isLoading { return true }
        if email.isEmpty || displayName.isEmpty { return true }
        if password.isEmpty || confirmPassword.isEmpty { return true }
        if password != confirmPassword { return true }
        if selectedRole == .profesor && subjects.isEmpty { return true }
        return false
    }

    private func addSubject() {
        let trimmed = newSubject.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        // Evita duplicados (case-insensitive)
        if !subjects.contains(where: { $0.compare(trimmed, options: .caseInsensitive) == .orderedSame }) {
            withAnimation { subjects.append(trimmed) }
        }
        newSubject = ""
    }

    private func register() {
        errorMessage = nil
        isLoading = true

        authViewModel.register(
            email: email,
            password: password,
            displayName: displayName,
            role: selectedRole,
            subjects: (selectedRole == .profesor) ? subjects : []
        ) { success, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorMessage = "Error: \(error.localizedDescription)"
                } else if success {
                    // El listener del AuthViewModel actualizará el estado y
                    // la navegación padre debería reaccionar. Cerramos esta vista.
                    dismiss()
                }
            }
        }
    }
}

// MARK: - ErrorBanner
private struct ErrorBanner: View {
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
            Text(text)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundColor(Color.white)
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red)
        .cornerRadius(10)
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
            .environmentObject(AuthViewModel())
    }
}
