//
//  CalendarView.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import SwiftUI

struct CalendarView: View {
    @StateObject private var calendarVM = CalendarViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var selectedAvailability: Availability?
    @State private var showDetail = false

    var body: some View {
        NavigationView {
            List(calendarVM.availabilities) { availability in
                Button(action: {
                    selectedAvailability = availability
                    showDetail = true
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(availability.date)
                                .font(.headline)
                            Text("\(availability.startTime) - \(availability.endTime)")
                                .font(.subheadline)
                        }
                        Spacer()
                        if availability.isBooked {
                            Text("No disponible")
                                .foregroundColor(.red)
                                .font(.caption)
                        } else {
                            Text("Disponible")
                                .foregroundColor(.green)
                                .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("Calendario semanal")
            .onAppear {
                calendarVM.fetchAvailabilities()
            }
            .sheet(isPresented: $showDetail) {
                if let availability = selectedAvailability {
                    AvailabilityDetailView(availability: availability)
                        .environmentObject(authViewModel)
                }
            }
        }
    }
}
