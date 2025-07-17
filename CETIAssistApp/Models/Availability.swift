//
//  Availability.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import Foundation

struct Availability: Identifiable {
    let id: String
    let professorId: String
    let professorName: String
    let date: String
    let startTime: String
    let endTime: String
    let isAvailable: Bool
}
