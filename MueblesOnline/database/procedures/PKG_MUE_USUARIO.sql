-- =============================================================================
-- Paquete PL/SQL (Oracle 21c)
-- Entidad   : MUE_USUARIO
-- Referencia: Docs/DDL_MUEBLERIA.sql
-- Propósito : CRUD y autenticación de usuarios de aplicación.
-- Ejecutar conectado al esquema MUEBLERIA.
-- =============================================================================

CREATE OR REPLACE PACKAGE PKG_MUE_USUARIO AS

  PROCEDURE PR_USUARIO_INSERTAR (
    P_ROL_ROL                 IN NUMBER,
    P_TDC_TIPO_DOCUMENTO      IN NUMBER,
    P_PRF_PROFESION           IN NUMBER,
    P_USU_LOGIN               IN VARCHAR2,
    P_USU_PASSWORD_HASH       IN VARCHAR2,
    P_USU_ACTIVO              IN NUMBER,
    P_USU_NUMERO_DOCUMENTO    IN NUMBER,
    P_USU_PRIMER_NOMBRE       IN VARCHAR2,
    P_USU_SEGUNDO_NOMBRE      IN VARCHAR2,
    P_USU_PRIMER_APELLIDO     IN VARCHAR2,
    P_USU_SEGUNDO_APELLIDO    IN VARCHAR2,
    P_USU_FECHA_DE_NACIMIENTO IN DATE,
    P_USU_TELEFONO_RESIDENCIA IN NUMBER,
    P_USU_TELEFONO_CELULAR    IN NUMBER,
    P_USU_ZONA                IN NUMBER,
    P_USU_MUNICIPIO           IN VARCHAR2,
    P_USU_DEPARTAMENTO        IN VARCHAR2,
    P_USU_CIUDAD              IN VARCHAR2,
    P_USU_CORREO              IN VARCHAR2,
    P_USU_NIT                 IN NUMBER,
    O_USU_USUARIO             OUT NUMBER,
    O_COD_RET                 OUT NUMBER,
    O_MSG                     OUT VARCHAR2
  );

  PROCEDURE PR_USUARIO_ACTUALIZAR (
    P_USU_USUARIO             IN NUMBER,
    P_ROL_ROL                 IN NUMBER,
    P_TDC_TIPO_DOCUMENTO      IN NUMBER,
    P_PRF_PROFESION           IN NUMBER,
    P_USU_LOGIN               IN VARCHAR2,
    P_USU_NUMERO_DOCUMENTO    IN NUMBER,
    P_USU_PRIMER_NOMBRE       IN VARCHAR2,
    P_USU_SEGUNDO_NOMBRE      IN VARCHAR2,
    P_USU_PRIMER_APELLIDO     IN VARCHAR2,
    P_USU_SEGUNDO_APELLIDO    IN VARCHAR2,
    P_USU_FECHA_DE_NACIMIENTO IN DATE,
    P_USU_TELEFONO_RESIDENCIA IN NUMBER,
    P_USU_TELEFONO_CELULAR    IN NUMBER,
    P_USU_ZONA                IN NUMBER,
    P_USU_MUNICIPIO           IN VARCHAR2,
    P_USU_DEPARTAMENTO        IN VARCHAR2,
    P_USU_CIUDAD              IN VARCHAR2,
    P_USU_CORREO              IN VARCHAR2,
    P_USU_NIT                 IN NUMBER,
    O_COD_RET                 OUT NUMBER,
    O_MSG                     OUT VARCHAR2
  );

  PROCEDURE PR_USUARIO_CAMBIAR_ESTADO (
    P_USU_USUARIO IN NUMBER,
    P_USU_ACTIVO  IN NUMBER,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  );

  PROCEDURE PR_USUARIO_LOGIN (
    P_USU_LOGIN         IN VARCHAR2,
    P_USU_PASSWORD_HASH IN VARCHAR2,
    O_CURSOR            OUT SYS_REFCURSOR,
    O_COD_RET           OUT NUMBER,
    O_MSG               OUT VARCHAR2
  );

  PROCEDURE PR_USUARIO_OBTENER (
    P_USU_USUARIO IN NUMBER,
    O_CURSOR      OUT SYS_REFCURSOR,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  );

  PROCEDURE PR_USUARIO_LISTAR (
    O_CURSOR  OUT SYS_REFCURSOR,
    O_COD_RET OUT NUMBER,
    O_MSG     OUT VARCHAR2
  );

  PROCEDURE PR_USUARIO_ELIMINAR (
    P_USU_USUARIO IN NUMBER,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  );

END PKG_MUE_USUARIO;
/

CREATE OR REPLACE PACKAGE BODY PKG_MUE_USUARIO AS

  C_OK    CONSTANT NUMBER := 0;
  C_ERR   CONSTANT NUMBER := 1;
  C_NOFND CONSTANT NUMBER := 2;

  FUNCTION FN_EXISTE_ROL (P_ROL IN NUMBER) RETURN NUMBER IS
    V_N NUMBER;
  BEGIN
    IF P_ROL IS NULL THEN
      RETURN 1;
    END IF;
    SELECT COUNT(1) INTO V_N FROM MUE_ROL WHERE ROL_Rol = P_ROL;
    RETURN V_N;
  END;

  FUNCTION FN_EXISTE_TIPO_DOC (P_TDC IN NUMBER) RETURN NUMBER IS
    V_N NUMBER;
  BEGIN
    SELECT COUNT(1) INTO V_N FROM MUE_TIPO_DOCUMENTO WHERE TDC_Tipo_Documento = P_TDC;
    RETURN V_N;
  END;

  FUNCTION FN_EXISTE_PROF (P_PRF IN NUMBER) RETURN NUMBER IS
    V_N NUMBER;
  BEGIN
    IF P_PRF IS NULL THEN
      RETURN 1;
    END IF;
    SELECT COUNT(1) INTO V_N FROM MUE_PROFESION WHERE PRF_Profesion = P_PRF;
    RETURN V_N;
  END;

  PROCEDURE PR_USUARIO_INSERTAR (
    P_ROL_ROL                 IN NUMBER,
    P_TDC_TIPO_DOCUMENTO      IN NUMBER,
    P_PRF_PROFESION           IN NUMBER,
    P_USU_LOGIN               IN VARCHAR2,
    P_USU_PASSWORD_HASH       IN VARCHAR2,
    P_USU_ACTIVO              IN NUMBER,
    P_USU_NUMERO_DOCUMENTO    IN NUMBER,
    P_USU_PRIMER_NOMBRE       IN VARCHAR2,
    P_USU_SEGUNDO_NOMBRE      IN VARCHAR2,
    P_USU_PRIMER_APELLIDO     IN VARCHAR2,
    P_USU_SEGUNDO_APELLIDO    IN VARCHAR2,
    P_USU_FECHA_DE_NACIMIENTO IN DATE,
    P_USU_TELEFONO_RESIDENCIA IN NUMBER,
    P_USU_TELEFONO_CELULAR    IN NUMBER,
    P_USU_ZONA                IN NUMBER,
    P_USU_MUNICIPIO           IN VARCHAR2,
    P_USU_DEPARTAMENTO        IN VARCHAR2,
    P_USU_CIUDAD              IN VARCHAR2,
    P_USU_CORREO              IN VARCHAR2,
    P_USU_NIT                 IN NUMBER,
    O_USU_USUARIO             OUT NUMBER,
    O_COD_RET                 OUT NUMBER,
    O_MSG                     OUT VARCHAR2
  ) IS
    V_N NUMBER;
  BEGIN
    O_COD_RET     := C_ERR;
    O_MSG         := NULL;
    O_USU_USUARIO := NULL;

    IF TRIM(P_USU_LOGIN) IS NULL THEN
      O_MSG := 'El login es obligatorio.';
      RETURN;
    END IF;

    IF TRIM(P_USU_PASSWORD_HASH) IS NULL THEN
      O_MSG := 'La contraseña (hash) es obligatoria.';
      RETURN;
    END IF;

    IF P_TDC_TIPO_DOCUMENTO IS NULL THEN
      O_MSG := 'El tipo de documento es obligatorio.';
      RETURN;
    END IF;

    IF P_USU_NUMERO_DOCUMENTO IS NULL THEN
      O_MSG := 'El número de documento es obligatorio.';
      RETURN;
    END IF;

    IF TRIM(P_USU_PRIMER_NOMBRE) IS NULL OR TRIM(P_USU_PRIMER_APELLIDO) IS NULL THEN
      O_MSG := 'Nombre y primer apellido son obligatorios.';
      RETURN;
    END IF;

    IF TRIM(P_USU_CORREO) IS NULL THEN
      O_MSG := 'El correo es obligatorio.';
      RETURN;
    END IF;

    IF P_USU_ACTIVO IS NULL OR P_USU_ACTIVO NOT IN (0, 1) THEN
      O_MSG := 'El estado activo debe ser 0 o 1.';
      RETURN;
    END IF;

    IF FN_EXISTE_TIPO_DOC(P_TDC_TIPO_DOCUMENTO) = 0 THEN
      O_MSG := 'El tipo de documento no existe.';
      RETURN;
    END IF;

    IF FN_EXISTE_ROL(P_ROL_ROL) = 0 THEN
      O_MSG := 'El rol indicado no existe.';
      RETURN;
    END IF;

    IF FN_EXISTE_PROF(P_PRF_PROFESION) = 0 THEN
      O_MSG := 'La profesión indicada no existe.';
      RETURN;
    END IF;

    INSERT INTO MUE_USUARIO (
      ROL_Rol,
      TDC_Tipo_Documento,
      PRF_Profesion,
      USU_Login,
      USU_Password_Hash,
      USU_Activo,
      USU_Numero_Documento,
      USU_Primer_Nombre,
      USU_Segundo_Nombre,
      USU_Primer_Apellido,
      USU_Segundo_Apellido,
      USU_Fecha_De_Nacimiento,
      USU_Telefono_Residencia,
      USU_Telefono_Celular,
      USU_Zona,
      USU_Municipio,
      USU_Departamento,
      USU_Ciudad,
      USU_Correo,
      USU_Nit,
      USU_Created_At
    ) VALUES (
      P_ROL_ROL,
      P_TDC_TIPO_DOCUMENTO,
      P_PRF_PROFESION,
      TRIM(P_USU_LOGIN),
      TRIM(P_USU_PASSWORD_HASH),
      P_USU_ACTIVO,
      P_USU_NUMERO_DOCUMENTO,
      TRIM(P_USU_PRIMER_NOMBRE),
      TRIM(P_USU_SEGUNDO_NOMBRE),
      TRIM(P_USU_PRIMER_APELLIDO),
      TRIM(P_USU_SEGUNDO_APELLIDO),
      P_USU_FECHA_DE_NACIMIENTO,
      P_USU_TELEFONO_RESIDENCIA,
      P_USU_TELEFONO_CELULAR,
      P_USU_ZONA,
      TRIM(P_USU_MUNICIPIO),
      TRIM(P_USU_DEPARTAMENTO),
      TRIM(P_USU_CIUDAD),
      TRIM(P_USU_CORREO),
      P_USU_NIT,
      SYSTIMESTAMP
    )
    RETURNING USU_Usuario INTO O_USU_USUARIO;

    O_COD_RET := C_OK;
    O_MSG     := 'Usuario registrado correctamente.';

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Login o número de documento ya registrado.';
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al insertar usuario: ' || SQLERRM;
      O_USU_USUARIO := NULL;
  END PR_USUARIO_INSERTAR;


  PROCEDURE PR_USUARIO_ACTUALIZAR (
    P_USU_USUARIO             IN NUMBER,
    P_ROL_ROL                 IN NUMBER,
    P_TDC_TIPO_DOCUMENTO      IN NUMBER,
    P_PRF_PROFESION           IN NUMBER,
    P_USU_LOGIN               IN VARCHAR2,
    P_USU_NUMERO_DOCUMENTO    IN NUMBER,
    P_USU_PRIMER_NOMBRE       IN VARCHAR2,
    P_USU_SEGUNDO_NOMBRE      IN VARCHAR2,
    P_USU_PRIMER_APELLIDO     IN VARCHAR2,
    P_USU_SEGUNDO_APELLIDO    IN VARCHAR2,
    P_USU_FECHA_DE_NACIMIENTO IN DATE,
    P_USU_TELEFONO_RESIDENCIA IN NUMBER,
    P_USU_TELEFONO_CELULAR    IN NUMBER,
    P_USU_ZONA                IN NUMBER,
    P_USU_MUNICIPIO           IN VARCHAR2,
    P_USU_DEPARTAMENTO        IN VARCHAR2,
    P_USU_CIUDAD              IN VARCHAR2,
    P_USU_CORREO              IN VARCHAR2,
    P_USU_NIT                 IN NUMBER,
    O_COD_RET                 OUT NUMBER,
    O_MSG                     OUT VARCHAR2
  ) IS
    V_N NUMBER;
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_USU_USUARIO IS NULL THEN
      O_MSG := 'Identificador de usuario inválido.';
      RETURN;
    END IF;

    IF TRIM(P_USU_LOGIN) IS NULL THEN
      O_MSG := 'El login es obligatorio.';
      RETURN;
    END IF;

    IF P_TDC_TIPO_DOCUMENTO IS NULL THEN
      O_MSG := 'El tipo de documento es obligatorio.';
      RETURN;
    END IF;

    IF P_USU_NUMERO_DOCUMENTO IS NULL THEN
      O_MSG := 'El número de documento es obligatorio.';
      RETURN;
    END IF;

    IF TRIM(P_USU_PRIMER_NOMBRE) IS NULL OR TRIM(P_USU_PRIMER_APELLIDO) IS NULL THEN
      O_MSG := 'Nombre y primer apellido son obligatorios.';
      RETURN;
    END IF;

    IF TRIM(P_USU_CORREO) IS NULL THEN
      O_MSG := 'El correo es obligatorio.';
      RETURN;
    END IF;

    IF FN_EXISTE_TIPO_DOC(P_TDC_TIPO_DOCUMENTO) = 0 THEN
      O_MSG := 'El tipo de documento no existe.';
      RETURN;
    END IF;

    IF FN_EXISTE_ROL(P_ROL_ROL) = 0 THEN
      O_MSG := 'El rol indicado no existe.';
      RETURN;
    END IF;

    IF FN_EXISTE_PROF(P_PRF_PROFESION) = 0 THEN
      O_MSG := 'La profesión indicada no existe.';
      RETURN;
    END IF;

    SELECT COUNT(1) INTO V_N FROM MUE_USUARIO WHERE USU_Usuario = P_USU_USUARIO;
    IF V_N = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'Usuario no encontrado.';
      RETURN;
    END IF;

    UPDATE MUE_USUARIO
       SET ROL_Rol                 = P_ROL_ROL,
           TDC_Tipo_Documento      = P_TDC_TIPO_DOCUMENTO,
           PRF_Profesion           = P_PRF_PROFESION,
           USU_Login               = TRIM(P_USU_LOGIN),
           USU_Numero_Documento    = P_USU_NUMERO_DOCUMENTO,
           USU_Primer_Nombre       = TRIM(P_USU_PRIMER_NOMBRE),
           USU_Segundo_Nombre      = TRIM(P_USU_SEGUNDO_NOMBRE),
           USU_Primer_Apellido     = TRIM(P_USU_PRIMER_APELLIDO),
           USU_Segundo_Apellido    = TRIM(P_USU_SEGUNDO_APELLIDO),
           USU_Fecha_De_Nacimiento = P_USU_FECHA_DE_NACIMIENTO,
           USU_Telefono_Residencia = P_USU_TELEFONO_RESIDENCIA,
           USU_Telefono_Celular    = P_USU_TELEFONO_CELULAR,
           USU_Zona                = P_USU_ZONA,
           USU_Municipio           = TRIM(P_USU_MUNICIPIO),
           USU_Departamento        = TRIM(P_USU_DEPARTAMENTO),
           USU_Ciudad              = TRIM(P_USU_CIUDAD),
           USU_Correo              = TRIM(P_USU_CORREO),
           USU_Nit                 = P_USU_NIT,
           USU_Updated_At          = SYSTIMESTAMP
     WHERE USU_Usuario = P_USU_USUARIO;

    O_COD_RET := C_OK;
    O_MSG     := 'Usuario actualizado correctamente.';

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Login o número de documento ya usado por otro usuario.';
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al actualizar usuario: ' || SQLERRM;
  END PR_USUARIO_ACTUALIZAR;


  PROCEDURE PR_USUARIO_CAMBIAR_ESTADO (
    P_USU_USUARIO IN NUMBER,
    P_USU_ACTIVO  IN NUMBER,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_USU_USUARIO IS NULL THEN
      O_MSG := 'Identificador de usuario inválido.';
      RETURN;
    END IF;

    IF P_USU_ACTIVO IS NULL OR P_USU_ACTIVO NOT IN (0, 1) THEN
      O_MSG := 'El estado activo debe ser 0 o 1.';
      RETURN;
    END IF;

    UPDATE MUE_USUARIO
       SET USU_Activo     = P_USU_ACTIVO,
           USU_Updated_At = SYSTIMESTAMP
     WHERE USU_Usuario = P_USU_USUARIO;

    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'Usuario no encontrado.';
      RETURN;
    END IF;

    O_COD_RET := C_OK;
    O_MSG     := 'Estado de usuario actualizado.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al cambiar estado: ' || SQLERRM;
  END PR_USUARIO_CAMBIAR_ESTADO;


  PROCEDURE PR_USUARIO_LOGIN (
    P_USU_LOGIN          IN VARCHAR2,
    P_USU_PASSWORD_HASH  IN VARCHAR2,
    O_CURSOR             OUT SYS_REFCURSOR,
    O_COD_RET            OUT NUMBER,
    O_MSG                OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF TRIM(P_USU_LOGIN) IS NULL OR TRIM(P_USU_PASSWORD_HASH) IS NULL THEN
      O_MSG := 'Login y contraseña son obligatorios.';
      RETURN;
    END IF;

    OPEN O_CURSOR FOR
      SELECT U.USU_Usuario,
             U.USU_Login,
             U.ROL_Rol,
             U.USU_Primer_Nombre,
             U.USU_Primer_Apellido
        FROM MUE_USUARIO U
       WHERE U.USU_Login = TRIM(P_USU_LOGIN)
         AND U.USU_Password_Hash = TRIM(P_USU_PASSWORD_HASH)
         AND U.USU_Activo = 1;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error en login: ' || SQLERRM;
  END PR_USUARIO_LOGIN;


  PROCEDURE PR_USUARIO_OBTENER (
    P_USU_USUARIO IN NUMBER,
    O_CURSOR      OUT SYS_REFCURSOR,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_USU_USUARIO IS NULL THEN
      O_MSG := 'Identificador de usuario inválido.';
      RETURN;
    END IF;

    OPEN O_CURSOR FOR
      SELECT U.USU_Usuario,
             U.ROL_Rol,
             U.USU_Login,
             U.USU_Activo,
             U.USU_Primer_Nombre,
             U.USU_Primer_Apellido,
             U.USU_Correo
        FROM MUE_USUARIO U
       WHERE U.USU_Usuario = P_USU_USUARIO;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al consultar usuario: ' || SQLERRM;
  END PR_USUARIO_OBTENER;


  PROCEDURE PR_USUARIO_LISTAR (
    O_CURSOR  OUT SYS_REFCURSOR,
    O_COD_RET OUT NUMBER,
    O_MSG     OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    OPEN O_CURSOR FOR
      SELECT U.USU_Usuario,
             U.USU_Login
        FROM MUE_USUARIO U
       ORDER BY U.USU_Usuario DESC;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al listar usuarios: ' || SQLERRM;
  END PR_USUARIO_LISTAR;


  PROCEDURE PR_USUARIO_ELIMINAR (
    P_USU_USUARIO IN NUMBER,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_USU_USUARIO IS NULL THEN
      O_MSG := 'Identificador de usuario inválido.';
      RETURN;
    END IF;

    DELETE FROM MUE_USUARIO WHERE USU_Usuario = P_USU_USUARIO;

    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'Usuario no encontrado.';
      RETURN;
    END IF;

    O_COD_RET := C_OK;
    O_MSG     := 'Usuario eliminado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al eliminar usuario: ' || SQLERRM;
  END PR_USUARIO_ELIMINAR;

END PKG_MUE_USUARIO;
/
