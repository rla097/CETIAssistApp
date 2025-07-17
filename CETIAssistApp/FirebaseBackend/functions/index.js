//
//  index.js
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { validateBooking } = require("./services/validateBooking");

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
