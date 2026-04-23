-- =============================================================================
-- Paquete PL/SQL (Oracle 21c)
-- Entidad  : MUE_TIPO_EVENTO
-- Propósito: CRUD de tipos de evento de aplicación.
-- Ejecutar conectado al esquema MUEBLERIA.
-- =============================================================================

CREATE OR REPLACE PACKAGE PKG_MUE_TIPO_EVENTO AS
  /**
   * Catálogo de tipos de evento — operaciones CRUD y listado.
   * Convención de retorno: O_COD_RET = 0 éxito; distinto de 0 error controlado.
   */

  PROCEDURE PR_TIPO_EVENTO_INSERTAR (
    P_TEV_TIPO    IN  VARCHAR2,
    O_TEV_TIPO_EV OUT NUMBER,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  );

  PROCEDURE PR_TIPO_EVENTO_ACTUALIZAR (
    P_TEV_TIPO_EV IN  NUMBER,
    P_TEV_TIPO    IN  VARCHAR2,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  );

  PROCEDURE PR_TIPO_EVENTO_ELIMINAR (
    P_TEV_TIPO_EV IN  NUMBER,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  );

  PROCEDURE PR_TIPO_EVENTO_OBTENER (
    P_TEV_TIPO_EV IN  NUMBER,
    O_TEV_TIPO    OUT VARCHAR2,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  );

  PROCEDURE PR_TIPO_EVENTO_LISTAR (
    P_FILTRO_TIPO IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR      OUT SYS_REFCURSOR,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  );

END PKG_MUE_TIPO_EVENTO;
/

CREATE OR REPLACE PACKAGE BODY PKG_MUE_TIPO_EVENTO AS

  C_OK    CONSTANT NUMBER := 0;
  C_ERR   CONSTANT NUMBER := 1;
  C_NOFND CONSTANT NUMBER := 2;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_TIPO_EVENTO_INSERTAR (
    P_TEV_TIPO    IN  VARCHAR2,
    O_TEV_TIPO_EV OUT NUMBER,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET     := C_ERR;
    O_MSG         := NULL;
    O_TEV_TIPO_EV := NULL;

    IF TRIM(P_TEV_TIPO) IS NULL THEN
      O_MSG := 'El tipo de evento es obligatorio.';
      RETURN;
    END IF;

    INSERT INTO MUE_TIPO_EVENTO (
      TEV_Tipo
    ) VALUES (
      P_TEV_TIPO
    )
    RETURNING TEV_Tipo_Evento INTO O_TEV_TIPO_EV;

    O_COD_RET := C_OK;
    O_MSG     := 'Tipo de evento registrado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET     := C_ERR;
      O_MSG         := 'Error al insertar tipo de evento: ' || SQLERRM;
      O_TEV_TIPO_EV := NULL;
  END PR_TIPO_EVENTO_INSERTAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_TIPO_EVENTO_ACTUALIZAR (
    P_TEV_TIPO_EV IN  NUMBER,
    P_TEV_TIPO    IN  VARCHAR2,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  ) IS
    V_N NUMBER;
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_TEV_TIPO_EV IS NULL THEN
      O_MSG := 'Identificador de tipo de evento inválido.';
      RETURN;
    END IF;

    SELECT COUNT(1) INTO V_N FROM MUE_TIPO_EVENTO WHERE TEV_Tipo_Evento = P_TEV_TIPO_EV;
    IF V_N = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El tipo de evento no existe.';
      RETURN;
    END IF;

    UPDATE MUE_TIPO_EVENTO
       SET TEV_Tipo = P_TEV_TIPO
     WHERE TEV_Tipo_Evento = P_TEV_TIPO_EV;

    O_COD_RET := C_OK;
    O_MSG     := 'Tipo de evento actualizado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al actualizar tipo de evento: ' || SQLERRM;
  END PR_TIPO_EVENTO_ACTUALIZAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_TIPO_EVENTO_ELIMINAR (
    P_TEV_TIPO_EV IN  NUMBER,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_TEV_TIPO_EV IS NULL THEN
      O_MSG := 'Identificador de tipo de evento inválido.';
      RETURN;
    END IF;

    DELETE FROM MUE_TIPO_EVENTO WHERE TEV_Tipo_Evento = P_TEV_TIPO_EV;

    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El tipo de evento no existe.';
      RETURN;
    END IF;

    O_COD_RET := C_OK;
    O_MSG     := 'Tipo de evento eliminado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      -- Ej.: ORA-02292 si MUE_EVENTO_APLICACION referencia este tipo
      O_COD_RET := C_ERR;
      O_MSG     := 'No se puede eliminar el tipo de evento (puede estar referenciado): ' || SQLERRM;
  END PR_TIPO_EVENTO_ELIMINAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_TIPO_EVENTO_OBTENER (
    P_TEV_TIPO_EV IN  NUMBER,
    O_TEV_TIPO    OUT VARCHAR2,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET  := C_ERR;
    O_MSG      := NULL;
    O_TEV_TIPO := NULL;

    IF P_TEV_TIPO_EV IS NULL THEN
      O_MSG := 'Identificador de tipo de evento inválido.';
      RETURN;
    END IF;

    SELECT T.TEV_Tipo
      INTO O_TEV_TIPO
      FROM MUE_TIPO_EVENTO T
     WHERE T.TEV_Tipo_Evento = P_TEV_TIPO_EV;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El tipo de evento no existe.';
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al consultar tipo de evento: ' || SQLERRM;
  END PR_TIPO_EVENTO_OBTENER;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_TIPO_EVENTO_LISTAR (
    P_FILTRO_TIPO IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR      OUT SYS_REFCURSOR,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    OPEN O_CURSOR FOR
      SELECT T.TEV_Tipo_Evento AS Tipo_Evento_Id,
             T.TEV_Tipo        AS Tipo
        FROM MUE_TIPO_EVENTO T
       WHERE P_FILTRO_TIPO IS NULL
          OR UPPER(T.TEV_Tipo) LIKE '%' || UPPER(TRIM(P_FILTRO_TIPO)) || '%'
       ORDER BY T.TEV_Tipo ASC;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al listar tipos de evento: ' || SQLERRM;
  END PR_TIPO_EVENTO_LISTAR;

END PKG_MUE_TIPO_EVENTO;
/

-- GRANT EXECUTE ON PKG_MUE_TIPO_EVENTO TO USR_APP_MUEBLERIA;