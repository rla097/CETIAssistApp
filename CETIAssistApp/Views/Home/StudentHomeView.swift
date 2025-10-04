//
//  StudentHomeView.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import SwiftUI
import FirebaseAuth

struct StudentHomeView: View {
    // Nombre del alumno (Auth). Fallback: usuario del email o "Alumno"
    private var fullName: String {
        if let n = Auth.auth().currentUser?.displayName, !n.trimmingCharacters(in: .whitespaces).isEmpty {
            return n
        }
        if let email = Auth.auth().currentUser?.email, let user = email.split(separator: "@").first {
            return user.replacingOccurrences(of: ".", with: " ").capitalized
        }
        return "Alumno"
    }
    private var firstName: String {
        let parts = fullName.split(separator: " ")
        return parts.first.map(String.init) ?? fullName
    }
    private var initials: String {
        let parts = fullName.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }.map { String($0) }
        return letters.joined().uppercased()
    }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        headerCard

                        // Acción principal: ir a asesorías disponibles
                        NavigationLink {
                            CalendarView() // Tu lista de asesorías (ya estilizada)
                        } label: {
                            PrimaryCTA(
                                title: "Ver asesorías disponibles",
                                subtitle: "Explora por fecha, modalidad y agenda tu lugar",
                                systemImage: "calendar.badge.checkmark"
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)

                        // (Opcional) atajos o info adicional aquí…

                        Spacer(minLength: 12)
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
            }
            // 🔵 Cambiamos el título de navegación:
            .navigationTitle("Bienvenido, \(firstName)")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Header con gradiente
    private var headerCard: some View {
        ZStack {
            LinearGradient(
                colors: [Color.indigo, Color.blue],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.18))
                        .frame(width: 64, height: 64)
                    Text(initials)
                        .font(.title3).bold()
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("¡Hola, \(firstName)!")
                        .font(.title2).bold()
                        .foregroundStyle(.white)

                    Text("Encuentra y agenda asesorías de forma rápida.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                        .lineLimit(2)
                }

                Spacer()
            }
            .padding()
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, minHeight: 110)
    }
}

// MARK: - Componentes auxiliares

private struct PrimaryCTA: View {
    let title: String
    let subtitle: String
    let systemImage: String

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(LinearGradient(colors: [Color.accentColor, Color.accentColor.opacity(0.7)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 52, height: 52)
                Image(systemName: systemImage)
                    .foregroundStyle(.white)
                    .font(.system(size: 22, weight: .semibold))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.primary.opacity(colorScheme == .dark ? 0.12 : 0.08))
        )
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.06), radius: 8, x: 0, y: 3)
    }
}

#Preview {
    StudentHomeView()
}
