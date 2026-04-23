-- =============================================================================
-- Paquete PL/SQL (Oracle 21c)
-- Entidad  : MUE_ESTADO_CAJA
-- Propósito: CRUD de estados de caja (ej. ABIERTA, CERRADA, EN_REVISION).
-- Ejecutar conectado al esquema MUEBLERIA.
-- =============================================================================

CREATE OR REPLACE PACKAGE PKG_MUE_ESTADO_CAJA AS
  /**
   * Catálogo de estados de caja — operaciones CRUD y listado.
   * Convención de retorno: O_COD_RET = 0 éxito; distinto de 0 error controlado.
   */

  PROCEDURE PR_ESTADO_CAJA_INSERTAR (
    P_ECA_ESTADO   IN  VARCHAR2,
    O_ECA_ESTADO_C OUT NUMBER,
    O_COD_RET      OUT NUMBER,
    O_MSG          OUT VARCHAR2
  );

  PROCEDURE PR_ESTADO_CAJA_ACTUALIZAR (
    P_ECA_ESTADO_C IN  NUMBER,
    P_ECA_ESTADO   IN  VARCHAR2,
    O_COD_RET      OUT NUMBER,
    O_MSG          OUT VARCHAR2
  );

  PROCEDURE PR_ESTADO_CAJA_ELIMINAR (
    P_ECA_ESTADO_C IN  NUMBER,
    O_COD_RET      OUT NUMBER,
    O_MSG          OUT VARCHAR2
  );

  PROCEDURE PR_ESTADO_CAJA_OBTENER (
    P_ECA_ESTADO_C IN  NUMBER,
    O_ECA_ESTADO   OUT VARCHAR2,
    O_COD_RET      OUT NUMBER,
    O_MSG          OUT VARCHAR2
  );

  PROCEDURE PR_ESTADO_CAJA_LISTAR (
    P_FILTRO_ESTADO IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR        OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  );

END PKG_MUE_ESTADO_CAJA;
/

CREATE OR REPLACE PACKAGE BODY PKG_MUE_ESTADO_CAJA AS

  C_OK    CONSTANT NUMBER := 0;
  C_ERR   CONSTANT NUMBER := 1;
  C_NOFND CONSTANT NUMBER := 2;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_ESTADO_CAJA_INSERTAR (
    P_ECA_ESTADO   IN  VARCHAR2,
    O_ECA_ESTADO_C OUT NUMBER,
    O_COD_RET      OUT NUMBER,
    O_MSG          OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET      := C_ERR;
    O_MSG          := NULL;
    O_ECA_ESTADO_C := NULL;

    IF TRIM(P_ECA_ESTADO) IS NULL THEN
      O_MSG := 'El estado de caja es obligatorio.';
      RETURN;
    END IF;

    INSERT INTO MUE_ESTADO_CAJA (
      ECA_Estado
    ) VALUES (
      P_ECA_ESTADO
    )
    RETURNING ECA_Estado_Caja INTO O_ECA_ESTADO_C;

    O_COD_RET := C_OK;
    O_MSG     := 'Estado de caja registrado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET      := C_ERR;
      O_MSG          := 'Error al insertar estado de caja: ' || SQLERRM;
      O_ECA_ESTADO_C := NULL;
  END PR_ESTADO_CAJA_INSERTAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_ESTADO_CAJA_ACTUALIZAR (
    P_ECA_ESTADO_C IN  NUMBER,
    P_ECA_ESTADO   IN  VARCHAR2,
    O_COD_RET      OUT NUMBER,
    O_MSG          OUT VARCHAR2
  ) IS
    V_N NUMBER;
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_ECA_ESTADO_C IS NULL THEN
      O_MSG := 'Identificador de estado de caja inválido.';
      RETURN;
    END IF;

    SELECT COUNT(1) INTO V_N FROM MUE_ESTADO_CAJA WHERE ECA_Estado_Caja = P_ECA_ESTADO_C;
    IF V_N = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El estado de caja no existe.';
      RETURN;
    END IF;

    UPDATE MUE_ESTADO_CAJA
       SET ECA_Estado = P_ECA_ESTADO
     WHERE ECA_Estado_Caja = P_ECA_ESTADO_C;

    O_COD_RET := C_OK;
    O_MSG     := 'Estado de caja actualizado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al actualizar estado de caja: ' || SQLERRM;
  END PR_ESTADO_CAJA_ACTUALIZAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_ESTADO_CAJA_ELIMINAR (
    P_ECA_ESTADO_C IN  NUMBER,
    O_COD_RET      OUT NUMBER,
    O_MSG          OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_ECA_ESTADO_C IS NULL THEN
      O_MSG := 'Identificador de estado de caja inválido.';
      RETURN;
    END IF;

    DELETE FROM MUE_ESTADO_CAJA WHERE ECA_Estado_Caja = P_ECA_ESTADO_C;

    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El estado de caja no existe.';
      RETURN;
    END IF;

    O_COD_RET := C_OK;
    O_MSG     := 'Estado de caja eliminado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      -- Ej.: ORA-02292 si MUE_CIERRE_CAJA referencia este estado
      O_COD_RET := C_ERR;
      O_MSG     := 'No se puede eliminar el estado de caja (puede estar referenciado): ' || SQLERRM;
  END PR_ESTADO_CAJA_ELIMINAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_ESTADO_CAJA_OBTENER (
    P_ECA_ESTADO_C IN  NUMBER,
    O_ECA_ESTADO   OUT VARCHAR2,
    O_COD_RET      OUT NUMBER,
    O_MSG          OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET    := C_ERR;
    O_MSG        := NULL;
    O_ECA_ESTADO := NULL;

    IF P_ECA_ESTADO_C IS NULL THEN
      O_MSG := 'Identificador de estado de caja inválido.';
      RETURN;
    END IF;

    SELECT E.ECA_Estado
      INTO O_ECA_ESTADO
      FROM MUE_ESTADO_CAJA E
     WHERE E.ECA_Estado_Caja = P_ECA_ESTADO_C;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El estado de caja no existe.';
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al consultar estado de caja: ' || SQLERRM;
  END PR_ESTADO_CAJA_OBTENER;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_ESTADO_CAJA_LISTAR (
    P_FILTRO_ESTADO IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR        OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    OPEN O_CURSOR FOR
      SELECT E.ECA_Estado_Caja AS Estado_Caja_Id,
             E.ECA_Estado      AS Estado
        FROM MUE_ESTADO_CAJA E
       WHERE P_FILTRO_ESTADO IS NULL
          OR UPPER(E.ECA_Estado) LIKE '%' || UPPER(TRIM(P_FILTRO_ESTADO)) || '%'
       ORDER BY E.ECA_Estado ASC;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al listar estados de caja: ' || SQLERRM;
  END PR_ESTADO_CAJA_LISTAR;

END PKG_MUE_ESTADO_CAJA;
/

-- GRANT EXECUTE ON PKG_MUE_ESTADO_CAJA TO USR_APP_MUEBLERIA;