'use strict';

const admin = require('firebase-admin');
const functions = require('firebase-functions');
const moment = require('moment-timezone');
const nodemailer = require('nodemailer');

admin.initializeApp();

const firestore = admin.firestore();
const messaging = admin.messaging();

// Configure the email transport using the default SMTP transport.
const mailTransport = nodemailer.createTransport({
    host: 'ssl0.ovh.net',
    port: 465,
    secure: true,
    auth: {
        user: 'contact@beandbrew.com',
        pass: 'Yell0-Submarine'
    }
});

exports.brews = functions.region('europe-west1').pubsub.schedule('0 */1 * * *')
    .timeZone('Europe/Paris') // Users can choose timezone - default is America/Los_Angeles
    .onRun(async (context) => {
        const currentDate = new Date();
        const before = admin.firestore.Timestamp.fromMillis(currentDate.setMonth(currentDate.getMonth() - 3))
        const brews = firestore.collection('brews');
        const snapshot = await brews.where('status', 'in', [1, 2])
            .where('started_at', '>=', before)
            .where('started_at', '<=', admin.firestore.Timestamp.now()).get();
        if (snapshot.empty) {
            console.log('No matching brews.');
            return;
        }
        snapshot.forEach(async doc => {
            var user;
            const brew = doc.data();
            const started = brew.started_at.toDate();
            const receiptDoc = await firestore.collection('receipts').doc(brew.receipt).get();
            if (receiptDoc.exists) {
                const receipt= receiptDoc.data();
                const userDoc = await firestore.collection('users').doc(brew.creator).get();
                if (userDoc.exists) {
                    user = userDoc.data();
                }
                const name = localizedText(receipt.title, user != null ? user.language : null);
                const title = 'Brassin #' + brew.reference + (name != null ? ' - '+ name : '')
                if (receipt.primaryday != null) {
                    started.setDate(started.getDate() + receipt.primaryday);
                    if (isTime(started)) {
                        const body = receipt.secondaryday == null ? 'Fin du brassin.' : 'Fin de la fermenation primaire.';
                        await sendToDevice(user, title, body, doc.id);
                    }
                }
                if (receipt.secondaryday != null) {
                    started.setDate(new Date(started.getDate() + receipt.secondaryday));
                    if (isTime(started)) {
                        const body = receipt.tertiaryday == null ? 'Fin du brassin.' : 'Fin de la fermenation secondaire.';
                        await sendToDevice(user, title, body, doc.id);
                    }
                }
                if (receipt.tertiaryday != null) {
                    started.setDate(started.getDate() + receipt.tertiaryday);
                    if (isTime(started)) {
                        const body = 'Fin du brassin.';
                        await sendToDevice(user, title, body, doc.id);
                    }
                }
            }
        });
        return null;
    }
);

const sendToTopic = async (topic, title, body, id, model) => {
    await messaging.sendToTopic(topic,
        {
            notification: {
                title: title,
                body: body,
                sound: 'default'
            },
            data: {
                id: id,
                name: model
            }
        },
        {
            priority: 'high',
            contentAvailable: true,
        }
    );
    functions.logger.log("Successfully sent message: ", topic, '=>', title);
}

const sendToDevice = async (user, title, body, id) => {
    if (user != null && user.devices != null) {
        for (const device of user.devices) {
            await messaging.sendToDevice(device.token,
                {
                    notification: {
                        title: title,
                        body: body,
                        sound: 'default'
                    },
                    data: {
                        id: id,
                        name: 'brew'
                    }
                },
                {
                    priority: 'high',
                    contentAvailable: true,
                }
            );
            functions.logger.log("Successfully sent message: ", user.full_name, '=>', device.name, device.token);
        }
    }
}

function isToday(date) {
    if (date == null || !date instanceof Date) {
        return  false;
    }
    const now = new Date();
    return now.getDay() === date.getDay() && now.getMonth() === date.getMonth() && now.getFullYear() === date.getFullYear();
}

function isTime(date) {
    if (date == null || !date instanceof Date) {
        return  false;
    }
    const now = new Date();
    return isToday(date) && now.getHours() === date.getHours();
}

function localizedText(value, language) {
    if (value instanceof Object) {
        try {
            const map = new Map(Object.entries(value));
            if (language != null && map.has(language)) {
                return map.get(language);
            }
            return map.entries().next().value[1];
        }
        catch (e) { }
    }
    return value;
}

exports.notification = functions.https.onCall(async(data, context) => {
    await sendToTopic(data.topic, data.title, data.subtitle, data.uuid, data.model);
    return true;
});

exports.updates = functions.https.onRequest(async (req, res) => {
    const collection = firestore.collection('brews');
    const snapshot = await collection.get();
    if (snapshot.empty) {
        console.log('No matching notifications.');
        return;
    }
    snapshot.forEach(async doc => {
        const rec = doc.data();
        if (rec.inserted_at != null) {
            try {
                functions.logger.log(`Yeast:`, rec.name);
                rec.cells = rec.cells / 11.5;
                await doc.ref.set(rec);
            }
            catch (error) {
                functions.logger.error(
                    'There was an error update:',
                    error
                );
            }
        }
    });
    return true;
});