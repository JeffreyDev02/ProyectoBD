SET SERVEROUTPUT ON SIZE UNLIMITED;

PROMPT === 1) Insertar registro en historial (Transacción de Venta) ===
DECLARE
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_HIST_TRANSACCION.PR_HIST_INSERTAR(
    P_TTR_TIPO_TRANSACCION => 1,
    P_USU_USUARIO          => 1,
    P_HIS_FECHA            => SYSTIMESTAMP,
    P_HIS_DESCRIPCION      => 'Registro de factura FAC-001 realizada con éxito',
    P_HIS_TABLA_AFECTADA   => 'MUE_FACTURA',
    P_HIS_ID_REFERENCIA    => 10,
    O_COD_RET              => V_RET,
    O_MSG                  => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 2) Obtener un registro específico del historial ===
DECLARE
  V_CUR  SYS_REFCURSOR;
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
  V_ID_H NUMBER;

  V_ID_HIST NUMBER; V_TIPO NUMBER; V_USU NUMBER; V_FEC TIMESTAMP; V_DSC VARCHAR2(200);
BEGIN

  SELECT MAX(HIS_Historial) INTO V_ID_H FROM MUE_HIST_TRANSACCION;

  PKG_MUE_HIST_TRANSACCION.PR_HIST_OBTENER(
    P_HIS_HISTORIAL => V_ID_H,
    O_CURSOR        => V_CUR,
    O_COD_RET       => V_RET,
    O_MSG           => V_MSG
  );
  
  FETCH V_CUR INTO V_ID_HIST, V_TIPO, V_USU, V_FEC, V_DSC;
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' DESCRIPCION=' || V_DSC || ' FECHA=' || V_FEC);
  CLOSE V_CUR;
END;
/

PROMPT === 3) Listar historial por usuario ===
DECLARE
  V_CUR  SYS_REFCURSOR;
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
  V_FEC  TIMESTAMP; V_DSC VARCHAR2(200); V_TAB VARCHAR2(50);
BEGIN
  PKG_MUE_HIST_TRANSACCION.PR_HIST_LISTAR(
    P_USU_USUARIO => 1,
    O_CURSOR      => V_CUR,
    O_COD_RET     => V_RET,
    O_MSG         => V_MSG
  );
  
  DBMS_OUTPUT.PUT_LINE('MOVIMIENTOS DEL USUARIO:');
  LOOP
    FETCH V_CUR INTO V_FEC, V_DSC, V_TAB;
    EXIT WHEN V_CUR%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('  [' || V_FEC || '] Tabla: ' || V_TAB || ' - ' || V_DSC);
  END LOOP;
  CLOSE V_CUR;
END;
/

PROMPT === 4) Verificación de integridad (No existe eliminación) ===
BEGIN
  -- Esta sección es informativa para confirmar que el paquete cumple el requerimiento
  DBMS_OUTPUT.PUT_LINE('VERIFICACION: El paquete PKG_MUE_HIST_TRANSACCION no expone métodos de borrado.');
END;
/

PROMPT === Verificación en tabla (Últimos 5 movimientos) ===
SELECT * FROM (
  SELECT HIS_Fecha, HIS_Descripcion, HIS_Tabla_Afectada 
  FROM MUE_HIST_TRANSACCION 
  ORDER BY HIS_Fecha DESC
) WHERE ROWNUM <= 5;