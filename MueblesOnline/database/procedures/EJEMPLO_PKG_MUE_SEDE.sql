-- =============================================================================
-- EJEMPLO DE ESTÁNDAR — Paquete PL/SQL (Oracle 21c)
-- Entidad: MUE_SEDE (referencia: Docs/DDL_MUEBLERIA.sql)
-- Propósito: Plantilla para el equipo; reemplazar/adaptar por cada módulo.
-- Ejecutar conectado al esquema MUEBLERIA (o el esquema acordado).
-- =============================================================================

CREATE OR REPLACE PACKAGE PKG_MUE_SEDE AS
  /**
   * Catálogo de sedes — operaciones CRUD y listado.
   * Convención de retorno: O_COD_RET = 0 éxito; distinto de 0 error controlado.
   */

  PROCEDURE PR_SEDE_INSERTAR (
    P_SED_NOMBRE       IN VARCHAR2,
    P_SED_MUNICIPIO    IN VARCHAR2,
    P_SED_DEPARTAMENTO IN VARCHAR2,
    P_SED_PAIS         IN VARCHAR2,
    P_SED_DIRECCION    IN VARCHAR2,
    O_SED_SEDE         OUT NUMBER,
    O_COD_RET          OUT NUMBER,
    O_MSG              OUT VARCHAR2
  );

  PROCEDURE PR_SEDE_ACTUALIZAR (
    P_SED_SEDE         IN NUMBER,
    P_SED_NOMBRE       IN VARCHAR2,
    P_SED_MUNICIPIO    IN VARCHAR2,
    P_SED_DEPARTAMENTO IN VARCHAR2,
    P_SED_PAIS         IN VARCHAR2,
    P_SED_DIRECCION    IN VARCHAR2,
    O_COD_RET          OUT NUMBER,
    O_MSG              OUT VARCHAR2
  );

  PROCEDURE PR_SEDE_ELIMINAR (
    P_SED_SEDE IN NUMBER,
    O_COD_RET  OUT NUMBER,
    O_MSG      OUT VARCHAR2
  );

  PROCEDURE PR_SEDE_OBTENER (
    P_SED_SEDE         IN NUMBER,
    O_SED_NOMBRE       OUT VARCHAR2,
    O_SED_MUNICIPIO    OUT VARCHAR2,
    O_SED_DEPARTAMENTO OUT VARCHAR2,
    O_SED_PAIS         OUT VARCHAR2,
    O_SED_DIRECCION    OUT VARCHAR2,
    O_COD_RET          OUT NUMBER,
    O_MSG              OUT VARCHAR2
  );

  PROCEDURE PR_SEDE_LISTAR (
    P_FILTRO_NOMBRE IN VARCHAR2 DEFAULT NULL,
    O_CURSOR        OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  );

END PKG_MUE_SEDE;
/

CREATE OR REPLACE PACKAGE BODY PKG_MUE_SEDE AS

  C_OK    CONSTANT NUMBER := 0;
  C_ERR   CONSTANT NUMBER := 1;
  C_NOFND CONSTANT NUMBER := 2;

  PROCEDURE PR_SEDE_INSERTAR (
    P_SED_NOMBRE       IN VARCHAR2,
    P_SED_MUNICIPIO    IN VARCHAR2,
    P_SED_DEPARTAMENTO IN VARCHAR2,
    P_SED_PAIS         IN VARCHAR2,
    P_SED_DIRECCION    IN VARCHAR2,
    O_SED_SEDE         OUT NUMBER,
    O_COD_RET          OUT NUMBER,
    O_MSG              OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;
    O_SED_SEDE := NULL;

    IF TRIM(P_SED_NOMBRE) IS NULL THEN
      O_MSG := 'El nombre de la sede es obligatorio.';
      RETURN;
    END IF;

    INSERT INTO MUE_SEDE (
      SED_Nombre,
      SED_Municipio,
      SED_Departamento,
      SED_Pais,
      SED_Direccion
    ) VALUES (
      P_SED_NOMBRE,
      P_SED_MUNICIPIO,
      P_SED_DEPARTAMENTO,
      P_SED_PAIS,
      P_SED_DIRECCION
    )
    RETURNING SED_Sede INTO O_SED_SEDE;

    O_COD_RET := C_OK;
    O_MSG     := 'Sede registrada correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al insertar sede: ' || SQLERRM;
      O_SED_SEDE := NULL;
  END PR_SEDE_INSERTAR;

  PROCEDURE PR_SEDE_ACTUALIZAR (
    P_SED_SEDE         IN NUMBER,
    P_SED_NOMBRE       IN VARCHAR2,
    P_SED_MUNICIPIO    IN VARCHAR2,
    P_SED_DEPARTAMENTO IN VARCHAR2,
    P_SED_PAIS         IN VARCHAR2,
    P_SED_DIRECCION    IN VARCHAR2,
    O_COD_RET          OUT NUMBER,
    O_MSG              OUT VARCHAR2
  ) IS
    V_N NUMBER;
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_SED_SEDE IS NULL THEN
      O_MSG := 'Identificador de sede inválido.';
      RETURN;
    END IF;

    SELECT COUNT(1) INTO V_N FROM MUE_SEDE WHERE SED_Sede = P_SED_SEDE;
    IF V_N = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'La sede no existe.';
      RETURN;
    END IF;

    UPDATE MUE_SEDE
       SET SED_Nombre       = P_SED_NOMBRE,
           SED_Municipio    = P_SED_MUNICIPIO,
           SED_Departamento = P_SED_DEPARTAMENTO,
           SED_Pais         = P_SED_PAIS,
           SED_Direccion    = P_SED_DIRECCION
     WHERE SED_Sede = P_SED_SEDE;

    O_COD_RET := C_OK;
    O_MSG     := 'Sede actualizada correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al actualizar sede: ' || SQLERRM;
  END PR_SEDE_ACTUALIZAR;

  PROCEDURE PR_SEDE_ELIMINAR (
    P_SED_SEDE IN NUMBER,
    O_COD_RET  OUT NUMBER,
    O_MSG      OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_SED_SEDE IS NULL THEN
      O_MSG := 'Identificador de sede inválido.';
      RETURN;
    END IF;

    DELETE FROM MUE_SEDE WHERE SED_Sede = P_SED_SEDE;
    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'La sede no existe.';
      RETURN;
    END IF;

    O_COD_RET := C_OK;
    O_MSG     := 'Sede eliminada correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      -- Ej.: ORA-02292 restricción de integridad hija (ej. MUE_BODEGA)
      O_COD_RET := C_ERR;
      O_MSG     := 'No se puede eliminar la sede (puede estar referenciada): ' || SQLERRM;
  END PR_SEDE_ELIMINAR;

  PROCEDURE PR_SEDE_OBTENER (
    P_SED_SEDE         IN NUMBER,
    O_SED_NOMBRE       OUT VARCHAR2,
    O_SED_MUNICIPIO    OUT VARCHAR2,
    O_SED_DEPARTAMENTO OUT VARCHAR2,
    O_SED_PAIS         OUT VARCHAR2,
    O_SED_DIRECCION    OUT VARCHAR2,
    O_COD_RET          OUT NUMBER,
    O_MSG              OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;
    O_SED_NOMBRE := NULL;
    O_SED_MUNICIPIO := NULL;
    O_SED_DEPARTAMENTO := NULL;
    O_SED_PAIS := NULL;
    O_SED_DIRECCION := NULL;

    IF P_SED_SEDE IS NULL THEN
      O_MSG := 'Identificador de sede inválido.';
      RETURN;
    END IF;

    SELECT S.SED_Nombre,
           S.SED_Municipio,
           S.SED_Departamento,
           S.SED_Pais,
           S.SED_Direccion
      INTO O_SED_NOMBRE,
           O_SED_MUNICIPIO,
           O_SED_DEPARTAMENTO,
           O_SED_PAIS,
           O_SED_DIRECCION
      FROM MUE_SEDE S
     WHERE S.SED_Sede = P_SED_SEDE;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'La sede no existe.';
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al consultar sede: ' || SQLERRM;
  END PR_SEDE_OBTENER;

  PROCEDURE PR_SEDE_LISTAR (
    P_FILTRO_NOMBRE IN VARCHAR2 DEFAULT NULL,
    O_CURSOR        OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    OPEN O_CURSOR FOR
      SELECT S.SED_Sede         AS Sede_Id,
             S.SED_Nombre       AS Nombre,
             S.SED_Municipio    AS Municipio,
             S.SED_Departamento AS Departamento,
             S.SED_Pais         AS Pais,
             S.SED_Direccion    AS Direccion
        FROM MUE_SEDE S
       WHERE P_FILTRO_NOMBRE IS NULL
          OR UPPER(S.SED_Nombre) LIKE '%' || UPPER(TRIM(P_FILTRO_NOMBRE)) || '%'
       ORDER BY S.SED_Nombre ASC;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al listar sedes: ' || SQLERRM;
  END PR_SEDE_LISTAR;

END PKG_MUE_SEDE;
/

-- Permisos de ejecución (ajustar usuario de aplicación)
-- GRANT EXECUTE ON PKG_MUE_SEDE TO USR_APP_MUEBLERIA;
