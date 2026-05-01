-- =============================================================================
-- Paquete PL/SQL (Oracle 21c)
-- Entidad   : MUE_TIPO_DOCUMENTO
-- Referencia: Docs/DDL_MUEBLERIA.sql
-- Propósito : CRUD completo para el catálogo de tipos de documento.
-- Ejecutar conectado al esquema MUEBLERIA.
-- =============================================================================

CREATE OR REPLACE PACKAGE PKG_MUE_TIPO_DOCUMENTO AS

  PROCEDURE PR_TIPO_DOC_INSERTAR (
    P_TDC_TIPO     IN  VARCHAR2,
    O_TDC_TIPO_DOC OUT NUMBER,
    O_COD_RET      OUT NUMBER,
    O_MSG          OUT VARCHAR2
  );

  PROCEDURE PR_TIPO_DOC_ACTUALIZAR (
    P_TDC_TIPO_DOCUMENTO IN  NUMBER,
    P_TDC_TIPO           IN  VARCHAR2,
    O_COD_RET            OUT NUMBER,
    O_MSG                OUT VARCHAR2
  );

  PROCEDURE PR_TIPO_DOC_ELIMINAR (
    P_TDC_TIPO_DOCUMENTO IN  NUMBER,
    O_COD_RET            OUT NUMBER,
    O_MSG                OUT VARCHAR2
  );

  PROCEDURE PR_TIPO_DOC_OBTENER (
    P_TDC_TIPO_DOCUMENTO IN  NUMBER,
    O_TDC_TIPO           OUT VARCHAR2,
    O_COD_RET            OUT NUMBER,
    O_MSG                OUT VARCHAR2
  );

  PROCEDURE PR_TIPO_DOC_LISTAR (
    P_FILTRO_TIPO IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR      OUT SYS_REFCURSOR,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  );

END PKG_MUE_TIPO_DOCUMENTO;
/

CREATE OR REPLACE PACKAGE BODY PKG_MUE_TIPO_DOCUMENTO AS

  C_OK    CONSTANT NUMBER := 0;
  C_ERR   CONSTANT NUMBER := 1;
  C_NOFND CONSTANT NUMBER := 2;

  PROCEDURE PR_TIPO_DOC_INSERTAR (
    P_TDC_TIPO     IN  VARCHAR2,
    O_TDC_TIPO_DOC OUT NUMBER,
    O_COD_RET      OUT NUMBER,
    O_MSG          OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET      := C_ERR;
    O_MSG          := NULL;
    O_TDC_TIPO_DOC := NULL;

    IF TRIM(P_TDC_TIPO) IS NULL THEN
      O_MSG := 'El tipo de documento es obligatorio.';
      RETURN;
    END IF;

    INSERT INTO MUE_TIPO_DOCUMENTO (TDC_Tipo)
    VALUES (TRIM(P_TDC_TIPO))
    RETURNING TDC_Tipo_Documento INTO O_TDC_TIPO_DOC;

    O_COD_RET := C_OK;
    O_MSG     := 'Tipo de documento registrado correctamente.';
  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET      := C_ERR;
      O_MSG          := 'Error al insertar tipo de documento: ' || SQLERRM;
      O_TDC_TIPO_DOC := NULL;
  END PR_TIPO_DOC_INSERTAR;

  PROCEDURE PR_TIPO_DOC_ACTUALIZAR (
    P_TDC_TIPO_DOCUMENTO IN  NUMBER,
    P_TDC_TIPO           IN  VARCHAR2,
    O_COD_RET            OUT NUMBER,
    O_MSG                OUT VARCHAR2
  ) IS
    V_N NUMBER;
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_TDC_TIPO_DOCUMENTO IS NULL THEN
      O_MSG := 'Identificador de tipo de documento inválido.';
      RETURN;
    END IF;

    IF TRIM(P_TDC_TIPO) IS NULL THEN
      O_MSG := 'El tipo de documento es obligatorio.';
      RETURN;
    END IF;

    SELECT COUNT(1) INTO V_N FROM MUE_TIPO_DOCUMENTO WHERE TDC_Tipo_Documento = P_TDC_TIPO_DOCUMENTO;
    IF V_N = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El tipo de documento no existe.';
      RETURN;
    END IF;

    UPDATE MUE_TIPO_DOCUMENTO
       SET TDC_Tipo = TRIM(P_TDC_TIPO)
     WHERE TDC_Tipo_Documento = P_TDC_TIPO_DOCUMENTO;

    O_COD_RET := C_OK;
    O_MSG     := 'Tipo de documento actualizado correctamente.';
  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al actualizar tipo de documento: ' || SQLERRM;
  END PR_TIPO_DOC_ACTUALIZAR;

  PROCEDURE PR_TIPO_DOC_ELIMINAR (
    P_TDC_TIPO_DOCUMENTO IN  NUMBER,
    O_COD_RET            OUT NUMBER,
    O_MSG                OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_TDC_TIPO_DOCUMENTO IS NULL THEN
      O_MSG := 'Identificador de tipo de documento inválido.';
      RETURN;
    END IF;

    DELETE FROM MUE_TIPO_DOCUMENTO WHERE TDC_Tipo_Documento = P_TDC_TIPO_DOCUMENTO;
    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El tipo de documento no existe.';
      RETURN;
    END IF;

    O_COD_RET := C_OK;
    O_MSG     := 'Tipo de documento eliminado correctamente.';
  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'No se puede eliminar el tipo de documento (puede estar referenciado en usuarios): ' || SQLERRM;
  END PR_TIPO_DOC_ELIMINAR;

  PROCEDURE PR_TIPO_DOC_OBTENER (
    P_TDC_TIPO_DOCUMENTO IN  NUMBER,
    O_TDC_TIPO           OUT VARCHAR2,
    O_COD_RET            OUT NUMBER,
    O_MSG                OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET  := C_ERR;
    O_MSG      := NULL;
    O_TDC_TIPO := NULL;

    IF P_TDC_TIPO_DOCUMENTO IS NULL THEN
      O_MSG := 'Identificador de tipo de documento inválido.';
      RETURN;
    END IF;

    SELECT T.TDC_Tipo
      INTO O_TDC_TIPO
      FROM MUE_TIPO_DOCUMENTO T
     WHERE T.TDC_Tipo_Documento = P_TDC_TIPO_DOCUMENTO;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El tipo de documento no existe.';
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al consultar tipo de documento: ' || SQLERRM;
  END PR_TIPO_DOC_OBTENER;

  PROCEDURE PR_TIPO_DOC_LISTAR (
    P_FILTRO_TIPO IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR      OUT SYS_REFCURSOR,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    OPEN O_CURSOR FOR
      SELECT T.TDC_Tipo_Documento AS Tipo_Doc_Id,
             T.TDC_Tipo           AS Tipo
        FROM MUE_TIPO_DOCUMENTO T
       WHERE P_FILTRO_TIPO IS NULL
          OR UPPER(T.TDC_Tipo) LIKE '%' || UPPER(TRIM(P_FILTRO_TIPO)) || '%'
       ORDER BY T.TDC_Tipo ASC;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al listar tipos de documento: ' || SQLERRM;
  END PR_TIPO_DOC_LISTAR;

END PKG_MUE_TIPO_DOCUMENTO;
/

-- GRANT EXECUTE ON PKG_MUE_TIPO_DOCUMENTO TO USR_APP_MUEBLERIA;