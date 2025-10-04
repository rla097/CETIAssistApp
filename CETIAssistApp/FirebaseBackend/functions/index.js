//
//  index.js
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { validateBooking } = require("./services/validateBooking");

// Inicializa Firebase Admin si no está inicializado
if (!admin.apps.length) {
  admin.initializeApp();
}

admin.initializeApp();

/**
 * Endpoint HTTPS para validar una reserva
 */
exports.validateReservation = functions.https.onCall(async (data, context) => {
  const { studentId, availabilityId } = data;

  if (!studentId || !availabilityId) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Parámetros incompletos: se requiere studentId y availabilityId"
    );
  }

  try {
    const validation = await validateBooking(studentId, availabilityId);

    if (!validation.valid) {
      throw new functions.https.HttpsError("failed-precondition", validation.message);
    }

    return { valid: true, message: "Reserva válida" };

  } catch (error) {
    console.error("❌ Error en validateReservation:", error);
    throw new functions.https.HttpsError(
      "internal",
      error.message || "Error interno en la validación"
    );
  }
});

/**
 * 🧹 Nueva función HTTPS para obtener asesorías disponibles
 * - Elimina asesorías con fecha anterior a la actual
 * - Devuelve solo las asesorías futuras
 */
exports.getAvailableSessions = functions.https.onCall(async (data, context) => {
  const db = admin.firestore();
  const today = new Date();
  today.setHours(0, 0, 0, 0); // solo compara fechas, no horas

  try {
    const snapshot = await db.collection("asesorias").get();

    if (snapshot.empty) {
      console.log("No se encontraron asesorías registradas.");
      return [];
    }

    const validSessions = [];
    const batch = db.batch();

    snapshot.forEach((doc) => {
      const asesoría = doc.data();
      let fecha;

      // Soporta tanto Timestamp como String ISO
      if (asesoría.fecha?.toDate) {
        fecha = asesoría.fecha.toDate();
      } else {
        fecha = new Date(asesoría.fecha);
      }

      if (fecha < today) {
        console.log(`🗑 Eliminando asesoría pasada: ${doc.id} (${fecha})`);
        batch.delete(doc.ref);
      } else {
        validSessions.push({
          id: doc.id,
          ...asesoría,
        });
      }
    });

    // Aplica los cambios si hay asesorías viejas
    if (!batch._ops || batch._ops.length > 0) {
      await batch.commit();
      console.log("✅ Asesorías antiguas eliminadas.");
    }

    console.log(`📅 Asesorías vigentes: ${validSessions.length}`);
    return validSessions;

  } catch (error) {
    console.error("❌ Error en getAvailableSessions:", error);
    throw new functions.https.HttpsError(
      "internal",
      error.message || "Error al obtener asesorías disponibles"
    );
  }
});
