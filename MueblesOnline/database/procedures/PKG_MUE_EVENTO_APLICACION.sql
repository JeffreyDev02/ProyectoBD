CREATE OR REPLACE PACKAGE BODY PKG_MUE_EVENTO_APLICACION AS

  C_OK    CONSTANT NUMBER := 0;
  C_ERR   CONSTANT NUMBER := 1;
  C_NOFND CONSTANT NUMBER := 2;

  PROCEDURE PR_EVENTO_INSERTAR (
    P_USU_USUARIO IN NUMBER,
    P_TEV_TIPO    IN NUMBER,
    P_EVT_FECHA   IN TIMESTAMP,
    P_EVT_DETALLE IN VARCHAR2,
    O_EVT_EVENTO  OUT NUMBER,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  ) IS
    V_EXISTE NUMBER;
  BEGIN
    IF P_EVT_FECHA IS NULL THEN
      O_COD_RET := C_ERR;
      O_MSG := 'La fecha del evento es obligatoria.';
      RETURN;
    END IF;

    SELECT COUNT(*)
      INTO V_EXISTE
      FROM MUE_USUARIO
     WHERE USU_Usuario = P_USU_USUARIO;

    IF V_EXISTE = 0 THEN
      O_COD_RET := C_ERR;
      O_MSG := 'El usuario indicado no existe.';
      RETURN;
    END IF;

    SELECT COUNT(*)
      INTO V_EXISTE
      FROM MUE_TIPO_EVENTO
     WHERE TEV_Tipo_Evento = P_TEV_TIPO;

    IF V_EXISTE = 0 THEN
      O_COD_RET := C_ERR;
      O_MSG := 'El tipo de evento indicado no existe.';
      RETURN;
    END IF;

    INSERT INTO MUE_EVENTO_APLICACION (
      USU_Usuario,
      TEV_Tipo,
      EVT_Fecha,
      EVT_Detalle,
      EVT_Created_At
    )
    VALUES (
      P_USU_USUARIO,
      P_TEV_TIPO,
      P_EVT_FECHA,
      P_EVT_DETALLE,
      SYSTIMESTAMP
    )
    RETURNING EVT_Evento INTO O_EVT_EVENTO;

    O_COD_RET := C_OK;
    O_MSG := 'Evento registrado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG := 'Error al insertar evento: ' || SQLERRM;
  END PR_EVENTO_INSERTAR;


  PROCEDURE PR_EVENTO_OBTENER (
    P_EVT_EVENTO IN NUMBER,
    O_CURSOR     OUT SYS_REFCURSOR,
    O_COD_RET    OUT NUMBER,
    O_MSG        OUT VARCHAR2
  ) IS
  BEGIN
    -- [FIX #15] Columnas explícitas en lugar de SELECT *
    OPEN O_CURSOR FOR
      SELECT EVT_Evento,
             USU_Usuario,
             TEV_Tipo,
             EVT_Fecha,
             EVT_Detalle,
             EVT_Created_At
        FROM MUE_EVENTO_APLICACION
       WHERE EVT_Evento = P_EVT_EVENTO;

    O_COD_RET := C_OK;
    O_MSG := 'OK';
  END PR_EVENTO_OBTENER;


  PROCEDURE PR_EVENTO_LISTAR (
    P_USU_USUARIO IN NUMBER DEFAULT NULL,
    P_TEV_TIPO    IN NUMBER DEFAULT NULL,
    O_CURSOR      OUT SYS_REFCURSOR,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  ) IS
  BEGIN
    -- [FIX #15] Columnas explícitas en lugar de SELECT *
    OPEN O_CURSOR FOR
      SELECT EVT_Evento,
             USU_Usuario,
             TEV_Tipo,
             EVT_Fecha,
             EVT_Detalle,
             EVT_Created_At
        FROM MUE_EVENTO_APLICACION
       WHERE (P_USU_USUARIO IS NULL OR USU_Usuario = P_USU_USUARIO)
         AND (P_TEV_TIPO    IS NULL OR TEV_Tipo    = P_TEV_TIPO)
       ORDER BY EVT_Fecha DESC;

    O_COD_RET := C_OK;
    O_MSG := 'OK';
  END PR_EVENTO_LISTAR;

END PKG_MUE_EVENTO_APLICACION;
/