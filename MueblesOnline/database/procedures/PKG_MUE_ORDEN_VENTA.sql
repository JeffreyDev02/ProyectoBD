-- =============================================================================
-- PAQUETE: PKG_MUE_ORDEN_VENTA
-- TABLA: MUE_ORDEN_VENTA
-- =============================================================================

CREATE OR REPLACE PACKAGE PKG_MUE_ORDEN_VENTA AS

  PROCEDURE PR_ORDEN_INSERTAR (
    P_MOV_NUMERO      IN VARCHAR2,
    P_MOV_FECHA       IN DATE,
    P_MOV_DESCRIPCION IN VARCHAR2,
    P_EOV_ESTADO      IN NUMBER,
    P_USU_USUARIO     IN NUMBER,
    P_ENV_ENVIO       IN NUMBER,
    O_MOV_ORDEN       OUT NUMBER,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  );

  PROCEDURE PR_ORDEN_ACTUALIZAR (
    P_MOV_ORDEN       IN NUMBER,
    P_MOV_NUMERO      IN VARCHAR2,
    P_MOV_FECHA       IN DATE,
    P_MOV_DESCRIPCION IN VARCHAR2,
    P_EOV_ESTADO      IN NUMBER,
    P_USU_USUARIO     IN NUMBER,
    P_ENV_ENVIO       IN NUMBER,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  );

  PROCEDURE PR_ORDEN_CAMBIAR_ESTADO (
    P_MOV_ORDEN   IN NUMBER,
    P_EOV_ESTADO  IN NUMBER,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  );

  PROCEDURE PR_ORDEN_RECALCULAR_TOTAL (
    P_MOV_ORDEN   IN NUMBER,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  );

  PROCEDURE PR_ORDEN_ELIMINAR (
    P_MOV_ORDEN IN NUMBER,
    O_COD_RET   OUT NUMBER,
    O_MSG       OUT VARCHAR2
  );

  PROCEDURE PR_ORDEN_OBTENER (
    P_MOV_ORDEN IN NUMBER,
    O_CURSOR    OUT SYS_REFCURSOR,
    O_COD_RET   OUT NUMBER,
    O_MSG       OUT VARCHAR2
  );

  PROCEDURE PR_ORDEN_LISTAR (
    O_CURSOR   OUT SYS_REFCURSOR,
    O_COD_RET  OUT NUMBER,
    O_MSG      OUT VARCHAR2
  );

END PKG_MUE_ORDEN_VENTA;
/
CREATE OR REPLACE PACKAGE BODY PKG_MUE_ORDEN_VENTA AS

  C_OK    CONSTANT NUMBER := 0;
  C_ERR   CONSTANT NUMBER := 1;
  C_NOFND CONSTANT NUMBER := 2;

  PROCEDURE PR_ORDEN_INSERTAR (
    P_MOV_NUMERO      IN VARCHAR2,
    P_MOV_FECHA       IN DATE,
    P_MOV_DESCRIPCION IN VARCHAR2,
    P_EOV_ESTADO      IN NUMBER,
    P_USU_USUARIO     IN NUMBER,
    P_ENV_ENVIO       IN NUMBER,
    O_MOV_ORDEN       OUT NUMBER,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  ) IS
  BEGIN
    INSERT INTO MUE_ORDEN_VENTA (
      MOV_Numero,
      MOV_Fecha,
      MOV_Total,
      MOV_Descripcion,
      EOV_Estado,
      USU_Usuario,
      ENV_Envio,
      MOV_Created_At
    )
    VALUES (
      P_MOV_NUMERO,
      P_MOV_FECHA,
      0,
      P_MOV_DESCRIPCION,
      P_EOV_ESTADO,
      P_USU_USUARIO,
      P_ENV_ENVIO,
      SYSTIMESTAMP
    )
    RETURNING MOV_Orden_Venta INTO O_MOV_ORDEN;

    O_COD_RET := C_OK;
    O_MSG := 'Orden registrada correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG := 'Error al insertar orden: ' || SQLERRM;
  END PR_ORDEN_INSERTAR;

  PROCEDURE PR_ORDEN_ACTUALIZAR (
    P_MOV_ORDEN       IN NUMBER,
    P_MOV_NUMERO      IN VARCHAR2,
    P_MOV_FECHA       IN DATE,
    P_MOV_DESCRIPCION IN VARCHAR2,
    P_EOV_ESTADO      IN NUMBER,
    P_USU_USUARIO     IN NUMBER,
    P_ENV_ENVIO       IN NUMBER,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  ) IS
  BEGIN
    UPDATE MUE_ORDEN_VENTA
       SET MOV_Numero = P_MOV_NUMERO,
           MOV_Fecha = P_MOV_FECHA,
           MOV_Descripcion = P_MOV_DESCRIPCION,
           EOV_Estado = P_EOV_ESTADO,
           USU_Usuario = P_USU_USUARIO,
           ENV_Envio = P_ENV_ENVIO
     WHERE MOV_Orden_Venta = P_MOV_ORDEN;

    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG := 'Orden no encontrada.';
    ELSE
      O_COD_RET := C_OK;
      O_MSG := 'Orden actualizada correctamente.';
    END IF;
  END PR_ORDEN_ACTUALIZAR;

  PROCEDURE PR_ORDEN_CAMBIAR_ESTADO (
    P_MOV_ORDEN   IN NUMBER,
    P_EOV_ESTADO  IN NUMBER,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  ) IS
  BEGIN
    UPDATE MUE_ORDEN_VENTA
       SET EOV_Estado = P_EOV_ESTADO
     WHERE MOV_Orden_Venta = P_MOV_ORDEN;

    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG := 'Orden no encontrada.';
    ELSE
      O_COD_RET := C_OK;
      O_MSG := 'Estado actualizado correctamente.';
    END IF;
  END PR_ORDEN_CAMBIAR_ESTADO;

  PROCEDURE PR_ORDEN_RECALCULAR_TOTAL (
    P_MOV_ORDEN   IN NUMBER,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  ) IS
    V_TOTAL NUMBER(14,2);
  BEGIN
    SELECT NVL(SUM(MOD_Total_Linea),0)
      INTO V_TOTAL
      FROM MUE_ORDEN_DETALLE
     WHERE MOV_Orden_Venta = P_MOV_ORDEN;

    UPDATE MUE_ORDEN_VENTA
       SET MOV_Total = V_TOTAL
     WHERE MOV_Orden_Venta = P_MOV_ORDEN;

    O_COD_RET := C_OK;
    O_MSG := 'Total recalculado correctamente.';
  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG := 'Error al recalcular total: ' || SQLERRM;
  END PR_ORDEN_RECALCULAR_TOTAL;

  PROCEDURE PR_ORDEN_ELIMINAR (
    P_MOV_ORDEN IN NUMBER,
    O_COD_RET   OUT NUMBER,
    O_MSG       OUT VARCHAR2
  ) IS
  BEGIN
    DELETE FROM MUE_ORDEN_VENTA
     WHERE MOV_Orden_Venta = P_MOV_ORDEN;

    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG := 'Orden no encontrada.';
    ELSE
      O_COD_RET := C_OK;
      O_MSG := 'Orden eliminada correctamente.';
    END IF;
  END PR_ORDEN_ELIMINAR;

  PROCEDURE PR_ORDEN_OBTENER (
    P_MOV_ORDEN IN NUMBER,
    O_CURSOR    OUT SYS_REFCURSOR,
    O_COD_RET   OUT NUMBER,
    O_MSG       OUT VARCHAR2
  ) IS
  BEGIN
    OPEN O_CURSOR FOR
      SELECT *
        FROM MUE_ORDEN_VENTA
       WHERE MOV_Orden_Venta = P_MOV_ORDEN;

    O_COD_RET := C_OK;
    O_MSG := 'OK';
  END PR_ORDEN_OBTENER;

  PROCEDURE PR_ORDEN_LISTAR (
    O_CURSOR   OUT SYS_REFCURSOR,
    O_COD_RET  OUT NUMBER,
    O_MSG      OUT VARCHAR2
  ) IS
  BEGIN
    OPEN O_CURSOR FOR
      SELECT *
        FROM MUE_ORDEN_VENTA
       ORDER BY MOV_Fecha DESC;

    O_COD_RET := C_OK;
    O_MSG := 'OK';
  END PR_ORDEN_LISTAR;

END PKG_MUE_ORDEN_VENTA;
/