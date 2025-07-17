//
//  sendEmail.js
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

const nodemailer = require("nodemailer");
const functions = require("firebase-functions");

// 🔐 Puedes almacenar estas credenciales en funciones.config()
const gmailEmail = functions.config().gmail.email;
const gmailPassword = functions.config().gmail.password;

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: gmailEmail,
    pass: gmailPassword,
  },
});

/**
 * Envía un correo con los datos proporcionados
 * @param {Object} mailOptions
 * @returns {Promise}
 */
function sendEmail(mailOptions) {
  return transporter.sendMail(mailOptions);
}

module.exports = { sendEmail };
