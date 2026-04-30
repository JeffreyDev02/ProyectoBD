-- =============================================================================
-- Paquete PL/SQL (Oracle 21c)
-- Entidad   : MUE_METODO_PAGO
-- Referencia: Docs/DDL_MUEBLERIA.sql
-- Propósito : CRUD completo para el catálogo de métodos de pago.
-- Ejecutar conectado al esquema MUEBLERIA.
-- =============================================================================

CREATE OR REPLACE PACKAGE PKG_MUE_METODO_PAGO AS
  /**
   * Catálogo de métodos de pago — operaciones CRUD y listado.
   * Convención de retorno: O_COD_RET = 0 éxito; distinto de 0 error controlado.
   */

  PROCEDURE PR_METODO_PAGO_INSERTAR (
    P_MPA_METODO    IN  VARCHAR2,
    O_MPA_METODO_PAGO OUT NUMBER,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  );

  PROCEDURE PR_METODO_PAGO_ACTUALIZAR (
    P_MPA_METODO_PAGO IN  NUMBER,
    P_MPA_METODO      IN  VARCHAR2,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  );

  PROCEDURE PR_METODO_PAGO_ELIMINAR (
    P_MPA_METODO_PAGO IN  NUMBER,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  );

  PROCEDURE PR_METODO_PAGO_OBTENER (
    P_MPA_METODO_PAGO IN  NUMBER,
    O_MPA_METODO      OUT VARCHAR2,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  );

  PROCEDURE PR_METODO_PAGO_LISTAR (
    P_FILTRO_METODO IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR        OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  );

END PKG_MUE_METODO_PAGO;
/

CREATE OR REPLACE PACKAGE BODY PKG_MUE_METODO_PAGO AS

  C_OK    CONSTANT NUMBER := 0;
  C_ERR   CONSTANT NUMBER := 1;
  C_NOFND CONSTANT NUMBER := 2;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_METODO_PAGO_INSERTAR (
    P_MPA_METODO      IN  VARCHAR2,
    O_MPA_METODO_PAGO OUT NUMBER,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET         := C_ERR;
    O_MSG             := NULL;
    O_MPA_METODO_PAGO := NULL;

    IF TRIM(P_MPA_METODO) IS NULL THEN
      O_MSG := 'El nombre del método de pago es obligatorio.';
      RETURN;
    END IF;

    INSERT INTO MUE_METODO_PAGO (MPA_Metodo)
    VALUES (TRIM(P_MPA_METODO))
    RETURNING MPA_Metodo_Pago INTO O_MPA_METODO_PAGO;

    O_COD_RET := C_OK;
    O_MSG     := 'Método de pago registrado correctamente.';

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      O_COD_RET         := C_ERR;
      O_MSG             := 'Ya existe un método de pago con ese nombre.';
      O_MPA_METODO_PAGO := NULL;
    WHEN OTHERS THEN
      O_COD_RET         := C_ERR;
      O_MSG             := 'Error al insertar método de pago: ' || SQLERRM;
      O_MPA_METODO_PAGO := NULL;
  END PR_METODO_PAGO_INSERTAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_METODO_PAGO_ACTUALIZAR (
    P_MPA_METODO_PAGO IN  NUMBER,
    P_MPA_METODO      IN  VARCHAR2,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  ) IS
    V_N NUMBER;
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_MPA_METODO_PAGO IS NULL THEN
      O_MSG := 'Identificador de método de pago inválido.';
      RETURN;
    END IF;

    IF TRIM(P_MPA_METODO) IS NULL THEN
      O_MSG := 'El nombre del método de pago es obligatorio.';
      RETURN;
    END IF;

    SELECT COUNT(1) INTO V_N FROM MUE_METODO_PAGO WHERE MPA_Metodo_Pago = P_MPA_METODO_PAGO;
    IF V_N = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El método de pago no existe.';
      RETURN;
    END IF;

    UPDATE MUE_METODO_PAGO
       SET MPA_Metodo = TRIM(P_MPA_METODO)
     WHERE MPA_Metodo_Pago = P_MPA_METODO_PAGO;

    O_COD_RET := C_OK;
    O_MSG     := 'Método de pago actualizado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al actualizar método de pago: ' || SQLERRM;
  END PR_METODO_PAGO_ACTUALIZAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_METODO_PAGO_ELIMINAR (
    P_MPA_METODO_PAGO IN  NUMBER,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_MPA_METODO_PAGO IS NULL THEN
      O_MSG := 'Identificador de método de pago inválido.';
      RETURN;
    END IF;

    DELETE FROM MUE_METODO_PAGO WHERE MPA_Metodo_Pago = P_MPA_METODO_PAGO;
    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El método de pago no existe.';
      RETURN;
    END IF;

    O_COD_RET := C_OK;
    O_MSG     := 'Método de pago eliminado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      -- ORA-02292: referenciado en MUE_FACTURA
      O_COD_RET := C_ERR;
      O_MSG     := 'No se puede eliminar el método de pago (puede estar referenciado en facturas): ' || SQLERRM;
  END PR_METODO_PAGO_ELIMINAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_METODO_PAGO_OBTENER (
    P_MPA_METODO_PAGO IN  NUMBER,
    O_MPA_METODO      OUT VARCHAR2,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET    := C_ERR;
    O_MSG        := NULL;
    O_MPA_METODO := NULL;

    IF P_MPA_METODO_PAGO IS NULL THEN
      O_MSG := 'Identificador de método de pago inválido.';
      RETURN;
    END IF;

    SELECT M.MPA_Metodo
      INTO O_MPA_METODO
      FROM MUE_METODO_PAGO M
     WHERE M.MPA_Metodo_Pago = P_MPA_METODO_PAGO;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El método de pago no existe.';
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al consultar método de pago: ' || SQLERRM;
  END PR_METODO_PAGO_OBTENER;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_METODO_PAGO_LISTAR (
    P_FILTRO_METODO IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR        OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    OPEN O_CURSOR FOR
      SELECT M.MPA_Metodo_Pago AS Metodo_Pago_Id,
             M.MPA_Metodo      AS Metodo
        FROM MUE_METODO_PAGO M
       WHERE P_FILTRO_METODO IS NULL
          OR UPPER(M.MPA_Metodo) LIKE '%' || UPPER(TRIM(P_FILTRO_METODO)) || '%'
       ORDER BY M.MPA_Metodo ASC;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al listar métodos de pago: ' || SQLERRM;
  END PR_METODO_PAGO_LISTAR;

END PKG_MUE_METODO_PAGO;
/

-- Permisos de ejecución (ajustar usuario de aplicación)
-- GRANT EXECUTE ON PKG_MUE_METODO_PAGO TO USR_APP_MUEBLERIA;