//
//  AvailabilityDetailView.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import SwiftUI
import FirebaseAuth

struct AvailabilityDetailView: View {
    let availability: Availability
    @ObservedObject var availabilityVM: AvailabilityViewModel

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var isBooking: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""

    // Si el usuario actual es el profesor dueño, ocultamos el CTA de “Agendar”
    private var isOwner: Bool {
        Auth.auth().currentUser?.uid == availability.professorId
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerCard

                infoCard

                if showUnavailableBanner {
                    unavailableBanner
                }

                if showBookCTA {
                    bookCTA
                }
            }
            .padding()
        }
        .navigationTitle("Detalle de asesoría")
        .navigationBarTitleDisplayMode(.inline)
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK") {
                if alertTitle == "Éxito" { dismiss() }
            }
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - Header

    private var headerCard: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            VStack(alignment: .leading, spacing: 10) {
                // Materia
                Text(availability.subject)
                    .font(.title2).bold()
                    .foregroundStyle(.white)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    Chip(text: availability.modality.displayName,
                         systemImage: availability.modality == .virtual ? "laptopcomputer" : "mappin.and.ellipse")
                    Chip(text: availability.isAvailable ? "Disponible" : "Reservada",
                         systemImage: availability.isAvailable ? "checkmark.circle.fill" : "xmark.circle.fill",
                         tint: availability.isAvailable ? .white.opacity(0.9) : .white.opacity(0.6))
                }

                HStack(spacing: 10) {
                    Pill(systemImage: "calendar", text: availability.date)
                    Pill(systemImage: "clock", text: "\(availability.startTime) – \(availability.endTime)")
                }
                .padding(.top, 4)

                HStack(spacing: 8) {
                    Image(systemName: "person.fill")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                    Text(availability.professorName)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.top, 4)
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 160)
    }

    private var gradientColors: [Color] {
        if availability.modality == .presencial {
            return [Color.blue, Color.indigo]
        } else {
            return [Color.purple, Color.blue]
        }
    }

    // MARK: - Info Card

    private var infoCard: some View {
        VStack(spacing: 14) {
            // Modalidad
            InfoRow(
                icon: availability.modality == .virtual ? "wifi" : "building.2",
                title: "Modalidad",
                value: availability.modality.displayName
            )

            // Aula (solo presencial)
            if availability.modality == .presencial,
               let aula = availability.aula, !aula.isEmpty {
                InfoRow(icon: "mappin.and.ellipse", title: "Aula", value: aula)
            }

            // Horario
            InfoRow(icon: "calendar", title: "Fecha", value: availability.date)
            InfoRow(icon: "clock.arrow.circlepath", title: "Horario", value: "\(availability.startTime) – \(availability.endTime)")

            // Estado
            InfoRow(
                icon: availability.isAvailable ? "checkmark.circle" : "xmark.circle",
                title: "Estado",
                value: availability.isAvailable ? "Disponible" : "Reservada",
                valueColor: availability.isAvailable ? .green : .secondary
            )
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.primary.opacity(colorScheme == .dark ? 0.1 : 0.08))
        )
    }

    private var showUnavailableBanner: Bool {
        !availability.isAvailable
    }

    private var unavailableBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.yellow)
            Text("Esta asesoría ya fue reservada.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(12)
        .background(Color.yellow.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - CTA

    private var showBookCTA: Bool {
        // Mostrar CTA solo a alumnos (no dueño) y si está disponible
        availability.isAvailable && !isOwner
    }

    private var bookCTA: some View {
        Button(action: book) {
            HStack {
                if isBooking { ProgressView().tint(.white) }
                Text(isBooking ? "Agendando..." : "Agendar asesoría")
                    .fontWeight(.semibold)
                Image(systemName: "calendar.badge.checkmark")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundStyle(.white)
            .background(
                LinearGradient(
                    colors: [Color.accentColor, Color.accentColor.opacity(0.8)],
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(radius: 6, y: 2)
        }
        .disabled(isBooking)
    }

    // MARK: - Actions

    private func book() {
        guard let user = Auth.auth().currentUser else {
            show("Error", "Debes iniciar sesión para agendar.")
            return
        }
        isBooking = true
        availabilityVM.markAsBooked(id: availability.id, studentId: user.uid) { ok, error in
            isBooking = false
            if let e = error {
                show("Error", e.localizedDescription)
            } else if ok {
                show("Éxito", "La asesoría fue agendada correctamente.")
            } else {
                show("Error", "No se pudo agendar la asesoría.")
            }
        }
    }

    private func show(_ title: String, _ message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}

// MARK: - Aux UI Components

private struct Chip: View {
    let text: String
    var systemImage: String? = nil
    var tint: Color = .white.opacity(0.9)

    var body: some View {
        HStack(spacing: 6) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.caption)
            }
            Text(text)
                .font(.caption).bold()
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.18))
        .clipShape(Capsule())
    }
}

private struct Pill: View {
    let systemImage: String
    let text: String
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.caption)
            Text(text)
                .font(.caption).bold()
        }
        .foregroundStyle(.white.opacity(0.95))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.white.opacity(0.18))
        .clipShape(Capsule())
    }
}

private struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    var valueColor: Color = .primary

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Image(systemName: icon)
                .font(.headline)
                .frame(width: 24)
                .foregroundColor(.accentColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
                    .foregroundColor(valueColor)
                    .bold()
            }

            Spacer()
        }
    }
}

#Preview {
    let sample = Availability(
        id: "demo",
        professorId: "p1",
        professorName: "Profa. Demo",
        date: "2025-10-10",
        startTime: "10:00",
        endTime: "11:00",
        isAvailable: true,
        subject: "Cálculo I",
        modality: .presencial,
        aula: "Aula 205"
    )
    return NavigationView {
        AvailabilityDetailView(availability: sample, availabilityVM: AvailabilityViewModel())
    }
}
