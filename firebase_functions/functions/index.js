const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");

const app = initializeApp();
const db = getFirestore(app);

const handleStockNotification = async (change, context) => {
  try {
    const afterData = change.after.data();

    if (typeof afterData.cantidad !== 'number' || 
        afterData.stock_minimo === null || 
        typeof afterData.stock_minimo !== 'number') {
      return;
    }

    if (afterData.cantidad <= afterData.stock_minimo) {
      const categoria = context.params.collectionName;
      
      const existingNotification = await db.collection("notificaciones")
        .where("documentoId", "==", context.params.productId)
        .where("leida", "==", false)
        .limit(1)
        .get();

      if (existingNotification.empty) {
        await db.collection("notificaciones").add({
          titulo: `⚠️ Stock bajo en ${categoria.toUpperCase()}`,
          mensaje: `El producto "${afterData.articulo || 'Sin nombre'}" tiene stock bajo (${afterData.cantidad} unidades).`,
          detalle_extra: `Stock mínimo: ${afterData.stock_minimo}`,
          fecha: FieldValue.serverTimestamp(),
          leida: false,
          documentoId: context.params.productId,
          tipo: "stock_bajo",
          categoria: categoria
        });
        console.log(`Notificación creada para ${categoria}:`, context.params.productId);
      }
    }
  } catch (error) {
    console.error("Error en la función:", error);
  }
};

// Configura los triggers para cada colección
const collections = ['oxxokids', 'oxxoadultos', 'papeleria', 'sublimacion'];

collections.forEach(collection => {
  exports[`checkStockMinimo_${collection}`] = onDocumentUpdated(
    {
      document: `${collection}/{productId}`,
      region: "us-central1",
      memory: "512MiB"
    },
    async (event) => {
      await handleStockNotification(event.data, {
        params: {
          ...event.params,
          collectionName: collection
        }
      });
    }
  );
});