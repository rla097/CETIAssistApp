//
//  FirebaseManager.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore

final class FirebaseManager {
    static let shared = FirebaseManager()

    let auth: Auth
    let firestore: Firestore

    private init() {
        self.auth = Auth.auth()
        self.firestore = Firestore.firestore()
    }
}
