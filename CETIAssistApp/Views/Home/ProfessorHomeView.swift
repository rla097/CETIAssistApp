//
//  ProfessorHomeView.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import SwiftUI
import FirebaseAuth

struct ProfessorHomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @StateObject private var calendarViewModel = CalendarViewModel()
    @StateObject private var availabilityVM = AvailabilityViewModel()

    @State private var isPresentingNewAvailability = false
    @State private var showSignOutConfirm = false

    private let alsoDeletePast = true

    // Nombre (para header)
    private var fullName: String {
        if let n = Auth.auth().currentUser?.displayName, !n.trimmingCharacters(in: .whitespaces).isEmpty { return n }
        if let email = Auth.auth().currentUser?.email, let user = email.split(separator: "@").first {
            return user.replacingOccurrences(of: ".", with: " ").capitalized
        }
        return "Asesor"
    }
    private var firstName: String { fullName.split(separator: " ").first.map(String.init) ?? fullName }
    private var initials: String {
        let parts = fullName.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }.map { String($0) }
        return letters.joined().uppercased()
    }

    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 20) {
                        // ⬆️ ancla de inicio
                        Color.clear.frame(height: 0).id("top")

                        // Header
                        headerCard

                        // CTA publicar
                        Button { isPresentingNewAvailability = true } label: {
                            PrimaryCTA(
                                title: "Publicar nueva asesoría",
                                subtitle: "Define fecha, horario y modalidad",
                                systemImage: "plus.circle.fill"
                            )
                        }
                        .buttonStyle(.plain)

                        // Contenido
                        if calendarViewModel.isLoading && calendarViewModel.availabilities.isEmpty {
                            ProgressView("Cargando asesorías…")
                                .frame(maxWidth: .infinity, minHeight: 140)
                        } else if let error = calendarViewModel.errorMessage {
                            ErrorCard(message: error) {
                                calendarViewModel.startListening(alsoDeletePast: alsoDeletePast)
                            }
                        } else if calendarViewModel.availabilities.isEmpty {
                            EmptyStateCard(
                                title: "Sin asesorías publicadas",
                                subtitle: "Publica tu disponibilidad para asesorar a los alumnos.",
                                systemImage: "calendar.badge.plus"
                            )
                        } else {
                            LazyVStack(spacing: 14) {
                                ForEach(calendarViewModel.availabilities, id: \.id) { a in
                                    NavigationLink {
                                        AvailabilityDetailView(availability: a, availabilityVM: availabilityVM)
                                    } label: {
                                        ProfessorAvailabilityCardRow(availability: a)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        // Cerrar sesión
                        Button { showSignOutConfirm = true } label: {
                            DestructiveCTA(
                                title: "Cerrar sesión",
                                systemImage: "rectangle.portrait.and.arrow.right"
                            )
                        }
                        .buttonStyle(.plain)

                        Spacer(minLength: 12)

                        // ⬇️ ancla de fin
                        Color.clear.frame(height: 0).id("bottom")
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                    .padding(.horizontal)
                }
                .background(
                    LinearGradient(
                        colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
                        startPoint: .top, endPoint: .bottom
                    )
                    .ignoresSafeArea()
                )
                .navigationTitle("Inicio Asesor")
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $isPresentingNewAvailability) {
                    NewAvailabilityView().environmentObject(authViewModel)
                }
                .onAppear { calendarViewModel.startListening(alsoDeletePast: alsoDeletePast) }
                .onDisappear { calendarViewModel.stopListening() }
                .alert("Cerrar sesión", isPresented: $showSignOutConfirm) {
                    Button("Cancelar", role: .cancel) {}
                    Button("Cerrar sesión", role: .destructive) { authViewModel.signOut() }
                } message: { Text("¿Seguro que deseas cerrar tu sesión?") }

                // 🔘 Botones de scroll SIEMPRE visibles (ajusta si quieres condicionar por cantidad)
                .safeAreaInset(edge: .bottom) {
                    HStack {
                        Spacer()
                        VStack(spacing: 10) {
                            Button {
                                withAnimation(.easeInOut) { proxy.scrollTo("top", anchor: .top) }
                            } label: {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 48, height: 48)
                                    .overlay(Image(systemName: "chevron.up").font(.headline))
                                    .overlay(Circle().stroke(Color.primary.opacity(0.12)))
                                    .shadow(radius: 4, y: 2)
                            }
                            Button {
                                withAnimation(.easeInOut) { proxy.scrollTo("bottom", anchor: .bottom) }
                            } label: {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 48, height: 48)
                                    .overlay(Image(systemName: "chevron.down").font(.headline))
                                    .overlay(Circle().stroke(Color.primary.opacity(0.12)))
                                    .shadow(radius: 4, y: 2)
                            }
                        }
                        .padding(.trailing, 16)
                    }
                    .padding(.bottom, 8)
                }
            }
        }
    }

    // Header
    private var headerCard: some View {
        ZStack {
            LinearGradient(colors: [Color.indigo, Color.blue],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

            HStack(spacing: 16) {
                ZStack {
                    Circle().fill(Color.white.opacity(0.18)).frame(width: 64, height: 64)
                    Text(initials).font(.title3).bold().foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("¡Hola, \(firstName)!").font(.title2).bold().foregroundStyle(.white)
                    Text("Gestiona y publica asesorías para tus alumnos.")
                        .font(.subheadline).foregroundStyle(.white.opacity(0.9)).lineLimit(2)
                }
                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: .infinity, minHeight: 110)
    }
}

// ====== Componentes ======

private struct ProfessorAvailabilityCardRow: View {
    let availability: Availability
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: accentColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 44, height: 44)
                Image(systemName: availability.modality == .virtual ? "laptopcomputer" : "mappin.and.ellipse")
                    .foregroundStyle(.white)
                    .font(.system(size: 18, weight: .semibold))
            }
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(availability.subject).font(.headline).lineLimit(2)
                    Spacer(minLength: 8)
                    ChipSmall(text: availability.modality.displayName)
                    StatusPill(isAvailable: availability.isAvailable)
                }
                HStack(spacing: 10) {
                    Label(availability.date, systemImage: "calendar")
                    Label("\(availability.startTime) – \(availability.endTime)", systemImage: "clock")
                }
                .font(.caption).foregroundStyle(.secondary)

                if availability.modality == .presencial, let aula = availability.aula, !aula.isEmpty {
                    HStack(spacing: 8) { Image(systemName: "building.2"); Text("Aula: \(aula)") }
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(.ultraThinMaterial))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Color.primary.opacity(colorScheme == .dark ? 0.12 : 0.08)))
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.06), radius: 8, x: 0, y: 3)
    }

    private var accentColors: [Color] {
        availability.modality == .presencial ? [Color.blue, Color.indigo] : [Color.purple, Color.blue]
    }
}

private struct ChipSmall: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.caption2).bold()
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.secondary.opacity(0.15))
            .clipShape(Capsule())
    }
}

private struct StatusPill: View {
    let isAvailable: Bool
    var body: some View {
        Text(isAvailable ? "Disponible" : "Reservada")
            .font(.caption2).bold()
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background((isAvailable ? Color.green : Color.gray).opacity(0.2))
            .foregroundStyle(isAvailable ? .green : .secondary)
            .clipShape(Capsule())
    }
}

private struct ErrorCard: View {
    let message: String
    let retry: () -> Void
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.yellow).font(.title2)
            Text("Ocurrió un error").font(.headline)
            Text(message).font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
            Button(action: retry) { Label("Reintentar", systemImage: "arrow.clockwise") }
                .padding(.vertical, 6).padding(.horizontal, 12)
                .background(Color.blue.opacity(0.12)).clipShape(Capsule())
        }
        .frame(maxWidth: .infinity, minHeight: 140)
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(.ultraThinMaterial))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Color.primary.opacity(0.08)))
    }
}

private struct EmptyStateCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: systemImage).font(.largeTitle).foregroundStyle(.secondary).padding(.top, 18)
            Text(title).font(.headline)
            Text(subtitle).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal, 8)
            Spacer(minLength: 4)
        }
        .frame(maxWidth: .infinity, minHeight: 140)
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(.ultraThinMaterial))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Color.primary.opacity(0.08)))
    }
}

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
                Image(systemName: systemImage).foregroundStyle(.white).font(.system(size: 22, weight: .semibold))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.subheadline).foregroundStyle(.secondary)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(.ultraThinMaterial))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Color.primary.opacity(colorScheme == .dark ? 0.12 : 0.08)))
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.06), radius: 8, x: 0, y: 3)
    }
}

private struct DestructiveCTA: View {
    let title: String
    let subtitle: String
    let systemImage: String
    init(title: String, systemImage: String, subtitle: String = "") {
        self.title = title
        self.systemImage = systemImage
        self.subtitle = subtitle
    }
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(LinearGradient(colors: [Color.red, Color.red.opacity(0.7)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 52, height: 52)
                Image(systemName: systemImage).foregroundStyle(.white).font(.system(size: 22, weight: .semibold))
            }
            VStack(alignment: .leading, spacing: subtitle.isEmpty ? 0 : 4) {
                Text(title).font(.headline)
                if !subtitle.isEmpty { Text(subtitle).font(.caption).foregroundStyle(.secondary) }
            }
            Spacer()
            Image(systemName: "chevron.right").font(.subheadline).foregroundStyle(.secondary)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(.ultraThinMaterial))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Color.primary.opacity(colorScheme == .dark ? 0.12 : 0.08)))
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.06), radius: 8, x: 0, y: 3)
        .accessibilityLabel("Cerrar sesión")
        .accessibilityHint("Saldrás de tu cuenta actual")
    }
}

#Preview {
    ProfessorHomeView()
        .environmentObject(AuthViewModel())
}
