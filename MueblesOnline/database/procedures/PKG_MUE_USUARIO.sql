SET SERVEROUTPUT ON SIZE UNLIMITED;

PROMPT === 1) Insertar usuario de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_USUARIO.PR_USUARIO_INSERTAR(
    P_ROL_ROL              => 1,
    P_TDC_TIPO_DOCUMENTO   => 1,
    P_PRF_PROFESION        => NULL,
    P_USU_LOGIN            => 'asolis_admin',
    P_USU_PASSWORD_HASH    => '5e884898da28047151d0e56f',
    P_USU_NUMERO_DOCUMENTO => 30051020,
    P_USU_PRIMER_NOMBRE    => 'Ana',
    P_USU_SEGUNDO_NOMBRE   => 'Lucia',
    P_USU_PRIMER_APELLIDO  => 'Solis',
    P_USU_SEGUNDO_APELLIDO => 'Mendez',
    P_USU_CORREO           => 'asolis@muebleria.com',
    O_USU_USUARIO          => V_ID,
    O_COD_RET              => V_RET,
    O_MSG                  => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG || ' ID=' || V_ID);
END;
/

PROMPT === 2) Obtener usuario insertado ===
DECLARE
  V_CUR  SYS_REFCURSOR;
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
  V_ID   NUMBER;
  V_ID_U NUMBER; V_LOG VARCHAR2(50); V_ACT NUMBER; V_NOM VARCHAR2(50); V_APE VARCHAR2(50); V_EML VARCHAR2(100); V_ROL NUMBER;
BEGIN
  SELECT MAX(USU_Usuario) INTO V_ID FROM MUE_USUARIO WHERE USU_Login = 'asolis_admin';

  PKG_MUE_USUARIO.PR_USUARIO_OBTENER(
    P_USU_USUARIO => V_ID,
    O_CURSOR      => V_CUR,
    O_COD_RET     => V_RET,
    O_MSG         => V_MSG
  );
  
  FETCH V_CUR INTO V_ID_U, V_ROL, V_LOG, V_ACT, V_NOM, V_APE, V_EML;
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' LOGIN=' || V_LOG || ' NOMBRE=' || V_NOM || ' ' || V_APE);
  CLOSE V_CUR;
END;
/

PROMPT === 3) Probar Login Exitoso ===
DECLARE
  V_CUR  SYS_REFCURSOR;
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
  V_ID_U NUMBER; V_LOG VARCHAR2(50); V_ROL NUMBER; V_NOM VARCHAR2(50); V_APE VARCHAR2(50);
BEGIN
  PKG_MUE_USUARIO.PR_USUARIO_LOGIN(
    P_USU_LOGIN         => 'asolis_admin',
    P_USU_PASSWORD_HASH => '5e884898da28047151d0e56f',
    O_CURSOR            => V_CUR,
    O_COD_RET           => V_RET,
    O_MSG               => V_MSG
  );
  
  FETCH V_CUR INTO V_ID_U, V_LOG, V_ROL, V_NOM, V_APE;
  IF V_CUR%FOUND THEN
    DBMS_OUTPUT.PUT_LINE('LOGIN OK: Bienvenido ' || V_NOM);
  ELSE
    DBMS_OUTPUT.PUT_LINE('LOGIN ERROR: Credenciales invalidas');
  END IF;
  CLOSE V_CUR;
END;
/

PROMPT === 4) Actualizar datos de usuario ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(USU_Usuario) INTO V_ID FROM MUE_USUARIO WHERE USU_Login = 'asolis_admin';

  PKG_MUE_USUARIO.PR_USUARIO_ACTUALIZAR(
    P_USU_USUARIO          => V_ID,
    P_ROL_ROL              => 1,
    P_TDC_TIPO_DOCUMENTO   => 1,
    P_PRF_PROFESION        => NULL,
    P_USU_LOGIN            => 'asolis_admin',
    P_USU_NUMERO_DOCUMENTO => 30051020,
    P_USU_PRIMER_NOMBRE    => 'Ana',
    P_USU_SEGUNDO_NOMBRE   => 'Lucia',
    P_USU_PRIMER_APELLIDO  => 'Solis (Modificado)',
    P_USU_SEGUNDO_APELLIDO => 'Mendez',
    P_USU_CORREO           => 'ana.solis_new@muebleria.com',
    O_COD_RET              => V_RET,
    O_MSG                  => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('UPDATE RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 5) Cambiar Estado (Desactivar) ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(USU_Usuario) INTO V_ID FROM MUE_USUARIO WHERE USU_Login = 'asolis_admin';

  PKG_MUE_USUARIO.PR_USUARIO_CAMBIAR_ESTADO(
    P_USU_USUARIO => V_ID,
    P_USU_ACTIVO  => 0,
    O_COD_RET     => V_RET,
    O_MSG         => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('ESTADO RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 6) Caso negativo: Login con usuario inactivo ===
DECLARE
  V_CUR  SYS_REFCURSOR;
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
  V_ID_U NUMBER;
BEGIN
  PKG_MUE_USUARIO.PR_USUARIO_LOGIN(
    P_USU_LOGIN         => 'asolis_admin',
    P_USU_PASSWORD_HASH => '5e884898da28047151d0e56f',
    O_CURSOR            => V_CUR,
    O_COD_RET           => V_RET,
    O_MSG               => V_MSG
  );
  
  FETCH V_CUR INTO V_ID_U;
  IF V_CUR%NOTFOUND THEN
    DBMS_OUTPUT.PUT_LINE('ESPERADO: Acceso denegado por cuenta inactiva.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('FALLO: Se permitio el acceso.');
  END IF;
  CLOSE V_CUR;
END;
/

PROMPT === 7) Eliminar usuario de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(USU_Usuario) INTO V_ID FROM MUE_USUARIO WHERE USU_Login = 'asolis_admin';

  PKG_MUE_USUARIO.PR_USUARIO_ELIMINAR(
    P_USU_USUARIO => V_ID,
    O_COD_RET     => V_RET,
    O_MSG         => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('DELETE RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === Verificacion final (Debe ser 0) ===
SELECT COUNT(1) AS CANT FROM MUE_USUARIO WHERE USU_Login = 'asolis_admin';