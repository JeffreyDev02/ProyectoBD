CREATE OR REPLACE PACKAGE BODY PKG_MUE_CUENTA AS

  C_OK    CONSTANT NUMBER := 0;
  C_ERR   CONSTANT NUMBER := 1;
  C_NOFND CONSTANT NUMBER := 2;

  PROCEDURE PR_CUENTA_INSERTAR (
    P_CSE_NO_CUENTA   IN VARCHAR2,
    P_CSE_TIPO        IN VARCHAR2,
    P_CSE_DESCRIPCION IN VARCHAR2,
    P_SED_SEDE        IN NUMBER,
    O_CSE_CUENTA      OUT NUMBER,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  ) IS
    V_EXISTE NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO V_EXISTE
      FROM MUE_SEDE
     WHERE SED_Sede = P_SED_SEDE;

    IF V_EXISTE = 0 THEN
      O_COD_RET := C_ERR;
      O_MSG := 'La sede indicada no existe.';
      RETURN;
    END IF;

    INSERT INTO MUE_CUENTA (
      CSE_No_Cuenta,
      CSE_Tipo,
      CSE_Descripcion,
      SED_Sede
    )
    VALUES (
      P_CSE_NO_CUENTA,
      P_CSE_TIPO,
      P_CSE_DESCRIPCION,
      P_SED_SEDE
    )
    RETURNING CSE_Cuenta_Sede INTO O_CSE_CUENTA;

    O_COD_RET := C_OK;
    O_MSG := 'Cuenta registrada correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG := 'Error al insertar cuenta: ' || SQLERRM;
  END PR_CUENTA_INSERTAR;


  PROCEDURE PR_CUENTA_ACTUALIZAR (
    P_CSE_CUENTA      IN NUMBER,
    P_CSE_NO_CUENTA   IN VARCHAR2,
    P_CSE_TIPO        IN VARCHAR2,
    P_CSE_DESCRIPCION IN VARCHAR2,
    P_SED_SEDE        IN NUMBER,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  ) IS
    V_EXISTE NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO V_EXISTE
      FROM MUE_SEDE
     WHERE SED_Sede = P_SED_SEDE;

    IF V_EXISTE = 0 THEN
      O_COD_RET := C_ERR;
      O_MSG := 'La sede indicada no existe.';
      RETURN;
    END IF;

    UPDATE MUE_CUENTA
       SET CSE_No_Cuenta   = P_CSE_NO_CUENTA,
           CSE_Tipo        = P_CSE_TIPO,
           CSE_Descripcion = P_CSE_DESCRIPCION,
           SED_Sede        = P_SED_SEDE
     WHERE CSE_Cuenta_Sede = P_CSE_CUENTA;

    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG := 'Cuenta no encontrada.';
      RETURN;
    END IF;

    O_COD_RET := C_OK;
    O_MSG := 'Cuenta actualizada correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG := 'Error al actualizar cuenta: ' || SQLERRM;
  END PR_CUENTA_ACTUALIZAR;


  PROCEDURE PR_CUENTA_ELIMINAR (
    P_CSE_CUENTA IN NUMBER,
    O_COD_RET    OUT NUMBER,
    O_MSG        OUT VARCHAR2
  ) IS
  BEGIN
    DELETE FROM MUE_CUENTA
     WHERE CSE_Cuenta_Sede = P_CSE_CUENTA;

    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG := 'Cuenta no encontrada.';
      RETURN;
    END IF;

    O_COD_RET := C_OK;
    O_MSG := 'Cuenta eliminada correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG := 'Error al eliminar cuenta: ' || SQLERRM;
  END PR_CUENTA_ELIMINAR;


  PROCEDURE PR_CUENTA_OBTENER (
    P_CSE_CUENTA IN NUMBER,
    O_CURSOR     OUT SYS_REFCURSOR,
    O_COD_RET    OUT NUMBER,
    O_MSG        OUT VARCHAR2
  ) IS
  BEGIN
    OPEN O_CURSOR FOR
      SELECT *
        FROM MUE_CUENTA
       WHERE CSE_Cuenta_Sede = P_CSE_CUENTA;

    O_COD_RET := C_OK;
    O_MSG := 'OK';
  END PR_CUENTA_OBTENER;


  PROCEDURE PR_CUENTA_LISTAR (
    O_CURSOR  OUT SYS_REFCURSOR,
    O_COD_RET OUT NUMBER,
    O_MSG     OUT VARCHAR2
  ) IS
  BEGIN
    OPEN O_CURSOR FOR
      SELECT *
        FROM MUE_CUENTA
       ORDER BY CSE_Cuenta_Sede DESC;

    O_COD_RET := C_OK;
    O_MSG := 'OK';
  END PR_CUENTA_LISTAR;

END PKG_MUE_CUENTA;
/