-- =============================================================================
-- Paquete PL/SQL (Oracle 21c)
-- Entidad  : MUE_PROFESION
-- Propósito: CRUD de profesiones.
-- Ejecutar conectado al esquema MUEBLERIA.
-- =============================================================================

CREATE OR REPLACE PACKAGE PKG_MUE_PROFESION AS
  /**
   * Catálogo de profesiones — operaciones CRUD y listado.
   * Convención de retorno: O_COD_RET = 0 éxito; distinto de 0 error controlado.
   */

  PROCEDURE PR_PROFESION_INSERTAR (
    P_PRF_NOMBRE        IN  VARCHAR2,
    P_PRF_ESPECIALIDAD  IN  VARCHAR2,
    P_PRF_DESCRIPCION   IN  VARCHAR2,
    O_PRF_PROFESION     OUT NUMBER,
    O_COD_RET           OUT NUMBER,
    O_MSG               OUT VARCHAR2
  );

  PROCEDURE PR_PROFESION_ACTUALIZAR (
    P_PRF_PROFESION     IN  NUMBER,
    P_PRF_NOMBRE        IN  VARCHAR2,
    P_PRF_ESPECIALIDAD  IN  VARCHAR2,
    P_PRF_DESCRIPCION   IN  VARCHAR2,
    O_COD_RET           OUT NUMBER,
    O_MSG               OUT VARCHAR2
  );

  PROCEDURE PR_PROFESION_ELIMINAR (
    P_PRF_PROFESION IN  NUMBER,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  );

  PROCEDURE PR_PROFESION_OBTENER (
    P_PRF_PROFESION    IN  NUMBER,
    O_PRF_NOMBRE       OUT VARCHAR2,
    O_PRF_ESPECIALIDAD OUT VARCHAR2,
    O_PRF_DESCRIPCION  OUT VARCHAR2,
    O_COD_RET          OUT NUMBER,
    O_MSG              OUT VARCHAR2
  );

  PROCEDURE PR_PROFESION_LISTAR (
    P_FILTRO_NOMBRE IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR        OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  );

END PKG_MUE_PROFESION;
/

CREATE OR REPLACE PACKAGE BODY PKG_MUE_PROFESION AS

  C_OK    CONSTANT NUMBER := 0;
  C_ERR   CONSTANT NUMBER := 1;
  C_NOFND CONSTANT NUMBER := 2;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_PROFESION_INSERTAR (
    P_PRF_NOMBRE        IN  VARCHAR2,
    P_PRF_ESPECIALIDAD  IN  VARCHAR2,
    P_PRF_DESCRIPCION   IN  VARCHAR2,
    O_PRF_PROFESION     OUT NUMBER,
    O_COD_RET           OUT NUMBER,
    O_MSG               OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET       := C_ERR;
    O_MSG           := NULL;
    O_PRF_PROFESION := NULL;

    IF TRIM(P_PRF_NOMBRE) IS NULL THEN
      O_MSG := 'El nombre de la profesión es obligatorio.';
      RETURN;
    END IF;

    INSERT INTO MUE_PROFESION (
      PRF_Nombre,
      PRF_Especialidad,
      PRF_Descripcion
    ) VALUES (
      P_PRF_NOMBRE,
      P_PRF_ESPECIALIDAD,
      P_PRF_DESCRIPCION
    )
    RETURNING PRF_Profesion INTO O_PRF_PROFESION;

    O_COD_RET := C_OK;
    O_MSG     := 'Profesión registrada correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET       := C_ERR;
      O_MSG           := 'Error al insertar profesión: ' || SQLERRM;
      O_PRF_PROFESION := NULL;
  END PR_PROFESION_INSERTAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_PROFESION_ACTUALIZAR (
    P_PRF_PROFESION     IN  NUMBER,
    P_PRF_NOMBRE        IN  VARCHAR2,
    P_PRF_ESPECIALIDAD  IN  VARCHAR2,
    P_PRF_DESCRIPCION   IN  VARCHAR2,
    O_COD_RET           OUT NUMBER,
    O_MSG               OUT VARCHAR2
  ) IS
    V_N NUMBER;
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_PRF_PROFESION IS NULL THEN
      O_MSG := 'Identificador de profesión inválido.';
      RETURN;
    END IF;

    SELECT COUNT(1) INTO V_N FROM MUE_PROFESION WHERE PRF_Profesion = P_PRF_PROFESION;
    IF V_N = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'La profesión no existe.';
      RETURN;
    END IF;

    UPDATE MUE_PROFESION
       SET PRF_Nombre       = P_PRF_NOMBRE,
           PRF_Especialidad = P_PRF_ESPECIALIDAD,
           PRF_Descripcion  = P_PRF_DESCRIPCION
     WHERE PRF_Profesion = P_PRF_PROFESION;

    O_COD_RET := C_OK;
    O_MSG     := 'Profesión actualizada correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al actualizar profesión: ' || SQLERRM;
  END PR_PROFESION_ACTUALIZAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_PROFESION_ELIMINAR (
    P_PRF_PROFESION IN  NUMBER,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_PRF_PROFESION IS NULL THEN
      O_MSG := 'Identificador de profesión inválido.';
      RETURN;
    END IF;

    DELETE FROM MUE_PROFESION WHERE PRF_Profesion = P_PRF_PROFESION;

    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'La profesión no existe.';
      RETURN;
    END IF;

    O_COD_RET := C_OK;
    O_MSG     := 'Profesión eliminada correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      -- Ej.: ORA-02292 si MUE_USUARIO referencia esta profesión
      O_COD_RET := C_ERR;
      O_MSG     := 'No se puede eliminar la profesión (puede estar referenciada): ' || SQLERRM;
  END PR_PROFESION_ELIMINAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_PROFESION_OBTENER (
    P_PRF_PROFESION    IN  NUMBER,
    O_PRF_NOMBRE       OUT VARCHAR2,
    O_PRF_ESPECIALIDAD OUT VARCHAR2,
    O_PRF_DESCRIPCION  OUT VARCHAR2,
    O_COD_RET          OUT NUMBER,
    O_MSG              OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET          := C_ERR;
    O_MSG              := NULL;
    O_PRF_NOMBRE       := NULL;
    O_PRF_ESPECIALIDAD := NULL;
    O_PRF_DESCRIPCION  := NULL;

    IF P_PRF_PROFESION IS NULL THEN
      O_MSG := 'Identificador de profesión inválido.';
      RETURN;
    END IF;

    SELECT P.PRF_Nombre,
           P.PRF_Especialidad,
           P.PRF_Descripcion
      INTO O_PRF_NOMBRE,
           O_PRF_ESPECIALIDAD,
           O_PRF_DESCRIPCION
      FROM MUE_PROFESION P
     WHERE P.PRF_Profesion = P_PRF_PROFESION;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'La profesión no existe.';
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al consultar profesión: ' || SQLERRM;
  END PR_PROFESION_OBTENER;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_PROFESION_LISTAR (
    P_FILTRO_NOMBRE IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR        OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    OPEN O_CURSOR FOR
      SELECT P.PRF_Profesion   AS Profesion_Id,
             P.PRF_Nombre      AS Nombre,
             P.PRF_Especialidad AS Especialidad,
             P.PRF_Descripcion AS Descripcion
        FROM MUE_PROFESION P
       WHERE P_FILTRO_NOMBRE IS NULL
          OR UPPER(P.PRF_Nombre) LIKE '%' || UPPER(TRIM(P_FILTRO_NOMBRE)) || '%'
       ORDER BY P.PRF_Nombre ASC;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al listar profesiones: ' || SQLERRM;
  END PR_PROFESION_LISTAR;

END PKG_MUE_PROFESION;
/

-- GRANT EXECUTE ON PKG_MUE_PROFESION TO USR_APP_MUEBLERIA;