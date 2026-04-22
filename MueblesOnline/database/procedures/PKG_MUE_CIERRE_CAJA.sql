CREATE OR REPLACE PACKAGE PKG_MUE_CIERRE_CAJA AS

  PROCEDURE PR_CAJA_APERTURAR (
    P_SED_SEDE        IN NUMBER,
    P_MONTO_INICIAL   IN NUMBER,
    P_ECA_ESTADO      IN NUMBER,
    O_CCA_CIERRE      OUT NUMBER,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  );

  PROCEDURE PR_CAJA_CERRAR (
    P_CCA_CIERRE      IN NUMBER,
    P_MONTO_FINAL     IN NUMBER,
    P_ECA_ESTADO      IN NUMBER,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  );

  PROCEDURE PR_CAJA_OBTENER (
    P_CCA_CIERRE      IN NUMBER,
    O_CURSOR          OUT SYS_REFCURSOR,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  );

  PROCEDURE PR_CAJA_LISTAR (
    O_CURSOR          OUT SYS_REFCURSOR,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  );

  PROCEDURE PR_CAJA_ELIMINAR (
    P_CCA_CIERRE      IN NUMBER,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  );

END PKG_MUE_CIERRE_CAJA;
/
CREATE OR REPLACE PACKAGE BODY PKG_MUE_CIERRE_CAJA AS

  C_OK       CONSTANT NUMBER := 0;
  C_ERR      CONSTANT NUMBER := 1;
  C_NOFND    CONSTANT NUMBER := 2;

  PROCEDURE PR_CAJA_APERTURAR (
    P_SED_SEDE,
    P_MONTO_INICIAL,
    P_ECA_ESTADO,
    O_CCA_CIERRE OUT NUMBER,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
  ) IS
    V_EXISTE NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO V_EXISTE
      FROM MUE_CIERRE_CAJA
     WHERE SED_Sede = P_SED_SEDE
       AND CCA_Fecha_Fin IS NULL;

    IF V_EXISTE > 0 THEN
      O_COD_RET := C_ERR;
      O_MSG := 'Ya existe una caja abierta en esta sede.';
      RETURN;
    END IF;

    INSERT INTO MUE_CIERRE_CAJA (
      SED_Sede,
      CCA_Fecha_Inicio,
      CCA_Monto_Inicial,
      ECA_Estado,
      CCA_Created_At
    )
    VALUES (
      P_SED_SEDE,
      SYSTIMESTAMP,
      P_MONTO_INICIAL,
      P_ECA_ESTADO,
      SYSTIMESTAMP
    )
    RETURNING CCA_Cierre_Caja INTO O_CCA_CIERRE;

    O_COD_RET := C_OK;
    O_MSG := 'Caja aperturada correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG := 'Error al aperturar caja: ' || SQLERRM;
  END PR_CAJA_APERTURAR;


  PROCEDURE PR_CAJA_CERRAR (
    P_CCA_CIERRE,
    P_MONTO_FINAL,
    P_ECA_ESTADO,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
  ) IS
  BEGIN
    UPDATE MUE_CIERRE_CAJA
       SET CCA_Fecha_Fin = SYSTIMESTAMP,
           CCA_Monto_Final = P_MONTO_FINAL,
           ECA_Estado = P_ECA_ESTADO
     WHERE CCA_Cierre_Caja = P_CCA_CIERRE
       AND CCA_Fecha_Fin IS NULL;

    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG := 'Caja no encontrada o ya cerrada.';
      RETURN;
    END IF;

    O_COD_RET := C_OK;
    O_MSG := 'Caja cerrada correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG := 'Error al cerrar caja: ' || SQLERRM;
  END PR_CAJA_CERRAR;


  PROCEDURE PR_CAJA_OBTENER (
    P_CCA_CIERRE IN NUMBER,
    O_CURSOR OUT SYS_REFCURSOR,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
  ) IS
  BEGIN
    OPEN O_CURSOR FOR
      SELECT *
        FROM MUE_CIERRE_CAJA
       WHERE CCA_Cierre_Caja = P_CCA_CIERRE;

    O_COD_RET := C_OK;
    O_MSG := 'OK';
  END PR_CAJA_OBTENER;


  PROCEDURE PR_CAJA_LISTAR (
    O_CURSOR OUT SYS_REFCURSOR,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
  ) IS
  BEGIN
    OPEN O_CURSOR FOR
      SELECT *
        FROM MUE_CIERRE_CAJA
       ORDER BY CCA_Fecha_Inicio DESC;

    O_COD_RET := C_OK;
    O_MSG := 'OK';
  END PR_CAJA_LISTAR;


  PROCEDURE PR_CAJA_ELIMINAR (
    P_CCA_CIERRE IN NUMBER,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
  ) IS
  BEGIN
    DELETE FROM MUE_CIERRE_CAJA
     WHERE CCA_Cierre_Caja = P_CCA_CIERRE;

    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG := 'Registro de caja no encontrado.';
      RETURN;
    END IF;

    O_COD_RET := C_OK;
    O_MSG := 'Registro eliminado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG := 'Error al eliminar registro: ' || SQLERRM;
  END PR_CAJA_ELIMINAR;

END PKG_MUE_CIERRE_CAJA;
/