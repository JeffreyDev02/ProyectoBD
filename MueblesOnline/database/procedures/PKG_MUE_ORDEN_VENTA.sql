CREATE OR REPLACE PACKAGE BODY PKG_MUE_ORDEN_VENTA AS

  C_OK    CONSTANT NUMBER := 0;
  C_ERR   CONSTANT NUMBER := 1;
  C_NOFND CONSTANT NUMBER := 2;

  PROCEDURE PR_VALIDAR_CABECERA (
    P_EOV_ESTADO  IN NUMBER,
    P_USU_USUARIO IN NUMBER,
    P_ENV_ENVIO   IN NUMBER,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  ) IS
    V_EXISTE NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO V_EXISTE
      FROM MUE_ESTADO_ORDEN_VENTA
     WHERE EOV_Estado = P_EOV_ESTADO;

    IF V_EXISTE = 0 THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'El estado de orden indicado no existe.';
      RETURN;
    END IF;

    SELECT COUNT(*)
      INTO V_EXISTE
      FROM MUE_USUARIO
     WHERE USU_Usuario = P_USU_USUARIO;

    IF V_EXISTE = 0 THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'El usuario indicado no existe.';
      RETURN;
    END IF;

    IF P_ENV_ENVIO IS NOT NULL THEN
      SELECT COUNT(*)
        INTO V_EXISTE
        FROM MUE_ENVIO
       WHERE ENV_Envio = P_ENV_ENVIO;

      IF V_EXISTE = 0 THEN
        O_COD_RET := C_ERR;
        O_MSG     := 'El envío indicado no existe.';
        RETURN;
      END IF;
    END IF;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';
  END PR_VALIDAR_CABECERA;


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
    IF P_MOV_NUMERO IS NULL THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'El número de orden es obligatorio.';
      RETURN;
    END IF;

    IF P_MOV_FECHA IS NULL THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'La fecha de orden es obligatoria.';
      RETURN;
    END IF;

    PR_VALIDAR_CABECERA(
      P_EOV_ESTADO,
      P_USU_USUARIO,
      P_ENV_ENVIO,
      O_COD_RET,
      O_MSG
    );

    IF O_COD_RET <> C_OK THEN
      RETURN;
    END IF;

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
    O_MSG     := 'Orden registrada correctamente.';

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Ya existe una orden con ese número.';
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al insertar orden: ' || SQLERRM;
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
    V_EXISTE NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO V_EXISTE
      FROM MUE_ORDEN_VENTA
     WHERE MOV_Orden_Venta = P_MOV_ORDEN;

    IF V_EXISTE = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'Orden no encontrada.';
      RETURN;
    END IF;

    IF P_MOV_NUMERO IS NULL THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'El número de orden es obligatorio.';
      RETURN;
    END IF;

    IF P_MOV_FECHA IS NULL THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'La fecha de orden es obligatoria.';
      RETURN;
    END IF;

    PR_VALIDAR_CABECERA(
      P_EOV_ESTADO,
      P_USU_USUARIO,
      P_ENV_ENVIO,
      O_COD_RET,
      O_MSG
    );

    IF O_COD_RET <> C_OK THEN
      RETURN;
    END IF;

    UPDATE MUE_ORDEN_VENTA
       SET MOV_Numero      = P_MOV_NUMERO,
           MOV_Fecha       = P_MOV_FECHA,
           MOV_Descripcion = P_MOV_DESCRIPCION,
           EOV_Estado      = P_EOV_ESTADO,
           USU_Usuario     = P_USU_USUARIO,
           ENV_Envio       = P_ENV_ENVIO
     WHERE MOV_Orden_Venta = P_MOV_ORDEN;

    O_COD_RET := C_OK;
    O_MSG     := 'Orden actualizada correctamente.';

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Ya existe otra orden con ese número.';
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al actualizar orden: ' || SQLERRM;
  END PR_ORDEN_ACTUALIZAR;


  PROCEDURE PR_ORDEN_CAMBIAR_ESTADO (
    P_MOV_ORDEN  IN NUMBER,
    P_EOV_ESTADO IN NUMBER,
    O_COD_RET    OUT NUMBER,
    O_MSG        OUT VARCHAR2
  ) IS
    V_EXISTE NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO V_EXISTE
      FROM MUE_ESTADO_ORDEN_VENTA
     WHERE EOV_Estado = P_EOV_ESTADO;

    IF V_EXISTE = 0 THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'El estado indicado no existe.';
      RETURN;
    END IF;

    UPDATE MUE_ORDEN_VENTA
       SET EOV_Estado = P_EOV_ESTADO
     WHERE MOV_Orden_Venta = P_MOV_ORDEN;

    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'Orden no encontrada.';
    ELSE
      O_COD_RET := C_OK;
      O_MSG     := 'Estado actualizado correctamente.';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al cambiar estado: ' || SQLERRM;
  END PR_ORDEN_CAMBIAR_ESTADO;


  PROCEDURE PR_ORDEN_RECALCULAR_TOTAL (
    P_MOV_ORDEN IN NUMBER,
    O_COD_RET   OUT NUMBER,
    O_MSG       OUT VARCHAR2
  ) IS
    V_TOTAL  NUMBER(14,2);
    V_EXISTE NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO V_EXISTE
      FROM MUE_ORDEN_VENTA
     WHERE MOV_Orden_Venta = P_MOV_ORDEN;

    IF V_EXISTE = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'Orden no encontrada para recalcular.';
      RETURN;
    END IF;

    SELECT NVL(SUM(MOD_Total_Linea), 0)
      INTO V_TOTAL
      FROM MUE_ORDEN_DETALLE
     WHERE MOV_Orden_Venta = P_MOV_ORDEN;

    UPDATE MUE_ORDEN_VENTA
       SET MOV_Total = V_TOTAL
     WHERE MOV_Orden_Venta = P_MOV_ORDEN;

    O_COD_RET := C_OK;
    O_MSG     := 'Total recalculado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al recalcular total: ' || SQLERRM;
  END PR_ORDEN_RECALCULAR_TOTAL;


  PROCEDURE PR_ORDEN_ELIMINAR (
    P_MOV_ORDEN IN NUMBER,
    O_COD_RET   OUT NUMBER,
    O_MSG       OUT VARCHAR2
  ) IS
    V_DETALLES NUMBER;
    V_FACTURAS NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO V_DETALLES
      FROM MUE_ORDEN_DETALLE
     WHERE MOV_Orden_Venta = P_MOV_ORDEN;

    IF V_DETALLES > 0 THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'No se puede eliminar: la orden tiene '
                   || V_DETALLES || ' detalle(s) asociado(s).';
      RETURN;
    END IF;

    SELECT COUNT(*)
      INTO V_FACTURAS
      FROM MUE_FACTURA
     WHERE MOV_Orden_Venta = P_MOV_ORDEN;

    IF V_FACTURAS > 0 THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'No se puede eliminar: la orden tiene '
                   || V_FACTURAS || ' factura(s) asociada(s).';
      RETURN;
    END IF;

    DELETE FROM MUE_ORDEN_VENTA
     WHERE MOV_Orden_Venta = P_MOV_ORDEN;

    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'Orden no encontrada.';
    ELSE
      O_COD_RET := C_OK;
      O_MSG     := 'Orden eliminada correctamente.';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al eliminar orden: ' || SQLERRM;
  END PR_ORDEN_ELIMINAR;


  PROCEDURE PR_ORDEN_OBTENER (
    P_MOV_ORDEN IN NUMBER,
    O_CURSOR    OUT SYS_REFCURSOR,
    O_COD_RET   OUT NUMBER,
    O_MSG       OUT VARCHAR2
  ) IS
  BEGIN
    -- [FIX #15] Columnas explícitas en lugar de SELECT *
    OPEN O_CURSOR FOR
      SELECT MOV_Orden_Venta,
             MOV_Numero,
             MOV_Fecha,
             MOV_Total,
             MOV_Descripcion,
             EOV_Estado,
             USU_Usuario,
             ENV_Envio,
             MOV_Created_At
        FROM MUE_ORDEN_VENTA
       WHERE MOV_Orden_Venta = P_MOV_ORDEN;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';
  END PR_ORDEN_OBTENER;


  PROCEDURE PR_ORDEN_LISTAR (
    O_CURSOR  OUT SYS_REFCURSOR,
    O_COD_RET OUT NUMBER,
    O_MSG     OUT VARCHAR2
  ) IS
  BEGIN
    -- [FIX #15] Columnas ex