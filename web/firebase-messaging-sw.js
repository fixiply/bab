importScripts("https://www.gstatic.com/firebasejs/9.10/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/9.10/firebase-auth.js");
importScripts("https://www.gstatic.com/firebasejs/9.10/firebase-storage.js");
importScripts("https://www.gstatic.com/firebasejs/9.10/firebase-firestore.js");
importScripts("https://www.gstatic.com/firebasejs/9.10/firebase-messaging.js");
importScripts("https://www.gstatic.com/firebasejs/9.10/firebase-analytics.js");

var firebaseConfig = {
    apiKey: "AIzaSyAAEsXWUis1p3rQSh7K7Xi6Rh2vD9utcXA",
    authDomain: "brasseur-bordelais.firebaseapp.com",
    databaseURL: "https://brasseur-bordelais-default-rtdb.europe-west1.firebasedatabase.app",
    projectId: "brasseur-bordelais",
    storageBucket: "brasseur-bordelais.appspot.com",
    messagingSenderId: "955480665092",
    appId: "1:955480665092:web:b9943e1fe865871b59d951",
    measurementId: "G-JDKVC86LYX"
};
// Initialize Firebase
firebase.initializeApp(firebaseConfig);
firebase.analytics();

const messaging = firebase.messaging();
messaging.onBackgroundMessage(function(payload) {
    console.log('Received background message ', payload);

    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body,
    };

    self.registration.showNotification(notificationTitle, notificationOptions);
});