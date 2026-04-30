-- =============================================================================
-- Paquete PL/SQL (Oracle 21c)
-- Entidad   : MUE_DEPARTAMENTO
-- Referencia: Docs/DDL_MUEBLERIA.sql
-- Propósito : CRUD completo para departamentos; valida FK a MUE_AREA.
-- Ejecutar conectado al esquema MUEBLERIA.
-- =============================================================================
 
CREATE OR REPLACE PACKAGE PKG_MUE_DEPARTAMENTO AS
  /**
   * Catálogo de departamentos — operaciones CRUD y listado.
   * Depende de MUE_AREA (ARE_Area debe existir antes de insertar).
   * Convención de retorno: O_COD_RET = 0 éxito; distinto de 0 error controlado.
   */
 
  PROCEDURE PR_DEPARTAMENTO_INSERTAR (
    P_DEP_NOMBRE      IN  VARCHAR2,
    P_DEP_DESCRIPCION IN  VARCHAR2,
    P_ARE_AREA        IN  NUMBER,
    O_DEP_DEPARTAMENTO OUT NUMBER,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  );
 
  PROCEDURE PR_DEPARTAMENTO_ACTUALIZAR (
    P_DEP_DEPARTAMENTO IN  NUMBER,
    P_DEP_NOMBRE       IN  VARCHAR2,
    P_DEP_DESCRIPCION  IN  VARCHAR2,
    P_ARE_AREA         IN  NUMBER,
    O_COD_RET          OUT NUMBER,
    O_MSG              OUT VARCHAR2
  );
 
  PROCEDURE PR_DEPARTAMENTO_ELIMINAR (
    P_DEP_DEPARTAMENTO IN  NUMBER,
    O_COD_RET          OUT NUMBER,
    O_MSG              OUT VARCHAR2
  );
 
  PROCEDURE PR_DEPARTAMENTO_OBTENER (
    P_DEP_DEPARTAMENTO  IN  NUMBER,
    O_DEP_NOMBRE        OUT VARCHAR2,
    O_DEP_DESCRIPCION   OUT VARCHAR2,
    O_DEP_CREATED_AT    OUT TIMESTAMP,
    O_ARE_AREA          OUT NUMBER,
    O_COD_RET           OUT NUMBER,
    O_MSG               OUT VARCHAR2
  );
 
  PROCEDURE PR_DEPARTAMENTO_LISTAR (
    P_FILTRO_NOMBRE IN  VARCHAR2 DEFAULT NULL,
    P_ARE_AREA      IN  NUMBER   DEFAULT NULL,
    O_CURSOR        OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  );
 
END PKG_MUE_DEPARTAMENTO;
/
 
CREATE OR REPLACE PACKAGE BODY PKG_MUE_DEPARTAMENTO AS
 
  C_OK    CONSTANT NUMBER := 0;
  C_ERR   CONSTANT NUMBER := 1;
  C_NOFND CONSTANT NUMBER := 2;
 
  -- ---------------------------------------------------------------------------
  PROCEDURE PR_DEPARTAMENTO_INSERTAR (
    P_DEP_NOMBRE      IN  VARCHAR2,
    P_DEP_DESCRIPCION IN  VARCHAR2,
    P_ARE_AREA        IN  NUMBER,
    O_DEP_DEPARTAMENTO OUT NUMBER,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  ) IS
    V_N NUMBER;
  BEGIN
    O_COD_RET          := C_ERR;
    O_MSG              := NULL;
    O_DEP_DEPARTAMENTO := NULL;
 
    -- Validar nombre obligatorio
    IF TRIM(P_DEP_NOMBRE) IS NULL THEN
      O_MSG := 'El nombre del departamento es obligatorio.';
      RETURN;
    END IF;
 
    -- Validar FK: el área debe existir
    IF P_ARE_AREA IS NULL THEN
      O_MSG := 'El área es obligatoria.';
      RETURN;
    END IF;
 
    SELECT COUNT(1) INTO V_N FROM MUE_AREA WHERE ARE_Area = P_ARE_AREA;
    IF V_N = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El área indicada no existe.';
      RETURN;
    END IF;
 
    INSERT INTO MUE_DEPARTAMENTO (
      DEP_Nombre,
      DEP_Descripcion,
      DEP_Created_At,
      ARE_Area
    ) VALUES (
      TRIM(P_DEP_NOMBRE),
      P_DEP_DESCRIPCION,
      SYSTIMESTAMP,
      P_ARE_AREA
    )
    RETURNING DEP_Departamento INTO O_DEP_DEPARTAMENTO;
 
    O_COD_RET := C_OK;
    O_MSG     := 'Departamento registrado correctamente.';
 
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      O_COD_RET          := C_ERR;
      O_MSG              := 'Ya existe un departamento con ese nombre.';
      O_DEP_DEPARTAMENTO := NULL;
    WHEN OTHERS THEN
      O_COD_RET          := C_ERR;
      O_MSG              := 'Error al insertar departamento: ' || SQLERRM;
      O_DEP_DEPARTAMENTO := NULL;
  END PR_DEPARTAMENTO_INSERTAR;
 
  -- ---------------------------------------------------------------------------
  PROCEDURE PR_DEPARTAMENTO_ACTUALIZAR (
    P_DEP_DEPARTAMENTO IN  NUMBER,
    P_DEP_NOMBRE       IN  VARCHAR2,
    P_DEP_DESCRIPCION  IN  VARCHAR2,
    P_ARE_AREA         IN  NUMBER,
    O_COD_RET          OUT NUMBER,
    O_MSG              OUT VARCHAR2
  ) IS
    V_N NUMBER;
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;
 
    IF P_DEP_DEPARTAMENTO IS NULL THEN
      O_MSG := 'Identificador de departamento inválido.';
      RETURN;
    END IF;
 
    IF TRIM(P_DEP_NOMBRE) IS NULL THEN
      O_MSG := 'El nombre del departamento es obligatorio.';
      RETURN;
    END IF;
 
    -- Verificar que el departamento exista
    SELECT COUNT(1) INTO V_N FROM MUE_DEPARTAMENTO WHERE DEP_Departamento = P_DEP_DEPARTAMENTO;
    IF V_N = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El departamento no existe.';
      RETURN;
    END IF;
 
    -- Validar FK: el área debe existir
    IF P_ARE_AREA IS NOT NULL THEN
      SELECT COUNT(1) INTO V_N FROM MUE_AREA WHERE ARE_Area = P_ARE_AREA;
      IF V_N = 0 THEN
        O_COD_RET := C_NOFND;
        O_MSG     := 'El área indicada no existe.';
        RETURN;
      END IF;
    END IF;
 
    UPDATE MUE_DEPARTAMENTO
       SET DEP_Nombre      = TRIM(P_DEP_NOMBRE),
           DEP_Descripcion = P_DEP_DESCRIPCION,
           ARE_Area        = P_ARE_AREA
     WHERE DEP_Departamento = P_DEP_DEPARTAMENTO;
 
    O_COD_RET := C_OK;
    O_MSG     := 'Departamento actualizado correctamente.';
 
  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al actualizar departamento: ' || SQLERRM;
  END PR_DEPARTAMENTO_ACTUALIZAR;
 
  -- ---------------------------------------------------------------------------
  PROCEDURE PR_DEPARTAMENTO_ELIMINAR (
    P_DEP_DEPARTAMENTO IN  NUMBER,
    O_COD_RET          OUT NUMBER,
    O_MSG              OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;
 
    IF P_DEP_DEPARTAMENTO IS NULL THEN
      O_MSG := 'Identificador de departamento inválido.';
      RETURN;
    END IF;
 
    DELETE FROM MUE_DEPARTAMENTO WHERE DEP_Departamento = P_DEP_DEPARTAMENTO;
    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El departamento no existe.';
      RETURN;
    END IF;
 
    O_COD_RET := C_OK;
    O_MSG     := 'Departamento eliminado correctamente.';
 
  EXCEPTION
    WHEN OTHERS THEN
      -- ORA-02292: registro hijo en MUE_EMPLEADO referencia este departamento
      O_COD_RET := C_ERR;
      O_MSG     := 'No se puede eliminar el departamento (puede estar referenciado por un empleado): ' || SQLERRM;
  END PR_DEPARTAMENTO_ELIMINAR;
 
  -- ---------------------------------------------------------------------------
  PROCEDURE PR_DEPARTAMENTO_OBTENER (
    P_DEP_DEPARTAMENTO  IN  NUMBER,
    O_DEP_NOMBRE        OUT VARCHAR2,
    O_DEP_DESCRIPCION   OUT VARCHAR2,
    O_DEP_CREATED_AT    OUT TIMESTAMP,
    O_ARE_AREA          OUT NUMBER,
    O_COD_RET           OUT NUMBER,
    O_MSG               OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET         := C_ERR;
    O_MSG             := NULL;
    O_DEP_NOMBRE      := NULL;
    O_DEP_DESCRIPCION := NULL;
    O_DEP_CREATED_AT  := NULL;
    O_ARE_AREA        := NULL;
 
    IF P_DEP_DEPARTAMENTO IS NULL THEN
      O_MSG := 'Identificador de departamento inválido.';
      RETURN;
    END IF;
 
    SELECT D.DEP_Nombre,
           D.DEP_Descripcion,
           D.DEP_Created_At,
           D.ARE_Area
      INTO O_DEP_NOMBRE,
           O_DEP_DESCRIPCION,
           O_DEP_CREATED_AT,
           O_ARE_AREA
      FROM MUE_DEPARTAMENTO D
     WHERE D.DEP_Departamento = P_DEP_DEPARTAMENTO;
 
    O_COD_RET := C_OK;
    O_MSG     := 'OK';
 
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El departamento no existe.';
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al consultar departamento: ' || SQLERRM;
  END PR_DEPARTAMENTO_OBTENER;
 
  -- ---------------------------------------------------------------------------
  PROCEDURE PR_DEPARTAMENTO_LISTAR (
    P_FILTRO_NOMBRE IN  VARCHAR2 DEFAULT NULL,
    P_ARE_AREA      IN  NUMBER   DEFAULT NULL,
    O_CURSOR        OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;
 
    OPEN O_CURSOR FOR
      SELECT D.DEP_Departamento AS Departamento_Id,
             D.DEP_Nombre       AS Nombre,
             D.DEP_Descripcion  AS Descripcion,
             D.ARE_Area         AS Area_Id,
             A.ARE_Area_Funcional AS Area_Funcional,
             D.DEP_Created_At   AS Creado_En
        FROM MUE_DEPARTAMENTO D
        JOIN MUE_AREA A ON A.ARE_Area = D.ARE_Area
       WHERE (P_FILTRO_NOMBRE IS NULL
              OR UPPER(D.DEP_Nombre) LIKE '%' || UPPER(TRIM(P_FILTRO_NOMBRE)) || '%')
         AND (P_ARE_AREA IS NULL OR D.ARE_Area = P_ARE_AREA)
       ORDER BY D.DEP_Nombre ASC;
 
    O_COD_RET := C_OK;
    O_MSG     := 'OK';
 
  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al listar departamentos: ' || SQLERRM;
  END PR_DEPARTAMENTO_LISTAR;
 
END PKG_MUE_DEPARTAMENTO;
/
 
-- Permisos de ejecución (ajustar usuario de aplicación)
-- GRANT EXECUTE ON PKG_MUE_DEPARTAMENTO TO USR_APP_MUEBLERIA;