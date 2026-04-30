CREATE OR REPLACE PACKAGE BODY PKG_MUE_HIST_TRANSACCION AS

  C_OK    CONSTANT NUMBER := 0;
  C_ERR   CONSTANT NUMBER := 1;
  C_NOFND CONSTANT NUMBER := 2;

  PROCEDURE PR_HIST_INSERTAR (
    P_HTR_TIPO    IN VARCHAR2,
    P_FAC_FACTURA IN NUMBER,
    P_HTR_DETALLE IN VARCHAR2,
    O_HTR_ID      OUT NUMBER,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  ) IS
    V_EXISTE NUMBER;
  BEGIN
    -- [FIX #14] Validar NULLs de campos obligatorios antes de ir a la BD
    IF P_HTR_TIPO IS NULL THEN
      O_COD_RET := C_ERR;
      O_MSG := 'El tipo de transacción no puede ser nulo.';
      RETURN;
    END IF;

    SELECT COUNT(*)
      INTO V_EXISTE
      FROM MUE_FACTURA
     WHERE FAC_Factura = P_FAC_FACTURA;

    IF V_EXISTE = 0 THEN
      O_COD_RET := C_ERR;
      O_MSG := 'La factura indicada no existe.';
      RETURN;
    END IF;

    INSERT INTO MUE_HIST_TRANSACCION (
      HTR_Tipo,
      FAC_Factura,
      HTR_Detalle,
      HTR_Created_At
    )
    VALUES (
      P_HTR_TIPO,
      P_FAC_FACTURA,
      P_HTR_DETALLE,
      SYSTIMESTAMP
    )
    RETURNING HTR_Hist_Transaccion INTO O_HTR_ID;

    O_COD_RET := C_OK;
    O_MSG := 'Historial registrado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG := 'Error al registrar historial: ' || SQLERRM;
  END PR_HIST_INSERTAR;


  PROCEDURE PR_HIST_OBTENER (
    P_HTR_ID  IN NUMBER,
    O_CURSOR  OUT SYS_REFCURSOR,
    O_COD_RET OUT NUMBER,
    O_MSG     OUT VARCHAR2
  ) IS
    V_EXISTE NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO V_EXISTE
      FROM MUE_HIST_TRANSACCION
     WHERE HTR_Hist_Transaccion = P_HTR_ID;

    IF V_EXISTE = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG := 'Registro no encontrado.';
      RETURN;
    END IF;

    -- [FIX #15] Columnas explícitas en lugar de SELECT *
    OPEN O_CURSOR FOR
      SELECT HTR_Hist_Transaccion,
             HTR_Tipo,
             FAC_Factura,
             HTR_Detalle,
             HTR_Created_At
        FROM MUE_HIST_TRANSACCION
       WHERE HTR_Hist_Transaccion = P_HTR_ID;

    O_COD_RET := C_OK;
    O_MSG := 'OK';
  END PR_HIST_OBTENER;


  PROCEDURE PR_HIST_LISTAR (
    P_FAC_FACTURA IN NUMBER DEFAULT NULL,
    O_CURSOR      OUT SYS_REFCURSOR,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  ) IS
  BEGIN
    -- [FIX #15] Columnas explícitas en lugar de SELECT *
    OPEN O_CURSOR FOR
      SELECT HTR_Hist_Transaccion,
             HTR_Tipo,
             FAC_Factura,
             HTR_Detalle,
             HTR_Created_At
        FROM MUE_HIST_TRANSACCION
       WHERE P_FAC_FACTURA IS NULL
          OR FAC_Factura = P_FAC_FACTURA
       ORDER BY HTR_Created_At DESC;

    O_COD_RET := C_OK;
    O_MSG := 'OK';
  END PR_HIST_LISTAR;

END PKG_MUE_HIST_TRANSACCION;
/