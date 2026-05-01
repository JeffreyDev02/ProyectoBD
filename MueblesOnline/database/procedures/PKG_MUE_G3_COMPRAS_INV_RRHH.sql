CREATE OR REPLACE PACKAGE PKG_MUE_G3_COMPRAS_INV_RRHH AS

-- ===========================
-- 1. PROCEDIMIENTOS DE TURNOS
-- ===========================
    PROCEDURE PR_TURNO_INSERTAR(
        P_HORA_ENTRADA IN TIMESTAMP, 
        P_HORA_SALIDA  IN TIMESTAMP, 
        P_DESCRIPCION  IN VARCHAR2, 
        O_COD_RET      OUT NUMBER, 
        O_MSG          OUT VARCHAR2
    );

    PROCEDURE PR_TURNO_LISTAR(
        O_DATA    OUT SYS_REFCURSOR, 
        O_COD_RET OUT NUMBER, 
        O_MSG     OUT VARCHAR2
    );

    PROCEDURE PR_TURNO_ACTUALIZAR(
        P_ID           IN NUMBER, 
        P_HORA_ENTRADA IN TIMESTAMP, 
        P_HORA_SALIDA  IN TIMESTAMP, 
        P_DESCRIPCION  IN VARCHAR2, 
        O_COD_RET      OUT NUMBER, 
        O_MSG          OUT VARCHAR2
    );

    PROCEDURE PR_TURNO_ELIMINAR(
        P_ID      IN NUMBER, 
        O_COD_RET OUT NUMBER, 
        O_MSG     OUT VARCHAR2
    );
-- ==========================================
 -- 2. PROCEDIMIENTOS DE CONCEPTOS DE PAGO
-- ==========================================
    PROCEDURE PR_CONCEPTO_INSERTAR(
        P_CODIGO      IN VARCHAR2, 
        P_NOMBRE      IN VARCHAR2, 
        P_TIPO        IN NUMBER, 
        P_DESCRIPCION IN VARCHAR2, 
        O_COD_RET     OUT NUMBER, 
        O_MSG         OUT VARCHAR2
    );

    PROCEDURE PR_CONCEPTO_LISTAR(
        O_DATA    OUT SYS_REFCURSOR, 
        O_COD_RET OUT NUMBER, 
        O_MSG     OUT VARCHAR2
    );
    
    PROCEDURE PR_CONCEPTO_ACTUALIZAR(
        P_ID           IN NUMBER,
        P_CODIGO       IN VARCHAR2, 
        P_NOMBRE       IN VARCHAR2, 
        P_TIPO         IN NUMBER, 
        P_DESCRIPCION  IN VARCHAR2, 
        O_COD_RET      OUT NUMBER, 
        O_MSG          OUT VARCHAR2
    );
    
    PROCEDURE PR_CONCEPTO_ELIMINAR(
        P_ID      IN NUMBER,
        O_COD_RET OUT NUMBER,
        O_MSG     OUT VARCHAR2
    );
    
-- =======================================
    -- 3. PEDIDO PROVEEDOR (CABECERA)
-- =====================================

    PROCEDURE PR_PEP_INSERTAR(
        P_FECHA          IN DATE,
        P_PROVEEDOR      IN NUMBER,
        P_ENTREGA        IN NUMBER,
        O_COD_RET        OUT NUMBER,
        O_MSG            OUT VARCHAR2
    );

    PROCEDURE PR_PEP_LISTAR(
        O_DATA    OUT SYS_REFCURSOR,
        O_COD_RET OUT NUMBER,
        O_MSG     OUT VARCHAR2
    );

    PROCEDURE PR_PEP_ACTUALIZAR(
        P_ID             IN NUMBER,
        P_FECHA          IN DATE,
        P_PROVEEDOR      IN NUMBER,
        P_ENTREGA        IN NUMBER,
        O_COD_RET        OUT NUMBER,
        O_MSG            OUT VARCHAR2
    );

    PROCEDURE PR_PEP_ELIMINAR(
        P_ID      IN NUMBER,
        O_COD_RET OUT NUMBER,
        O_MSG     OUT VARCHAR2
    );

    PROCEDURE PR_PEP_CANCELAR(
        P_ID      IN NUMBER,
        O_COD_RET OUT NUMBER,
        O_MSG     OUT VARCHAR2
    );

    PROCEDURE PR_PEP_ACTUALIZAR_TOTAL(
        P_ID      IN NUMBER,
        O_COD_RET OUT NUMBER,
        O_MSG     OUT VARCHAR2
    );
    
-- =========================
    -- 4. DETALLE PEDIDO MATERIAL
-- =========================

    PROCEDURE PR_DPM_INSERTAR(
        P_PEDIDO        IN NUMBER,
        P_MATERIAL      IN NUMBER,
        P_CANTIDAD      IN NUMBER,
        P_PRECIO        IN NUMBER,
        O_COD_RET       OUT NUMBER,
        O_MSG           OUT VARCHAR2
    );

    PROCEDURE PR_DPM_LISTAR(
        P_PEDIDO   IN NUMBER,
        O_DATA     OUT SYS_REFCURSOR,
        O_COD_RET  OUT NUMBER,
        O_MSG      OUT VARCHAR2
    );

    PROCEDURE PR_DPM_ACTUALIZAR(
        P_ID            IN NUMBER,
        P_CANTIDAD      IN NUMBER,
        P_PRECIO        IN NUMBER,
        O_COD_RET       OUT NUMBER,
        O_MSG           OUT VARCHAR2
    );

    PROCEDURE PR_DPM_ELIMINAR(
        P_ID      IN NUMBER,
        O_COD_RET OUT NUMBER,
        O_MSG     OUT VARCHAR2
    );

    -- MATERIAL_ALMACEN (CRUD + ajuste de stock con movimiento)
    PROCEDURE PR_MAL_INSERTAR(
        P_ALMACEN      IN NUMBER,
        P_MATERIAL     IN NUMBER,
        P_STOCK        IN NUMBER,
        P_STOCK_MIN    IN NUMBER,
        P_ZONA         IN VARCHAR2,
        O_COD_RET      OUT NUMBER,
        O_MSG          OUT VARCHAR2
    );

    PROCEDURE PR_MAL_LISTAR(
        O_DATA    OUT SYS_REFCURSOR,
        O_COD_RET OUT NUMBER,
        O_MSG     OUT VARCHAR2
    );

    PROCEDURE PR_MAL_ACTUALIZAR(
        P_ID          IN NUMBER,
        P_STOCK_MIN   IN NUMBER,
        P_ZONA        IN VARCHAR2,
        O_COD_RET     OUT NUMBER,
        O_MSG         OUT VARCHAR2
    );

    PROCEDURE PR_MAL_ELIMINAR(
        P_ID      IN NUMBER,
        O_COD_RET OUT NUMBER,
        O_MSG     OUT VARCHAR2
    );

    PROCEDURE PR_MAL_AJUSTAR_STOCK(
        P_ID            IN NUMBER,
        P_TIPO_MOV      IN NUMBER,
        P_CANTIDAD      IN NUMBER,
        P_OBSERVACION   IN VARCHAR2,
        O_COD_RET       OUT NUMBER,
        O_MSG           OUT VARCHAR2
    );
    
-- ==================================
    -- MOVIMIENTO INVENTARIO MATERIAL
-- ==================================
PROCEDURE PR_MIN_INSERTAR(
    P_MAL_ID        IN NUMBER,
    P_TIPO_MOV      IN NUMBER,
    P_CANTIDAD      IN NUMBER,
    P_OBSERVACION   IN VARCHAR2,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
);

PROCEDURE PR_MIN_LISTAR(
    P_MATERIAL      IN NUMBER,
    P_TIPO_MOV      IN NUMBER,
    P_FECHA_INI     IN DATE,
    P_FECHA_FIN     IN DATE,
    O_DATA          OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
);

PROCEDURE PR_MIN_OBTENER(
    P_ID            IN NUMBER,
    O_DATA          OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
);

PROCEDURE PR_MIN_ACTUALIZAR(
    P_ID            IN NUMBER,
    P_TIPO_MOV      IN NUMBER,
    P_CANTIDAD      IN NUMBER,
    P_OBSERVACION   IN VARCHAR2,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
);
-- ===========================================
-- DETALLE MATERIAL PRODUCTO (RECETA)
-- ===========================================
PROCEDURE PR_DMP_INSERTAR(
    P_TPR          IN NUMBER,
    P_MAT          IN NUMBER,
    P_PRO          IN NUMBER,
    P_CANTIDAD     IN NUMBER,
    O_COD_RET      OUT NUMBER,
    O_MSG          OUT VARCHAR2
);

PROCEDURE PR_DMP_LISTAR(
    P_PRO          IN NUMBER,
    O_DATA         OUT SYS_REFCURSOR,
    O_COD_RET      OUT NUMBER,
    O_MSG          OUT VARCHAR2
);

PROCEDURE PR_DMP_OBTENER(
    P_ID           IN NUMBER,
    O_DATA         OUT SYS_REFCURSOR,
    O_COD_RET      OUT NUMBER,
    O_MSG          OUT VARCHAR2
);

PROCEDURE PR_DMP_ACTUALIZAR(
    P_ID           IN NUMBER,
    P_TPR          IN NUMBER,
    P_MAT          IN NUMBER,
    P_PRO          IN NUMBER,
    P_CANTIDAD     IN NUMBER,
    O_COD_RET      OUT NUMBER,
    O_MSG          OUT VARCHAR2
);

PROCEDURE PR_DMP_ELIMINAR(
    P_ID           IN NUMBER,
    O_COD_RET      OUT NUMBER,
    O_MSG          OUT VARCHAR2
);
-- ================================================
-- PRODUCTO BODEGA (INVENTARIO PRODUCTO)
-- ================================================
PROCEDURE PR_PBO_INSERTAR(
    P_BODEGA        IN NUMBER,
    P_PRODUCTO      IN NUMBER,
    P_CANTIDAD      IN NUMBER,
    P_STOCK_MIN     IN NUMBER,
    P_UBICACION     IN VARCHAR2,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
);

PROCEDURE PR_PBO_LISTAR(
    P_BODEGA        IN NUMBER,
    P_PRODUCTO      IN NUMBER,
    O_DATA          OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
);

PROCEDURE PR_PBO_OBTENER(
    P_ID            IN NUMBER,
    O_DATA          OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
);

PROCEDURE PR_PBO_ACTUALIZAR(
    P_ID            IN NUMBER,
    P_CANTIDAD      IN NUMBER,
    P_STOCK_MIN     IN NUMBER,
    P_UBICACION     IN VARCHAR2,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
);

PROCEDURE PR_PBO_ELIMINAR(
    P_ID            IN NUMBER,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
);

-- ALERTA DE STOCK MINIMO
PROCEDURE PR_PBO_ALERTA_MINIMO(
    O_DATA          OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
);

-- =========================
-- ASIGNACION TURNO
-- =========================

PROCEDURE PR_AST_INSERTAR(
    P_EMP IN NUMBER,
    P_TUR IN NUMBER,
    P_FECHA_INICIO IN DATE,
    P_FECHA_FIN IN DATE,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
);

PROCEDURE PR_AST_LISTAR(
    P_EMP IN NUMBER,
    O_DATA OUT SYS_REFCURSOR,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
);

PROCEDURE PR_AST_OBTENER(
    P_ID IN NUMBER,
    O_DATA OUT SYS_REFCURSOR,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
);

PROCEDURE PR_AST_ACTUALIZAR(
    P_ID IN NUMBER,
    P_TUR IN NUMBER,
    P_FECHA_INICIO IN DATE,
    P_FECHA_FIN IN DATE,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
);

PROCEDURE PR_AST_ELIMINAR(
    P_ID IN NUMBER,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
);

-- =========================
-- REGISTRO ASISTENCIA
-- =========================

PROCEDURE PR_REA_ENTRADA(
    P_EMP IN NUMBER,
    P_OBS IN VARCHAR2,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
);

PROCEDURE PR_REA_SALIDA(
    P_EMP IN NUMBER,
    P_OBS IN VARCHAR2,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
);

PROCEDURE PR_REA_LISTAR(
    P_EMP IN NUMBER,
    O_DATA OUT SYS_REFCURSOR,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
);

PROCEDURE PR_REA_OBTENER(
    P_ID IN NUMBER,
    O_DATA OUT SYS_REFCURSOR,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
);

PROCEDURE PR_REA_ELIMINAR(
    P_ID IN NUMBER,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
);

-- =========================
-- CONTRATO
-- =========================

PROCEDURE PR_CTR_INSERTAR(
    P_EMP IN NUMBER,
    P_PUE IN NUMBER,
    P_FECHA_INICIO IN DATE,
    P_FECHA_FIN IN DATE,
    P_SALARIO IN NUMBER,
    P_MONEDA IN VARCHAR2,
    P_ESTADO IN NUMBER,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
);

PROCEDURE PR_CTR_LISTAR(
    P_EMP IN NUMBER,
    O_DATA OUT SYS_REFCURSOR,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
);

PROCEDURE PR_CTR_OBTENER(
    P_ID IN NUMBER,
    O_DATA OUT SYS_REFCURSOR,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
);

PROCEDURE PR_CTR_ACTUALIZAR(
    P_ID IN NUMBER,
    P_PUE IN NUMBER,
    P_FECHA_INICIO IN DATE,
    P_FECHA_FIN IN DATE,
    P_SALARIO IN NUMBER,
    P_MONEDA IN VARCHAR2,
    P_ESTADO IN NUMBER,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
);

PROCEDURE PR_CTR_ELIMINAR(
    P_ID IN NUMBER,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
);


-- =========================
-- NOMINA
-- =========================

PROCEDURE PR_NOM_INSERTAR(
    P_CONTRATO     IN NUMBER,
    P_FECHA_INI    IN DATE,
    P_FECHA_FIN    IN DATE,
    O_COD_RET      OUT NUMBER,
    O_MSG          OUT VARCHAR2
);

PROCEDURE PR_NOM_LISTAR(
    O_DATA    OUT SYS_REFCURSOR,
    O_COD_RET OUT NUMBER,
    O_MSG     OUT VARCHAR2
);

PROCEDURE PR_NOM_OBTENER(
    P_ID      IN NUMBER,
    O_DATA    OUT SYS_REFCURSOR,
    O_COD_RET OUT NUMBER,
    O_MSG     OUT VARCHAR2
);

PROCEDURE PR_NOM_ACTUALIZAR(
    P_ID           IN NUMBER,
    P_FECHA_INI    IN DATE,
    P_FECHA_FIN    IN DATE,
    O_COD_RET      OUT NUMBER,
    O_MSG          OUT VARCHAR2
);

PROCEDURE PR_NOM_ELIMINAR(
    P_ID      IN NUMBER,
    O_COD_RET OUT NUMBER,
    O_MSG     OUT VARCHAR2
);

PROCEDURE PR_NOM_CALCULAR_TOTALES(
    P_ID      IN NUMBER,
    O_COD_RET OUT NUMBER,
    O_MSG     OUT VARCHAR2
);

PROCEDURE PR_NOM_CERRAR(
    P_ID      IN NUMBER,
    O_COD_RET OUT NUMBER,
    O_MSG     OUT VARCHAR2
);

-- =========================
-- DETALLE NOMINA
-- =========================

PROCEDURE PR_DNM_INSERTAR(
    P_NOMINA        IN NUMBER,
    P_CONCEPTO      IN NUMBER,
    P_VALOR         IN NUMBER,
    P_OBSERVACION   IN VARCHAR2,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
);

PROCEDURE PR_DNM_LISTAR(
    P_NOMINA   IN NUMBER,
    O_DATA     OUT SYS_REFCURSOR,
    O_COD_RET  OUT NUMBER,
    O_MSG      OUT VARCHAR2
);

PROCEDURE PR_DNM_OBTENER(
    P_ID      IN NUMBER,
    O_DATA    OUT SYS_REFCURSOR,
    O_COD_RET OUT NUMBER,
    O_MSG     OUT VARCHAR2
);

PROCEDURE PR_DNM_ACTUALIZAR(
    P_ID          IN NUMBER,
    P_VALOR       IN NUMBER,
    P_OBSERVACION IN VARCHAR2,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
);

PROCEDURE PR_DNM_ELIMINAR(
    P_ID      IN NUMBER,
    O_COD_RET OUT NUMBER,
    O_MSG     OUT VARCHAR2
);


END PKG_MUE_G3_COMPRAS_INV_RRHH;
/

    


CREATE OR REPLACE PACKAGE BODY PKG_MUE_G3_COMPRAS_INV_RRHH AS

-----------------------------------------
-- PROCEDIMIENTOS DE TURNOS
-----------------------------------------

PROCEDURE PR_TURNO_INSERTAR(
    P_HORA_ENTRADA IN TIMESTAMP,
    P_HORA_SALIDA  IN TIMESTAMP,
    P_DESCRIPCION  IN VARCHAR2,
    O_COD_RET      OUT NUMBER,
    O_MSG          OUT VARCHAR2
) AS
BEGIN
    IF P_HORA_ENTRADA IS NULL OR P_HORA_SALIDA IS NULL THEN
        O_COD_RET := 1;
        O_MSG := 'Horas son obligatorias';
        RETURN;
    END IF;

    INSERT INTO MUE_TURNO (
        TUR_Hora_Entrada, 
        TUR_Hora_Salida, 
        TUR_Descripcion, 
        TUR_Created_At
    ) VALUES (
        P_HORA_ENTRADA, 
        P_HORA_SALIDA, 
        P_DESCRIPCION, 
        SYSTIMESTAMP
    );

    O_COD_RET := 0;
    O_MSG := 'Turno registrado exitosamente';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al insertar turno: ' || SQLERRM;
END;

--------------------------------------------------

PROCEDURE PR_TURNO_LISTAR(
    O_DATA    OUT SYS_REFCURSOR,
    O_COD_RET OUT NUMBER,
    O_MSG     OUT VARCHAR2
) AS
BEGIN
    OPEN O_DATA FOR 
        SELECT TUR_Turno, TUR_Hora_Entrada, TUR_Hora_Salida, TUR_Descripcion 
        FROM MUE_TURNO;

    O_COD_RET := 0;
    O_MSG := 'OK';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al consultar: ' || SQLERRM;
END;

--------------------------------------------------

PROCEDURE PR_TURNO_ACTUALIZAR(
    P_ID           IN NUMBER,
    P_HORA_ENTRADA IN TIMESTAMP,
    P_HORA_SALIDA  IN TIMESTAMP,
    P_DESCRIPCION  IN VARCHAR2,
    O_COD_RET      OUT NUMBER,
    O_MSG          OUT VARCHAR2
) AS
BEGIN
    IF P_ID IS NULL THEN
        O_COD_RET := 1;
        O_MSG := 'ID es obligatorio';
        RETURN;
    END IF;

    UPDATE MUE_TURNO 
    SET TUR_Hora_Entrada = P_HORA_ENTRADA,
        TUR_Hora_Salida  = P_HORA_SALIDA,
        TUR_Descripcion  = P_DESCRIPCION
    WHERE TUR_Turno = P_ID;

    IF SQL%ROWCOUNT = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'No se encontró el turno';
        RETURN;
    END IF;

    O_COD_RET := 0;
    O_MSG := 'Turno actualizado correctamente';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al actualizar: ' || SQLERRM;
END;

--------------------------------------------------

PROCEDURE PR_TURNO_ELIMINAR(
    P_ID      IN NUMBER,
    O_COD_RET OUT NUMBER,
    O_MSG     OUT VARCHAR2
) AS
BEGIN
    DELETE FROM MUE_TURNO 
    WHERE TUR_Turno = P_ID;

    IF SQL%ROWCOUNT = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'No se encontró el turno';
        RETURN;
    END IF;

    O_COD_RET := 0;
    O_MSG := 'Turno eliminado correctamente';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al eliminar: ' || SQLERRM;
END;

-----------------------------------------
-- PROCEDIMIENTOS DE CONCEPTOS DE PAGO
-----------------------------------------

PROCEDURE PR_CONCEPTO_INSERTAR(
    P_CODIGO      IN VARCHAR2,
    P_NOMBRE      IN VARCHAR2,
    P_TIPO        IN NUMBER,
    P_DESCRIPCION IN VARCHAR2,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
) IS
BEGIN
    IF P_CODIGO IS NULL OR P_NOMBRE IS NULL THEN
        O_COD_RET := 1;
        O_MSG := 'Código y nombre son obligatorios';
        RETURN;
    END IF;

    INSERT INTO MUE_CONCEPTO_PAGO (
        CPA_Codigo, 
        CPA_Nombre, 
        CPA_Tipo, 
        CPA_Descripcion, 
        CPA_Created_At
    ) VALUES (
        P_CODIGO, 
        P_NOMBRE, 
        P_TIPO, 
        P_DESCRIPCION, 
        SYSTIMESTAMP
    );

    O_COD_RET := 0;
    O_MSG := 'Concepto registrado con éxito';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error: ' || SQLERRM;
END;

--------------------------------------------------

PROCEDURE PR_CONCEPTO_LISTAR(
    O_DATA    OUT SYS_REFCURSOR,
    O_COD_RET OUT NUMBER,
    O_MSG     OUT VARCHAR2
) IS
BEGIN
    OPEN O_DATA FOR
        SELECT CPA_Concepto_Pago,
               CPA_Codigo,
               CPA_Nombre,
               CPA_Tipo,
               CPA_Descripcion,
               CPA_Created_At
          FROM MUE_CONCEPTO_PAGO
         ORDER BY CPA_Concepto_Pago DESC;

    O_COD_RET := 0;
    O_MSG := 'OK';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al listar conceptos: ' || SQLERRM;
END;

--------------------------------------------------

PROCEDURE PR_CONCEPTO_ACTUALIZAR(
    P_ID           IN NUMBER,
    P_CODIGO       IN VARCHAR2, 
    P_NOMBRE       IN VARCHAR2, 
    P_TIPO         IN NUMBER, 
    P_DESCRIPCION  IN VARCHAR2, 
    O_COD_RET      OUT NUMBER, 
    O_MSG          OUT VARCHAR2
) IS
BEGIN
    UPDATE MUE_CONCEPTO_PAGO
    SET CPA_Codigo      = P_CODIGO,
        CPA_Nombre      = P_NOMBRE,
        CPA_Tipo        = P_TIPO,
        CPA_Descripcion = P_DESCRIPCION
    WHERE CPA_Concepto_Pago = P_ID;

    IF SQL%ROWCOUNT = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'No existe el concepto';
        RETURN;
    END IF;

    O_COD_RET := 0;
    O_MSG := 'Concepto actualizado correctamente';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al actualizar: ' || SQLERRM;
END;

--------------------------------------------------

PROCEDURE PR_CONCEPTO_ELIMINAR(
    P_ID      IN NUMBER,
    O_COD_RET OUT NUMBER,
    O_MSG     OUT VARCHAR2
) IS
BEGIN
    DELETE FROM MUE_CONCEPTO_PAGO
    WHERE CPA_Concepto_Pago = P_ID;

    IF SQL%ROWCOUNT = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'No existe el concepto';
        RETURN;
    END IF;

    O_COD_RET := 0;
    O_MSG := 'Concepto eliminado correctamente';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al eliminar: ' || SQLERRM;
END;

-----------------------------------------
-- PEDIDO PROVEEDOR (CABECERA)
-----------------------------------------

PROCEDURE PR_PEP_INSERTAR(
    P_FECHA          IN DATE,
    P_PROVEEDOR      IN NUMBER,
    P_ENTREGA        IN NUMBER,
    O_COD_RET        OUT NUMBER,
    O_MSG            OUT VARCHAR2
) AS
BEGIN
    IF P_PROVEEDOR IS NULL THEN
        O_COD_RET := 1;
        O_MSG := 'Proveedor es obligatorio';
        RETURN;
    END IF;

    INSERT INTO MUE_PEDIDO_PROVEEDOR (
        PEP_Fecha,
        PEP_Total,
        PEP_Cancelado,
        PRV_Proveedor,
        ECM_Entrega_Compra,
        PEP_Created_At
    ) VALUES (
        P_FECHA,
        0,
        0,
        P_PROVEEDOR,
        P_ENTREGA,
        SYSTIMESTAMP
    );

    O_COD_RET := 0;
    O_MSG := 'Pedido creado correctamente';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al insertar pedido: ' || SQLERRM;
END;

--------------------------------------------------

PROCEDURE PR_PEP_LISTAR(
    O_DATA    OUT SYS_REFCURSOR,
    O_COD_RET OUT NUMBER,
    O_MSG     OUT VARCHAR2
) AS
BEGIN
    OPEN O_DATA FOR
        SELECT PEP_Pedido,
               PEP_Fecha,
               PEP_Total,
               PEP_Cancelado,
               PRV_Proveedor,
               ECM_Entrega_Compra,
               PEP_Created_At
          FROM MUE_PEDIDO_PROVEEDOR
         ORDER BY PEP_Pedido DESC;

    O_COD_RET := 0;
    O_MSG := 'OK';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al listar: ' || SQLERRM;
END;

--------------------------------------------------

PROCEDURE PR_PEP_ACTUALIZAR(
    P_ID             IN NUMBER,
    P_FECHA          IN DATE,
    P_PROVEEDOR      IN NUMBER,
    P_ENTREGA        IN NUMBER,
    O_COD_RET        OUT NUMBER,
    O_MSG            OUT VARCHAR2
) AS
BEGIN
    UPDATE MUE_PEDIDO_PROVEEDOR
    SET PEP_Fecha          = P_FECHA,
        PRV_Proveedor      = P_PROVEEDOR,
        ECM_Entrega_Compra = P_ENTREGA
    WHERE PEP_Pedido = P_ID;

    IF SQL%ROWCOUNT = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'No existe el pedido';
        RETURN;
    END IF;

    O_COD_RET := 0;
    O_MSG := 'Pedido actualizado';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al actualizar: ' || SQLERRM;
END;

--------------------------------------------------

PROCEDURE PR_PEP_ELIMINAR(
    P_ID      IN NUMBER,
    O_COD_RET OUT NUMBER,
    O_MSG     OUT VARCHAR2
) AS
BEGIN
    DELETE FROM MUE_PEDIDO_PROVEEDOR
    WHERE PEP_Pedido = P_ID;

    IF SQL%ROWCOUNT = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'No existe el pedido';
        RETURN;
    END IF;

    O_COD_RET := 0;
    O_MSG := 'Pedido eliminado';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al eliminar: ' || SQLERRM;
END;

--------------------------------------------------

PROCEDURE PR_PEP_CANCELAR(
    P_ID      IN NUMBER,
    O_COD_RET OUT NUMBER,
    O_MSG     OUT VARCHAR2
) AS
BEGIN
    UPDATE MUE_PEDIDO_PROVEEDOR
    SET PEP_Cancelado = 1
    WHERE PEP_Pedido = P_ID;

    IF SQL%ROWCOUNT = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'No existe el pedido';
        RETURN;
    END IF;

    O_COD_RET := 0;
    O_MSG := 'Pedido cancelado correctamente';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al cancelar: ' || SQLERRM;
END;

--------------------------------------------------

PROCEDURE PR_PEP_ACTUALIZAR_TOTAL(
    P_ID      IN NUMBER,
    O_COD_RET OUT NUMBER,
    O_MSG     OUT VARCHAR2
) AS
    V_TOTAL NUMBER(14,2);
BEGIN
    SELECT NVL(SUM(PPD_Subtotal), 0)
    INTO V_TOTAL
    FROM MUE_DETALLE_PEDIDO_MATERIAL
    WHERE PEP_Pedido = P_ID;

    UPDATE MUE_PEDIDO_PROVEEDOR
    SET PEP_Total = V_TOTAL
    WHERE PEP_Pedido = P_ID;

    IF SQL%ROWCOUNT = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'No existe el pedido';
        RETURN;
    END IF;

    O_COD_RET := 0;
    O_MSG := 'Total actualizado correctamente';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al actualizar total: ' || SQLERRM;
END;

-----------------------------------------
-- DETALLE PEDIDO MATERIAL
-----------------------------------------

-- INSERTAR DETALLE
-- Calcula subtotal automáticamente y actualiza total del pedido padre
PROCEDURE PR_DPM_INSERTAR(
    P_PEDIDO        IN NUMBER,
    P_MATERIAL      IN NUMBER,
    P_CANTIDAD      IN NUMBER,
    P_PRECIO        IN NUMBER,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
) AS
    V_SUBTOTAL NUMBER(14,2);
BEGIN
    -- Validaciones básicas
    IF P_PEDIDO IS NULL OR P_MATERIAL IS NULL THEN
        O_COD_RET := 1;
        O_MSG := 'Pedido y material son obligatorios';
        RETURN;
    END IF;

    -- Calcular subtotal
    V_SUBTOTAL := NVL(P_CANTIDAD,0) * NVL(P_PRECIO,0);

    INSERT INTO MUE_DETALLE_PEDIDO_MATERIAL (
        PEP_Pedido,
        MAT_Material,
        PPD_Cantidad,
        PPD_Precio_Unitario_Compra_Actual,
        PPD_Subtotal,
        PPD_Created_At
    ) VALUES (
        P_PEDIDO,
        P_MATERIAL,
        P_CANTIDAD,
        P_PRECIO,
        V_SUBTOTAL,
        SYSTIMESTAMP
    );

    -- Actualizar total del pedido padre
    PR_PEP_ACTUALIZAR_TOTAL(P_PEDIDO, O_COD_RET, O_MSG);
    IF O_COD_RET <> 0 THEN
        RETURN;
    END IF;

    O_COD_RET := 0;
    O_MSG := 'Detalle agregado correctamente';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al insertar detalle: ' || SQLERRM;
END;

--------------------------------------------------

-- LISTAR DETALLE POR PEDIDO
PROCEDURE PR_DPM_LISTAR(
    P_PEDIDO   IN NUMBER,
    O_DATA     OUT SYS_REFCURSOR,
    O_COD_RET  OUT NUMBER,
    O_MSG      OUT VARCHAR2
) AS
BEGIN
    OPEN O_DATA FOR
        SELECT 
            D.PPD_Pedido_Proveedor_Detalle,
            D.PEP_Pedido,
            D.MAT_Material,
            M.MAT_Nombre,
            D.PPD_Cantidad,
            D.PPD_Precio_Unitario_Compra_Actual,
            D.PPD_Subtotal
        FROM MUE_DETALLE_PEDIDO_MATERIAL D
        JOIN MUE_MATERIAL M ON M.MAT_Material = D.MAT_Material
        WHERE D.PEP_Pedido = P_PEDIDO
        ORDER BY D.PPD_Pedido_Proveedor_Detalle DESC;

    O_COD_RET := 0;
    O_MSG := 'OK';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al listar detalle: ' || SQLERRM;
END;

--------------------------------------------------

-- ACTUALIZAR DETALLE
-- Recalcula subtotal y actualiza total del pedido padre
PROCEDURE PR_DPM_ACTUALIZAR(
    P_ID            IN NUMBER,
    P_CANTIDAD      IN NUMBER,
    P_PRECIO        IN NUMBER,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
) AS
    V_SUBTOTAL NUMBER(14,2);
    V_PEDIDO   NUMBER;
BEGIN
    -- Obtener pedido padre
    SELECT PEP_Pedido
    INTO V_PEDIDO
    FROM MUE_DETALLE_PEDIDO_MATERIAL
    WHERE PPD_Pedido_Proveedor_Detalle = P_ID;

    -- Calcular nuevo subtotal
    V_SUBTOTAL := NVL(P_CANTIDAD,0) * NVL(P_PRECIO,0);

    UPDATE MUE_DETALLE_PEDIDO_MATERIAL
    SET PPD_Cantidad = P_CANTIDAD,
        PPD_Precio_Unitario_Compra_Actual = P_PRECIO,
        PPD_Subtotal = V_SUBTOTAL
    WHERE PPD_Pedido_Proveedor_Detalle = P_ID;

    IF SQL%ROWCOUNT = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'No existe el detalle';
        RETURN;
    END IF;

    -- Actualizar total del pedido padre
    PR_PEP_ACTUALIZAR_TOTAL(V_PEDIDO, O_COD_RET, O_MSG);
    IF O_COD_RET <> 0 THEN
        RETURN;
    END IF;

    O_COD_RET := 0;
    O_MSG := 'Detalle actualizado correctamente';

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        O_COD_RET := 1;
        O_MSG := 'Detalle no encontrado';
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al actualizar detalle: ' || SQLERRM;
END;

--------------------------------------------------

-- ELIMINAR DETALLE
-- Actualiza total del pedido padre después de eliminar
PROCEDURE PR_DPM_ELIMINAR(
    P_ID      IN NUMBER,
    O_COD_RET OUT NUMBER,
    O_MSG     OUT VARCHAR2
) AS
    V_PEDIDO NUMBER;
BEGIN
    -- Obtener pedido antes de eliminar
    SELECT PEP_Pedido
    INTO V_PEDIDO
    FROM MUE_DETALLE_PEDIDO_MATERIAL
    WHERE PPD_Pedido_Proveedor_Detalle = P_ID;

    DELETE FROM MUE_DETALLE_PEDIDO_MATERIAL
    WHERE PPD_Pedido_Proveedor_Detalle = P_ID;

    IF SQL%ROWCOUNT = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'No existe el detalle';
        RETURN;
    END IF;

    -- Actualizar total del pedido padre
    PR_PEP_ACTUALIZAR_TOTAL(V_PEDIDO, O_COD_RET, O_MSG);
    IF O_COD_RET <> 0 THEN
        RETURN;
    END IF;

    O_COD_RET := 0;
    O_MSG := 'Detalle eliminado correctamente';

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        O_COD_RET := 1;
        O_MSG := 'Detalle no encontrado';
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al eliminar detalle: ' || SQLERRM;
END;

-----------------------------------------
-- MATERIAL ALMACEN (INVENTARIO)
-----------------------------------------

-- INSERTAR REGISTRO DE INVENTARIO
PROCEDURE PR_MAL_INSERTAR(
    P_ALMACEN      IN NUMBER,
    P_MATERIAL     IN NUMBER,
    P_STOCK        IN NUMBER,
    P_STOCK_MIN    IN NUMBER,
    P_ZONA         IN VARCHAR2,
    O_COD_RET      OUT NUMBER,
    O_MSG          OUT VARCHAR2
) AS
BEGIN
    IF P_ALMACEN IS NULL OR P_MATERIAL IS NULL THEN
        O_COD_RET := 1;
        O_MSG := 'Almacén y material son obligatorios';
        RETURN;
    END IF;

    INSERT INTO MUE_MATERIAL_ALMACEN (
        ALM_Almacen,
        MAT_Material,
        MAL_Zona_Pasillo,
        MAL_Stock_Actual,
        MAL_Stock_Minimo,
        MAL_Created_At
    ) VALUES (
        P_ALMACEN,
        P_MATERIAL,
        P_ZONA,
        NVL(P_STOCK,0),
        NVL(P_STOCK_MIN,0),
        SYSTIMESTAMP
    );

    O_COD_RET := 0;
    O_MSG := 'Inventario creado correctamente';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al insertar inventario: ' || SQLERRM;
END;

--------------------------------------------------

-- LISTAR INVENTARIO
PROCEDURE PR_MAL_LISTAR(
    O_DATA    OUT SYS_REFCURSOR,
    O_COD_RET OUT NUMBER,
    O_MSG     OUT VARCHAR2
) AS
BEGIN
    OPEN O_DATA FOR
        SELECT 
            MAL.MAL_Material_Almacen,
            MAL.ALM_Almacen,
            MAL.MAT_Material,
            MAT.MAT_Nombre,
            MAL.MAL_Stock_Actual,
            MAL.MAL_Stock_Minimo,
            MAL.MAL_Zona_Pasillo
        FROM MUE_MATERIAL_ALMACEN MAL
        JOIN MUE_MATERIAL MAT ON MAT.MAT_Material = MAL.MAT_Material
        ORDER BY MAL.MAL_Material_Almacen DESC;

    O_COD_RET := 0;
    O_MSG := 'OK';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al listar inventario: ' || SQLERRM;
END;

--------------------------------------------------

-- ACTUALIZAR DATOS (NO STOCK)
PROCEDURE PR_MAL_ACTUALIZAR(
    P_ID          IN NUMBER,
    P_STOCK_MIN   IN NUMBER,
    P_ZONA        IN VARCHAR2,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
) AS
BEGIN
    UPDATE MUE_MATERIAL_ALMACEN
    SET MAL_Stock_Minimo = P_STOCK_MIN,
        MAL_Zona_Pasillo = P_ZONA
    WHERE MAL_Material_Almacen = P_ID;

    IF SQL%ROWCOUNT = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'No existe el registro';
        RETURN;
    END IF;

    O_COD_RET := 0;
    O_MSG := 'Inventario actualizado';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al actualizar: ' || SQLERRM;
END;

--------------------------------------------------

-- ELIMINAR REGISTRO
PROCEDURE PR_MAL_ELIMINAR(
    P_ID      IN NUMBER,
    O_COD_RET OUT NUMBER,
    O_MSG     OUT VARCHAR2
) AS
BEGIN
    DELETE FROM MUE_MATERIAL_ALMACEN
    WHERE MAL_Material_Almacen = P_ID;

    IF SQL%ROWCOUNT = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'No existe el registro';
        RETURN;
    END IF;

    O_COD_RET := 0;
    O_MSG := 'Inventario eliminado';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al eliminar: ' || SQLERRM;
END;

--------------------------------------------------

-- AJUSTE DE STOCK + MOVIMIENTO
-- Maneja entradas, salidas y ajustes
PROCEDURE PR_MAL_AJUSTAR_STOCK(
    P_ID            IN NUMBER,
    P_TIPO_MOV      IN NUMBER,
    P_CANTIDAD      IN NUMBER,
    P_OBSERVACION   IN VARCHAR2,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
) AS
    V_STOCK_ACTUAL NUMBER;
    V_NUEVO_STOCK  NUMBER;
BEGIN
    -- Obtener stock actual
    SELECT MAL_Stock_Actual
    INTO V_STOCK_ACTUAL
    FROM MUE_MATERIAL_ALMACEN
    WHERE MAL_Material_Almacen = P_ID
    FOR UPDATE;

    -- Lógica de movimiento
    -- (puedes mapear tipos: 1=entrada, 2=salida, 3=ajuste)
    IF P_TIPO_MOV = 1 THEN
        V_NUEVO_STOCK := V_STOCK_ACTUAL + P_CANTIDAD;
    ELSIF P_TIPO_MOV = 2 THEN
        V_NUEVO_STOCK := V_STOCK_ACTUAL - P_CANTIDAD;

        IF V_NUEVO_STOCK < 0 THEN
            O_COD_RET := 1;
            O_MSG := 'Stock insuficiente';
            RETURN;
        END IF;
    ELSE
        -- ajuste directo
        V_NUEVO_STOCK := P_CANTIDAD;
    END IF;

    -- Actualizar stock
    UPDATE MUE_MATERIAL_ALMACEN
    SET MAL_Stock_Actual = V_NUEVO_STOCK
    WHERE MAL_Material_Almacen = P_ID;

    -- Insertar movimiento
    INSERT INTO MUE_MOVIMIENTO_INVENTARIO_MATERIAL (
        MAL_Material_Almacen,
        TMM_Tipo_Movimiento_Material,
        MIN_Cantidad,
        MIN_Fecha_Movimiento,
        MIN_Observaciones,
        MIN_Created_At
    ) VALUES (
        P_ID,
        P_TIPO_MOV,
        P_CANTIDAD,
        SYSDATE,
        P_OBSERVACION,
        SYSTIMESTAMP
    );

    O_COD_RET := 0;
    O_MSG := 'Stock actualizado correctamente';

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        O_COD_RET := 1;
        O_MSG := 'No existe el inventario';
    WHEN OTHERS THEN    
        O_COD_RET := -1;
        O_MSG := 'Error al ajustar stock: ' || SQLERRM;
END;

PROCEDURE PR_MIN_INSERTAR(
    P_MAL_ID        IN NUMBER,
    P_TIPO_MOV      IN NUMBER,
    P_CANTIDAD      IN NUMBER,
    P_OBSERVACION   IN VARCHAR2,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
) AS
    V_STOCK_ACTUAL   NUMBER;
    V_STOCK_TOTAL    NUMBER;
    V_MATERIAL       NUMBER;
    V_NUEVO_STOCK    NUMBER;
BEGIN
    -- Obtener datos y bloquear
    SELECT MAL.MAL_Stock_Actual, MAT.MAT_Stock_Total, MAT.MAT_Material
    INTO V_STOCK_ACTUAL, V_STOCK_TOTAL, V_MATERIAL
    FROM MUE_MATERIAL_ALMACEN MAL
    JOIN MUE_MATERIAL MAT ON MAT.MAT_Material = MAL.MAT_Material
    WHERE MAL.MAL_Material_Almacen = P_MAL_ID
    FOR UPDATE;

    -- Lógica de movimiento
    IF P_TIPO_MOV = 1 THEN -- ENTRADA
        V_NUEVO_STOCK := V_STOCK_ACTUAL + P_CANTIDAD;
        V_STOCK_TOTAL := V_STOCK_TOTAL + P_CANTIDAD;

    ELSIF P_TIPO_MOV = 2 THEN -- SALIDA
        IF V_STOCK_ACTUAL < P_CANTIDAD THEN
            O_COD_RET := 1;
            O_MSG := 'Stock insuficiente';
            RETURN;
        END IF;

        V_NUEVO_STOCK := V_STOCK_ACTUAL - P_CANTIDAD;
        V_STOCK_TOTAL := V_STOCK_TOTAL - P_CANTIDAD;

    ELSE -- AJUSTE
        V_STOCK_TOTAL := V_STOCK_TOTAL - V_STOCK_ACTUAL + P_CANTIDAD;
        V_NUEVO_STOCK := P_CANTIDAD;
    END IF;

    -- Actualizar stocks
    UPDATE MUE_MATERIAL_ALMACEN
    SET MAL_Stock_Actual = V_NUEVO_STOCK
    WHERE MAL_Material_Almacen = P_MAL_ID;

    UPDATE MUE_MATERIAL
    SET MAT_Stock_Total = V_STOCK_TOTAL
    WHERE MAT_Material = V_MATERIAL;

    -- Insertar movimiento
    INSERT INTO MUE_MOVIMIENTO_INVENTARIO_MATERIAL (
        MAL_Material_Almacen,
        TMM_Tipo_Movimiento_Material,
        MIN_Cantidad,
        MIN_Fecha_Movimiento,
        MIN_Observaciones,
        MIN_Created_At
    ) VALUES (
        P_MAL_ID,
        P_TIPO_MOV,
        P_CANTIDAD,
        SYSDATE,
        P_OBSERVACION,
        SYSTIMESTAMP
    );

    O_COD_RET := 0;
    O_MSG := 'Movimiento registrado correctamente';

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        O_COD_RET := 1;
        O_MSG := 'No existe inventario';
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error: ' || SQLERRM;
END;

PROCEDURE PR_MIN_LISTAR(
    P_MATERIAL      IN NUMBER,
    P_TIPO_MOV      IN NUMBER,
    P_FECHA_INI     IN DATE,
    P_FECHA_FIN     IN DATE,
    O_DATA          OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
) AS
BEGIN
    OPEN O_DATA FOR
        SELECT 
            MIN.MIN_Movimiento_Inventario_Material,
            MIN.MAL_Material_Almacen,
            MAT.MAT_Nombre,
            MIN.TMM_Tipo_Movimiento_Material,
            MIN.MIN_Cantidad,
            MIN.MIN_Fecha_Movimiento,
            MIN.MIN_Observaciones
        FROM MUE_MOVIMIENTO_INVENTARIO_MATERIAL MIN
        JOIN MUE_MATERIAL_ALMACEN MAL ON MAL.MAL_Material_Almacen = MIN.MAL_Material_Almacen
        JOIN MUE_MATERIAL MAT ON MAT.MAT_Material = MAL.MAT_Material
        WHERE (P_MATERIAL IS NULL OR MAT.MAT_Material = P_MATERIAL)
          AND (P_TIPO_MOV IS NULL OR MIN.TMM_Tipo_Movimiento_Material = P_TIPO_MOV)
          AND (P_FECHA_INI IS NULL OR MIN.MIN_Fecha_Movimiento >= P_FECHA_INI)
          AND (P_FECHA_FIN IS NULL OR MIN.MIN_Fecha_Movimiento <= P_FECHA_FIN)
        ORDER BY MIN.MIN_Movimiento_Inventario_Material DESC;

    O_COD_RET := 0;
    O_MSG := 'OK';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al listar: ' || SQLERRM;
END;

PROCEDURE PR_MIN_OBTENER(
    P_ID            IN NUMBER,
    O_DATA          OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
) AS
BEGIN
    OPEN O_DATA FOR
        SELECT MIN_Movimiento_Inventario_Material,
               MAL_Material_Almacen,
               TMM_Tipo_Movimiento_Material,
               MIN_Cantidad,
               MIN_Fecha_Movimiento,
               MIN_Observaciones,
               MIN_Created_At
          FROM MUE_MOVIMIENTO_INVENTARIO_MATERIAL
         WHERE MIN_Movimiento_Inventario_Material = P_ID;

    O_COD_RET := 0;
    O_MSG := 'OK';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error: ' || SQLERRM;
END;

PROCEDURE PR_MIN_ACTUALIZAR(
    P_ID            IN NUMBER,
    P_TIPO_MOV      IN NUMBER,
    P_CANTIDAD      IN NUMBER,
    P_OBSERVACION   IN VARCHAR2,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
) AS
    V_OLD_CANTIDAD NUMBER;
    V_OLD_TIPO     NUMBER;
    V_MAL_ID       NUMBER;
BEGIN
    -- Obtener movimiento actual
    SELECT MIN_Cantidad, TMM_Tipo_Movimiento_Material, MAL_Material_Almacen
    INTO V_OLD_CANTIDAD, V_OLD_TIPO, V_MAL_ID
    FROM MUE_MOVIMIENTO_INVENTARIO_MATERIAL
    WHERE MIN_Movimiento_Inventario_Material = P_ID
    FOR UPDATE;

    -- Revertir movimiento anterior
    PR_MIN_INSERTAR(
        V_MAL_ID,
        CASE 
            WHEN V_OLD_TIPO = 1 THEN 2
            WHEN V_OLD_TIPO = 2 THEN 1
            ELSE 3
        END,
        V_OLD_CANTIDAD,
        'Reverso automático',
        O_COD_RET,
        O_MSG
    );
    IF O_COD_RET <> 0 THEN
        RETURN;
    END IF;

    -- Aplicar nuevo movimiento
    PR_MIN_INSERTAR(
        V_MAL_ID,
        P_TIPO_MOV,
        P_CANTIDAD,
        P_OBSERVACION,
        O_COD_RET,
        O_MSG
    );
    IF O_COD_RET <> 0 THEN
        RETURN;
    END IF;

    -- Actualizar registro original
    UPDATE MUE_MOVIMIENTO_INVENTARIO_MATERIAL
    SET TMM_Tipo_Movimiento_Material = P_TIPO_MOV,
        MIN_Cantidad = P_CANTIDAD,
        MIN_Observaciones = P_OBSERVACION
    WHERE MIN_Movimiento_Inventario_Material = P_ID;

    O_COD_RET := 0;
    O_MSG := 'Movimiento actualizado correctamente';

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        O_COD_RET := 1;
        O_MSG := 'Movimiento no encontrado';
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error: ' || SQLERRM;
END;

PROCEDURE PR_DMP_INSERTAR(
    P_TPR          IN NUMBER,
    P_MAT          IN NUMBER,
    P_PRO          IN NUMBER,
    P_CANTIDAD     IN NUMBER,
    O_COD_RET      OUT NUMBER,
    O_MSG          OUT VARCHAR2
) AS
    V_EXISTE NUMBER;
BEGIN
    -- Validaciones obligatorias
    IF P_TPR IS NULL OR P_MAT IS NULL OR P_PRO IS NULL THEN
        O_COD_RET := 1;
        O_MSG := 'TPR, MAT y PRO son obligatorios';
        RETURN;
    END IF;

    IF NVL(P_CANTIDAD,0) <= 0 THEN
        O_COD_RET := 1;
        O_MSG := 'Cantidad debe ser mayor a 0';
        RETURN;
    END IF;

    -- Validar TPR
    SELECT COUNT(*) INTO V_EXISTE 
    FROM MUE_TALLER_PRODUCCION 
    WHERE TPR_Taller_Produccion = P_TPR;

    IF V_EXISTE = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'No existe el taller';
        RETURN;
    END IF;

    -- Validar MATERIAL
    SELECT COUNT(*) INTO V_EXISTE 
    FROM MUE_MATERIAL 
    WHERE MAT_Material = P_MAT;

    IF V_EXISTE = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'No existe el material';
        RETURN;
    END IF;

    -- Validar PRODUCTO
    SELECT COUNT(*) INTO V_EXISTE 
    FROM MUE_PRODUCTO 
    WHERE PRO_Producto = P_PRO;

    IF V_EXISTE = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'No existe el producto';
        RETURN;
    END IF;

    -- Insertar
    INSERT INTO MUE_DETALLE_MATERIAL_PRODUCTO (
        TPR_Taller_Produccion,
        MAT_Material,
        PRO_Producto,
        DMP_Cantidad_Material,
        DMP_Created_At
    ) VALUES (
        P_TPR,
        P_MAT,
        P_PRO,
        P_CANTIDAD,
        SYSTIMESTAMP
    );

    O_COD_RET := 0;
    O_MSG := 'Receta creada correctamente';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al insertar: ' || SQLERRM;
END;

PROCEDURE PR_DMP_LISTAR(
    P_PRO          IN NUMBER,
    O_DATA         OUT SYS_REFCURSOR,
    O_COD_RET      OUT NUMBER,
    O_MSG          OUT VARCHAR2
) AS
BEGIN
    OPEN O_DATA FOR
        SELECT 
            DMP.DMP_Detalle_Material_Producto,
            DMP.TPR_Taller_Produccion,
            TPR.TPR_Descripcion,
            DMP.MAT_Material,
            MAT.MAT_Nombre,
            DMP.PRO_Producto,
            PRO.PRO_Nombre,
            DMP.DMP_Cantidad_Material
        FROM MUE_DETALLE_MATERIAL_PRODUCTO DMP
        JOIN MUE_TALLER_PRODUCCION TPR ON TPR.TPR_Taller_Produccion = DMP.TPR_Taller_Produccion
        JOIN MUE_MATERIAL MAT ON MAT.MAT_Material = DMP.MAT_Material
        JOIN MUE_PRODUCTO PRO ON PRO.PRO_Producto = DMP.PRO_Producto
        WHERE (P_PRO IS NULL OR DMP.PRO_Producto = P_PRO)
        ORDER BY DMP.DMP_Detalle_Material_Producto DESC;

    O_COD_RET := 0;
    O_MSG := 'OK';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al listar: ' || SQLERRM;
END;

PROCEDURE PR_DMP_OBTENER(
    P_ID           IN NUMBER,
    O_DATA         OUT SYS_REFCURSOR,
    O_COD_RET      OUT NUMBER,
    O_MSG          OUT VARCHAR2
) AS
BEGIN
    OPEN O_DATA FOR
        SELECT DMP_Detalle_Material_Producto,
               TPR_Taller_Produccion,
               MAT_Material,
               PRO_Producto,
               DMP_Cantidad_Material,
               DMP_Created_At
          FROM MUE_DETALLE_MATERIAL_PRODUCTO
         WHERE DMP_Detalle_Material_Producto = P_ID;

    O_COD_RET := 0;
    O_MSG := 'OK';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error: ' || SQLERRM;
END;

PROCEDURE PR_DMP_ACTUALIZAR(
    P_ID           IN NUMBER,
    P_TPR          IN NUMBER,
    P_MAT          IN NUMBER,
    P_PRO          IN NUMBER,
    P_CANTIDAD     IN NUMBER,
    O_COD_RET      OUT NUMBER,
    O_MSG          OUT VARCHAR2
) AS
    V_EXISTE NUMBER;
BEGIN
    -- Validar existencia del registro
    SELECT COUNT(*) INTO V_EXISTE
    FROM MUE_DETALLE_MATERIAL_PRODUCTO
    WHERE DMP_Detalle_Material_Producto = P_ID;

    IF V_EXISTE = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'No existe el registro';
        RETURN;
    END IF;

    -- Reutilizar validaciones básicas
    IF NVL(P_CANTIDAD,0) <= 0 THEN
        O_COD_RET := 1;
        O_MSG := 'Cantidad inválida';
        RETURN;
    END IF;

    -- Update
    UPDATE MUE_DETALLE_MATERIAL_PRODUCTO
    SET TPR_Taller_Produccion = P_TPR,
        MAT_Material = P_MAT,
        PRO_Producto = P_PRO,
        DMP_Cantidad_Material = P_CANTIDAD
    WHERE DMP_Detalle_Material_Producto = P_ID;

    O_COD_RET := 0;
    O_MSG := 'Receta actualizada correctamente';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al actualizar: ' || SQLERRM;
END;

PROCEDURE PR_DMP_ELIMINAR(
    P_ID           IN NUMBER,
    O_COD_RET      OUT NUMBER,
    O_MSG          OUT VARCHAR2
) AS
BEGIN
    DELETE FROM MUE_DETALLE_MATERIAL_PRODUCTO
    WHERE DMP_Detalle_Material_Producto = P_ID;

    IF SQL%ROWCOUNT = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'No existe el registro';
        RETURN;
    END IF;

    O_COD_RET := 0;
    O_MSG := 'Receta eliminada correctamente';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al eliminar: ' || SQLERRM;
END;

PROCEDURE PR_PBO_INSERTAR(
    P_BODEGA        IN NUMBER,
    P_PRODUCTO      IN NUMBER,
    P_CANTIDAD      IN NUMBER,
    P_STOCK_MIN     IN NUMBER,
    P_UBICACION     IN VARCHAR2,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
) AS
    V_EXISTE NUMBER;
BEGIN
    IF P_BODEGA IS NULL OR P_PRODUCTO IS NULL THEN
        O_COD_RET := 1;
        O_MSG := 'Bodega y producto son obligatorios';
        RETURN;
    END IF;

    -- Validar bodega
    SELECT COUNT(*) INTO V_EXISTE 
    FROM MUE_BODEGA WHERE BOD_Bodega = P_BODEGA;

    IF V_EXISTE = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'No existe la bodega';
        RETURN;
    END IF;

    -- Validar producto
    SELECT COUNT(*) INTO V_EXISTE 
    FROM MUE_PRODUCTO WHERE PRO_Producto = P_PRODUCTO;

    IF V_EXISTE = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'No existe el producto';
        RETURN;
    END IF;

    -- Evitar duplicado (unique ya existe pero lo controlamos)
    SELECT COUNT(*) INTO V_EXISTE
    FROM MUE_PRODUCTO_BODEGA
    WHERE BOD_Bodega = P_BODEGA
      AND PRO_Producto = P_PRODUCTO;

    IF V_EXISTE > 0 THEN
        O_COD_RET := 1;
        O_MSG := 'Ya existe el producto en la bodega';
        RETURN;
    END IF;

    INSERT INTO MUE_PRODUCTO_BODEGA (
        BOD_Bodega,
        PRO_Producto,
        PBO_Cantidad_Disponible,
        PBO_Stock_Minimo,
        PBO_Ubicacion,
        PBO_Created_At
    ) VALUES (
        P_BODEGA,
        P_PRODUCTO,
        NVL(P_CANTIDAD,0),
        NVL(P_STOCK_MIN,0),
        P_UBICACION,
        SYSTIMESTAMP
    );

    O_COD_RET := 0;
    O_MSG := 'Registro creado correctamente';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error: ' || SQLERRM;
END;

PROCEDURE PR_PBO_LISTAR(
    P_BODEGA        IN NUMBER,
    P_PRODUCTO      IN NUMBER,
    O_DATA          OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
) AS
BEGIN
    OPEN O_DATA FOR
        SELECT 
            PBO.PBO_Producto_Bodega,
            PBO.BOD_Bodega,
            BOD.BOD_Nombre,
            PBO.PRO_Producto,
            PRO.PRO_Nombre,
            PBO.PBO_Cantidad_Disponible,
            PBO.PBO_Stock_Minimo,
            PBO.PBO_Ubicacion,
            CASE 
                WHEN PBO.PBO_Cantidad_Disponible <= PBO.PBO_Stock_Minimo 
                THEN 'CRITICO'
                ELSE 'OK'
            END AS ESTADO_STOCK
        FROM MUE_PRODUCTO_BODEGA PBO
        JOIN MUE_BODEGA BOD ON BOD.BOD_Bodega = PBO.BOD_Bodega
        JOIN MUE_PRODUCTO PRO ON PRO.PRO_Producto = PBO.PRO_Producto
        WHERE (P_BODEGA IS NULL OR PBO.BOD_Bodega = P_BODEGA)
          AND (P_PRODUCTO IS NULL OR PBO.PRO_Producto = P_PRODUCTO)
        ORDER BY PBO.PBO_Producto_Bodega DESC;

    O_COD_RET := 0;
    O_MSG := 'OK';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al listar: ' || SQLERRM;
END;

PROCEDURE PR_PBO_OBTENER(
    P_ID            IN NUMBER,
    O_DATA          OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
) AS
BEGIN
    OPEN O_DATA FOR
        SELECT PBO_Producto_Bodega,
               BOD_Bodega,
               PRO_Producto,
               PBO_Cantidad_Disponible,
               PBO_Stock_Minimo,
               PBO_Ubicacion,
               PBO_Created_At
          FROM MUE_PRODUCTO_BODEGA
         WHERE PBO_Producto_Bodega = P_ID;

    O_COD_RET := 0;
    O_MSG := 'OK';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error: ' || SQLERRM;
END;

PROCEDURE PR_PBO_ACTUALIZAR(
    P_ID            IN NUMBER,
    P_CANTIDAD      IN NUMBER,
    P_STOCK_MIN     IN NUMBER,
    P_UBICACION     IN VARCHAR2,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
) AS
BEGIN
    UPDATE MUE_PRODUCTO_BODEGA
    SET PBO_Cantidad_Disponible = P_CANTIDAD,
        PBO_Stock_Minimo        = P_STOCK_MIN,
        PBO_Ubicacion           = P_UBICACION
    WHERE PBO_Producto_Bodega = P_ID;

    IF SQL%ROWCOUNT = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'No existe el registro';
        RETURN;
    END IF;

    -- Alerta
    IF P_CANTIDAD <= P_STOCK_MIN THEN
        O_COD_RET := 2;
        O_MSG := 'Actualizado, pero en nivel crítico de stock';
        RETURN;
    END IF;

    O_COD_RET := 0;
    O_MSG := 'Actualizado correctamente';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error: ' || SQLERRM;
END;

PROCEDURE PR_PBO_ELIMINAR(
    P_ID            IN NUMBER,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
) AS
BEGIN
    DELETE FROM MUE_PRODUCTO_BODEGA
    WHERE PBO_Producto_Bodega = P_ID;

    IF SQL%ROWCOUNT = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'No existe el registro';
        RETURN;
    END IF;

    O_COD_RET := 0;
    O_MSG := 'Eliminado correctamente';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error: ' || SQLERRM;
END;

PROCEDURE PR_PBO_ALERTA_MINIMO(
    O_DATA          OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
) AS
BEGIN
    OPEN O_DATA FOR
        SELECT 
            PBO.PBO_Producto_Bodega,
            BOD.BOD_Nombre,
            PRO.PRO_Nombre,
            PBO.PBO_Cantidad_Disponible,
            PBO.PBO_Stock_Minimo
        FROM MUE_PRODUCTO_BODEGA PBO
        JOIN MUE_BODEGA BOD ON BOD.BOD_Bodega = PBO.BOD_Bodega
        JOIN MUE_PRODUCTO PRO ON PRO.PRO_Producto = PBO.PRO_Producto
        WHERE PBO.PBO_Cantidad_Disponible <= PBO.PBO_Stock_Minimo
        ORDER BY PBO.PBO_Cantidad_Disponible ASC;

    O_COD_RET := 0;
    O_MSG := 'OK';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error: ' || SQLERRM;
END;

-- =========================
-- ASIGNACION TURNO
-- =========================

PROCEDURE PR_AST_INSERTAR(
    P_EMP IN NUMBER,
    P_TUR IN NUMBER,
    P_FECHA_INICIO IN DATE,
    P_FECHA_FIN IN DATE,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
) AS
    V_EXISTE NUMBER;
BEGIN
    -- Validaciones básicas
    IF P_EMP IS NULL OR P_TUR IS NULL OR P_FECHA_INICIO IS NULL THEN
        O_COD_RET := 1;
        O_MSG := 'Empleado, turno y fecha inicio son obligatorios';
        RETURN;
    END IF;

    -- Validar empleado
    SELECT COUNT(*) INTO V_EXISTE
    FROM MUE_EMPLEADO
    WHERE EMP_Empleado = P_EMP;

    IF V_EXISTE = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'Empleado no existe';
        RETURN;
    END IF;

    -- Validar turno
    SELECT COUNT(*) INTO V_EXISTE
    FROM MUE_TURNO
    WHERE TUR_Turno = P_TUR;

    IF V_EXISTE = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'Turno no existe';
        RETURN;
    END IF;

    -- Validar fechas coherentes
    IF P_FECHA_FIN IS NOT NULL AND P_FECHA_FIN < P_FECHA_INICIO THEN
        O_COD_RET := 1;
        O_MSG := 'Fecha fin no puede ser menor que fecha inicio';
        RETURN;
    END IF;

    INSERT INTO MUE_ASIGNACION_TURNO (
        EMP_Empleado,
        TUR_Turno,
        AST_Fecha_Inicio,
        AST_Fecha_Fin,
        AST_Created_At
    ) VALUES (
        P_EMP,
        P_TUR,
        P_FECHA_INICIO,
        P_FECHA_FIN,
        SYSTIMESTAMP
    );

    O_COD_RET := 0;
    O_MSG := 'Asignación creada correctamente';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al insertar: ' || SQLERRM;
END;

--------------------------------------------------

PROCEDURE PR_AST_LISTAR(
    P_EMP IN NUMBER,
    O_DATA OUT SYS_REFCURSOR,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
) AS
BEGIN
    OPEN O_DATA FOR
        SELECT 
            AST.AST_Asignacion_Turno,
            AST.EMP_Empleado,
            E.EMP_Primer_Nombre || ' ' || E.EMP_Primer_Apellido AS EMPLEADO,
            AST.TUR_Turno,
            T.TUR_Descripcion,
            AST.AST_Fecha_Inicio,
            AST.AST_Fecha_Fin
        FROM MUE_ASIGNACION_TURNO AST
        JOIN MUE_EMPLEADO E ON E.EMP_Empleado = AST.EMP_Empleado
        JOIN MUE_TURNO T ON T.TUR_Turno = AST.TUR_Turno
        WHERE (P_EMP IS NULL OR AST.EMP_Empleado = P_EMP)
        ORDER BY AST.AST_Asignacion_Turno DESC;

    O_COD_RET := 0;
    O_MSG := 'OK';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al listar: ' || SQLERRM;
END;

--------------------------------------------------

PROCEDURE PR_AST_OBTENER(
    P_ID IN NUMBER,
    O_DATA OUT SYS_REFCURSOR,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
) AS
BEGIN
    OPEN O_DATA FOR
        SELECT AST_Asignacion_Turno,
               EMP_Empleado,
               TUR_Turno,
               AST_Fecha_Inicio,
               AST_Fecha_Fin,
               AST_Created_At
          FROM MUE_ASIGNACION_TURNO
         WHERE AST_Asignacion_Turno = P_ID;

    O_COD_RET := 0;
    O_MSG := 'OK';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al obtener: ' || SQLERRM;
END;

--------------------------------------------------

PROCEDURE PR_AST_ACTUALIZAR(
    P_ID IN NUMBER,
    P_TUR IN NUMBER,
    P_FECHA_INICIO IN DATE,
    P_FECHA_FIN IN DATE,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
) AS
BEGIN
    -- Validar fechas
    IF P_FECHA_FIN IS NOT NULL AND P_FECHA_FIN < P_FECHA_INICIO THEN
        O_COD_RET := 1;
        O_MSG := 'Fecha fin inválida';
        RETURN;
    END IF;

    UPDATE MUE_ASIGNACION_TURNO
    SET TUR_Turno = P_TUR,
        AST_Fecha_Inicio = P_FECHA_INICIO,
        AST_Fecha_Fin = P_FECHA_FIN
    WHERE AST_Asignacion_Turno = P_ID;

    IF SQL%ROWCOUNT = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'No existe la asignación';
        RETURN;
    END IF;

    O_COD_RET := 0;
    O_MSG := 'Actualizado correctamente';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al actualizar: ' || SQLERRM;
END;

--------------------------------------------------

PROCEDURE PR_AST_ELIMINAR(
    P_ID IN NUMBER,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
) AS
BEGIN
    DELETE FROM MUE_ASIGNACION_TURNO
    WHERE AST_Asignacion_Turno = P_ID;

    IF SQL%ROWCOUNT = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'No existe la asignación';
        RETURN;
    END IF;

    O_COD_RET := 0;
    O_MSG := 'Eliminado correctamente';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al eliminar: ' || SQLERRM;
END;

-- =========================
-- REGISTRO ASISTENCIA
-- =========================

-- 🔹 ENTRADA (abre jornada)
PROCEDURE PR_REA_ENTRADA(
    P_EMP IN NUMBER,
    P_OBS IN VARCHAR2,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
) AS
    V_EXISTE NUMBER;
BEGIN
    -- Validar empleado
    SELECT COUNT(*) INTO V_EXISTE
    FROM MUE_EMPLEADO
    WHERE EMP_Empleado = P_EMP;

    IF V_EXISTE = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'Empleado no existe';
        RETURN;
    END IF;

    -- Validar que no tenga jornada abierta hoy
    SELECT COUNT(*) INTO V_EXISTE
    FROM MUE_REGISTRO_ASISTENCIA
    WHERE EMP_Empleado = P_EMP
      AND TRUNC(REA_Fecha) = TRUNC(SYSDATE)
      AND REA_Hora_Salida IS NULL;

    IF V_EXISTE > 0 THEN
        O_COD_RET := 1;
        O_MSG := 'Ya existe una entrada sin salida';
        RETURN;
    END IF;

    INSERT INTO MUE_REGISTRO_ASISTENCIA (
        EMP_Empleado,
        REA_Fecha,
        REA_Hora_Entrada,
        REA_Observaciones,
        REA_Created_At
    ) VALUES (
        P_EMP,
        TRUNC(SYSDATE),
        SYSTIMESTAMP,
        P_OBS,
        SYSTIMESTAMP
    );

    O_COD_RET := 0;
    O_MSG := 'Entrada registrada';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error en entrada: ' || SQLERRM;
END;

--------------------------------------------------

-- 🔹 SALIDA (cierra jornada)
PROCEDURE PR_REA_SALIDA(
    P_EMP IN NUMBER,
    P_OBS IN VARCHAR2,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
) AS
    V_ID NUMBER;
BEGIN
    -- Buscar jornada abierta
    SELECT REA_Registro_Asistencia
    INTO V_ID
    FROM MUE_REGISTRO_ASISTENCIA
    WHERE EMP_Empleado = P_EMP
      AND TRUNC(REA_Fecha) = TRUNC(SYSDATE)
      AND REA_Hora_Salida IS NULL
    FOR UPDATE;

    -- Cerrar jornada
    UPDATE MUE_REGISTRO_ASISTENCIA
    SET REA_Hora_Salida = SYSTIMESTAMP,
        REA_Observaciones = REA_Observaciones || ' | ' || P_OBS
    WHERE REA_Registro_Asistencia = V_ID;

    O_COD_RET := 0;
    O_MSG := 'Salida registrada';

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        O_COD_RET := 1;
        O_MSG := 'No hay entrada abierta';
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error en salida: ' || SQLERRM;
END;

--------------------------------------------------

-- 🔹 LISTAR
PROCEDURE PR_REA_LISTAR(
    P_EMP IN NUMBER,
    O_DATA OUT SYS_REFCURSOR,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
) AS
BEGIN
    OPEN O_DATA FOR
        SELECT 
            R.REA_Registro_Asistencia,
            R.EMP_Empleado,
            E.EMP_Primer_Nombre || ' ' || E.EMP_Primer_Apellido AS EMPLEADO,
            R.REA_Fecha,
            R.REA_Hora_Entrada,
            R.REA_Hora_Salida,
            R.REA_Observaciones
        FROM MUE_REGISTRO_ASISTENCIA R
        JOIN MUE_EMPLEADO E ON E.EMP_Empleado = R.EMP_Empleado
        WHERE (P_EMP IS NULL OR R.EMP_Empleado = P_EMP)
        ORDER BY R.REA_Registro_Asistencia DESC;

    O_COD_RET := 0;
    O_MSG := 'OK';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al listar: ' || SQLERRM;
END;

--------------------------------------------------

-- 🔹 OBTENER
PROCEDURE PR_REA_OBTENER(
    P_ID IN NUMBER,
    O_DATA OUT SYS_REFCURSOR,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
) AS
BEGIN
    OPEN O_DATA FOR
        SELECT REA_Registro_Asistencia,
               EMP_Empleado,
               REA_Fecha,
               REA_Hora_Entrada,
               REA_Hora_Salida,
               REA_Observaciones,
               REA_Created_At
          FROM MUE_REGISTRO_ASISTENCIA
         WHERE REA_Registro_Asistencia = P_ID;

    O_COD_RET := 0;
    O_MSG := 'OK';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al obtener: ' || SQLERRM;
END;

--------------------------------------------------

-- 🔹 ELIMINAR
PROCEDURE PR_REA_ELIMINAR(
    P_ID IN NUMBER,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
) AS
BEGIN
    DELETE FROM MUE_REGISTRO_ASISTENCIA
    WHERE REA_Registro_Asistencia = P_ID;

    IF SQL%ROWCOUNT = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'No existe el registro';
        RETURN;
    END IF;

    O_COD_RET := 0;
    O_MSG := 'Eliminado correctamente';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al eliminar: ' || SQLERRM;
END;

-- =========================
-- CONTRATO
-- =========================

PROCEDURE PR_CTR_INSERTAR(
    P_EMP IN NUMBER,
    P_PUE IN NUMBER,
    P_FECHA_INICIO IN DATE,
    P_FECHA_FIN IN DATE,
    P_SALARIO IN NUMBER,
    P_MONEDA IN VARCHAR2,
    P_ESTADO IN NUMBER,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
) AS
    V_EXISTE NUMBER;
BEGIN
    -- Validaciones obligatorias
    IF P_EMP IS NULL OR P_PUE IS NULL OR P_FECHA_INICIO IS NULL THEN
        O_COD_RET := 1;
        O_MSG := 'Empleado, puesto y fecha inicio son obligatorios';
        RETURN;
    END IF;

    -- Validar empleado
    SELECT COUNT(*) INTO V_EXISTE
    FROM MUE_EMPLEADO
    WHERE EMP_Empleado = P_EMP;

    IF V_EXISTE = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'Empleado no existe';
        RETURN;
    END IF;

    -- Validar puesto
    SELECT COUNT(*) INTO V_EXISTE
    FROM MUE_PUESTO
    WHERE PUE_Puesto = P_PUE;

    IF V_EXISTE = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'Puesto no existe';
        RETURN;
    END IF;

    -- Validar fechas
    IF P_FECHA_FIN IS NOT NULL AND P_FECHA_FIN < P_FECHA_INICIO THEN
        O_COD_RET := 1;
        O_MSG := 'Fecha fin inválida';
        RETURN;
    END IF;

    -- Validar estado (0 o 1)
    IF P_ESTADO NOT IN (0,1) THEN
        O_COD_RET := 1;
        O_MSG := 'Estado inválido';
        RETURN;
    END IF;

    -- 🚫 Evitar múltiples contratos activos
    IF P_ESTADO = 1 THEN
        SELECT COUNT(*) INTO V_EXISTE
        FROM MUE_CONTRATO
        WHERE EMP_Empleado = P_EMP
          AND CTR_Estado = 1;

        IF V_EXISTE > 0 THEN
            O_COD_RET := 1;
            O_MSG := 'Empleado ya tiene contrato activo';
            RETURN;
        END IF;
    END IF;

    INSERT INTO MUE_CONTRATO (
        EMP_Empleado,
        PUE_Puesto,
        CTR_Fecha_Inicio,
        CTR_Fecha_Fin,
        CTR_Salario_Base,
        CTR_Moneda,
        CTR_Estado,
        CTR_Created_At
    ) VALUES (
        P_EMP,
        P_PUE,
        P_FECHA_INICIO,
        P_FECHA_FIN,
        P_SALARIO,
        P_MONEDA,
        P_ESTADO,
        SYSTIMESTAMP
    );

    O_COD_RET := 0;
    O_MSG := 'Contrato creado correctamente';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al insertar: ' || SQLERRM;
END;

--------------------------------------------------

PROCEDURE PR_CTR_LISTAR(
    P_EMP IN NUMBER,
    O_DATA OUT SYS_REFCURSOR,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
) AS
BEGIN
    OPEN O_DATA FOR
        SELECT 
            C.CTR_Contrato,
            C.EMP_Empleado,
            E.EMP_Primer_Nombre || ' ' || E.EMP_Primer_Apellido AS EMPLEADO,
            C.PUE_Puesto,
            P.PUE_Titulo,
            C.CTR_Fecha_Inicio,
            C.CTR_Fecha_Fin,
            C.CTR_Salario_Base,
            C.CTR_Moneda,
            C.CTR_Estado
        FROM MUE_CONTRATO C
        JOIN MUE_EMPLEADO E ON E.EMP_Empleado = C.EMP_Empleado
        JOIN MUE_PUESTO P ON P.PUE_Puesto = C.PUE_Puesto
        WHERE (P_EMP IS NULL OR C.EMP_Empleado = P_EMP)
        ORDER BY C.CTR_Contrato DESC;

    O_COD_RET := 0;
    O_MSG := 'OK';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al listar: ' || SQLERRM;
END;

--------------------------------------------------

PROCEDURE PR_CTR_OBTENER(
    P_ID IN NUMBER,
    O_DATA OUT SYS_REFCURSOR,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
) AS
BEGIN
    OPEN O_DATA FOR
        SELECT CTR_Contrato,
               EMP_Empleado,
               PUE_Puesto,
               CTR_Fecha_Inicio,
               CTR_Fecha_Fin,
               CTR_Salario_Base,
               CTR_Moneda,
               CTR_Estado,
               CTR_Created_At,
               CTR_Updated_At
          FROM MUE_CONTRATO
         WHERE CTR_Contrato = P_ID;

    O_COD_RET := 0;
    O_MSG := 'OK';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al obtener: ' || SQLERRM;
END;

--------------------------------------------------

PROCEDURE PR_CTR_ACTUALIZAR(
    P_ID IN NUMBER,
    P_PUE IN NUMBER,
    P_FECHA_INICIO IN DATE,
    P_FECHA_FIN IN DATE,
    P_SALARIO IN NUMBER,
    P_MONEDA IN VARCHAR2,
    P_ESTADO IN NUMBER,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
) AS
    V_EMP NUMBER;
    V_EXISTE NUMBER;
BEGIN
    -- Obtener empleado del contrato
    SELECT EMP_Empleado INTO V_EMP
    FROM MUE_CONTRATO
    WHERE CTR_Contrato = P_ID;

    -- Validar fechas
    IF P_FECHA_FIN IS NOT NULL AND P_FECHA_FIN < P_FECHA_INICIO THEN
        O_COD_RET := 1;
        O_MSG := 'Fechas inválidas';
        RETURN;
    END IF;

    -- Validar único activo
    IF P_ESTADO = 1 THEN
        SELECT COUNT(*) INTO V_EXISTE
        FROM MUE_CONTRATO
        WHERE EMP_Empleado = V_EMP
          AND CTR_Estado = 1
          AND CTR_Contrato <> P_ID;

        IF V_EXISTE > 0 THEN
            O_COD_RET := 1;
            O_MSG := 'Ya existe otro contrato activo';
            RETURN;
        END IF;
    END IF;

    UPDATE MUE_CONTRATO
    SET PUE_Puesto = P_PUE,
        CTR_Fecha_Inicio = P_FECHA_INICIO,
        CTR_Fecha_Fin = P_FECHA_FIN,
        CTR_Salario_Base = P_SALARIO,
        CTR_Moneda = P_MONEDA,
        CTR_Estado = P_ESTADO,
        CTR_Updated_At = SYSTIMESTAMP
    WHERE CTR_Contrato = P_ID;

    IF SQL%ROWCOUNT = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'No existe el contrato';
        RETURN;
    END IF;

    O_COD_RET := 0;
    O_MSG := 'Contrato actualizado';

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        O_COD_RET := 1;
        O_MSG := 'Contrato no encontrado';
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al actualizar: ' || SQLERRM;
END;

--------------------------------------------------

PROCEDURE PR_CTR_ELIMINAR(
    P_ID IN NUMBER,
    O_COD_RET OUT NUMBER,
    O_MSG OUT VARCHAR2
) AS
BEGIN
    DELETE FROM MUE_CONTRATO
    WHERE CTR_Contrato = P_ID;

    IF SQL%ROWCOUNT = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'No existe el contrato';
        RETURN;
    END IF;

    O_COD_RET := 0;
    O_MSG := 'Contrato eliminado';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al eliminar: ' || SQLERRM;
END;

-----------------------------------------
-- INSERTAR NOMINA
-----------------------------------------
PROCEDURE PR_NOM_INSERTAR(
    P_CONTRATO     IN NUMBER,
    P_FECHA_INI    IN DATE,
    P_FECHA_FIN    IN DATE,
    O_COD_RET      OUT NUMBER,
    O_MSG          OUT VARCHAR2
) AS
    V_EXISTE NUMBER;
BEGIN
    -- Validar contrato
    SELECT COUNT(*) INTO V_EXISTE
    FROM MUE_CONTRATO
    WHERE CTR_Contrato = P_CONTRATO;

    IF V_EXISTE = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'Contrato no existe';
        RETURN;
    END IF;

    IF P_FECHA_INI > P_FECHA_FIN THEN
        O_COD_RET := 1;
        O_MSG := 'Fechas inválidas';
        RETURN;
    END IF;

    INSERT INTO MUE_NOMINA (
        CTR_Contrato,
        NOM_Fecha_Inicio,
        NOM_Fecha_Fin,
        NOM_Estado,
        NOM_Created_At
    ) VALUES (
        P_CONTRATO,
        P_FECHA_INI,
        P_FECHA_FIN,
        0, -- abierta
        SYSTIMESTAMP
    );

    O_COD_RET := 0;
    O_MSG := 'Nómina creada correctamente';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al insertar nómina: ' || SQLERRM;
END;

--------------------------------------------------

PROCEDURE PR_NOM_LISTAR(
    O_DATA    OUT SYS_REFCURSOR,
    O_COD_RET OUT NUMBER,
    O_MSG     OUT VARCHAR2
) AS
BEGIN
    OPEN O_DATA FOR
        SELECT NOM_Nomina,
               CTR_Contrato,
               NOM_Fecha_Inicio,
               NOM_Fecha_Fin,
               NOM_Fecha_Pago,
               NOM_Total_Devengos,
               NOM_Total_Deducciones,
               NOM_Neto_Pagar,
               NOM_Estado,
               NOM_Created_At
          FROM MUE_NOMINA
         ORDER BY NOM_Nomina DESC;

    O_COD_RET := 0;
    O_MSG := 'OK';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al listar: ' || SQLERRM;
END;

--------------------------------------------------

PROCEDURE PR_NOM_OBTENER(
    P_ID      IN NUMBER,
    O_DATA    OUT SYS_REFCURSOR,
    O_COD_RET OUT NUMBER,
    O_MSG     OUT VARCHAR2
) AS
BEGIN
    OPEN O_DATA FOR
        SELECT NOM_Nomina,
               CTR_Contrato,
               NOM_Fecha_Inicio,
               NOM_Fecha_Fin,
               NOM_Fecha_Pago,
               NOM_Total_Devengos,
               NOM_Total_Deducciones,
               NOM_Neto_Pagar,
               NOM_Estado,
               NOM_Created_At
          FROM MUE_NOMINA
         WHERE NOM_Nomina = P_ID;

    O_COD_RET := 0;
    O_MSG := 'OK';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al obtener: ' || SQLERRM;
END;

--------------------------------------------------

PROCEDURE PR_NOM_ACTUALIZAR(
    P_ID           IN NUMBER,
    P_FECHA_INI    IN DATE,
    P_FECHA_FIN    IN DATE,
    O_COD_RET      OUT NUMBER,
    O_MSG          OUT VARCHAR2
) AS
BEGIN
    UPDATE MUE_NOMINA
    SET NOM_Fecha_Inicio = P_FECHA_INI,
        NOM_Fecha_Fin    = P_FECHA_FIN
    WHERE NOM_Nomina = P_ID
    AND NOM_Estado = 0; -- solo abiertas

    IF SQL%ROWCOUNT = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'No existe o ya está cerrada';
        RETURN;
    END IF;

    O_COD_RET := 0;
    O_MSG := 'Nómina actualizada';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al actualizar: ' || SQLERRM;
END;

--------------------------------------------------

PROCEDURE PR_NOM_ELIMINAR(
    P_ID      IN NUMBER,
    O_COD_RET OUT NUMBER,
    O_MSG     OUT VARCHAR2
) AS
BEGIN
    DELETE FROM MUE_NOMINA
    WHERE NOM_Nomina = P_ID
    AND NOM_Estado = 0;

    IF SQL%ROWCOUNT = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'No existe o ya está cerrada';
        RETURN;
    END IF;

    O_COD_RET := 0;
    O_MSG := 'Nómina eliminada';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al eliminar: ' || SQLERRM;
END;

--------------------------------------------------
-- CALCULAR TOTALES
--------------------------------------------------
PROCEDURE PR_NOM_CALCULAR_TOTALES(
    P_ID      IN NUMBER,
    O_COD_RET OUT NUMBER,
    O_MSG     OUT VARCHAR2
) AS
    V_DEVENGOS NUMBER := 0;
    V_DEDUCCIONES NUMBER := 0;
BEGIN
    -- Sumar detalles
    SELECT 
        NVL(SUM(CASE WHEN CPA_Tipo = 1 THEN DNM_Valor END),0),
        NVL(SUM(CASE WHEN CPA_Tipo = 2 THEN DNM_Valor END),0)
    INTO V_DEVENGOS, V_DEDUCCIONES
    FROM MUE_DETALLE_NOMINA D
    JOIN MUE_CONCEPTO_PAGO C 
        ON C.CPA_Concepto_Pago = D.CPA_Concepto_Pago
    WHERE D.NOM_Nomina = P_ID;

    UPDATE MUE_NOMINA
    SET NOM_Total_Devengos    = V_DEVENGOS,
        NOM_Total_Deducciones = V_DEDUCCIONES,
        NOM_Neto_Pagar        = V_DEVENGOS - V_DEDUCCIONES
    WHERE NOM_Nomina = P_ID;

    IF SQL%ROWCOUNT = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'No existe la nómina';
        RETURN;
    END IF;

    O_COD_RET := 0;
    O_MSG := 'Totales calculados';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al calcular: ' || SQLERRM;
END;

--------------------------------------------------
-- CERRAR NOMINA
--------------------------------------------------
PROCEDURE PR_NOM_CERRAR(
    P_ID      IN NUMBER,
    O_COD_RET OUT NUMBER,
    O_MSG     OUT VARCHAR2
) AS
BEGIN
    -- Calcular antes de cerrar
    PR_NOM_CALCULAR_TOTALES(P_ID, O_COD_RET, O_MSG);
    IF O_COD_RET <> 0 THEN
        RETURN;
    END IF;

    UPDATE MUE_NOMINA
    SET NOM_Estado = 1,
        NOM_Fecha_Pago = SYSDATE
    WHERE NOM_Nomina = P_ID
    AND NOM_Estado = 0;

    IF SQL%ROWCOUNT = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'No existe o ya cerrada';
        RETURN;
    END IF;

    O_COD_RET := 0;
    O_MSG := 'Nómina cerrada correctamente';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al cerrar nómina: ' || SQLERRM;
END;

-----------------------------------------
-- INSERTAR DETALLE NOMINA
-----------------------------------------
PROCEDURE PR_DNM_INSERTAR(
    P_NOMINA        IN NUMBER,
    P_CONCEPTO      IN NUMBER,
    P_VALOR         IN NUMBER,
    P_OBSERVACION   IN VARCHAR2,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
) AS
    V_EXISTE NUMBER;
BEGIN
    -- Validar nómina
    SELECT COUNT(*) INTO V_EXISTE
    FROM MUE_NOMINA
    WHERE NOM_Nomina = P_NOMINA
    AND NOM_Estado = 0;

    IF V_EXISTE = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'Nómina no existe o está cerrada';
        RETURN;
    END IF;

    -- Validar concepto
    SELECT COUNT(*) INTO V_EXISTE
    FROM MUE_CONCEPTO_PAGO
    WHERE CPA_Concepto_Pago = P_CONCEPTO;

    IF V_EXISTE = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'Concepto no existe';
        RETURN;
    END IF;

    INSERT INTO MUE_DETALLE_NOMINA (
        NOM_Nomina,
        CPA_Concepto_Pago,
        DNM_Valor,
        DNM_Observaciones,
        DNM_Created_At
    ) VALUES (
        P_NOMINA,
        P_CONCEPTO,
        NVL(P_VALOR,0),
        P_OBSERVACION,
        SYSTIMESTAMP
    );

    -- Recalcular totales
    PR_NOM_CALCULAR_TOTALES(P_NOMINA, O_COD_RET, O_MSG);
    IF O_COD_RET <> 0 THEN
        RETURN;
    END IF;

    O_COD_RET := 0;
    O_MSG := 'Detalle agregado correctamente';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al insertar detalle: ' || SQLERRM;
END;

--------------------------------------------------

PROCEDURE PR_DNM_LISTAR(
    P_NOMINA   IN NUMBER,
    O_DATA     OUT SYS_REFCURSOR,
    O_COD_RET  OUT NUMBER,
    O_MSG      OUT VARCHAR2
) AS
BEGIN
    OPEN O_DATA FOR
        SELECT 
            D.DNM_Detalle_Nomina,
            D.NOM_Nomina,
            D.CPA_Concepto_Pago,
            C.CPA_Nombre,
            C.CPA_Tipo,
            D.DNM_Valor,
            D.DNM_Observaciones
        FROM MUE_DETALLE_NOMINA D
        JOIN MUE_CONCEPTO_PAGO C 
            ON C.CPA_Concepto_Pago = D.CPA_Concepto_Pago
        WHERE D.NOM_Nomina = P_NOMINA
        ORDER BY D.DNM_Detalle_Nomina DESC;

    O_COD_RET := 0;
    O_MSG := 'OK';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al listar: ' || SQLERRM;
END;

--------------------------------------------------

PROCEDURE PR_DNM_OBTENER(
    P_ID      IN NUMBER,
    O_DATA    OUT SYS_REFCURSOR,
    O_COD_RET OUT NUMBER,
    O_MSG     OUT VARCHAR2
) AS
BEGIN
    OPEN O_DATA FOR
        SELECT DNM_Detalle_Nomina,
               NOM_Nomina,
               CPA_Concepto_Pago,
               DNM_Valor,
               DNM_Observaciones,
               DNM_Created_At
          FROM MUE_DETALLE_NOMINA
         WHERE DNM_Detalle_Nomina = P_ID;

    O_COD_RET := 0;
    O_MSG := 'OK';

EXCEPTION
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al obtener: ' || SQLERRM;
END;

--------------------------------------------------

PROCEDURE PR_DNM_ACTUALIZAR(
    P_ID          IN NUMBER,
    P_VALOR       IN NUMBER,
    P_OBSERVACION IN VARCHAR2,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
) AS
    V_NOMINA NUMBER;
BEGIN
    -- Obtener nómina padre
    SELECT NOM_Nomina
    INTO V_NOMINA
    FROM MUE_DETALLE_NOMINA
    WHERE DNM_Detalle_Nomina = P_ID;

    -- Validar que esté abierta
    UPDATE MUE_DETALLE_NOMINA D
    SET DNM_Valor = NVL(P_VALOR,0),
        DNM_Observaciones = P_OBSERVACION
    WHERE DNM_Detalle_Nomina = P_ID
    AND EXISTS (
        SELECT 1 FROM MUE_NOMINA N
        WHERE N.NOM_Nomina = D.NOM_Nomina
        AND N.NOM_Estado = 0
    );

    IF SQL%ROWCOUNT = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'No existe o nómina cerrada';
        RETURN;
    END IF;

    -- Recalcular totales
    PR_NOM_CALCULAR_TOTALES(V_NOMINA, O_COD_RET, O_MSG);
    IF O_COD_RET <> 0 THEN
        RETURN;
    END IF;

    O_COD_RET := 0;
    O_MSG := 'Detalle actualizado';

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        O_COD_RET := 1;
        O_MSG := 'Detalle no encontrado';
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al actualizar: ' || SQLERRM;
END;

--------------------------------------------------

PROCEDURE PR_DNM_ELIMINAR(
    P_ID      IN NUMBER,
    O_COD_RET OUT NUMBER,
    O_MSG     OUT VARCHAR2
) AS
    V_NOMINA NUMBER;
BEGIN
    -- Obtener nómina padre
    SELECT NOM_Nomina
    INTO V_NOMINA
    FROM MUE_DETALLE_NOMINA
    WHERE DNM_Detalle_Nomina = P_ID;

    DELETE FROM MUE_DETALLE_NOMINA D
    WHERE DNM_Detalle_Nomina = P_ID
    AND EXISTS (
        SELECT 1 FROM MUE_NOMINA N
        WHERE N.NOM_Nomina = D.NOM_Nomina
        AND N.NOM_Estado = 0
    );

    IF SQL%ROWCOUNT = 0 THEN
        O_COD_RET := 1;
        O_MSG := 'No existe o nómina cerrada';
        RETURN;
    END IF;

    -- Recalcular totales
    PR_NOM_CALCULAR_TOTALES(V_NOMINA, O_COD_RET, O_MSG);
    IF O_COD_RET <> 0 THEN
        RETURN;
    END IF;

    O_COD_RET := 0;
    O_MSG := 'Detalle eliminado';

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        O_COD_RET := 1;
        O_MSG := 'Detalle no encontrado';
    WHEN OTHERS THEN
        O_COD_RET := -1;
        O_MSG := 'Error al eliminar: ' || SQLERRM;
END;

END PKG_MUE_G3_COMPRAS_INV_RRHH;
/
