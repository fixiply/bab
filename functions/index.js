'use strict';

const admin = require('firebase-admin');
const functions = require('firebase-functions');
const nodemailer = require('nodemailer');

const i18next = require('i18next');

admin.initializeApp();

const firestore = admin.firestore();
const messaging = admin.messaging();

const transporter = nodemailer.createTransport({
  host: "ssl0.ovh.net",
  port: 465,
  secure: true, // Use `true` for port 465, `false` for all other ports
  auth: {
    user: "contact@beandbrew.com",
    pass: "Yell0-Submarine",
  },
});

exports.brews = functions.region('europe-west1').pubsub.schedule('*/15 * * * *')
    .timeZone('Europe/Paris') // Users can choose timezone - default is America/Los_Angeles
    .onRun(async (context) => {
            const currentDate = new Date();
            const before = admin.firestore.Timestamp.fromMillis(currentDate.setMonth(currentDate.getMonth() - 2))
            const brews = firestore.collection('brews');
            const snapshot = await brews.where('started_at', '>=', before)
                .where('started_at', '<=', admin.firestore.Timestamp.now()).get();
            if (snapshot.empty) {
                console.log('No matching brews.');
                return;
            }
            snapshot.forEach(async doc=> {
                var user;
                const brew = doc.data();
                if (brew.started_at != null) {
                    var started = brew.started_at.toDate();
                    if (brew.fermented_at != null) {
                        started = brew.fermented_at.toDate();
                    }
                    console.log('Brew '+doc.id+' creator: '+brew.creator+' recipe: '+brew.recipe+' started: '+started);
                    const recipeDoc = await firestore.collection('recipes').doc(brew.recipe).get();
                    if (recipeDoc.exists) {
                        const recipe = recipeDoc.data();
                        const userDoc = await firestore.collection('users').doc(brew.creator).get();
                        if (userDoc.exists) {
                            user = userDoc.data();
                            console.log('User '+brew.creator+ ' language: '+user.language+' email: '+user.email);
                        }
                        i18next.init({
                            // initImmediate: false,
                            lng: user != null ? user.language : 'fr',
                            fallbackLng: user != null ? user.language : 'fr',
                            preload: ['en', 'fr'],
                            resources: {
                                fr: {
                                    translation: {
                                        brew: 'Brassin',
                                        end: 'Fin du brassin',
                                        start: 'Début',
                                        dryhop: 'Début du houblonnage à cru',
                                    },
                                },
                                en: {
                                    translation: {
                                        brew: 'Brew',
                                        end: 'End brew',
                                        start: 'Start',
                                        dryhop: 'Start dry hopping',
                                    },
                                },
                            },
                        });
                        const name = localizedText(recipe.title, user != null ? user.language : null);
                        const title = i18next.t('brew') + ' #' + brew.reference + (name != null ? ' - ' + name : '');
                        if (recipe.fermentation != null) {
                            for (var i= 0; i < recipe.fermentation.length; i++) {
                                started.setDate(started.getDate() + recipe.fermentation[i].duration);
                                console.log('\t Fermentation '+recipe.fermentation[i].name+' started: '+started + " now: "+isTime(started));
                                if (isTime(started)) {
                                    var body = i18next.t('start') + " «"  + recipe.fermentation[i].name + "»";
                                    if ((i + 1) < recipe.fermentation.length ) {
                                        body = i18next.t('end');
                                    }
                                    await sendMail(user.email, title, body + ".");
                                    await sendToDevice(user, title, body + ".", doc.id, 'brew');
                                    break;
                                } else if (i === 0) {
                                    if (recipe.hops != null) {
                                        for (const item of recipe.hops) {
                                            if (item.use === 4) { // Dry hppping
                                                var dryhop = new Date(started.getTime())
                                                dryhop.setDate(dryhop.getDate() - item.duration);
                                                console.log('\t Dryhop started: '+started + " now: "+isTime(dryhop));
                                                // log('   '+doc.id+' dryhop: '+dryhop);
                                                if (isTime(dryhop)) {
                                                    await sendMail(user.email, title, i18next.t('dryhop') + ".");
                                                    await sendToDevice(user, title, i18next.t('dryhop') + ".", doc.id, 'brew');
                                                    break;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            });
            return null;
        }
    );

const sendToTopic = async (topic, title, body, id, route) => {
    await messaging.sendToTopic(topic,
        {
            notification: {
                title: title,
                body: body,
                sound: 'default'
            },
            data: {
                id: id,
                route: route
            }
        },
        {
            priority: 'high',
            contentAvailable: true,
        }
    );
    functions.logger.log("Successfully sent message: ", topic, '=>', title);
}

const sendToDevice = async (user, title, body, id, route) => {
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
                        route: route
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

const sendMail = async (to, subject, text, html) => {
    // send mail with defined transport object
    const info = await transporter.sendMail({
        from: 'BeAndBrew <noreply@beandbrew.com>', // sender address
        to: to, // list of receivers
        subject: subject, // Subject line
        text: text, // plain text body
        html: html // html body
    });
    functions.logger.log("Message sent: ", info.messageId);
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
    const start = new Date();
    start.setSeconds(0);
    start.setMilliseconds(0);
    const end = new Date();
    end.setMinutes(start.getMinutes() + 15);
    end.setSeconds(0);
    end.setMilliseconds(0);
    return isToday(start) && date.getTime() >= start.getTime() && date.getTime() < end.getTime();
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
    await sendToTopic(data.topic, data.title, data.subtitle, data.uuid, data.route);
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

exports.createUser = functions.auth.user().onCreate((user) => {
    var now = new Date();
    firestore.collection("users").doc(user.uid).set({
        inserted_at: now,
        updated_at: now,
        name: user.displayName,
        email: user.email,
        role: 2,
        verified: false,
        subscriptions: [{
            inserted_at: now,
            started_at: now
        }]
    }).then(() => {
        console.log("User #" + user.uid + " successfully written!");
    }).catch((error) => {
        console.error("Error writing user: ", error);
    });
});

exports.deleteUser = functions.auth.user().onDelete((user) => {
    firestore.collection("users").doc(user.uid).delete().then(() => {
        console.log("User #" + user.uid + " successfully deleted!");
    }).catch((error) => {
        console.error("Error removing user: ", error);
    });
});