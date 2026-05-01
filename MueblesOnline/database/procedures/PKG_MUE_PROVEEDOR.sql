-- =============================================================================
-- Paquete PL/SQL (Oracle 21c)
-- Entidad  : MUE_PROVEEDOR
-- Propósito: CRUD de proveedores de materiales.
-- Ejecutar conectado al esquema MUEBLERIA.
-- =============================================================================

CREATE OR REPLACE PACKAGE PKG_MUE_PROVEEDOR AS
  /**
   * Catálogo de proveedores — operaciones CRUD y listado.
   * Convención de retorno: O_COD_RET = 0 éxito; distinto de 0 error controlado.
   */

  PROCEDURE PR_PROVEEDOR_INSERTAR (
    P_PRV_NIT            IN  VARCHAR2,
    P_PRV_NOMBRE_EMPRESA IN  VARCHAR2,
    P_PRV_EMAIL          IN  VARCHAR2,
    P_PRV_ZONA           IN  VARCHAR2,
    P_PRV_MUNICIPIO      IN  VARCHAR2,
    P_PRV_DEPARTAMENTO   IN  VARCHAR2,
    P_PRV_PAIS           IN  VARCHAR2,
    P_PRV_TELEFONO       IN  NUMBER,
    O_PRV_PROVEEDOR      OUT NUMBER,
    O_COD_RET            OUT NUMBER,
    O_MSG                OUT VARCHAR2
  );

  PROCEDURE PR_PROVEEDOR_ACTUALIZAR (
    P_PRV_PROVEEDOR      IN  NUMBER,
    P_PRV_NIT            IN  VARCHAR2,
    P_PRV_NOMBRE_EMPRESA IN  VARCHAR2,
    P_PRV_EMAIL          IN  VARCHAR2,
    P_PRV_ZONA           IN  VARCHAR2,
    P_PRV_MUNICIPIO      IN  VARCHAR2,
    P_PRV_DEPARTAMENTO   IN  VARCHAR2,
    P_PRV_PAIS           IN  VARCHAR2,
    P_PRV_TELEFONO       IN  NUMBER,
    O_COD_RET            OUT NUMBER,
    O_MSG                OUT VARCHAR2
  );

  PROCEDURE PR_PROVEEDOR_ELIMINAR (
    P_PRV_PROVEEDOR IN  NUMBER,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  );

  PROCEDURE PR_PROVEEDOR_OBTENER (
    P_PRV_PROVEEDOR      IN  NUMBER,
    O_PRV_NIT            OUT VARCHAR2,
    O_PRV_NOMBRE_EMPRESA OUT VARCHAR2,
    O_PRV_EMAIL          OUT VARCHAR2,
    O_PRV_ZONA           OUT VARCHAR2,
    O_PRV_MUNICIPIO      OUT VARCHAR2,
    O_PRV_DEPARTAMENTO   OUT VARCHAR2,
    O_PRV_PAIS           OUT VARCHAR2,
    O_PRV_TELEFONO       OUT NUMBER,
    O_PRV_CREATED_AT     OUT TIMESTAMP,
    O_COD_RET            OUT NUMBER,
    O_MSG                OUT VARCHAR2
  );

  PROCEDURE PR_PROVEEDOR_LISTAR (
    P_FILTRO_NOMBRE IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR        OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  );

END PKG_MUE_PROVEEDOR;
/

CREATE OR REPLACE PACKAGE BODY PKG_MUE_PROVEEDOR AS

  C_OK    CONSTANT NUMBER := 0;
  C_ERR   CONSTANT NUMBER := 1;
  C_NOFND CONSTANT NUMBER := 2;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_PROVEEDOR_INSERTAR (
    P_PRV_NIT            IN  VARCHAR2,
    P_PRV_NOMBRE_EMPRESA IN  VARCHAR2,
    P_PRV_EMAIL          IN  VARCHAR2,
    P_PRV_ZONA           IN  VARCHAR2,
    P_PRV_MUNICIPIO      IN  VARCHAR2,
    P_PRV_DEPARTAMENTO   IN  VARCHAR2,
    P_PRV_PAIS           IN  VARCHAR2,
    P_PRV_TELEFONO       IN  NUMBER,
    O_PRV_PROVEEDOR      OUT NUMBER,
    O_COD_RET            OUT NUMBER,
    O_MSG                OUT VARCHAR2
  ) IS
    V_N NUMBER;
  BEGIN
    O_COD_RET       := C_ERR;
    O_MSG           := NULL;
    O_PRV_PROVEEDOR := NULL;

    -- Validaciones de campos obligatorios
    IF TRIM(P_PRV_NIT) IS NULL THEN
      O_MSG := 'El NIT del proveedor es obligatorio.';
      RETURN;
    END IF;

    IF TRIM(P_PRV_NOMBRE_EMPRESA) IS NULL THEN
      O_MSG := 'El nombre de empresa del proveedor es obligatorio.';
      RETURN;
    END IF;

    IF TRIM(P_PRV_EMAIL) IS NULL THEN
      O_MSG := 'El correo electrónico del proveedor es obligatorio.';
      RETURN;
    END IF;

    IF P_PRV_TELEFONO IS NULL THEN
      O_MSG := 'El teléfono del proveedor es obligatorio.';
      RETURN;
    END IF;

    -- Validar unicidad del NIT
    SELECT COUNT(1) INTO V_N FROM MUE_PROVEEDOR WHERE PRV_Nit = TRIM(P_PRV_NIT);
    IF V_N > 0 THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Ya existe un proveedor registrado con ese NIT.';
      RETURN;
    END IF;

    INSERT INTO MUE_PROVEEDOR (
      PRV_Nit,
      PRV_Nombre_Empresa,
      PRV_Email,
      PRV_Zona,
      PRV_Municipio,
      PRV_Departamento,
      PRV_Pais,
      PRV_Telefono,
      PRV_Created_At
    ) VALUES (
      TRIM(P_PRV_NIT),
      P_PRV_NOMBRE_EMPRESA,
      P_PRV_EMAIL,
      P_PRV_ZONA,
      P_PRV_MUNICIPIO,
      P_PRV_DEPARTAMENTO,
      P_PRV_PAIS,
      P_PRV_TELEFONO,
      SYSTIMESTAMP
    )
    RETURNING PRV_Proveedor INTO O_PRV_PROVEEDOR;

    O_COD_RET := C_OK;
    O_MSG     := 'Proveedor registrado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET       := C_ERR;
      O_MSG           := 'Error al insertar proveedor: ' || SQLERRM;
      O_PRV_PROVEEDOR := NULL;
  END PR_PROVEEDOR_INSERTAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_PROVEEDOR_ACTUALIZAR (
    P_PRV_PROVEEDOR      IN  NUMBER,
    P_PRV_NIT            IN  VARCHAR2,
    P_PRV_NOMBRE_EMPRESA IN  VARCHAR2,
    P_PRV_EMAIL          IN  VARCHAR2,
    P_PRV_ZONA           IN  VARCHAR2,
    P_PRV_MUNICIPIO      IN  VARCHAR2,
    P_PRV_DEPARTAMENTO   IN  VARCHAR2,
    P_PRV_PAIS           IN  VARCHAR2,
    P_PRV_TELEFONO       IN  NUMBER,
    O_COD_RET            OUT NUMBER,
    O_MSG                OUT VARCHAR2
  ) IS
    V_N NUMBER;
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_PRV_PROVEEDOR IS NULL THEN
      O_MSG := 'Identificador de proveedor inválido.';
      RETURN;
    END IF;

    IF TRIM(P_PRV_NIT) IS NULL THEN
      O_MSG := 'El NIT del proveedor es obligatorio.';
      RETURN;
    END IF;

    IF TRIM(P_PRV_NOMBRE_EMPRESA) IS NULL THEN
      O_MSG := 'El nombre de empresa del proveedor es obligatorio.';
      RETURN;
    END IF;

    IF TRIM(P_PRV_EMAIL) IS NULL THEN
      O_MSG := 'El correo electrónico del proveedor es obligatorio.';
      RETURN;
    END IF;

    IF P_PRV_TELEFONO IS NULL THEN
      O_MSG := 'El teléfono del proveedor es obligatorio.';
      RETURN;
    END IF;

    -- Verificar existencia
    SELECT COUNT(1) INTO V_N FROM MUE_PROVEEDOR WHERE PRV_Proveedor = P_PRV_PROVEEDOR;
    IF V_N = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El proveedor no existe.';
      RETURN;
    END IF;

    -- Validar que el NIT no está en uso por otro proveedor
    SELECT COUNT(1) INTO V_N
      FROM MUE_PROVEEDOR
     WHERE PRV_Nit = TRIM(P_PRV_NIT)
       AND PRV_Proveedor <> P_PRV_PROVEEDOR;

    IF V_N > 0 THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'El NIT ya está en uso por otro proveedor.';
      RETURN;
    END IF;

    UPDATE MUE_PROVEEDOR
       SET PRV_Nit            = TRIM(P_PRV_NIT),
           PRV_Nombre_Empresa = TRIM(P_PRV_NOMBRE_EMPRESA),
           PRV_Email          = TRIM(P_PRV_EMAIL),
           PRV_Zona           = P_PRV_ZONA,
           PRV_Municipio      = P_PRV_MUNICIPIO,
           PRV_Departamento   = P_PRV_DEPARTAMENTO,
           PRV_Pais           = P_PRV_PAIS,
           PRV_Telefono       = P_PRV_TELEFONO
     WHERE PRV_Proveedor = P_PRV_PROVEEDOR;

    O_COD_RET := C_OK;
    O_MSG     := 'Proveedor actualizado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al actualizar proveedor: ' || SQLERRM;
  END PR_PROVEEDOR_ACTUALIZAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_PROVEEDOR_ELIMINAR (
    P_PRV_PROVEEDOR IN  NUMBER,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_PRV_PROVEEDOR IS NULL THEN
      O_MSG := 'Identificador de proveedor inválido.';
      RETURN;
    END IF;

    DELETE FROM MUE_PROVEEDOR WHERE PRV_Proveedor = P_PRV_PROVEEDOR;

    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El proveedor no existe.';
      RETURN;
    END IF;

    O_COD_RET := C_OK;
    O_MSG     := 'Proveedor eliminado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      -- Ej.: ORA-02292 si MUE_PEDIDO_PROVEEDOR referencia este proveedor
      O_COD_RET := C_ERR;
      O_MSG     := 'No se puede eliminar el proveedor (puede estar referenciado): ' || SQLERRM;
  END PR_PROVEEDOR_ELIMINAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_PROVEEDOR_OBTENER (
    P_PRV_PROVEEDOR      IN  NUMBER,
    O_PRV_NIT            OUT VARCHAR2,
    O_PRV_NOMBRE_EMPRESA OUT VARCHAR2,
    O_PRV_EMAIL          OUT VARCHAR2,
    O_PRV_ZONA           OUT VARCHAR2,
    O_PRV_MUNICIPIO      OUT VARCHAR2,
    O_PRV_DEPARTAMENTO   OUT VARCHAR2,
    O_PRV_PAIS           OUT VARCHAR2,
    O_PRV_TELEFONO       OUT NUMBER,
    O_PRV_CREATED_AT     OUT TIMESTAMP,
    O_COD_RET            OUT NUMBER,
    O_MSG                OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET            := C_ERR;
    O_MSG                := NULL;
    O_PRV_NIT            := NULL;
    O_PRV_NOMBRE_EMPRESA := NULL;
    O_PRV_EMAIL          := NULL;
    O_PRV_ZONA           := NULL;
    O_PRV_MUNICIPIO      := NULL;
    O_PRV_DEPARTAMENTO   := NULL;
    O_PRV_PAIS           := NULL;
    O_PRV_TELEFONO       := NULL;
    O_PRV_CREATED_AT     := NULL;

    IF P_PRV_PROVEEDOR IS NULL THEN
      O_MSG := 'Identificador de proveedor inválido.';
      RETURN;
    END IF;

    SELECT P.PRV_Nit,
           P.PRV_Nombre_Empresa,
           P.PRV_Email,
           P.PRV_Zona,
           P.PRV_Municipio,
           P.PRV_Departamento,
           P.PRV_Pais,
           P.PRV_Telefono,
           P.PRV_Created_At
      INTO O_PRV_NIT,
           O_PRV_NOMBRE_EMPRESA,
           O_PRV_EMAIL,
           O_PRV_ZONA,
           O_PRV_MUNICIPIO,
           O_PRV_DEPARTAMENTO,
           O_PRV_PAIS,
           O_PRV_TELEFONO,
           O_PRV_CREATED_AT
      FROM MUE_PROVEEDOR P
     WHERE P.PRV_Proveedor = P_PRV_PROVEEDOR;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El proveedor no existe.';
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al consultar proveedor: ' || SQLERRM;
  END PR_PROVEEDOR_OBTENER;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_PROVEEDOR_LISTAR (
    P_FILTRO_NOMBRE IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR        OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    OPEN O_CURSOR FOR
      SELECT P.PRV_Proveedor      AS Proveedor_Id,
             P.PRV_Nit            AS Nit,
             P.PRV_Nombre_Empresa AS Nombre_Empresa,
             P.PRV_Email          AS Email,
             P.PRV_Zona           AS Zona,
             P.PRV_Municipio      AS Municipio,
             P.PRV_Departamento   AS Departamento,
             P.PRV_Pais           AS Pais,
             P.PRV_Telefono       AS Telefono,
             P.PRV_Created_At     AS Creado_En
        FROM MUE_PROVEEDOR P
       WHERE P_FILTRO_NOMBRE IS NULL
          OR UPPER(P.PRV_Nombre_Empresa) LIKE '%' || UPPER(TRIM(P_FILTRO_NOMBRE)) || '%'
       ORDER BY P.PRV_Nombre_Empresa ASC;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al listar proveedores: ' || SQLERRM;
  END PR_PROVEEDOR_LISTAR;

END PKG_MUE_PROVEEDOR;
/

-- GRANT EXECUTE ON PKG_MUE_PROVEEDOR TO USR_APP_MUEBLERIA;