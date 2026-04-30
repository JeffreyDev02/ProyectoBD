CREATE OR REPLACE PACKAGE BODY PKG_MUE_NOTA_CREDITO AS

  C_OK    CONSTANT NUMBER := 0;
  C_ERR   CONSTANT NUMBER := 1;
  C_NOFND CONSTANT NUMBER := 2;

  PROCEDURE PR_NC_INSERTAR (
    P_FAC_FACTURA IN NUMBER,
    P_NCR_FECHA   IN DATE,
    P_NCR_MONTO   IN NUMBER,
    P_NCR_MOTIVO  IN VARCHAR2,
    O_NCR_ID      OUT NUMBER,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  ) IS
    V_TOTAL_FACTURA NUMBER;
  BEGIN
    -- [FIX #13] Validar NULL antes de cualquier comparación
    IF P_NCR_MONTO IS NULL THEN
      O_COD_RET := C_ERR;
      O_MSG := 'El monto de la nota crédito no puede ser nulo.';
      RETURN;
    END IF;

    IF P_NCR_MONTO <= 0 THEN
      O_COD_RET := C_ERR;
      O_MSG := 'El monto de la nota crédito debe ser mayor a cero.';
      RETURN;
    END IF;

    SELECT FAC_Total
      INTO V_TOTAL_FACTURA
      FROM MUE_FACTURA
     WHERE FAC_Factura = P_FAC_FACTURA;

    IF P_NCR_MONTO > V_TOTAL_FACTURA THEN
      O_COD_RET := C_ERR;
      O_MSG := 'El monto de la nota crédito no puede ser mayor al total de la factura.';
      RETURN;
    END IF;

    -- [FIX #15] Columnas explícitas en lugar de SELECT *
    INSERT INTO MUE_NOTA_CREDITO (
      FAC_Factura,
      NCR_Fecha,
      NCR_Monto,
      NCR_Motivo,
      NCR_Created_At
    )
    VALUES (
      P_FAC_FACTURA,
      P_NCR_FECHA,
      P_NCR_MONTO,
      P_NCR_MOTIVO,
      SYSTIMESTAMP
    )
    RETURNING NCR_Nota_Credito INTO O_NCR_ID;

    O_COD_RET := C_OK;
    O_MSG := 'Nota crédito registrada correctamente.';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      O_COD_RET := C_ERR;
      O_MSG := 'La factura indicada no existe.';
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG := 'Error al registrar nota crédito: ' || SQLERRM;
  END PR_NC_INSERTAR;


  PROCEDURE PR_NC_ACTUALIZAR (
    P_NCR_ID     IN NUMBER,
    P_NCR_FECHA  IN DATE,
    P_NCR_MONTO  IN NUMBER,
    P_NCR_MOTIVO IN VARCHAR2,
    O_COD_RET    OUT NUMBER,
    O_MSG        OUT VARCHAR2
  ) IS
    V_TOTAL_FACTURA NUMBER;
    V_FACTURA       NUMBER;
  BEGIN
    -- [FIX #13] Validar NULL/cero antes de ir a la BD
    IF P_NCR_MONTO IS NULL THEN
      O_COD_RET := C_ERR;
      O_MSG := 'El monto de la nota crédito no puede ser nulo.';
      RETURN;
    END IF;

    IF P_NCR_MONTO <= 0 THEN
      O_COD_RET := C_ERR;
      O_MSG := 'El monto de la nota crédito debe ser mayor a cero.';
      RETURN;
    END IF;

    SELECT FAC_Factura
      INTO V_FACTURA
      FROM MUE_NOTA_CREDITO
     WHERE NCR_Nota_Credito = P_NCR_ID;

    SELECT FAC_Total
      INTO V_TOTAL_FACTURA
      FROM MUE_FACTURA
     WHERE FAC_Factura = V_FACTURA;

    IF P_NCR_MONTO > V_TOTAL_FACTURA THEN
      O_COD_RET := C_ERR;
      O_MSG := 'El monto supera el total de la factura.';
      RETURN;
    END IF;

    UPDATE MUE_NOTA_CREDITO
       SET NCR_Fecha  = P_NCR_FECHA,
           NCR_Monto  = P_NCR_MONTO,
           NCR_Motivo = P_NCR_MOTIVO
     WHERE NCR_Nota_Credito = P_NCR_ID;

    O_COD_RET := C_OK;
    O_MSG := 'Nota crédito actualizada correctamente.';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      O_COD_RET := C_NOFND;
      O_MSG := 'Nota crédito no encontrada.';
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG := 'Error al actualizar nota crédito: ' || SQLERRM;
  END PR_NC_ACTUALIZAR;


  PROCEDURE PR_NC_ELIMINAR (
    P_NCR_ID  IN NUMBER,
    O_COD_RET OUT NUMBER,
    O_MSG     OUT VARCHAR2
  ) IS
  BEGIN
    DELETE FROM MUE_NOTA_CREDITO
     WHERE NCR_Nota_Credito = P_NCR_ID;

    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG := 'Nota crédito no encontrada.';
      RETURN;
    END IF;

    O_COD_RET := C_OK;
    O_MSG := 'Nota crédito eliminada correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG := 'Error al eliminar nota crédito: ' || SQLERRM;
  END PR_NC_ELIMINAR;


  PROCEDURE PR_NC_OBTENER (
    P_NCR_ID  IN NUMBER,
    O_CURSOR  OUT SYS_REFCURSOR,
    O_COD_RET OUT NUMBER,
    O_MSG     OUT VARCHAR2
  ) IS
  BEGIN
    -- [FIX #15] Columnas explícitas en lugar de SELECT *
    OPEN O_CURSOR FOR
      SELECT NCR_Nota_Credito,
             FAC_Factura,
             NCR_Fecha,
             NCR_Monto,
             NCR_Motivo,
             NCR_Created_At
        FROM MUE_NOTA_CREDITO
       WHERE NCR_Nota_Credito = P_NCR_ID;

    O_COD_RET := C_OK;
    O_MSG := 'OK';
  END PR_NC_OBTENER;


  PROCEDURE PR_NC_LISTAR (
    P_FAC_FACTURA IN NUMBER DEFAULT NULL,
    O_CURSOR      OUT SYS_REFCURSOR,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  ) IS
  BEGIN
    -- [FIX #15] Columnas explícitas en lugar de SELECT *
    OPEN O_CURSOR FOR
      SELECT NCR_Nota_Credito,
             FAC_Factura,
             NCR_Fecha,
             NCR_Monto,
             NCR_Motivo,
             NCR_Created_At
        FROM MUE_NOTA_CREDITO
       WHERE P_FAC_FACTURA IS NULL
          OR FAC_Factura = P_FAC_FACTURA
       ORDER BY NCR_Fecha DESC;

    O_COD_RET := C_OK;
    O_MSG := 'OK';
  END PR_NC_LISTAR;

END PKG_MUE_NOTA_CREDITO;
/