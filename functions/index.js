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

exports.pushNotification = functions.region('europe-west1').pubsub.schedule('0 */1 * * *')
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
            const brew = doc.data();
            const started = brew.started_at.toDate();
            const receiptDoc = await firestore.collection('receipts').doc(brew.receipt).get();
            if (receiptDoc.exists) {
                const receipt= receiptDoc.data();
                const title = 'Brassin #' + brew.reference
                if (receipt.primaryday != null) {
                    started.setDate(started.getDate() + receipt.primaryday);
                    if (isTime(started)) {
                        const body = receipt.secondaryday == null ? 'Fin du brassin.' : 'Fin de la fermenation.';
                        await sendToDevice(brew.creator, title, body, doc.id);
                        console.debug(doc.id, '->', brew.reference, ' receipt: ', brew.receipt, 'primary date', started);
                    }
                }
                if (receipt.secondaryday != null) {
                    started.setDate(new Date(started.getDate() + receipt.secondaryday));
                    if (isTime(started)) {
                        const body = receipt.tertiaryday == null ? 'Fin du brassin.' : 'Fin de la fermenation.';
                        await sendToDevice(brew.creator, title, body, doc.id);
                        console.debug(doc.id, '->', brew.reference, ' receipt: ', brew.receipt, 'secondary date', started);
                    }
                }
                if (receipt.tertiaryday != null) {
                    started.setDate(started.getDate() + receipt.tertiaryday);
                    if (isTime(started)) {
                        const body = 'Fin du brassin.';
                        await sendToDevice(brew.creator, title, body, doc.id);
                        console.debug(doc.id, '->', brew.reference, ' receipt: ', brew.receipt, 'tertiary date', started);
                    }
                }
            }
        });
        return null;
    }
);

const sendToTopic = async (topic, title, body, id) => {
    await messaging.sendToTopic(topic,
        {
            notification: {
                title: title,
                body: body,
                sound: 'default'
            },
            data: {
                id: id
            }
        },
        {
            priority: 'high',
            contentAvailable: true,
        }
    )
}

const sendToDevice = async (userId, title, body, id) => {
    const userDoc = await firestore.collection('users').doc(userId).get();
    if (userDoc.exists) {
        const user = userDoc.data();
        if (user.devices != null) {
            for (const device of user.devices) {
                console.debug('Send ', '->', user.full_name, 'device', device.token);
                await messaging.sendToDevice(device.token,
                    {
                        notification: {
                            title: title,
                            body: body,
                            sound: 'default'
                        },
                        data: {
                            id: id
                        }
                    },
                    {
                        priority: 'high',
                        contentAvailable: true,
                    }
                )
            }
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
    return null;
});