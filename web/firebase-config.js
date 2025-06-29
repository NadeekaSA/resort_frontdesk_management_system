// Import the functions you need from the SDKs you need
import { initializeApp } from "https://www.gstatic.com/firebasejs/11.8.1/firebase-app.js";
import { getAnalytics } from "https://www.gstatic.com/firebasejs/11.8.1/firebase-analytics.js";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyAt1Kcel-KV9xN0CQGMh89Nwrbb4CW7J4A",
  authDomain: "luckyresort-a44e8.firebaseapp.com",
  projectId: "luckyresort-a44e8",
  storageBucket: "luckyresort-a44e8.appspot.com",
  messagingSenderId: "711682178851",
  appId: "1:711682178851:web:389d8a44a78909661dd696",
  measurementId: "G-6FNB1E6K0G"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);