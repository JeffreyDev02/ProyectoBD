-- =============================================================================
-- Paquete PL/SQL (Oracle 21c)
-- Entidad   : MUE_CIERRE_CAJA
-- Referencia: Docs/DDL_MUEBLERIA.sql
-- Propósito : CRUD para cierres de caja (FK a MUE_SEDE, MUE_ESTADO_CAJA).
-- Ejecutar conectado al esquema MUEBLERIA.
-- =============================================================================

CREATE OR REPLACE PACKAGE PKG_MUE_CIERRE_CAJA AS
  /**
   * Cierres de caja — operaciones CRUD y listado.
   * Convención de retorno: O_COD_RET = 0 éxito; distinto de 0 error controlado.
   */

  PROCEDURE PR_CIERRE_INSERTAR (
    P_SED_SEDE          IN NUMBER,
    P_CCA_FECHA_INICIO  IN TIMESTAMP,
    P_CCA_FECHA_FIN     IN TIMESTAMP DEFAULT NULL,
    P_CCA_MONTO_INICIAL IN NUMBER DEFAULT NULL,
    P_CCA_MONTO_FINAL   IN NUMBER DEFAULT NULL,
    P_ECA_ESTADO        IN NUMBER,
    O_CCA_CIERRE        OUT NUMBER,
    O_COD_RET           OUT NUMBER,
    O_MSG               OUT VARCHAR2
  );

  PROCEDURE PR_CIERRE_ACTUALIZAR (
    P_CCA_CIERRE        IN NUMBER,
    P_SED_SEDE          IN NUMBER,
    P_CCA_FECHA_INICIO  IN TIMESTAMP,
    P_CCA_FECHA_FIN     IN TIMESTAMP DEFAULT NULL,
    P_CCA_MONTO_INICIAL IN NUMBER DEFAULT NULL,
    P_CCA_MONTO_FINAL   IN NUMBER DEFAULT NULL,
    P_ECA_ESTADO        IN NUMBER,
    O_COD_RET           OUT NUMBER,
    O_MSG               OUT VARCHAR2
  );

  PROCEDURE PR_CIERRE_ELIMINAR (
    P_CCA_CIERRE IN NUMBER,
    O_COD_RET    OUT NUMBER,
    O_MSG        OUT VARCHAR2
  );

  PROCEDURE PR_CIERRE_OBTENER (
    P_CCA_CIERRE IN NUMBER,
    O_CURSOR     OUT SYS_REFCURSOR,
    O_COD_RET    OUT NUMBER,
    O_MSG        OUT VARCHAR2
  );

  PROCEDURE PR_CIERRE_LISTAR (
    P_SED_SEDE IN NUMBER DEFAULT NULL,
    O_CURSOR   OUT SYS_REFCURSOR,
    O_COD_RET  OUT NUMBER,
    O_MSG      OUT VARCHAR2
  );

END PKG_MUE_CIERRE_CAJA;
/

CREATE OR REPLACE PACKAGE BODY PKG_MUE_CIERRE_CAJA AS

  C_OK    CONSTANT NUMBER := 0;
  C_ERR   CONSTANT NUMBER := 1;
  C_NOFND CONSTANT NUMBER := 2;

  PROCEDURE PR_CIERRE_INSERTAR (
    P_SED_SEDE          IN NUMBER,
    P_CCA_FECHA_INICIO  IN TIMESTAMP,
    P_CCA_FECHA_FIN     IN TIMESTAMP DEFAULT NULL,
    P_CCA_MONTO_INICIAL IN NUMBER DEFAULT NULL,
    P_CCA_MONTO_FINAL   IN NUMBER DEFAULT NULL,
    P_ECA_ESTADO        IN NUMBER,
    O_CCA_CIERRE        OUT NUMBER,
    O_COD_RET           OUT NUMBER,
    O_MSG               OUT VARCHAR2
  ) IS
    V_N NUMBER;
  BEGIN
    O_COD_RET    := C_ERR;
    O_MSG        := NULL;
    O_CCA_CIERRE := NULL;

    IF P_SED_SEDE IS NULL THEN
      O_MSG := 'La sede es obligatoria.';
      RETURN;
    END IF;

    IF P_CCA_FECHA_INICIO IS NULL THEN
      O_MSG := 'La fecha de inicio es obligatoria.';
      RETURN;
    END IF;

    IF P_ECA_ESTADO IS NULL THEN
      O_MSG := 'El estado de caja es obligatorio.';
      RETURN;
    END IF;

    IF P_CCA_FECHA_FIN IS NOT NULL AND P_CCA_FECHA_FIN < P_CCA_FECHA_INICIO THEN
      O_MSG := 'La fecha fin no puede ser anterior a la fecha de inicio.';
      RETURN;
    END IF;

    SELECT COUNT(1) INTO V_N FROM MUE_SEDE WHERE SED_Sede = P_SED_SEDE;
    IF V_N = 0 THEN
      O_MSG := 'La sede indicada no existe.';
      RETURN;
    END IF;

    SELECT COUNT(1) INTO V_N FROM MUE_ESTADO_CAJA WHERE ECA_Estado_Caja = P_ECA_ESTADO;
    IF V_N = 0 THEN
      O_MSG := 'El estado de caja indicado no existe.';
      RETURN;
    END IF;

    INSERT INTO MUE_CIERRE_CAJA (
      SED_Sede,
      CCA_Fecha_Inicio,
      CCA_Fecha_Fin,
      CCA_Monto_Inicial,
      CCA_Monto_Final,
      ECA_Estado,
      CCA_Created_At
    ) VALUES (
      P_SED_SEDE,
      P_CCA_FECHA_INICIO,
      P_CCA_FECHA_FIN,
      P_CCA_MONTO_INICIAL,
      P_CCA_MONTO_FINAL,
      P_ECA_ESTADO,
      SYSTIMESTAMP
    )
    RETURNING CCA_Cierre_Caja INTO O_CCA_CIERRE;

    O_COD_RET := C_OK;
    O_MSG     := 'Cierre de caja registrado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET    := C_ERR;
      O_MSG        := 'Error al insertar cierre de caja: ' || SQLERRM;
      O_CCA_CIERRE := NULL;
  END PR_CIERRE_INSERTAR;


  PROCEDURE PR_CIERRE_ACTUALIZAR (
    P_CCA_CIERRE        IN NUMBER,
    P_SED_SEDE          IN NUMBER,
    P_CCA_FECHA_INICIO  IN TIMESTAMP,
    P_CCA_FECHA_FIN     IN TIMESTAMP DEFAULT NULL,
    P_CCA_MONTO_INICIAL IN NUMBER DEFAULT NULL,
    P_CCA_MONTO_FINAL   IN NUMBER DEFAULT NULL,
    P_ECA_ESTADO        IN NUMBER,
    O_COD_RET           OUT NUMBER,
    O_MSG               OUT VARCHAR2
  ) IS
    V_N NUMBER;
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_CCA_CIERRE IS NULL THEN
      O_MSG := 'Identificador de cierre de caja inválido.';
      RETURN;
    END IF;

    IF P_SED_SEDE IS NULL THEN
      O_MSG := 'La sede es obligatoria.';
      RETURN;
    END IF;

    IF P_CCA_FECHA_INICIO IS NULL THEN
      O_MSG := 'La fecha de inicio es obligatoria.';
      RETURN;
    END IF;

    IF P_ECA_ESTADO IS NULL THEN
      O_MSG := 'El estado de caja es obligatorio.';
      RETURN;
    END IF;

    IF P_CCA_FECHA_FIN IS NOT NULL AND P_CCA_FECHA_FIN < P_CCA_FECHA_INICIO THEN
      O_MSG := 'La fecha fin no puede ser anterior a la fecha de inicio.';
      RETURN;
    END IF;

    SELECT COUNT(1) INTO V_N FROM MUE_CIERRE_CAJA WHERE CCA_Cierre_Caja = P_CCA_CIERRE;
    IF V_N = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El cierre de caja no existe.';
      RETURN;
    END IF;

    SELECT COUNT(1) INTO V_N FROM MUE_SEDE WHERE SED_Sede = P_SED_SEDE;
    IF V_N = 0 THEN
      O_MSG := 'La sede indicada no existe.';
      RETURN;
    END IF;

    SELECT COUNT(1) INTO V_N FROM MUE_ESTADO_CAJA WHERE ECA_Estado_Caja = P_ECA_ESTADO;
    IF V_N = 0 THEN
      O_MSG := 'El estado de caja indicado no existe.';
      RETURN;
    END IF;

    UPDATE MUE_CIERRE_CAJA
       SET SED_Sede          = P_SED_SEDE,
           CCA_Fecha_Inicio  = P_CCA_FECHA_INICIO,
           CCA_Fecha_Fin     = P_CCA_FECHA_FIN,
           CCA_Monto_Inicial = P_CCA_MONTO_INICIAL,
           CCA_Monto_Final   = P_CCA_MONTO_FINAL,
           ECA_Estado        = P_ECA_ESTADO
     WHERE CCA_Cierre_Caja = P_CCA_CIERRE;

    O_COD_RET := C_OK;
    O_MSG     := 'Cierre de caja actualizado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al actualizar cierre de caja: ' || SQLERRM;
  END PR_CIERRE_ACTUALIZAR;


  PROCEDURE PR_CIERRE_ELIMINAR (
    P_CCA_CIERRE IN NUMBER,
    O_COD_RET    OUT NUMBER,
    O_MSG        OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_CCA_CIERRE IS NULL THEN
      O_MSG := 'Identificador de cierre de caja inválido.';
      RETURN;
    END IF;

    DELETE FROM MUE_CIERRE_CAJA WHERE CCA_Cierre_Caja = P_CCA_CIERRE;

    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El cierre de caja no existe.';
      RETURN;
    END IF;

    O_COD_RET := C_OK;
    O_MSG     := 'Cierre de caja eliminado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al eliminar cierre de caja: ' || SQLERRM;
  END PR_CIERRE_ELIMINAR;


  PROCEDURE PR_CIERRE_OBTENER (
    P_CCA_CIERRE IN NUMBER,
    O_CURSOR     OUT SYS_REFCURSOR,
    O_COD_RET    OUT NUMBER,
    O_MSG        OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_CCA_CIERRE IS NULL THEN
      O_MSG := 'Identificador de cierre de caja inválido.';
      RETURN;
    END IF;

    OPEN O_CURSOR FOR
      SELECT C.CCA_Cierre_Caja,
             C.SED_Sede,
             C.CCA_Fecha_Inicio,
             C.CCA_Fecha_Fin,
             C.CCA_Monto_Inicial,
             C.CCA_Monto_Final,
             C.ECA_Estado,
             C.CCA_Created_At
        FROM MUE_CIERRE_CAJA C
       WHERE C.CCA_Cierre_Caja = P_CCA_CIERRE;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al consultar cierre de caja: ' || SQLERRM;
  END PR_CIERRE_OBTENER;


  PROCEDURE PR_CIERRE_LISTAR (
    P_SED_SEDE IN NUMBER DEFAULT NULL,
    O_CURSOR   OUT SYS_REFCURSOR,
    O_COD_RET  OUT NUMBER,
    O_MSG      OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    OPEN O_CURSOR FOR
      SELECT C.CCA_Cierre_Caja,
             C.SED_Sede,
             C.CCA_Fecha_Inicio,
             C.CCA_Fecha_Fin,
             C.CCA_Monto_Inicial,
             C.CCA_Monto_Final,
             C.ECA_Estado,
             C.CCA_Created_At
        FROM MUE_CIERRE_CAJA C
       WHERE P_SED_SEDE IS NULL OR C.SED_Sede = P_SED_SEDE
       ORDER BY C.CCA_Fecha_Inicio DESC, C.CCA_Cierre_Caja DESC;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al listar cierres de caja: ' || SQLERRM;
  END PR_CIERRE_LISTAR;

END PKG_MUE_CIERRE_CAJA;
/
