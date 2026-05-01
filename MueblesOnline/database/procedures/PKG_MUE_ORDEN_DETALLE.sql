CREATE OR REPLACE PACKAGE BODY PKG_MUE_ORDEN_DETALLE AS

  C_OK    CONSTANT NUMBER := 0;
  C_ERR   CONSTANT NUMBER := 1;
  C_NOFND CONSTANT NUMBER := 2;

  PROCEDURE PR_DETALLE_INSERTAR (
    P_MOV_ORDEN_VENTA IN NUMBER,
    P_PRO_PRODUCTO    IN NUMBER,
    P_MOD_CANTIDAD    IN NUMBER,
    P_MOD_PRECIO_UNIT IN NUMBER,
    O_MOD_DETALLE     OUT NUMBER,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  ) IS
    V_TOTAL  NUMBER(14,2);
    V_EXISTE NUMBER;
  BEGIN
    -- [FIX #16] Savepoint: INSERT + recálculo de total deben ser atómicos
    SAVEPOINT sp_detalle_insertar;

    IF P_MOD_CANTIDAD IS NULL OR P_MOD_CANTIDAD <= 0 THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'La cantidad debe ser mayor a cero.';
      RETURN;
    END IF;

    IF P_MOD_PRECIO_UNIT IS NULL OR P_MOD_PRECIO_UNIT < 0 THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'El precio unitario no puede ser negativo.';
      RETURN;
    END IF;

    SELECT COUNT(*)
      INTO V_EXISTE
      FROM MUE_ORDEN_VENTA
     WHERE MOV_Orden_Venta = P_MOV_ORDEN_VENTA;

    IF V_EXISTE = 0 THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'La orden de venta indicada no existe.';
      RETURN;
    END IF;

    SELECT COUNT(*)
      INTO V_EXISTE
      FROM MUE_PRODUCTO
     WHERE PRO_Producto = P_PRO_PRODUCTO;

    IF V_EXISTE = 0 THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'El producto indicado no existe.';
      RETURN;
    END IF;

    V_TOTAL := P_MOD_CANTIDAD * P_MOD_PRECIO_UNIT;

    INSERT INTO MUE_ORDEN_DETALLE (
      MOV_Orden_Venta,
      PRO_Producto,
      MOD_Cantidad,
      MOD_Precio_Unitario,
      MOD_Total_Linea,
      MOD_Created_At
    )
    VALUES (
      P_MOV_ORDEN_VENTA,
      P_PRO_PRODUCTO,
      P_MOD_CANTIDAD,
      P_MOD_PRECIO_UNIT,
      V_TOTAL,
      SYSTIMESTAMP
    )
    RETURNING MOD_Orden_Detalle INTO O_MOD_DETALLE;

    DECLARE
      V_RET     NUMBER;
      V_MSG_REC VARCHAR2(500);
    BEGIN
      PKG_MUE_ORDEN_VENTA.PR_ORDEN_RECALCULAR_TOTAL(
        P_MOV_ORDEN_VENTA,
        V_RET,
        V_MSG_REC
      );

      IF V_RET <> C_OK THEN
        O_COD_RET := V_RET;
        O_MSG     := 'Detalle insertado pero error al recalcular total: ' || V_MSG_REC;
        RETURN;
      END IF;
    END;

    O_COD_RET := C_OK;
    O_MSG     := 'Detalle agregado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      -- [FIX #16] Revertimos INSERT + cualquier cambio parcial
      ROLLBACK TO SAVEPOINT sp_detalle_insertar;
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al insertar detalle: ' || SQLERRM;
  END PR_DETALLE_INSERTAR;


  PROCEDURE PR_DETALLE_ACTUALIZAR (
    P_MOD_DETALLE     IN NUMBER,
    P_MOD_CANTIDAD    IN NUMBER,
    P_MOD_PRECIO_UNIT IN NUMBER,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  ) IS
    V_TOTAL   NUMBER(14,2);
    V_ORDEN   NUMBER;
    V_RET     NUMBER;
    V_MSG_REC VARCHAR2(500);
  BEGIN
    -- [FIX #16] Savepoint: UPDATE + recálculo deben ser atómicos
    SAVEPOINT sp_detalle_actualizar;

    IF P_MOD_CANTIDAD IS NULL OR P_MOD_CANTIDAD <= 0 THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'La cantidad debe ser mayor a cero.';
      RETURN;
    END IF;

    IF P_MOD_PRECIO_UNIT IS NULL OR P_MOD_PRECIO_UNIT < 0 THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'El precio unitario no puede ser negativo.';
      RETURN;
    END IF;

    SELECT MOV_Orden_Venta
      INTO V_ORDEN
      FROM MUE_ORDEN_DETALLE
     WHERE MOD_Orden_Detalle = P_MOD_DETALLE;

    V_TOTAL := P_MOD_CANTIDAD * P_MOD_PRECIO_UNIT;

    UPDATE MUE_ORDEN_DETALLE
       SET MOD_Cantidad        = P_MOD_CANTIDAD,
           MOD_Precio_Unitario = P_MOD_PRECIO_UNIT,
           MOD_Total_Linea     = V_TOTAL
     WHERE MOD_Orden_Detalle = P_MOD_DETALLE;

    PKG_MUE_ORDEN_VENTA.PR_ORDEN_RECALCULAR_TOTAL(
      V_ORDEN,
      V_RET,
      V_MSG_REC
    );

    IF V_RET <> C_OK THEN
      O_COD_RET := V_RET;
      O_MSG     := 'Detalle actualizado pero error al recalcular total: ' || V_MSG_REC;
      RETURN;
    END IF;

    O_COD_RET := C_OK;
    O_MSG     := 'Detalle actualizado correctamente.';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'Detalle no encontrado.';
    WHEN OTHERS THEN
      -- [FIX #16] Revertimos UPDATE + recálculo parcial
      ROLLBACK TO SAVEPOINT sp_detalle_actualizar;
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al actualizar detalle: ' || SQLERRM;
  END PR_DETALLE_ACTUALIZAR;


  PROCEDURE PR_DETALLE_ELIMINAR (
    P_MOD_DETALLE IN NUMBER,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  ) IS
    V_ORDEN   NUMBER;
    V_RET     NUMBER;
    V_MSG_REC VARCHAR2(500);
  BEGIN
    -- [FIX #16] Savepoint: DELETE + recálculo deben ser atómicos
    SAVEPOINT sp_detalle_eliminar;

    SELECT MOV_Orden_Venta
      INTO V_ORDEN
      FROM MUE_ORDEN_DETALLE
     WHERE MOD_Orden_Detalle = P_MOD_DETALLE;

    DELETE FROM MUE_ORDEN_DETALLE
     WHERE MOD_Orden_Detalle = P_MOD_DETALLE;

    PKG_MUE_ORDEN_VENTA.PR_ORDEN_RECALCULAR_TOTAL(
      V_ORDEN,
      V_RET,
      V_MSG_REC
    );

    IF V_RET <> C_OK THEN
      O_COD_RET := V_RET;
      O_MSG     := 'Detalle eliminado pero error al recalcular total: ' || V_MSG_REC;
      RETURN;
    END IF;

    O_COD_RET := C_OK;
    O_MSG     := 'Detalle eliminado correctamente.';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'Detalle no encontrado.';
    WHEN OTHERS THEN
      -- [FIX #16] Revertimos DELETE + recálculo parcial
      ROLLBACK TO SAVEPOINT sp_detalle_eliminar;
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al eliminar detalle: ' || SQLERRM;
  END PR_DETALLE_ELIMINAR;


  PROCEDURE PR_DETALLE_OBTENER (
    P_MOD_DETALLE IN NUMBER,
    O_CURSOR      OUT SYS_REFCURSOR,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  ) IS
  BEGIN
    -- [FIX #15] Columnas explícitas en lugar de SELECT *
    OPEN O_CURSOR FOR
      SELECT MOD_Orden_Detalle,
             MOV_Orden_Venta,
             PRO_Producto,
             MOD_Cantidad,
             MOD_Precio_Unitario,
             MOD_Total_Linea,
             MOD_Created_At
        FROM MUE_ORDEN_DETALLE
       WHERE MOD_Orden_Detalle = P_MOD_DETALLE;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';
  END PR_DETALLE_OBTENER;


  PROCEDURE PR_DETALLE_LISTAR (
    P_MOV_ORDEN IN NUMBER,
    O_CURSOR    OUT SYS_REFCURSOR,
    O_COD_RET   OUT NUMBER,
    O_MSG       OUT VARCHAR2
  ) IS
  BEGIN
    -- [FIX #15] Columnas explícitas en lugar de SELECT *
    OPEN O_CURSOR FOR
      SELECT MOD_Orden_Detalle,
             MOV_Orden_Venta,
             PRO_Producto,
             MOD_Cantidad,
             MOD_Precio_Unitario,
             MOD_Total_Linea,
             MOD_Created_At
        FROM MUE_ORDEN_DETALLE
       WHERE MOV_Orden_Venta = P_MOV_ORDEN
       ORDER BY MOD_Orden_Detalle;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';
  END PR_DETALLE_LISTAR;

END PKG_MUE_ORDEN_DETALLE;
/