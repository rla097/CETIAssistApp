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

    // Índice del elemento actualmente enfocado para hacer step arriba/abajo
    @State private var currentIndex: Int? = nil

    var body: some View {
        ScrollViewReader { proxy in
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
                            // ⬆️ ancla de inicio
                            Color.clear.frame(height: 0).id("top")

                            if availabilityVM.isLoading && availabilityVM.items.isEmpty {
                                ProgressView("Cargando asesorías…")
                                    .frame(maxWidth: .infinity, minHeight: 160)
                                    .padding(.horizontal)
                            } else if filteredItems.isEmpty {
                                EmptyStateCard().padding(.horizontal)
                            } else {
                                ForEach(Array(filteredItems.enumerated()), id: \.element.id) { index, item in
                                    NavigationLink {
                                        AvailabilityDetailView(availability: item, availabilityVM: availabilityVM)
                                    } label: {
                                        AvailabilityCardRow(availability: item)
                                            .id(item.id) // importante para scrollTo por elemento
                                            .background(
                                                // leve realce del elemento “enfocado”
                                                (index == (currentIndex ?? -1) ? Color.primary.opacity(0.04) : Color.clear)
                                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                            )
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.horizontal)
                                }
                            }

                            // ⬇️ ancla de fin
                            Color.clear.frame(height: 0).id("bottom")
                        }
                        .padding(.vertical, 8)
                    }
                    .refreshable { availabilityVM.startListening(professorId: nil) }
                }
            }
            .navigationTitle("Asesorías")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                availabilityVM.startListening(professorId: nil)
                // Si ya hay datos al entrar, colocamos foco en el primero
                if let firstIdx = filteredItems.indices.first {
                    currentIndex = firstIdx
                    if let firstId = filteredItems[firstIdx].id as String? {
                        proxy.scrollTo(firstId, anchor: .top)
                    }
                }
            }
            .onDisappear { availabilityVM.stopListening() }

            // 🔘 Botones de scroll por 1 elemento
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        Button {
                            stepUp(proxy: proxy)
                        } label: {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 48, height: 48)
                                .overlay(Image(systemName: "chevron.up").font(.headline))
                                .overlay(Circle().stroke(Color.primary.opacity(0.12)))
                                .shadow(radius: 4, y: 2)
                        }
                        .disabled(isAtTop)

                        Button {
                            stepDown(proxy: proxy)
                        } label: {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 48, height: 48)
                                .overlay(Image(systemName: "chevron.down").font(.headline))
                                .overlay(Circle().stroke(Color.primary.opacity(0.12)))
                                .shadow(radius: 4, y: 2)
                        }
                        .disabled(isAtBottom)
                    }
                    .padding(.trailing, 16)
                }
                .padding(.bottom, 8)   // despega del Home Indicator
            }

            // 🔄 Mantener currentIndex válido cuando cambian los datos
            // OJO: evitamos el requisito de Equatable en Array usando los IDs (String es Equatable)
            .onChange(of: availabilityVM.items.map(\.id)) { _ in
                normalizeCurrentIndexAndAutoFocus(proxy: proxy)
            }
            .onChange(of: filteredItems.map(\.id)) { _ in
                normalizeCurrentIndexAndAutoFocus(proxy: proxy)
            }
            .onChange(of: modalityFilter) { _ in
                // al cambiar filtro, reseteamos al primer elemento (si existe)
                if let first = filteredItems.indices.first {
                    currentIndex = first
                    withAnimation(.easeInOut) {
                        proxy.scrollTo(filteredItems[first].id, anchor: .top)
                    }
                } else {
                    currentIndex = nil
                }
            }
        }
    }

    // MARK: - Helpers de scroll por elemento

    private var hasItems: Bool { !filteredItems.isEmpty }

    private var isAtTop: Bool {
        guard hasItems, let idx = currentIndex else { return true }
        return idx <= filteredItems.startIndex
    }

    private var isAtBottom: Bool {
        guard hasItems, let idx = currentIndex else { return true }
        return idx >= filteredItems.endIndex - 1
    }

    private func normalizeCurrentIndexAndAutoFocus(proxy: ScrollViewProxy) {
        guard hasItems else {
            currentIndex = nil
            return
        }
        // Si el índice actual es nulo o está fuera de rango, colócalo en 0
        if currentIndex == nil || !(filteredItems.indices).contains(currentIndex!) {
            currentIndex = filteredItems.indices.first
        }
        if let idx = currentIndex {
            withAnimation(.easeInOut) {
                proxy.scrollTo(filteredItems[idx].id, anchor: .center)
            }
        }
    }

    private func stepUp(proxy: ScrollViewProxy) {
        guard hasItems else { return }
        let next = max((currentIndex ?? 0) - 1, filteredItems.startIndex)
        currentIndex = next
        withAnimation(.easeInOut) {
            proxy.scrollTo(filteredItems[next].id, anchor: .top)
        }
    }

    private func stepDown(proxy: ScrollViewProxy) {
        guard hasItems else { return }
        let next = min((currentIndex ?? -1) + 1, filteredItems.endIndex - 1)
        currentIndex = next
        withAnimation(.easeInOut) {
            proxy.scrollTo(filteredItems[next].id, anchor: .bottom)
        }
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

// MARK: - Card Row, Empty, Filtro

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
    NavigationView { CalendarView() }
}
