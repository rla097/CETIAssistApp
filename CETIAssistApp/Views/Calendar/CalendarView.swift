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
        NavigationView {
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

                contentList
            }
            .navigationTitle("Asesorías")
            .onAppear { availabilityVM.startListening(professorId: nil) }
            .onDisappear { availabilityVM.stopListening() }
        }
    }

    private var contentList: some View {
        Group {
            if availabilityVM.isLoading && availabilityVM.items.isEmpty {
                ProgressView("Cargando asesorías…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if filteredItems.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.largeTitle)
                        .padding(.top, 40)
                    Text("No hay asesorías disponibles").font(.headline)
                    Text("Vuelve más tarde.").foregroundColor(.secondary).font(.subheadline)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal)
            } else {
                List {
                    ForEach(filteredItems) { item in
                        NavigationLink {
                            AvailabilityDetailView(availability: item, availabilityVM: availabilityVM)
                        } label: {
                            availabilityRow(item) // contenido visual de la fila
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .refreshable {
                    availabilityVM.startListening(professorId: nil)
                }
            }
        }
    }

    private var filteredItems: [Availability] {
        availabilityVM.items.filter { item in
            switch modalityFilter {
            case .all: return true
            case .virtual: return item.modality == .virtual
            case .presencial: return item.modality == .presencial
            }
        }
    }

    @ViewBuilder
    private func availabilityRow(_ a: Availability) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(a.subject).font(.headline)
                Spacer()
                Text(a.modality.displayName)
                    .font(.caption)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.15))
                    .clipShape(Capsule())
            }
            Text("\(a.date) • \(a.startTime) – \(a.endTime)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            if a.modality == .presencial, let aula = a.aula, !aula.isEmpty {
                Text("Aula: \(aula)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 6)
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

#Preview { CalendarView() }
