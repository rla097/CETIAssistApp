//
//  ProfessorHomeView.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import SwiftUI

struct ProfessorHomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingNewAvailability = false

    var body: some View {
        NavigationView {
            VStack {
                Text("Bienvenido, Profesor")
                    .font(.largeTitle)
                    .bold()
                    .padding()

                CalendarView()
                    .environmentObject(authViewModel) // Asumiendo que CalendarView maneja disponibilidad profesor

                Spacer()

                Button(action: {
                    showingNewAvailability = true
                }) {
                    Text("Publicar nueva disponibilidad")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .sheet(isPresented: $showingNewAvailability) {
                    NewAvailabilityView()
                        .environmentObject(authViewModel)
                }

                Button(action: {
                    authViewModel.logout()
                }) {
                    Text("Cerrar sesión")
                        .foregroundColor(.red)
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.top, 10)
            }
            .navigationTitle("Inicio Profesor")
        }
    }
}

struct ProfessorHomeView_Previews: PreviewProvider {
    static var previews: some View {
        ProfessorHomeView()
            .environmentObject(AuthViewModel())
    }
}
