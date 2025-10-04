//
//  getAvailableSessions.js
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 04/10/25.
//

const functions = require("firebase-functions");
const admin = require("firebase-admin");

if (!admin.apps.length) {
  admin.initializeApp();
}

exports.getAvailableSessions = functions.https.onCall(async (data, context) => {
  const today = new Date();
  today.setHours(0, 0, 0, 0); // Comienza desde el inicio del día actual

  const snapshot = await admin.firestore().collection("asesorias").get();

  const validSessions = [];
  const batch = admin.firestore().batch();

  snapshot.forEach((doc) => {
    const asesoría = doc.data();
    const fecha = asesoría.fecha?.toDate ? asesoría.fecha.toDate() : new Date(asesoría.fecha);

    if (fecha < today) {
      // 🔴 eliminar asesorías pasadas
      batch.delete(doc.ref);
    } else {
      // 🟢 conservar asesorías futuras
      validSessions.push({
        id: doc.id,
        ...asesoría,
      });
    }
  });

  await batch.commit();

  console.log(`Asesorías antiguas eliminadas. Asesorías actuales: ${validSessions.length}`);
  return validSessions;
});
