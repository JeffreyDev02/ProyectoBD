-- =============================================================================
-- Paquete PL/SQL (Oracle 21c)
-- Entidad   : MUE_ESTADO_ORDEN_VENTA
-- Referencia: Docs/DDL_MUEBLERIA.sql
-- Propósito : CRUD completo para el catálogo de estados de orden de venta.
-- Ejecutar conectado al esquema MUEBLERIA.
-- =============================================================================

CREATE OR REPLACE PACKAGE PKG_MUE_ESTADO_ORDEN_VENTA AS

  PROCEDURE PR_ESTADO_OV_INSERTAR (
    P_EOV_ESTADO      IN  VARCHAR2,
    P_EOV_DESCRIPCION IN  VARCHAR2,
    O_EOV_ESTADO_OV   OUT NUMBER,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  );

  PROCEDURE PR_ESTADO_OV_ACTUALIZAR (
    P_EOV_ESTADO_OV   IN  NUMBER,
    P_EOV_ESTADO      IN  VARCHAR2,
    P_EOV_DESCRIPCION IN  VARCHAR2,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  );

  PROCEDURE PR_ESTADO_OV_ELIMINAR (
    P_EOV_ESTADO_OV IN  NUMBER,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  );

  PROCEDURE PR_ESTADO_OV_OBTENER (
    P_EOV_ESTADO_OV   IN  NUMBER,
    O_EOV_ESTADO      OUT VARCHAR2,
    O_EOV_DESCRIPCION OUT VARCHAR2,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  );

  PROCEDURE PR_ESTADO_OV_LISTAR (
    P_FILTRO_ESTADO IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR        OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  );

END PKG_MUE_ESTADO_ORDEN_VENTA;
/

CREATE OR REPLACE PACKAGE BODY PKG_MUE_ESTADO_ORDEN_VENTA AS

  C_OK    CONSTANT NUMBER := 0;
  C_ERR   CONSTANT NUMBER := 1;
  C_NOFND CONSTANT NUMBER := 2;

  PROCEDURE PR_ESTADO_OV_INSERTAR (
    P_EOV_ESTADO      IN  VARCHAR2,
    P_EOV_DESCRIPCION IN  VARCHAR2,
    O_EOV_ESTADO_OV   OUT NUMBER,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET       := C_ERR;
    O_MSG           := NULL;
    O_EOV_ESTADO_OV := NULL;

    IF TRIM(P_EOV_ESTADO) IS NULL THEN
      O_MSG := 'El estado de la orden de venta es obligatorio.';
      RETURN;
    END IF;

    INSERT INTO MUE_ESTADO_ORDEN_VENTA (EOV_Estado, EOV_Descripcion)
    VALUES (TRIM(P_EOV_ESTADO), P_EOV_DESCRIPCION)
    RETURNING EOV_Estado_Orden_Venta INTO O_EOV_ESTADO_OV;

    O_COD_RET := C_OK;
    O_MSG     := 'Estado de orden de venta registrado correctamente.';
  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET       := C_ERR;
      O_MSG           := 'Error al insertar estado de orden de venta: ' || SQLERRM;
      O_EOV_ESTADO_OV := NULL;
  END PR_ESTADO_OV_INSERTAR;

  PROCEDURE PR_ESTADO_OV_ACTUALIZAR (
    P_EOV_ESTADO_OV   IN  NUMBER,
    P_EOV_ESTADO      IN  VARCHAR2,
    P_EOV_DESCRIPCION IN  VARCHAR2,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  ) IS
    V_N NUMBER;
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_EOV_ESTADO_OV IS NULL THEN
      O_MSG := 'Identificador de estado inválido.';
      RETURN;
    END IF;

    IF TRIM(P_EOV_ESTADO) IS NULL THEN
      O_MSG := 'El estado es obligatorio.';
      RETURN;
    END IF;

    SELECT COUNT(1) INTO V_N FROM MUE_ESTADO_ORDEN_VENTA WHERE EOV_Estado_Orden_Venta = P_EOV_ESTADO_OV;
    IF V_N = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El estado de orden de venta no existe.';
      RETURN;
    END IF;

    UPDATE MUE_ESTADO_ORDEN_VENTA
       SET EOV_Estado      = TRIM(P_EOV_ESTADO),
           EOV_Descripcion = P_EOV_DESCRIPCION
     WHERE EOV_Estado_Orden_Venta = P_EOV_ESTADO_OV;

    O_COD_RET := C_OK;
    O_MSG     := 'Estado de orden de venta actualizado correctamente.';
  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al actualizar estado de orden de venta: ' || SQLERRM;
  END PR_ESTADO_OV_ACTUALIZAR;

  PROCEDURE PR_ESTADO_OV_ELIMINAR (
    P_EOV_ESTADO_OV IN  NUMBER,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_EOV_ESTADO_OV IS NULL THEN
      O_MSG := 'Identificador de estado inválido.';
      RETURN;
    END IF;

    DELETE FROM MUE_ESTADO_ORDEN_VENTA WHERE EOV_Estado_Orden_Venta = P_EOV_ESTADO_OV;
    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El estado de orden de venta no existe.';
      RETURN;
    END IF;

    O_COD_RET := C_OK;
    O_MSG     := 'Estado de orden de venta eliminado correctamente.';
  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'No se puede eliminar el estado (puede estar referenciado en órdenes de venta): ' || SQLERRM;
  END PR_ESTADO_OV_ELIMINAR;

  PROCEDURE PR_ESTADO_OV_OBTENER (
    P_EOV_ESTADO_OV   IN  NUMBER,
    O_EOV_ESTADO      OUT VARCHAR2,
    O_EOV_DESCRIPCION OUT VARCHAR2,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET         := C_ERR;
    O_MSG             := NULL;
    O_EOV_ESTADO      := NULL;
    O_EOV_DESCRIPCION := NULL;

    IF P_EOV_ESTADO_OV IS NULL THEN
      O_MSG := 'Identificador de estado inválido.';
      RETURN;
    END IF;

    SELECT E.EOV_Estado, E.EOV_Descripcion
      INTO O_EOV_ESTADO, O_EOV_DESCRIPCION
      FROM MUE_ESTADO_ORDEN_VENTA E
     WHERE E.EOV_Estado_Orden_Venta = P_EOV_ESTADO_OV;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El estado de orden de venta no existe.';
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al consultar estado de orden de venta: ' || SQLERRM;
  END PR_ESTADO_OV_OBTENER;

  PROCEDURE PR_ESTADO_OV_LISTAR (
    P_FILTRO_ESTADO IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR        OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    OPEN O_CURSOR FOR
      SELECT E.EOV_Estado_Orden_Venta AS Estado_OV_Id,
             E.EOV_Estado             AS Estado,
             E.EOV_Descripcion        AS Descripcion
        FROM MUE_ESTADO_ORDEN_VENTA E
       WHERE P_FILTRO_ESTADO IS NULL
          OR UPPER(E.EOV_Estado) LIKE '%' || UPPER(TRIM(P_FILTRO_ESTADO)) || '%'
       ORDER BY E.EOV_Estado ASC;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al listar estados de orden de venta: ' || SQLERRM;
  END PR_ESTADO_OV_LISTAR;

END PKG_MUE_ESTADO_ORDEN_VENTA;
/

-- GRANT EXECUTE ON PKG_MUE_ESTADO_ORDEN_VENTA TO USR_APP_MUEBLERIA;