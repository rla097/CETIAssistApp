//
//  validateBooking.js
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

const admin = require("firebase-admin");
const db = admin.firestore();

async function isAvailabilityAvailable(availabilityId) {
  const doc = await db.collection("availability").doc(availabilityId).get();
  if (!doc.exists) return false;

  const data = doc.data();
  return data.isAvailable === true;
}

async function hasStudentAlreadyReserved(studentId, availabilityId) {
  const snapshot = await db.collection("reservations")
    .where("studentId", "==", studentId)
    .where("availabilityId", "==", availabilityId)
    .get();

  return !snapshot.empty;
}

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
