//
//  sendEmail.js
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

const nodemailer = require("nodemailer");
const functions = require("firebase-functions");

const gmailEmail = functions.config().gmail.email;
const gmailPassword = functions.config().gmail.password;

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: gmailEmail,
    pass: gmailPassword,
  },
});

function sendEmail(mailOptions) {
  return transporter.sendMail(mailOptions);
}

module.exports = { sendEmail };
