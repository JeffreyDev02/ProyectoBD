CREATE OR REPLACE PACKAGE PKG_MUE_G3_COMPRAS_INV_RRHH AS

    -- 1. PROCEDIMIENTOS DE TURNOS
    PROCEDURE PR_TURNO_INSERTAR(
        "$P_HORA_ENTRADA" IN TIMESTAMP, 
        "$P_HORA_SALIDA"  IN TIMESTAMP, 
        "$P_DESCRIPCION"  IN VARCHAR2, 
        O_COD_RET         OUT NUMBER, 
        O_MSG             OUT VARCHAR2
    );

    PROCEDURE PR_TURNO_LISTAR(
        O_DATA    OUT SYS_REFCURSOR, 
        O_COD_RET OUT NUMBER, 
        O_MSG     OUT VARCHAR2
    );

    PROCEDURE PR_TURNO_ACTUALIZAR(
        "$P_ID"           IN NUMBER, 
        "$P_HORA_ENTRADA" IN TIMESTAMP, 
        "$P_HORA_SALIDA"  IN TIMESTAMP, 
        "$P_DESCRIPCION"  IN VARCHAR2, 
        O_COD_RET         OUT NUMBER, 
        O_MSG             OUT VARCHAR2
    );

    PROCEDURE PR_TURNO_ELIMINAR(
        "$P_ID"   IN NUMBER, 
        O_COD_RET OUT NUMBER, 
        O_MSG     OUT VARCHAR2
    );

    -- 2. PROCEDIMIENTOS DE CONCEPTOS DE PAGO (NUEVOS)
    PROCEDURE PR_CONCEPTO_INSERTAR(
        "$P_CODIGO"      IN VARCHAR2, 
        "$P_NOMBRE"      IN VARCHAR2, 
        "$P_TIPO"        IN NUMBER, 
        "$P_DESCRIPCION" IN VARCHAR2, 
        O_COD_RET        OUT NUMBER, 
        O_MSG            OUT VARCHAR2
    );

    PROCEDURE PR_CONCEPTO_LISTAR(
        O_DATA    OUT SYS_REFCURSOR, 
        O_COD_RET OUT NUMBER, 
        O_MSG     OUT VARCHAR2
    );
    
    PROCEDURE PR_CONCEPTO_ACTUALIZAR(
    "$P_ID"          IN NUMBER,
    "$P_CODIGO"      IN VARCHAR2, 
    "$P_NOMBRE"      IN VARCHAR2, 
    "$P_TIPO"        IN NUMBER, 
    "$P_DESCRIPCION" IN VARCHAR2, 
    O_COD_RET        OUT NUMBER, 
    O_MSG            OUT VARCHAR2
    
    );
    
    PROCEDURE PR_CONCEPTO_ELIMINAR(
    "$P_ID"   IN NUMBER,
    O_COD_RET OUT NUMBER,
    O_MSG     OUT VARCHAR2
    );

END PKG_MUE_G3_COMPRAS_INV_RRHH;
/

CREATE OR REPLACE PACKAGE BODY PKG_MUE_G3_COMPRAS_INV_RRHH AS
-----------------------------------------
    -- PROCEDIMIENTOS DE TURNOS
-----------------------------------------
    -- IMPLEMENTACIÓN: INSERTAR
    PROCEDURE PR_TURNO_INSERTAR(
        "$P_HORA_ENTRADA" IN  TIMESTAMP,
        "$P_HORA_SALIDA"  IN  TIMESTAMP,
        "$P_DESCRIPCION"  IN  VARCHAR2,
        O_COD_RET         OUT NUMBER,
        O_MSG             OUT VARCHAR2
    ) AS
    BEGIN
        INSERT INTO MUE_TURNO (
            TUR_Hora_Entrada, 
            TUR_Hora_Salida, 
            TUR_Descripcion, 
            TUR_Created_At
        ) 
        VALUES (
            "$P_HORA_ENTRADA", 
            "$P_HORA_SALIDA", 
            "$P_DESCRIPCION", 
            SYSTIMESTAMP
        );
        
        O_COD_RET := 0;
        O_MSG := 'Turno registrado exitosamente.';
    EXCEPTION
        WHEN OTHERS THEN
            O_COD_RET := -1;
            O_MSG := 'Error al insertar turno: ' || SQLERRM;
    END PR_TURNO_INSERTAR;

    -- IMPLEMENTACIÓN: LISTAR
    PROCEDURE PR_TURNO_LISTAR(
        O_DATA            OUT SYS_REFCURSOR,
        O_COD_RET         OUT NUMBER,
        O_MSG             OUT VARCHAR2
    ) AS
    BEGIN
        OPEN O_DATA FOR 
            SELECT TUR_Turno, TUR_Hora_Entrada, TUR_Hora_Salida, TUR_Descripcion 
            FROM MUE_TURNO;
        
        O_COD_RET := 0;
        O_MSG := 'Listado generado correctamente.';
    EXCEPTION
        WHEN OTHERS THEN
            O_COD_RET := -1;
            O_MSG := 'Error al consultar: ' || SQLERRM;
    END PR_TURNO_LISTAR;

    -- IMPLEMENTACIÓN: ACTUALIZAR
    PROCEDURE PR_TURNO_ACTUALIZAR(
        "$P_ID"           IN  NUMBER,
        "$P_HORA_ENTRADA" IN  TIMESTAMP,
        "$P_HORA_SALIDA"  IN  TIMESTAMP,
        "$P_DESCRIPCION"  IN  VARCHAR2,
        O_COD_RET         OUT NUMBER,
        O_MSG             OUT VARCHAR2
    ) AS
    BEGIN
        UPDATE MUE_TURNO 
        SET TUR_Hora_Entrada = "$P_HORA_ENTRADA",
            TUR_Hora_Salida  = "$P_HORA_SALIDA",
            TUR_Descripcion  = "$P_DESCRIPCION"
        WHERE TUR_Turno = "$P_ID";
        
        O_COD_RET := 0;
        O_MSG := 'Turno actualizado correctamente.';
    EXCEPTION
        WHEN OTHERS THEN
            O_COD_RET := -1;
            O_MSG := 'Error al actualizar: ' || SQLERRM;
    END PR_TURNO_ACTUALIZAR;

    -- IMPLEMENTACIÓN: ELIMINAR
    PROCEDURE PR_TURNO_ELIMINAR(
        "$P_ID"           IN  NUMBER,
        O_COD_RET         OUT NUMBER,
        O_MSG             OUT VARCHAR2
    ) AS
    BEGIN
        DELETE FROM MUE_TURNO 
        WHERE TUR_Turno = "$P_ID";
        
        O_COD_RET := 0;
        O_MSG := 'Turno eliminado correctamente.';
    EXCEPTION
        WHEN OTHERS THEN
            O_COD_RET := -1;
            O_MSG := 'Error al eliminar: ' || SQLERRM;
    END PR_TURNO_ELIMINAR;
    
-----------------------------------------
    -- PROCEDIMIENTOS DE CONCEPTOS DE PAGOS
-----------------------------------------
    PROCEDURE PR_CONCEPTO_INSERTAR(
        "$P_CODIGO"      IN  VARCHAR2,
        "$P_NOMBRE"      IN  VARCHAR2,
        "$P_TIPO"        IN  NUMBER,
        "$P_DESCRIPCION" IN  VARCHAR2,
        O_COD_RET        OUT NUMBER,
        O_MSG            OUT VARCHAR2
    ) IS
    BEGIN
        INSERT INTO MUE_CONCEPTO_PAGO (CPA_Codigo, CPA_Nombre, CPA_Tipo, CPA_Descripcion, CPA_Created_At)
        VALUES ("$P_CODIGO", "$P_NOMBRE", "$P_TIPO", "$P_DESCRIPCION", SYSTIMESTAMP);
        
        O_COD_RET := 0;
        O_MSG := 'Concepto registrado con éxito';
        COMMIT;
    EXCEPTION WHEN OTHERS THEN
        O_COD_RET := 1;
        O_MSG := 'Error: ' || SQLERRM;
        ROLLBACK;
    END;

    PROCEDURE PR_CONCEPTO_LISTAR(O_DATA OUT SYS_REFCURSOR, O_COD_RET OUT NUMBER, O_MSG OUT VARCHAR2) IS
    BEGIN
        OPEN O_DATA FOR SELECT * FROM MUE_CONCEPTO_PAGO ORDER BY CPA_Concepto_Pago DESC;
        O_COD_RET := 0;
        O_MSG := 'OK';
    END;
    
    PROCEDURE PR_CONCEPTO_ACTUALIZAR(
    "$P_ID"          IN NUMBER,
    "$P_CODIGO"      IN VARCHAR2, 
    "$P_NOMBRE"      IN VARCHAR2, 
    "$P_TIPO"        IN NUMBER, 
    "$P_DESCRIPCION" IN VARCHAR2, 
    O_COD_RET        OUT NUMBER, 
    O_MSG            OUT VARCHAR2
    ) IS
    BEGIN
        UPDATE MUE_CONCEPTO_PAGO
        SET CPA_Codigo      = "$P_CODIGO",
            CPA_Nombre      = "$P_NOMBRE",
            CPA_Tipo        = "$P_TIPO",
            CPA_Descripcion = "$P_DESCRIPCION"
        WHERE CPA_Concepto_Pago = "$P_ID";
    
        O_COD_RET := 0;
        O_MSG := 'Concepto actualizado correctamente';
        COMMIT;
    
    EXCEPTION
        WHEN OTHERS THEN
            O_COD_RET := -1;
            O_MSG := 'Error al actualizar: ' || SQLERRM;
            ROLLBACK;
    END;
    
    PROCEDURE PR_CONCEPTO_ELIMINAR(
        "$P_ID"   IN NUMBER,
        O_COD_RET OUT NUMBER,
        O_MSG     OUT VARCHAR2
    ) IS
    BEGIN
        DELETE FROM MUE_CONCEPTO_PAGO
        WHERE CPA_Concepto_Pago = "$P_ID";
    
        O_COD_RET := 0;
        O_MSG := 'Concepto eliminado correctamente';
        COMMIT;
    
    EXCEPTION
        WHEN OTHERS THEN
            O_COD_RET := -1;
            O_MSG := 'Error al eliminar: ' || SQLERRM;
            ROLLBACK;
    END;

END PKG_MUE_G3_COMPRAS_INV_RRHH;
/


/*****************************************************************************/

    