importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js");

firebase.initializeApp({
    apiKey: "AIzaSyCb53Gb_kFv8bAHsdssn9s_F6Rr-Aj4Iwg",
    authDomain: "flutterapp-49b80.firebaseapp.com",
    projectId: "flutterapp-49b80",
    storageBucket: "flutterapp-49b80.firebasestorage.app",
    messagingSenderId: "912687969284",
    appId: "1:912687969284:web:e266f2b0611e301af27151",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
    console.log(
        "[firebase-messaging-sw.js] Received background message ",
        payload,
    );
    // Customize notification here if needed
    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body,
        icon: "/icons/icon-192.png", // Verify this icon path exists or use a default
    };

    self.registration.showNotification(notificationTitle, notificationOptions);
});
