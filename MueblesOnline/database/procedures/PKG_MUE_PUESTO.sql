-- =============================================================================
-- Paquete PL/SQL (Oracle 21c)
-- Entidad  : MUE_PUESTO
-- Propósito: CRUD de puestos de trabajo.
-- Ejecutar conectado al esquema MUEBLERIA.
-- =============================================================================

CREATE OR REPLACE PACKAGE PKG_MUE_PUESTO AS
  /**
   * Catálogo de puestos — operaciones CRUD y listado.
   * Convención de retorno: O_COD_RET = 0 éxito; distinto de 0 error controlado.
   */

  PROCEDURE PR_PUESTO_INSERTAR (
    P_PUE_TITULO      IN  VARCHAR2,
    P_PUE_DESCRIPCION IN  VARCHAR2,
    O_PUE_PUESTO      OUT NUMBER,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  );

  PROCEDURE PR_PUESTO_ACTUALIZAR (
    P_PUE_PUESTO      IN  NUMBER,
    P_PUE_TITULO      IN  VARCHAR2,
    P_PUE_DESCRIPCION IN  VARCHAR2,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  );

  PROCEDURE PR_PUESTO_ELIMINAR (
    P_PUE_PUESTO IN  NUMBER,
    O_COD_RET    OUT NUMBER,
    O_MSG        OUT VARCHAR2
  );

  PROCEDURE PR_PUESTO_OBTENER (
    P_PUE_PUESTO      IN  NUMBER,
    O_PUE_TITULO      OUT VARCHAR2,
    O_PUE_DESCRIPCION OUT VARCHAR2,
    O_PUE_CREATED_AT  OUT TIMESTAMP,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  );

  PROCEDURE PR_PUESTO_LISTAR (
    P_FILTRO_TITULO IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR        OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  );

END PKG_MUE_PUESTO;
/

CREATE OR REPLACE PACKAGE BODY PKG_MUE_PUESTO AS

  C_OK    CONSTANT NUMBER := 0;
  C_ERR   CONSTANT NUMBER := 1;
  C_NOFND CONSTANT NUMBER := 2;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_PUESTO_INSERTAR (
    P_PUE_TITULO      IN  VARCHAR2,
    P_PUE_DESCRIPCION IN  VARCHAR2,
    O_PUE_PUESTO      OUT NUMBER,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET    := C_ERR;
    O_MSG        := NULL;
    O_PUE_PUESTO := NULL;

    IF TRIM(P_PUE_TITULO) IS NULL THEN
      O_MSG := 'El título del puesto es obligatorio.';
      RETURN;
    END IF;

    INSERT INTO MUE_PUESTO (
      PUE_Titulo,
      PUE_Descripcion,
      PUE_Created_At
    ) VALUES (
      P_PUE_TITULO,
      P_PUE_DESCRIPCION,
      SYSTIMESTAMP
    )
    RETURNING PUE_Puesto INTO O_PUE_PUESTO;

    O_COD_RET := C_OK;
    O_MSG     := 'Puesto registrado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET    := C_ERR;
      O_MSG        := 'Error al insertar puesto: ' || SQLERRM;
      O_PUE_PUESTO := NULL;
  END PR_PUESTO_INSERTAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_PUESTO_ACTUALIZAR (
    P_PUE_PUESTO      IN  NUMBER,
    P_PUE_TITULO      IN  VARCHAR2,
    P_PUE_DESCRIPCION IN  VARCHAR2,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  ) IS
    V_N NUMBER;
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_PUE_PUESTO IS NULL THEN
      O_MSG := 'Identificador de puesto inválido.';
      RETURN;
    END IF;

    SELECT COUNT(1) INTO V_N FROM MUE_PUESTO WHERE PUE_Puesto = P_PUE_PUESTO;
    IF V_N = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El puesto no existe.';
      RETURN;
    END IF;

    UPDATE MUE_PUESTO
       SET PUE_Titulo      = P_PUE_TITULO,
           PUE_Descripcion = P_PUE_DESCRIPCION
     WHERE PUE_Puesto = P_PUE_PUESTO;

    O_COD_RET := C_OK;
    O_MSG     := 'Puesto actualizado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al actualizar puesto: ' || SQLERRM;
  END PR_PUESTO_ACTUALIZAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_PUESTO_ELIMINAR (
    P_PUE_PUESTO IN  NUMBER,
    O_COD_RET    OUT NUMBER,
    O_MSG        OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_PUE_PUESTO IS NULL THEN
      O_MSG := 'Identificador de puesto inválido.';
      RETURN;
    END IF;

    DELETE FROM MUE_PUESTO WHERE PUE_Puesto = P_PUE_PUESTO;

    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El puesto no existe.';
      RETURN;
    END IF;

    O_COD_RET := C_OK;
    O_MSG     := 'Puesto eliminado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      -- Ej.: ORA-02292 si MUE_CONTRATO referencia este puesto
      O_COD_RET := C_ERR;
      O_MSG     := 'No se puede eliminar el puesto (puede estar referenciado): ' || SQLERRM;
  END PR_PUESTO_ELIMINAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_PUESTO_OBTENER (
    P_PUE_PUESTO      IN  NUMBER,
    O_PUE_TITULO      OUT VARCHAR2,
    O_PUE_DESCRIPCION OUT VARCHAR2,
    O_PUE_CREATED_AT  OUT TIMESTAMP,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET         := C_ERR;
    O_MSG             := NULL;
    O_PUE_TITULO      := NULL;
    O_PUE_DESCRIPCION := NULL;
    O_PUE_CREATED_AT  := NULL;

    IF P_PUE_PUESTO IS NULL THEN
      O_MSG := 'Identificador de puesto inválido.';
      RETURN;
    END IF;

    SELECT P.PUE_Titulo,
           P.PUE_Descripcion,
           P.PUE_Created_At
      INTO O_PUE_TITULO,
           O_PUE_DESCRIPCION,
           O_PUE_CREATED_AT
      FROM MUE_PUESTO P
     WHERE P.PUE_Puesto = P_PUE_PUESTO;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El puesto no existe.';
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al consultar puesto: ' || SQLERRM;
  END PR_PUESTO_OBTENER;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_PUESTO_LISTAR (
    P_FILTRO_TITULO IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR        OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    OPEN O_CURSOR FOR
      SELECT P.PUE_Puesto      AS Puesto_Id,
             P.PUE_Titulo      AS Titulo,
             P.PUE_Descripcion AS Descripcion,
             P.PUE_Created_At  AS Creado_En
        FROM MUE_PUESTO P
       WHERE P_FILTRO_TITULO IS NULL
          OR UPPER(P.PUE_Titulo) LIKE '%' || UPPER(TRIM(P_FILTRO_TITULO)) || '%'
       ORDER BY P.PUE_Titulo ASC;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al listar puestos: ' || SQLERRM;
  END PR_PUESTO_LISTAR;

END PKG_MUE_PUESTO;
/

-- GRANT EXECUTE ON PKG_MUE_PUESTO TO USR_APP_MUEBLERIA;