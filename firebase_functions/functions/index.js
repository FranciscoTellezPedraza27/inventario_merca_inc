const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore"); // Importa FieldValue

// Inicialización explícita
const app = initializeApp();
const db = getFirestore(app); // Pasa la app inicializada

exports.checkStockMinimo = onDocumentUpdated(
  {
    document: "oxxokids/{productId}",
    region: "us-central1",
    memory: "512MiB"
  },
  async (event) => {
    try {
      const beforeData = event.data.before.data();
      const afterData = event.data.after.data();

      // Validación de campos numéricos
      if (typeof afterData.cantidad !== 'number' || 
          typeof afterData.stock_minimo !== 'number') {
        console.error("Campos no numéricos:", {
          cantidad: typeof afterData.cantidad,
          stock_minimo: typeof afterData.stock_minimo
        });
        return;
      }

      if (afterData.cantidad <= afterData.stock_minimo) {
        await db.collection("notificaciones").add({
          titulo: "Stock Mínimo Alcanzado",
          mensaje: `Producto ${afterData.articulo || 'Sin nombre'} (${afterData.cantidad} unidades)`,
          fecha: FieldValue.serverTimestamp(), // Usa FieldValue importado
          leida: false,
          documentoId: event.params.productId,
          tipo: "stock_minimo",
          coleccion: "oxxokids"
        });
        console.log("Notificación creada para:", event.params.productId);
      }
    } catch (error) {
      console.error("Error en la función:", error);
      throw error;
    }
  }
);