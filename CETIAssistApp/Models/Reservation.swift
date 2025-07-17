//
//  Reservation.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import Foundation

struct Reservation: Identifiable {
    let id: String
    let studentId: String
    let availabilityId: String
    let reservedAt: Date
}
