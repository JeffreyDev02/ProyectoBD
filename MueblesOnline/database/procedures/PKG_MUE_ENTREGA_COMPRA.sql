-- =============================================================================
-- Paquete PL/SQL (Oracle 21c)
-- Entidad  : MUE_ENTREGA_COMPRA
-- Propósito: CRUD de fechas de entrega asociadas a pedidos a proveedor.
-- Ejecutar conectado al esquema MUEBLERIA.
-- =============================================================================

CREATE OR REPLACE PACKAGE PKG_MUE_ENTREGA_COMPRA AS
  /**
   * Catálogo de entregas de compra — operaciones CRUD y listado.
   * Convención de retorno: O_COD_RET = 0 éxito; distinto de 0 error controlado.
   */

  PROCEDURE PR_ENTREGA_COMPRA_INSERTAR (
    P_ECM_FECHA   IN  DATE,
    O_ECM_ENTREGA OUT NUMBER,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  );

  PROCEDURE PR_ENTREGA_COMPRA_ACTUALIZAR (
    P_ECM_ENTREGA IN  NUMBER,
    P_ECM_FECHA   IN  DATE,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  );

  PROCEDURE PR_ENTREGA_COMPRA_ELIMINAR (
    P_ECM_ENTREGA IN  NUMBER,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  );

  PROCEDURE PR_ENTREGA_COMPRA_OBTENER (
    P_ECM_ENTREGA IN  NUMBER,
    O_ECM_FECHA   OUT DATE,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  );

  PROCEDURE PR_ENTREGA_COMPRA_LISTAR (
    P_FILTRO_FECHA IN  DATE DEFAULT NULL,
    O_CURSOR       OUT SYS_REFCURSOR,
    O_COD_RET      OUT NUMBER,
    O_MSG          OUT VARCHAR2
  );

END PKG_MUE_ENTREGA_COMPRA;
/

CREATE OR REPLACE PACKAGE BODY PKG_MUE_ENTREGA_COMPRA AS

  C_OK    CONSTANT NUMBER := 0;
  C_ERR   CONSTANT NUMBER := 1;
  C_NOFND CONSTANT NUMBER := 2;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_ENTREGA_COMPRA_INSERTAR (
    P_ECM_FECHA   IN  DATE,
    O_ECM_ENTREGA OUT NUMBER,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET     := C_ERR;
    O_MSG         := NULL;
    O_ECM_ENTREGA := NULL;

    INSERT INTO MUE_ENTREGA_COMPRA (
      ECM_Fecha
    ) VALUES (
      P_ECM_FECHA
    )
    RETURNING ECM_Entrega_Compra INTO O_ECM_ENTREGA;

    O_COD_RET := C_OK;
    O_MSG     := 'Entrega de compra registrada correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET     := C_ERR;
      O_MSG         := 'Error al insertar entrega de compra: ' || SQLERRM;
      O_ECM_ENTREGA := NULL;
  END PR_ENTREGA_COMPRA_INSERTAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_ENTREGA_COMPRA_ACTUALIZAR (
    P_ECM_ENTREGA IN  NUMBER,
    P_ECM_FECHA   IN  DATE,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  ) IS
    V_N NUMBER;
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_ECM_ENTREGA IS NULL THEN
      O_MSG := 'Identificador de entrega de compra inválido.';
      RETURN;
    END IF;

    SELECT COUNT(1) INTO V_N FROM MUE_ENTREGA_COMPRA WHERE ECM_Entrega_Compra = P_ECM_ENTREGA;
    IF V_N = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'La entrega de compra no existe.';
      RETURN;
    END IF;

    UPDATE MUE_ENTREGA_COMPRA
       SET ECM_Fecha = P_ECM_FECHA
     WHERE ECM_Entrega_Compra = P_ECM_ENTREGA;

    O_COD_RET := C_OK;
    O_MSG     := 'Entrega de compra actualizada correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al actualizar entrega de compra: ' || SQLERRM;
  END PR_ENTREGA_COMPRA_ACTUALIZAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_ENTREGA_COMPRA_ELIMINAR (
    P_ECM_ENTREGA IN  NUMBER,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_ECM_ENTREGA IS NULL THEN
      O_MSG := 'Identificador de entrega de compra inválido.';
      RETURN;
    END IF;

    DELETE FROM MUE_ENTREGA_COMPRA WHERE ECM_Entrega_Compra = P_ECM_ENTREGA;

    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'La entrega de compra no existe.';
      RETURN;
    END IF;

    O_COD_RET := C_OK;
    O_MSG     := 'Entrega de compra eliminada correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      -- Ej.: ORA-02292 si MUE_PEDIDO_PROVEEDOR referencia esta entrega
      O_COD_RET := C_ERR;
      O_MSG     := 'No se puede eliminar la entrega (puede estar referenciada): ' || SQLERRM;
  END PR_ENTREGA_COMPRA_ELIMINAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_ENTREGA_COMPRA_OBTENER (
    P_ECM_ENTREGA IN  NUMBER,
    O_ECM_FECHA   OUT DATE,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET   := C_ERR;
    O_MSG       := NULL;
    O_ECM_FECHA := NULL;

    IF P_ECM_ENTREGA IS NULL THEN
      O_MSG := 'Identificador de entrega de compra inválido.';
      RETURN;
    END IF;

    SELECT E.ECM_Fecha
      INTO O_ECM_FECHA
      FROM MUE_ENTREGA_COMPRA E
     WHERE E.ECM_Entrega_Compra = P_ECM_ENTREGA;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'La entrega de compra no existe.';
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al consultar entrega de compra: ' || SQLERRM;
  END PR_ENTREGA_COMPRA_OBTENER;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_ENTREGA_COMPRA_LISTAR (
    P_FILTRO_FECHA IN  DATE DEFAULT NULL,
    O_CURSOR       OUT SYS_REFCURSOR,
    O_COD_RET      OUT NUMBER,
    O_MSG          OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    OPEN O_CURSOR FOR
      SELECT E.ECM_Entrega_Compra AS Entrega_Id,
             E.ECM_Fecha          AS Fecha
        FROM MUE_ENTREGA_COMPRA E
       WHERE P_FILTRO_FECHA IS NULL
          OR E.ECM_Fecha = P_FILTRO_FECHA
       ORDER BY E.ECM_Fecha DESC;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al listar entregas de compra: ' || SQLERRM;
  END PR_ENTREGA_COMPRA_LISTAR;

END PKG_MUE_ENTREGA_COMPRA;
/

-- GRANT EXECUTE ON PKG_MUE_ENTREGA_COMPRA TO USR_APP_MUEBLERIA;