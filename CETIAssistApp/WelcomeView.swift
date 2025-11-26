//
//  ContentView.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                Image("CetiPeersLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)

                NavigationLink(destination: LoginView()) {
                    Text("Iniciar Sesión")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }

                NavigationLink(destination: RegisterView()) {
                    Text("Registrarse")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                }

                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    WelcomeView()
}
