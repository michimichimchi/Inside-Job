// Wir importieren direkt die V2-Funktion für Zeitpläne ("scheduler")
const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");

admin.initializeApp();

// Der "Hausmeister": Läuft alle 5 Minuten
// Wir nutzen hier 'onSchedule' statt 'functions.pubsub.schedule'
exports.cleanupAbandonedRooms = onSchedule({
    schedule: "0 * * * *",
    region: "europe-west1",
}, async (event) => {

    const db = admin.database();
    const roomsRef = db.ref('rooms');

    // EINSTELLUNG: 4 Stunden Inaktivität
    const MAX_INACTIVE_TIME = 4 * 60 * 60 * 1000;

    const cutoffTime = Date.now() - MAX_INACTIVE_TIME;

    // Suche nach alten Räumen anhand von lastActivity
    const oldRoomsQuery = roomsRef.orderByChild('lastActivity').endAt(cutoffTime);

    const snapshot = await oldRoomsQuery.once('value');

    if (!snapshot.exists()) {
        console.log("Keine inaktiven Räume gefunden.");
        return;
    }

    const updates = {};
    let count = 0;

    snapshot.forEach(childSnapshot => {
        const roomData = childSnapshot.val();

        // Wir löschen alles, was von der Query gefunden wurde.
        // Die Query liefert:
        // 1. Räume mit lastActivity < cutoffTime (älter als 4h)
        // 2. Räume OHNE lastActivity (null), das beseitigt auch alte Legacy-Räume
        updates[childSnapshot.key] = null;

        const dateStr = roomData.lastActivity ? new Date(roomData.lastActivity).toISOString() : 'nie/unbekannt';
        console.log(`Lösche Raum ${childSnapshot.key} (Inaktiv seit ${dateStr})`);
        count++;
    });

    // Löschung durchführen
    if (count > 0) {
        await roomsRef.update(updates);
        console.log(`${count} inaktive Räume gelöscht.`);
    }
});