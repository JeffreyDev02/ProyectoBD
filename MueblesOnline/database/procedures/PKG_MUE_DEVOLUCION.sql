CREATE OR REPLACE PACKAGE BODY PKG_MUE_DEVOLUCION AS

  C_OK    CONSTANT NUMBER := 0;
  C_ERR   CONSTANT NUMBER := 1;
  C_NOFND CONSTANT NUMBER := 2;

  PROCEDURE PR_DEVOLUCION_INSERTAR (
    P_FAC_FACTURA    IN NUMBER,
    P_DEV_FECHA      IN DATE,
    P_DEV_MOTIVO     IN VARCHAR2,
    O_DEV_DEVOLUCION OUT NUMBER,
    O_COD_RET        OUT NUMBER,
    O_MSG            OUT VARCHAR2
  ) IS
    V_EXISTE NUMBER;
  BEGIN
    SAVEPOINT sp_devolucion_insertar;

    SELECT COUNT(*)
      INTO V_EXISTE
      FROM MUE_FACTURA
     WHERE FAC_Factura = P_FAC_FACTURA;

    IF V_EXISTE = 0 THEN
      O_COD_RET := C_ERR;
      O_MSG := 'La factura no existe.';
      RETURN;
    END IF;

    SELECT COUNT(*)
      INTO V_EXISTE
      FROM MUE_DEVOLUCION
     WHERE FAC_Factura = P_FAC_FACTURA;

    IF V_EXISTE > 0 THEN
      O_COD_RET := C_ERR;
      O_MSG := 'La factura ya tiene devolución registrada.';
      RETURN;
    END IF;

    INSERT INTO MUE_DEVOLUCION (
      FAC_Factura,
      DEV_Fecha,
      DEV_Motivo,
      DEV_Created_At
    )
    VALUES (
      P_FAC_FACTURA,
      P_DEV_FECHA,
      P_DEV_MOTIVO,
      SYSTIMESTAMP
    )
    RETURNING DEV_Devolucion INTO O_DEV_DEVOLUCION;

    FOR R IN (
      SELECT D.PRO_Producto, D.MOD_Cantidad
        FROM MUE_FACTURA F
        JOIN MUE_ORDEN_DETALLE D
          ON F.MOV_Orden_Venta = D.MOV_Orden_Venta
       WHERE F.FAC_Factura = P_FAC_FACTURA
    ) LOOP
      UPDATE MUE_PRODUCTO
         SET PRO_Cant_Existente = PRO_Cant_Existente + R.MOD_Cantidad
       WHERE PRO_Producto = R.PRO_Producto;
    END LOOP;

    O_COD_RET := C_OK;
    O_MSG := 'Devolución registrada correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT sp_devolucion_insertar;
      O_COD_RET := C_ERR;
      O_MSG := 'Error al registrar devolución: ' || SQLERRM;
  END PR_DEVOLUCION_INSERTAR;


  PROCEDURE PR_DEVOLUCION_ACTUALIZAR (
    P_DEV_DEVOLUCION IN NUMBER,
    P_DEV_FECHA      IN DATE,
    P_DEV_MOTIVO     IN VARCHAR2,
    O_COD_RET        OUT NUMBER,
    O_MSG            OUT VARCHAR2
  ) IS
    V_EXISTE NUMBER;
  BEGIN
    -- NOTA DE DISEÑO — STOCK:
    -- Este procedure actualiza únicamente DEV_Fecha y DEV_Motivo.
    -- La factura asociada (y por tanto las cantidades de stock
    -- devueltas) NO cambia en esta operación, por lo que no se
    -- requiere recalcular el inventario aquí.
    --
    -- Si en el futuro se permitiera cambiar la factura asociada
    -- o agregar un campo de cantidad parcial, SE DEBE:
    --   1. Revertir el stock sumado por la devolución original
    --      (restar MOD_Cantidad de la factura anterior).
    --   2. Aplicar el stock de la nueva factura/cantidad
    --      (sumar MOD_Cantidad de la nueva).
    --   3. Envolver todo en SAVEPOINT + ROLLBACK TO SAVEPOINT,
    --      siguiendo el patrón de PR_DEVOLUCION_INSERTAR
    --      y PR_DEVOLUCION_ELIMINAR.
    SELECT COUNT(*)
      INTO V_EXISTE
      FROM MUE_DEVOLUCION
     WHERE DEV_Devolucion = P_DEV_DEVOLUCION;

    IF V_EXISTE = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG := 'Devolución no encontrada.';
      RETURN;
    END IF;

    UPDATE MUE_DEVOLUCION
       SET DEV_Fecha  = P_DEV_FECHA,
           DEV_Motivo = P_DEV_MOTIVO
     WHERE DEV_Devolucion = P_DEV_DEVOLUCION;

    O_COD_RET := C_OK;
    O_MSG := 'Devolución actualizada correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG := 'Error al actualizar devolución: ' || SQLERRM;
  END PR_DEVOLUCION_ACTUALIZAR;


  PROCEDURE PR_DEVOLUCION_ELIMINAR (
    P_DEV_DEVOLUCION IN NUMBER,
    O_COD_RET        OUT NUMBER,
    O_MSG            OUT VARCHAR2
  ) IS
    V_FAC_FACTURA NUMBER;
  BEGIN
    SAVEPOINT sp_devolucion_eliminar;

    BEGIN
      SELECT FAC_Factura
        INTO V_FAC_FACTURA
        FROM MUE_DEVOLUCION
       WHERE DEV_Devolucion = P_DEV_DEVOLUCION;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        O_COD_RET := C_NOFND;
        O_MSG := 'Devolución no encontrada.';
        RETURN;
    END;

    FOR R IN (
      SELECT D.PRO_Producto, D.MOD_Cantidad
        FROM MUE_FACTURA F
        JOIN MUE_ORDEN_DETALLE D
          ON F.MOV_Orden_Venta = D.MOV_Orden_Venta
       WHERE F.FAC_Factura = V_FAC_FACTURA
    ) LOOP
      UPDATE MUE_PRODUCTO
         SET PRO_Cant_Existente = PRO_Cant_Existente - R.MOD_Cantidad
       WHERE PRO_Producto = R.PRO_Producto;
    END LOOP;

    DELETE FROM MUE_DEVOLUCION
     WHERE DEV_Devolucion = P_DEV_DEVOLUCION;

    O_COD_RET := C_OK;
    O_MSG := 'Devolución eliminada correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT sp_devolucion_eliminar;
      O_COD_RET := C_ERR;
      O_MSG := 'Error al eliminar devolución: ' || SQLERRM;
  END PR_DEVOLUCION_ELIMINAR;


  PROCEDURE PR_DEVOLUCION_OBTENER (
    P_DEV_DEVOLUCION IN NUMBER,
    O_CURSOR         OUT SYS_REFCURSOR,
    O_COD_RET        OUT NUMBER,
    O_MSG            OUT VARCHAR2
  ) IS
  BEGIN
    OPEN O_CURSOR FOR
      SELECT DEV_Devolucion,
             FAC_Factura,
             DEV_Fecha,
             DEV_Motivo,
             DEV_Created_At
        FROM MUE_DEVOLUCION
       WHERE DEV_Devolucion = P_DEV_DEVOLUCION;

    O_COD_RET := C_OK;
    O_MSG := 'OK';
  END PR_DEVOLUCION_OBTENER;


  PROCEDURE PR_DEVOLUCION_LISTAR (
    O_CURSOR  OUT SYS_REFCURSOR,
    O_COD_RET OUT NUMBER,
    O_MSG     OUT VARCHAR2
  ) IS
  BEGIN
    OPEN O_CURSOR FOR
      SELECT DEV_Devolucion,
             FAC_Factura,
             DEV_Fecha,
             DEV_Motivo,
             DEV_Created_At
        FROM MUE_DEVOLUCION
       ORDER BY DEV_Fecha DESC;

    O_COD_RET := C_OK;
    O_MSG := 'OK';
  END PR_DEVOLUCION_LISTAR;

END PKG_MUE_DEVOLUCION;
/