//
//  CalendarView.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import SwiftUI

struct CalendarView: View {
    @StateObject private var availabilityVM = AvailabilityViewModel()
    @State private var modalityFilter: ModalityFilter = .all

    var body: some View {
        ZStack {
            // Fondo sutil
            LinearGradient(
                colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Filtro por modalidad
                Picker("Modalidad", selection: $modalityFilter) {
                    ForEach(ModalityFilter.allCases) { f in
                        Text(f.title).tag(f)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)

                // Contenido principal
                ScrollView {
                    LazyVStack(spacing: 14) {
                        if availabilityVM.isLoading && availabilityVM.items.isEmpty {
                            ProgressView("Cargando asesorías…")
                                .frame(maxWidth: .infinity, minHeight: 160)
                        } else if filteredItems.isEmpty {
                            EmptyStateCard()
                                .padding(.horizontal)
                        } else {
                            ForEach(filteredItems) { item in
                                NavigationLink {
                                    AvailabilityDetailView(availability: item, availabilityVM: availabilityVM)
                                } label: {
                                    AvailabilityCardRow(availability: item)
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .refreshable { availabilityVM.startListening(professorId: nil) }
            }
        }
        // ⬇️ Estos títulos funcionan aunque este view no tenga su propio NavigationView,
        // el contenedor superior (StudentHomeView) los aplicará.
        .navigationTitle("Asesorías")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { availabilityVM.startListening(professorId: nil) }
        .onDisappear { availabilityVM.stopListening() }
    }

    // Filtro en memoria (el VM ya entrega solo disponibles futuras)
    private var filteredItems: [Availability] {
        availabilityVM.items.filter {
            switch modalityFilter {
            case .all: true
            case .virtual: $0.modality == .virtual
            case .presencial: $0.modality == .presencial
            }
        }
    }
}

// MARK: - Card Row

private struct AvailabilityCardRow: View {
    let availability: Availability
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Avatar/Icono
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: accentColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 44, height: 44)
                Image(systemName: availability.modality == .virtual ? "laptopcomputer" : "mappin.and.ellipse")
                    .foregroundStyle(.white)
                    .font(.system(size: 18, weight: .semibold))
            }

            VStack(alignment: .leading, spacing: 6) {
                // Título + chip modalidad
                HStack(alignment: .firstTextBaseline) {
                    Text(availability.subject)
                        .font(.headline)
                        .lineLimit(2)
                    Spacer(minLength: 8)
                    ChipSmall(text: availability.modality.displayName)
                }

                // Fecha y horario
                HStack(spacing: 10) {
                    Label(availability.date, systemImage: "calendar")
                    Label("\(availability.startTime) – \(availability.endTime)", systemImage: "clock")
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                // Aula (solo si presencial)
                if availability.modality == .presencial, let aula = availability.aula, !aula.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "building.2")
                        Text("Aula: \(aula)")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.primary.opacity(colorScheme == .dark ? 0.12 : 0.08))
        )
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.06), radius: 8, x: 0, y: 3)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(availability.subject), \(availability.modality.displayName), \(availability.date), \(availability.startTime) a \(availability.endTime)")
    }

    private var accentColors: [Color] {
        availability.modality == .presencial ? [Color.blue, Color.indigo] : [Color.purple, Color.blue]
    }
}

// MARK: - Chip pequeño

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

// MARK: - Empty State

private struct EmptyStateCard: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
                .padding(.top, 18)
            Text("No hay asesorías disponibles")
                .font(.headline)
            Text("Vuelve más tarde o ajusta los filtros de modalidad.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
            Spacer(minLength: 4)
        }
        .frame(maxWidth: .infinity, minHeight: 140)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08))
        )
    }
}

// MARK: - Filtro de modalidad

private enum ModalityFilter: String, CaseIterable, Identifiable {
    case all, virtual, presencial
    var id: String { rawValue }
    var title: String {
        switch self {
        case .all: "Todas"
        case .virtual: "Virtual"
        case .presencial: "Presencial"
        }
    }
}

#Preview {
    // Para previsualizar, envolvemos manualmente en NavigationView
    NavigationView { CalendarView() }
}
