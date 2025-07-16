//
//  StudentHomeView.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import SwiftUI

struct StudentHomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            VStack {
                Text("Bienvenido, Alumno")
                    .font(.largeTitle)
                    .bold()
                    .padding()

                CalendarView()
                    .environmentObject(authViewModel) // Si CalendarView usa AuthViewModel

                Spacer()

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
                        .padding(.horizontal)
                }
            }
            .navigationTitle("Inicio Alumno")
        }
    }
}

struct StudentHomeView_Previews: PreviewProvider {
    static var previews: some View {
        StudentHomeView()
            .environmentObject(AuthViewModel()) // Proveer el EnvironmentObject para preview
    }
}

