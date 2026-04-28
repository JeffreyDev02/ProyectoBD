SET SERVEROUTPUT ON;
DECLARE
    V_COD NUMBER;
    V_MSG VARCHAR2(200);
    V_CURSOR SYS_REFCURSOR;
BEGIN
    -- INSERTAR
    PKG_MUE_G3_COMPRAS_INV_RRHH.PR_TURNO_INSERTAR(
        SYSTIMESTAMP,
        SYSTIMESTAMP + INTERVAL '8' HOUR,
        'Turno prueba',
        V_COD,
        V_MSG
    );
    DBMS_OUTPUT.PUT_LINE('INSERT: ' || V_MSG);

    -- LISTAR
    PKG_MUE_G3_COMPRAS_INV_RRHH.PR_TURNO_LISTAR(
        V_CURSOR,
        V_COD,
        V_MSG
    );
    DBMS_OUTPUT.PUT_LINE('LISTAR: ' || V_MSG);

    -- ACTUALIZAR (ejemplo ID = 1)
    PKG_MUE_G3_COMPRAS_INV_RRHH.PR_TURNO_ACTUALIZAR(
        1,
        SYSTIMESTAMP,
        SYSTIMESTAMP + INTERVAL '6' HOUR,
        'Turno actualizado',
        V_COD,
        V_MSG
    );
    DBMS_OUTPUT.PUT_LINE('UPDATE: ' || V_MSG);

    -- ELIMINAR
    PKG_MUE_G3_COMPRAS_INV_RRHH.PR_TURNO_ELIMINAR(
        1,
        V_COD,
        V_MSG
    );
    DBMS_OUTPUT.PUT_LINE('DELETE: ' || V_MSG);

END;
/


DECLARE
    V_COD NUMBER;
    V_MSG VARCHAR2(200);
    V_CURSOR SYS_REFCURSOR;
BEGIN
    -- INSERTAR
    PKG_MUE_G3_COMPRAS_INV_RRHH.PR_CONCEPTO_INSERTAR(
        'BONO01',
        'Bono productividad',
        1,
        'Pago adicional',
        V_COD,
        V_MSG
    );
    DBMS_OUTPUT.PUT_LINE('INSERT: ' || V_MSG);

    -- LISTAR
    PKG_MUE_G3_COMPRAS_INV_RRHH.PR_CONCEPTO_LISTAR(
        V_CURSOR,
        V_COD,
        V_MSG
    );
    DBMS_OUTPUT.PUT_LINE('LISTAR: ' || V_MSG);

    -- ACTUALIZAR
    PKG_MUE_G3_COMPRAS_INV_RRHH.PR_CONCEPTO_ACTUALIZAR(
        1,
        'BONO01',
        'Bono actualizado',
        1,
        'Editado',
        V_COD,
        V_MSG
    );
    DBMS_OUTPUT.PUT_LINE('UPDATE: ' || V_MSG);

    -- ELIMINAR
    PKG_MUE_G3_COMPRAS_INV_RRHH.PR_CONCEPTO_ELIMINAR(
        1,
        V_COD,
        V_MSG
    );
    DBMS_OUTPUT.PUT_LINE('DELETE: ' || V_MSG);

END;
/

SELECT * FROM MUE_TURNO;
SELECT * FROM MUE_CONCEPTO_PAGO;
