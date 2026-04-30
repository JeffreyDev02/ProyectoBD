-- =============================================================================
-- Paquete PL/SQL (Oracle 21c)
-- Entidad   : MUE_AREA
-- Referencia: Docs/DDL_MUEBLERIA.sql
-- Propósito : CRUD completo para el catálogo de áreas funcionales.
-- Ejecutar conectado al esquema MUEBLERIA.
-- =============================================================================

CREATE OR REPLACE PACKAGE PKG_MUE_AREA AS
  /**
   * Catálogo de áreas funcionales — operaciones CRUD y listado.
   * Convención de retorno: O_COD_RET = 0 éxito; distinto de 0 error controlado.
   */

  PROCEDURE PR_AREA_INSERTAR (
    P_ARE_AREA_FUNCIONAL IN VARCHAR2,
    P_ARE_DESCRIPCION    IN VARCHAR2,
    O_ARE_AREA           OUT NUMBER,
    O_COD_RET            OUT NUMBER,
    O_MSG                OUT VARCHAR2
  );

  PROCEDURE PR_AREA_ACTUALIZAR (
    P_ARE_AREA           IN NUMBER,
    P_ARE_AREA_FUNCIONAL IN VARCHAR2,
    P_ARE_DESCRIPCION    IN VARCHAR2,
    O_COD_RET            OUT NUMBER,
    O_MSG                OUT VARCHAR2
  );

  PROCEDURE PR_AREA_ELIMINAR (
    P_ARE_AREA IN NUMBER,
    O_COD_RET  OUT NUMBER,
    O_MSG      OUT VARCHAR2
  );

  PROCEDURE PR_AREA_OBTENER (
    P_ARE_AREA           IN  NUMBER,
    O_ARE_AREA_FUNCIONAL OUT VARCHAR2,
    O_ARE_DESCRIPCION    OUT VARCHAR2,
    O_ARE_CREATED_AT     OUT TIMESTAMP,
    O_COD_RET            OUT NUMBER,
    O_MSG                OUT VARCHAR2
  );

  PROCEDURE PR_AREA_LISTAR (
    P_FILTRO_NOMBRE IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR        OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  );

END PKG_MUE_AREA;
/

CREATE OR REPLACE PACKAGE BODY PKG_MUE_AREA AS

  C_OK    CONSTANT NUMBER := 0;
  C_ERR   CONSTANT NUMBER := 1;
  C_NOFND CONSTANT NUMBER := 2;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_AREA_INSERTAR (
    P_ARE_AREA_FUNCIONAL IN VARCHAR2,
    P_ARE_DESCRIPCION    IN VARCHAR2,
    O_ARE_AREA           OUT NUMBER,
    O_COD_RET            OUT NUMBER,
    O_MSG                OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET  := C_ERR;
    O_MSG      := NULL;
    O_ARE_AREA := NULL;

    IF TRIM(P_ARE_AREA_FUNCIONAL) IS NULL THEN
      O_MSG := 'El nombre del área funcional es obligatorio.';
      RETURN;
    END IF;

    INSERT INTO MUE_AREA (
      ARE_Area_Funcional,
      ARE_Descripcion,
      ARE_Created_At
    ) VALUES (
      TRIM(P_ARE_AREA_FUNCIONAL),
      P_ARE_DESCRIPCION,
      SYSTIMESTAMP
    )
    RETURNING ARE_Area INTO O_ARE_AREA;

    O_COD_RET := C_OK;
    O_MSG     := 'Área registrada correctamente.';

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      O_COD_RET  := C_ERR;
      O_MSG      := 'Ya existe un área con ese nombre.';
      O_ARE_AREA := NULL;
    WHEN OTHERS THEN
      O_COD_RET  := C_ERR;
      O_MSG      := 'Error al insertar área: ' || SQLERRM;
      O_ARE_AREA := NULL;
  END PR_AREA_INSERTAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_AREA_ACTUALIZAR (
    P_ARE_AREA           IN NUMBER,
    P_ARE_AREA_FUNCIONAL IN VARCHAR2,
    P_ARE_DESCRIPCION    IN VARCHAR2,
    O_COD_RET            OUT NUMBER,
    O_MSG                OUT VARCHAR2
  ) IS
    V_N NUMBER;
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_ARE_AREA IS NULL THEN
      O_MSG := 'Identificador de área inválido.';
      RETURN;
    END IF;

    IF TRIM(P_ARE_AREA_FUNCIONAL) IS NULL THEN
      O_MSG := 'El nombre del área funcional es obligatorio.';
      RETURN;
    END IF;

    SELECT COUNT(1) INTO V_N FROM MUE_AREA WHERE ARE_Area = P_ARE_AREA;
    IF V_N = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El área no existe.';
      RETURN;
    END IF;

    UPDATE MUE_AREA
       SET ARE_Area_Funcional = TRIM(P_ARE_AREA_FUNCIONAL),
           ARE_Descripcion    = P_ARE_DESCRIPCION
     WHERE ARE_Area = P_ARE_AREA;

    O_COD_RET := C_OK;
    O_MSG     := 'Área actualizada correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al actualizar área: ' || SQLERRM;
  END PR_AREA_ACTUALIZAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_AREA_ELIMINAR (
    P_ARE_AREA IN NUMBER,
    O_COD_RET  OUT NUMBER,
    O_MSG      OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_ARE_AREA IS NULL THEN
      O_MSG := 'Identificador de área inválido.';
      RETURN;
    END IF;

    DELETE FROM MUE_AREA WHERE ARE_Area = P_ARE_AREA;
    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El área no existe.';
      RETURN;
    END IF;

    O_COD_RET := C_OK;
    O_MSG     := 'Área eliminada correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      -- ORA-02292: registro hijo en MUE_DEPARTAMENTO referencia esta área
      O_COD_RET := C_ERR;
      O_MSG     := 'No se puede eliminar el área (puede estar referenciada por un departamento): ' || SQLERRM;
  END PR_AREA_ELIMINAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_AREA_OBTENER (
    P_ARE_AREA           IN  NUMBER,
    O_ARE_AREA_FUNCIONAL OUT VARCHAR2,
    O_ARE_DESCRIPCION    OUT VARCHAR2,
    O_ARE_CREATED_AT     OUT TIMESTAMP,
    O_COD_RET            OUT NUMBER,
    O_MSG                OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET            := C_ERR;
    O_MSG                := NULL;
    O_ARE_AREA_FUNCIONAL := NULL;
    O_ARE_DESCRIPCION    := NULL;
    O_ARE_CREATED_AT     := NULL;

    IF P_ARE_AREA IS NULL THEN
      O_MSG := 'Identificador de área inválido.';
      RETURN;
    END IF;

    SELECT A.ARE_Area_Funcional,
           A.ARE_Descripcion,
           A.ARE_Created_At
      INTO O_ARE_AREA_FUNCIONAL,
           O_ARE_DESCRIPCION,
           O_ARE_CREATED_AT
      FROM MUE_AREA A
     WHERE A.ARE_Area = P_ARE_AREA;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El área no existe.';
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al consultar área: ' || SQLERRM;
  END PR_AREA_OBTENER;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_AREA_LISTAR (
    P_FILTRO_NOMBRE IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR        OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    OPEN O_CURSOR FOR
      SELECT A.ARE_Area           AS Area_Id,
             A.ARE_Area_Funcional AS Area_Funcional,
             A.ARE_Descripcion    AS Descripcion,
             A.ARE_Created_At     AS Creado_En
        FROM MUE_AREA A
       WHERE P_FILTRO_NOMBRE IS NULL
          OR UPPER(A.ARE_Area_Funcional) LIKE '%' || UPPER(TRIM(P_FILTRO_NOMBRE)) || '%'
       ORDER BY A.ARE_Area_Funcional ASC;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al listar áreas: ' || SQLERRM;
  END PR_AREA_LISTAR;

END PKG_MUE_AREA;
/

-- Permisos de ejecución (ajustar usuario de aplicación)
-- GRANT EXECUTE ON PKG_MUE_AREA TO USR_APP_MUEBLERIA;