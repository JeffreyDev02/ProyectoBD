-- =============================================================================
-- Pruebas manuales — PKG_MUE_TIPO_EVENTO
-- Ejecutar conectado al mismo esquema donde está compilado el paquete.
-- SQL Developer: habilitar View → Dbms Output y asociar la conexión.
-- SQL*Plus / SQLcl: SET SERVEROUTPUT ON SIZE UNLIMITED
-- =============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED

PROMPT === 1) Insertar tipo de evento de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_TIPO_EVENTO.PR_TIPO_EVENTO_INSERTAR(
    P_TEV_TIPO    => 'LOGIN QA',
    O_TEV_TIPO_EV => V_ID,
    O_COD_RET     => V_RET,
    O_MSG         => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG || ' ID=' || V_ID);
  IF V_RET <> 0 OR V_ID IS NULL THEN
    RAISE_APPLICATION_ERROR(-20001, 'Fallo insertar: ' || V_MSG);
  END IF;
END;
/

PROMPT === 2) Obtener tipo de evento insertado ===
DECLARE
  V_ID   NUMBER;
  V_TIPO VARCHAR2(60);
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
BEGIN
  SELECT MAX(TEV_Tipo_Evento) INTO V_ID FROM MUE_TIPO_EVENTO WHERE TEV_Tipo = 'LOGIN QA';

  PKG_MUE_TIPO_EVENTO.PR_TIPO_EVENTO_OBTENER(
    P_TEV_TIPO_EV => V_ID,
    O_TEV_TIPO    => V_TIPO,
    O_COD_RET     => V_RET,
    O_MSG         => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' TIPO=' || V_TIPO);
END;
/

PROMPT === 3) Listar con filtro ===
DECLARE
  V_CUR  SYS_REFCURSOR;
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
  V_TID  NUMBER;
  V_TIPO VARCHAR2(60);
BEGIN
  PKG_MUE_TIPO_EVENTO.PR_TIPO_EVENTO_LISTAR(
    P_FILTRO_TIPO => 'LOGIN',
    O_CURSOR      => V_CUR,
    O_COD_RET     => V_RET,
    O_MSG         => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('LISTAR RET=' || V_RET || ' ' || V_MSG);
  LOOP
    FETCH V_CUR INTO V_TID, V_TIPO;
    EXIT WHEN V_CUR%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('  Fila: ID=' || V_TID || ' ' || V_TIPO);
  END LOOP;
  CLOSE V_CUR;
END;
/

PROMPT === 4) Actualizar ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(TEV_Tipo_Evento) INTO V_ID FROM MUE_TIPO_EVENTO WHERE TEV_Tipo = 'LOGIN QA';

  PKG_MUE_TIPO_EVENTO.PR_TIPO_EVENTO_ACTUALIZAR(
    P_TEV_TIPO_EV => V_ID,
    P_TEV_TIPO    => 'LOGIN QA (mod)',
    O_COD_RET     => V_RET,
    O_MSG         => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('UPDATE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === 5) Verificación directa (solo testing; no usar en app) ===
SELECT TEV_Tipo_Evento, TEV_Tipo
  FROM MUE_TIPO_EVENTO
 WHERE TEV_Tipo LIKE 'LOGIN QA%'
 ORDER BY TEV_Tipo_Evento;

PROMPT === 6) Caso negativo: tipo vacío ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_TIPO_EVENTO.PR_TIPO_EVENTO_INSERTAR(
    P_TEV_TIPO    => '   ',
    O_TEV_TIPO_EV => V_ID,
    O_COD_RET     => V_RET,
    O_MSG         => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('Esperado RET<>0: RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 7) Eliminar tipo de evento de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(TEV_Tipo_Evento) INTO V_ID FROM MUE_TIPO_EVENTO WHERE TEV_Tipo LIKE 'LOGIN QA%';

  PKG_MUE_TIPO_EVENTO.PR_TIPO_EVENTO_ELIMINAR(
    P_TEV_TIPO_EV => V_ID,
    O_COD_RET     => V_RET,
    O_MSG         => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('DELETE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === Fin. Conteo restante con nombre de prueba (debe ser 0) ===
SELECT COUNT(1) AS CANT FROM MUE_TIPO_EVENTO WHERE TEV_Tipo LIKE 'LOGIN QA%';