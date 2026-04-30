CREATE OR REPLACE PACKAGE BODY PKG_MUE_FACTURA AS

  C_OK    CONSTANT NUMBER := 0;
  C_ERR   CONSTANT NUMBER := 1;
  C_NOFND CONSTANT NUMBER := 2;

  PROCEDURE PR_FACTURA_INSERTAR (
    P_FAC_NO_FACTURA      IN VARCHAR2,
    P_MOV_ORDEN_VENTA     IN NUMBER,
    P_EMP_EMPLEADO        IN NUMBER,
    P_FAC_SUBTOTAL        IN NUMBER,
    P_FAC_DESCUENTO       IN NUMBER,
    P_FAC_TOTAL           IN NUMBER,
    P_MPA_METODO_PAGO     IN NUMBER,
    P_EST_ESTABLECIMIENTO IN NUMBER,
    O_FAC_FACTURA         OUT NUMBER,
    O_COD_RET             OUT NUMBER,
    O_MSG                 OUT VARCHAR2
  ) IS
    V_EXISTE NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO V_EXISTE
      FROM MUE_ORDEN_VENTA
     WHERE MOV_Orden_Venta = P_MOV_ORDEN_VENTA;

    IF V_EXISTE = 0 THEN
      O_COD_RET := C_ERR;
      O_MSG := 'La orden de venta no existe.';
      RETURN;
    END IF;

    SELECT COUNT(*)
      INTO V_EXISTE
      FROM MUE_METODO_PAGO
     WHERE MPA_Metodo_Pago = P_MPA_METODO_PAGO;

    IF V_EXISTE = 0 THEN
      O_COD_RET := C_ERR;
      O_MSG := 'Método de pago no válido.';
      RETURN;
    END IF;

    IF P_EMP_EMPLEADO IS NOT NULL THEN
      SELECT COUNT(*)
        INTO V_EXISTE
        FROM MUE_EMPLEADO
       WHERE EMP_Empleado = P_EMP_EMPLEADO;

      IF V_EXISTE = 0 THEN
        O_COD_RET := C_ERR;
        O_MSG := 'Empleado no válido.';
        RETURN;
      END IF;
    END IF;

    IF P_EST_ESTABLECIMIENTO IS NOT NULL THEN
      SELECT COUNT(*)
        INTO V_EXISTE
        FROM MUE_ESTABLECIMIENTO
       WHERE EST_Establecimiento = P_EST_ESTABLECIMIENTO;

      IF V_EXISTE = 0 THEN
        O_COD_RET := C_ERR;
        O_MSG := 'El establecimiento especificado no existe.';
        RETURN;
      END IF;
    END IF;

    INSERT INTO MUE_FACTURA (
      FAC_No_Factura,
      FAC_Fecha,
      MOV_Orden_Venta,
      EMP_Empleado,
      FAC_Subtotal,
      FAC_Descuento,
      FAC_Total,
      MPA_Metodo_Pago,
      FAC_Created_At,
      EST_Establecimiento
    )
    VALUES (
      P_FAC_NO_FACTURA,
      SYSDATE,
      P_MOV_ORDEN_VENTA,
      P_EMP_EMPLEADO,
      P_FAC_SUBTOTAL,
      P_FAC_DESCUENTO,
      P_FAC_TOTAL,
      P_MPA_METODO_PAGO,
      SYSTIMESTAMP,
      P_EST_ESTABLECIMIENTO
    )
    RETURNING FAC_Factura INTO O_FAC_FACTURA;

    O_COD_RET := C_OK;
    O_MSG := 'Factura registrada correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG := 'Error al registrar factura: ' || SQLERRM;
  END PR_FACTURA_INSERTAR;


  PROCEDURE PR_FACTURA_ACTUALIZAR (
    P_FAC_FACTURA         IN NUMBER,
    P_EMP_EMPLEADO        IN NUMBER,
    P_FAC_SUBTOTAL        IN NUMBER,
    P_FAC_DESCUENTO       IN NUMBER,
    P_FAC_TOTAL           IN NUMBER,
    P_MPA_METODO_PAGO     IN NUMBER,
    P_EST_ESTABLECIMIENTO IN NUMBER,
    O_COD_RET             OUT NUMBER,
    O_MSG                 OUT VARCHAR2
  ) IS
    V_EXISTE NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO V_EXISTE
      FROM MUE_FACTURA
     WHERE FAC_Factura = P_FAC_FACTURA;

    IF V_EXISTE = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG := 'Factura no encontrada.';
      RETURN;
    END IF;

    IF P_MPA_METODO_PAGO IS NULL THEN
      O_COD_RET := C_ERR;
      O_MSG := 'El método de pago es obligatorio.';
      RETURN;
    END IF;

    SELECT COUNT(*)
      INTO V_EXISTE
      FROM MUE_METODO_PAGO
     WHERE MPA_Metodo_Pago = P_MPA_METODO_PAGO;

    IF V_EXISTE = 0 THEN
      O_COD_RET := C_ERR;
      O_MSG := 'Método de pago no válido.';
      RETURN;
    END IF;

    IF P_FAC_SUBTOTAL IS NULL THEN
      O_COD_RET := C_ERR;
      O_MSG := 'El subtotal es obligatorio.';
      RETURN;
    END IF;

    IF P_FAC_TOTAL IS NULL THEN
      O_COD_RET := C_ERR;
      O_MSG := 'El total es obligatorio.';
      RETURN;
    END IF;

    IF P_EMP_EMPLEADO IS NOT NULL THEN
      SELECT COUNT(*)
        INTO V_EXISTE
        FROM MUE_EMPLEADO
       WHERE EMP_Empleado = P_EMP_EMPLEADO;

      IF V_EXISTE = 0 THEN
        O_COD_RET := C_ERR;
        O_MSG := 'Empleado no válido.';
        RETURN;
      END IF;
    END IF;

    IF P_EST_ESTABLECIMIENTO IS NOT NULL THEN
      SELECT COUNT(*)
        INTO V_EXISTE
        FROM MUE_ESTABLECIMIENTO
       WHERE EST_Establecimiento = P_EST_ESTABLECIMIENTO;

      IF V_EXISTE = 0 THEN
        O_COD_RET := C_ERR;
        O_MSG := 'El establecimiento especificado no existe.';
        RETURN;
      END IF;
    END IF;

    UPDATE MUE_FACTURA
       SET EMP_Empleado        = P_EMP_EMPLEADO,
           FAC_Subtotal        = P_FAC_SUBTOTAL,
           FAC_Descuento       = P_FAC_DESCUENTO,
           FAC_Total           = P_FAC_TOTAL,
           MPA_Metodo_Pago     = P_MPA_METODO_PAGO,
           EST_Establecimiento = P_EST_ESTABLECIMIENTO
     WHERE FAC_Factura = P_FAC_FACTURA;

    O_COD_RET := C_OK;
    O_MSG := 'Factura actualizada correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG := 'Error al actualizar factura: ' || SQLERRM;
  END PR_FACTURA_ACTUALIZAR;


  PROCEDURE PR_FACTURA_ELIMINAR (
    P_FAC_FACTURA IN NUMBER,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  ) IS
  BEGIN
    DELETE FROM MUE_FACTURA
     WHERE FAC_Factura = P_FAC_FACTURA;

    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG := 'Factura no encontrada.';
      RETURN;
    END IF;

    O_COD_RET := C_OK;
    O_MSG := 'Factura eliminada correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG := 'Error al eliminar factura: ' || SQLERRM;
  END PR_FACTURA_ELIMINAR;


  PROCEDURE PR_FACTURA_OBTENER (
    P_FAC_FACTURA IN NUMBER,
    O_CURSOR      OUT SYS_REFCURSOR,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  ) IS
  BEGIN
    -- [FIX #15] Columnas explícitas en lugar de SELECT *
    OPEN O_CURSOR FOR
      SELECT FAC_Factura,
             FAC_No_Factura,
             FAC_Fecha,
             MOV_Orden_Venta,
             EMP_Empleado,
             FAC_Subtotal,
             FAC_Descuento,
             FAC_Total,
             MPA_Metodo_Pago,
             EST_Establecimiento,
             FAC_Created_At
        FROM MUE_FACTURA
       WHERE FAC_Factura = P_FAC_FACTURA;

    O_COD_RET := C_OK;
    O_MSG := 'OK';
  END PR_FACTURA_OBTENER;


  PROCEDURE PR_FACTURA_LISTAR (
    O_CURSOR  OUT SYS_REFCURSOR,
    O_COD_RET OUT NUMBER,
    O_MSG     OUT VARCHAR2
  ) IS
  BEGIN
    -- [FIX #15] Columnas explícitas en lugar de SELECT *
    OPEN O_CURSOR FOR
      SELECT FAC_Factura,
             FAC_No_Factura,
             FAC_Fecha,
             MOV_Orden_Venta,
             EMP_Empleado,
             FAC_Subtotal,
             FAC_Descuento,
             FAC_Total,
             MPA_Metodo_Pago,
             EST_Establecimiento,
             FAC_Created_At
        FROM MUE_FACTURA
       ORDER BY FAC_Fecha DESC;

    O_COD_RET := C_OK;
    O_MSG := 'OK';
  END PR_FACTURA_LISTAR;

END PKG_MUE_FACTURA;
/