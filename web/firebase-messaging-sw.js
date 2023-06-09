importScripts("https://www.gstatic.com/firebasejs/9.10/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/9.10/firebase-auth.js");
importScripts("https://www.gstatic.com/firebasejs/9.10/firebase-storage.js");
importScripts("https://www.gstatic.com/firebasejs/9.10/firebase-firestore.js");
importScripts("https://www.gstatic.com/firebasejs/9.10/firebase-messaging.js");
importScripts("https://www.gstatic.com/firebasejs/9.10/firebase-analytics.js");

var firebaseConfig = {
    apiKey: "AIzaSyA0M2m4ywAyaBqEnyXvYBdSybSgtQBOGFM",
    authDomain: "beandbrew.firebaseapp.com",
    projectId: "beandbrew",
    storageBucket: "beandbrew.appspot.com",
    messagingSenderId: "94135687117",
    appId: "1:94135687117:web:1eeccf8f5e36c7ccca1684",
    measurementId: "G-46JRTNPPYH"
};
firebase.analytics();
// Initialize Firebase
firebase.initializeApp(firebaseConfig);

const messaging = firebase.messaging();
messaging.onBackgroundMessage(function(payload) {
    console.log('Received background message ', payload);

    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body,
    };

    self.registration.showNotification(notificationTitle, notificationOptions);
});