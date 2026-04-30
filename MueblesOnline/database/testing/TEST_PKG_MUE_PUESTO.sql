-- =============================================================================
-- Pruebas manuales — PKG_MUE_PUESTO
-- Ejecutar conectado al mismo esquema donde está compilado el paquete.
-- SQL Developer: habilitar View → Dbms Output y asociar la conexión.
-- SQL*Plus / SQLcl: SET SERVEROUTPUT ON SIZE UNLIMITED
-- =============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED

PROMPT === 1) Insertar puesto de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_PUESTO.PR_PUESTO_INSERTAR(
    P_PUE_TITULO      => 'Analista QA',
    P_PUE_DESCRIPCION => 'Responsable de pruebas de calidad',
    O_PUE_PUESTO      => V_ID,
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG || ' ID=' || V_ID);
  IF V_RET <> 0 OR V_ID IS NULL THEN
    RAISE_APPLICATION_ERROR(-20001, 'Fallo insertar: ' || V_MSG);
  END IF;
END;
/

PROMPT === 2) Obtener puesto insertado ===
DECLARE
  V_ID   NUMBER;
  V_TIT  VARCHAR2(50);
  V_DESC VARCHAR2(200);
  V_CAT  TIMESTAMP(6);
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
BEGIN
  SELECT MAX(PUE_Puesto) INTO V_ID FROM MUE_PUESTO WHERE PUE_Titulo = 'Analista QA';

  PKG_MUE_PUESTO.PR_PUESTO_OBTENER(
    P_PUE_PUESTO      => V_ID,
    O_PUE_TITULO      => V_TIT,
    O_PUE_DESCRIPCION => V_DESC,
    O_PUE_CREATED_AT  => V_CAT,
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' TITULO=' || V_TIT || ' DESC=' || V_DESC);
END;
/

PROMPT === 3) Listar con filtro ===
DECLARE
  V_CUR  SYS_REFCURSOR;
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
  V_PID  NUMBER;
  V_TIT  VARCHAR2(50);
  V_DESC VARCHAR2(200);
  V_CAT  TIMESTAMP(6);
BEGIN
  PKG_MUE_PUESTO.PR_PUESTO_LISTAR(
    P_FILTRO_TITULO => 'Analista',
    O_CURSOR        => V_CUR,
    O_COD_RET       => V_RET,
    O_MSG           => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('LISTAR RET=' || V_RET || ' ' || V_MSG);
  LOOP
    FETCH V_CUR INTO V_PID, V_TIT, V_DESC, V_CAT;
    EXIT WHEN V_CUR%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('  Fila: ID=' || V_PID || ' ' || V_TIT);
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
  SELECT MAX(PUE_Puesto) INTO V_ID FROM MUE_PUESTO WHERE PUE_Titulo = 'Analista QA';

  PKG_MUE_PUESTO.PR_PUESTO_ACTUALIZAR(
    P_PUE_PUESTO      => V_ID,
    P_PUE_TITULO      => 'Analista QA (mod)',
    P_PUE_DESCRIPCION => 'Descripción actualizada del puesto',
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('UPDATE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === 5) Verificación directa (solo testing; no usar en app) ===
SELECT PUE_Puesto, PUE_Titulo, PUE_Descripcion
  FROM MUE_PUESTO
 WHERE PUE_Titulo LIKE 'Analista QA%'
 ORDER BY PUE_Puesto;

PROMPT === 6) Caso negativo: título vacío ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_PUESTO.PR_PUESTO_INSERTAR(
    P_PUE_TITULO      => '   ',
    P_PUE_DESCRIPCION => NULL,
    O_PUE_PUESTO      => V_ID,
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('Esperado RET<>0: RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 7) Eliminar puesto de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(PUE_Puesto) INTO V_ID FROM MUE_PUESTO WHERE PUE_Titulo LIKE 'Analista QA%';

  PKG_MUE_PUESTO.PR_PUESTO_ELIMINAR(
    P_PUE_PUESTO => V_ID,
    O_COD_RET    => V_RET,
    O_MSG        => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('DELETE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === Fin. Conteo restante con nombre de prueba (debe ser 0) ===
SELECT COUNT(1) AS CANT FROM MUE_PUESTO WHERE PUE_Titulo LIKE 'Analista QA%';