// Wir importieren direkt die V2-Funktion für Zeitpläne ("scheduler")
const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");

admin.initializeApp();

// Der "Hausmeister": Läuft alle 5 Minuten
// Wir nutzen hier 'onSchedule' statt 'functions.pubsub.schedule'
exports.cleanupAbandonedRooms = onSchedule({
    schedule: "every 5 minutes",
    region: "europe-west1", // Wir lassen den Code in Europa laufen, passend zu deiner Datenbank
}, async (event) => {

    const db = admin.database();
    const roomsRef = db.ref('rooms');

    // EINSTELLUNG: 3 Minuten Inaktivität
    const MAX_OFFLINE_TIME = 3 * 60 * 1000;

    const cutoffTime = Date.now() - MAX_OFFLINE_TIME;

    // Suche nach alten Räumen
    const abandonedRoomsQuery = roomsRef.orderByChild('hostLeftAt').endAt(cutoffTime);

    const snapshot = await abandonedRoomsQuery.once('value');

    if (!snapshot.exists()) {
        return; // Nichts zu tun
    }

    const updates = {};
    let count = 0;

    snapshot.forEach(childSnapshot => {
        const roomData = childSnapshot.val();

        // Sicherheitscheck
        if (roomData.hostStatus === "offline") {
            updates[childSnapshot.key] = null; // Löschen vormerken
            console.log(`Lösche Raum ${childSnapshot.key} (Offline seit ${new Date(roomData.hostLeftAt)})`);
            count++;
        }
    });

    // Löschung durchführen
    if (count > 0) {
        await roomsRef.update(updates);
        console.log(`${count} verwaiste Räume gelöscht.`);
    }
});