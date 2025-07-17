//
//  validateBooking.js
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

const admin = require("firebase-admin");
const db = admin.firestore();

/**
 * Verifica si una disponibilidad aún está disponible
 * @param {string} availabilityId
 * @returns {Promise<boolean>}
 */
async function isAvailabilityAvailable(availabilityId) {
  const doc = await db.collection("availability").doc(availabilityId).get();
  if (!doc.exists) return false;

  const data = doc.data();
  return data.isAvailable === true;
}

/**
 * Verifica si el alumno ya ha reservado esa disponibilidad
 * @param {string} studentId
 * @param {string} availabilityId
 * @returns {Promise<boolean>}
 */
async function hasStudentAlreadyReserved(studentId, availabilityId) {
  const snapshot = await db.collection("reservations")
    .where("studentId", "==", studentId)
    .where("availabilityId", "==", availabilityId)
    .get();

  return !snapshot.empty;
}

/**
 * Valida que se pueda realizar una reserva
 * @param {string} studentId
 * @param {string} availabilityId
 * @returns {Promise<{ valid: boolean, message?: string }>}
 */
async function validateBooking(studentId, availabilityId) {
  const isAvailable = await isAvailabilityAvailable(availabilityId);
  if (!isAvailable) {
    return { valid: false, message: "La asesoría ya fue reservada." };
  }

  const alreadyReserved = await hasStudentAlreadyReserved(studentId, availabilityId);
  if (alreadyReserved) {
    return { valid: false, message: "Ya reservaste esta asesoría." };
  }

  return { valid: true };
}

module.exports = {
  validateBooking
};
