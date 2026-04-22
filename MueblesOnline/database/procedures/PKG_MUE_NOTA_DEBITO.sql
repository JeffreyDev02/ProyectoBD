CREATE OR REPLACE PACKAGE PKG_MUE_NOTA_DEBITO AS

  PROCEDURE PR_ND_INSERTAR (
    P_FAC_FACTURA    IN NUMBER,
    P_NDB_FECHA      IN DATE,
    P_NDB_MONTO      IN NUMBER,
    P_NDB_MOTIVO     IN VARCHAR2,
    O_NDB_ID         OUT NUMBER,
    O_COD_RET        OUT NUMBER,
    O_MSG            OUT VARCHAR2
  );

  PROCEDURE PR_ND_ACTUALIZAR (
    P_NDB_ID         IN NUMBER,
    P_NDB_FECHA      IN DATE,
    P_NDB_MONTO      IN NUMBER,
    P_NDB_MOTIVO     IN VARCHAR2,
    O_COD_RET        OUT NUMBER,
    O_MSG            OUT VARCHAR2
  );

  PROCEDURE PR_ND_ELIMINAR (
    P_NDB_ID         IN NUMBER,
    O_COD_RET        OUT NUMBER,
    O_MSG            OUT VARCHAR2
  );

  PROCEDURE PR_ND_OBTENER (
    P_NDB_ID         IN NUMBER,
    O_CURSOR         OUT SYS_REFCURSOR,
    O_COD_RET        OUT NUMBER,
    O_MSG            OUT VARCHAR2
  );

  PROCEDURE PR_ND_LISTAR (
    P_FAC_FACTURA    IN NUMBER DEFAULT NULL,
    O_CURSOR         OUT SYS_REFCURSOR,
    O_COD_RET        OUT NUMBER,
    O_MSG            OUT VARCHAR2
  );

END PKG_MUE_NOTA_DEBITO;
/
CREATE OR REPLACE PACKAGE BODY PKG_MUE_NOTA_DEBITO AS

  C_OK    CONSTANT NUMBER := 0;
  C_ERR   CONSTANT NUMBER := 1;
  C_NOFND CONSTANT NUMBER := 2;

  PROCEDURE PR_ND_INSERTAR (
    P_FAC_FACTURA,
    P_NDB_FECHA,
    P_NDB_MONTO,
    P_NDB_MOTIVO,
    O_NDB_ID OUT NUMBER,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
  ) IS
    V_TOTAL_FACTURA NUMBER;
  BEGIN
    SELECT FAC_Total
      INTO V_TOTAL_FACTURA
      FROM MUE_FACTURA
     WHERE FAC_Factura = P_FAC_FACTURA;

    IF P_NDB_MONTO <= 0 THEN
      O_COD_RET := C_ERR;
      O_MSG := 'El monto debe ser mayor a cero.';
      RETURN;
    END IF;

    INSERT INTO MUE_NOTA_DEBITO (
      FAC_Factura,
      NDB_Fecha,
      NDB_Monto,
      NDB_Motivo,
      NDB_Created_At
    )
    VALUES (
      P_FAC_FACTURA,
      P_NDB_FECHA,
      P_NDB_MONTO,
      P_NDB_MOTIVO,
      SYSTIMESTAMP
    )
    RETURNING NDB_Nota_Debito INTO O_NDB_ID;

    O_COD_RET := C_OK;
    O_MSG := 'Nota débito registrada correctamente.';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      O_COD_RET := C_ERR;
      O_MSG := 'La factura indicada no existe.';
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG := 'Error al registrar nota débito: ' || SQLERRM;
  END PR_ND_INSERTAR;


  PROCEDURE PR_ND_ACTUALIZAR (
    P_NDB_ID,
    P_NDB_FECHA,
    P_NDB_MONTO,
    P_NDB_MOTIVO,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
  ) IS
    V_EXISTE NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO V_EXISTE
      FROM MUE_NOTA_DEBITO
     WHERE NDB_Nota_Debito = P_NDB_ID;

    IF V_EXISTE = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG := 'Nota débito no encontrada.';
      RETURN;
    END IF;

    IF P_NDB_MONTO <= 0 THEN
      O_COD_RET := C_ERR;
      O_MSG := 'El monto debe ser mayor a cero.';
      RETURN;
    END IF;

    UPDATE MUE_NOTA_DEBITO
       SET NDB_Fecha = P_NDB_FECHA,
           NDB_Monto = P_NDB_MONTO,
           NDB_Motivo = P_NDB_MOTIVO
     WHERE NDB_Nota_Debito = P_NDB_ID;

    O_COD_RET := C_OK;
    O_MSG := 'Nota débito actualizada correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG := 'Error al actualizar nota débito: ' || SQLERRM;
  END PR_ND_ACTUALIZAR;


  PROCEDURE PR_ND_ELIMINAR (
    P_NDB_ID IN NUMBER,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
  ) IS
  BEGIN
    DELETE FROM MUE_NOTA_DEBITO
     WHERE NDB_Nota_Debito = P_NDB_ID;

    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG := 'Nota débito no encontrada.';
      RETURN;
    END IF;

    O_COD_RET := C_OK;
    O_MSG := 'Nota débito eliminada correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG := 'Error al eliminar nota débito: ' || SQLERRM;
  END PR_ND_ELIMINAR;


  PROCEDURE PR_ND_OBTENER (
    P_NDB_ID IN NUMBER,
    O_CURSOR OUT SYS_REFCURSOR,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
  ) IS
  BEGIN
    OPEN O_CURSOR FOR
      SELECT *
        FROM MUE_NOTA_DEBITO
       WHERE NDB_Nota_Debito = P_NDB_ID;

    O_COD_RET := C_OK;
    O_MSG := 'OK';
  END PR_ND_OBTENER;


  PROCEDURE PR_ND_LISTAR (
    P_FAC_FACTURA IN NUMBER DEFAULT NULL,
    O_CURSOR OUT SYS_REFCURSOR,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
  ) IS
  BEGIN
    OPEN O_CURSOR FOR
      SELECT *
        FROM MUE_NOTA_DEBITO
       WHERE P_FAC_FACTURA IS NULL
          OR FAC_Factura = P_FAC_FACTURA
       ORDER BY NDB_Fecha DESC;

    O_COD_RET := C_OK;
    O_MSG := 'OK';
  END PR_ND_LISTAR;

END PKG_MUE_NOTA_DEBITO;
/