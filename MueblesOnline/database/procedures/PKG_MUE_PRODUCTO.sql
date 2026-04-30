CREATE OR REPLACE PACKAGE BODY PKG_MUE_PRODUCTO AS

  C_OK    CONSTANT NUMBER := 0;
  C_ERR   CONSTANT NUMBER := 1;
  C_NOFND CONSTANT NUMBER := 2;

  PROCEDURE PR_VALIDAR_PRODUCTO (
    P_CAT_CATEGORIA       IN NUMBER,
    P_PRO_NOMBRE          IN VARCHAR2,
    P_PRO_PRECIO_UNITARIO IN NUMBER,
    P_PRO_CANT_EXISTENTE  IN NUMBER,
    P_PRO_PESO_G          IN NUMBER,
    O_COD_RET             OUT NUMBER,
    O_MSG                 OUT VARCHAR2
  ) IS
    V_EXISTE NUMBER;
  BEGIN
    IF P_PRO_NOMBRE IS NULL THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'El nombre del producto es obligatorio.';
      RETURN;
    END IF;

    IF P_PRO_PRECIO_UNITARIO IS NULL OR P_PRO_PRECIO_UNITARIO < 0 THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'El precio unitario debe ser mayor o igual a cero.';
      RETURN;
    END IF;

    IF P_PRO_CANT_EXISTENTE IS NULL OR P_PRO_CANT_EXISTENTE < 0 THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'La cantidad existente debe ser mayor o igual a cero.';
      RETURN;
    END IF;

    IF P_PRO_PESO_G IS NOT NULL AND P_PRO_PESO_G < 0 THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'El peso no puede ser negativo.';
      RETURN;
    END IF;

    SELECT COUNT(*)
      INTO V_EXISTE
      FROM MUE_CATEGORIA
     WHERE CAT_Categoria = P_CAT_CATEGORIA;

    IF V_EXISTE = 0 THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'La categoría indicada no existe.';
      RETURN;
    END IF;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';
  END PR_VALIDAR_PRODUCTO;


  PROCEDURE PR_PRODUCTO_INSERTAR (
    P_CAT_CATEGORIA       IN NUMBER,
    P_PRO_NOMBRE          IN VARCHAR2,
    P_PRO_DESCRIPCION     IN VARCHAR2,
    P_PRO_PRECIO_UNITARIO IN NUMBER,
    P_PRO_CANT_EXISTENTE  IN NUMBER,
    P_PRO_ALTO_CM         IN NUMBER,
    P_PRO_ANCHO_CM        IN NUMBER,
    P_PRO_PROF_CM         IN NUMBER,
    P_PRO_COLOR           IN VARCHAR2,
    P_PRO_PESO_G          IN NUMBER,
    P_PRO_REFERENCIA      IN VARCHAR2,
    O_PRO_PRODUCTO        OUT NUMBER,
    O_COD_RET             OUT NUMBER,
    O_MSG                 OUT VARCHAR2
  ) IS
    V_EXISTE NUMBER;
  BEGIN
    PR_VALIDAR_PRODUCTO(
      P_CAT_CATEGORIA,
      P_PRO_NOMBRE,
      P_PRO_PRECIO_UNITARIO,
      P_PRO_CANT_EXISTENTE,
      P_PRO_PESO_G,
      O_COD_RET,
      O_MSG
    );

    IF O_COD_RET <> C_OK THEN
      RETURN;
    END IF;

    IF P_PRO_REFERENCIA IS NOT NULL THEN
      SELECT COUNT(*)
        INTO V_EXISTE
        FROM MUE_PRODUCTO
       WHERE PRO_Referencia = P_PRO_REFERENCIA;

      IF V_EXISTE > 0 THEN
        O_COD_RET := C_ERR;
        O_MSG     := 'Ya existe un producto con esa referencia.';
        RETURN;
      END IF;
    END IF;

    INSERT INTO MUE_PRODUCTO (
      CAT_Categoria,
      PRO_Nombre,
      PRO_Descripcion,
      PRO_Precio_Unitario,
      PRO_Cant_Existente,
      PRO_Alto_Cm,
      PRO_Ancho_Cm,
      PRO_Prof_Cm,
      PRO_Color,
      PRO_Peso_G,
      PRO_Referencia,
      PRO_Created_At
    )
    VALUES (
      P_CAT_CATEGORIA,
      P_PRO_NOMBRE,
      P_PRO_DESCRIPCION,
      P_PRO_PRECIO_UNITARIO,
      P_PRO_CANT_EXISTENTE,
      P_PRO_ALTO_CM,
      P_PRO_ANCHO_CM,
      P_PRO_PROF_CM,
      P_PRO_COLOR,
      P_PRO_PESO_G,
      P_PRO_REFERENCIA,
      SYSTIMESTAMP
    )
    RETURNING PRO_Producto INTO O_PRO_PRODUCTO;

    O_COD_RET := C_OK;
    O_MSG     := 'Producto registrado correctamente.';

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Ya existe un producto con esa referencia.';
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al insertar producto: ' || SQLERRM;
  END PR_PRODUCTO_INSERTAR;


  PROCEDURE PR_PRODUCTO_ACTUALIZAR (
    P_PRO_PRODUCTO        IN NUMBER,
    P_CAT_CATEGORIA       IN NUMBER,
    P_PRO_NOMBRE          IN VARCHAR2,
    P_PRO_DESCRIPCION     IN VARCHAR2,
    P_PRO_PRECIO_UNITARIO IN NUMBER,
    P_PRO_CANT_EXISTENTE  IN NUMBER,
    P_PRO_ALTO_CM         IN NUMBER,
    P_PRO_ANCHO_CM        IN NUMBER,
    P_PRO_PROF_CM         IN NUMBER,
    P_PRO_COLOR           IN VARCHAR2,
    P_PRO_PESO_G          IN NUMBER,
    P_PRO_REFERENCIA      IN VARCHAR2,
    O_COD_RET             OUT NUMBER,
    O_MSG                 OUT VARCHAR2
  ) IS
    V_EXISTE NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO V_EXISTE
      FROM MUE_PRODUCTO
     WHERE PRO_Producto = P_PRO_PRODUCTO;

    IF V_EXISTE = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'Producto no encontrado.';
      RETURN;
    END IF;

    PR_VALIDAR_PRODUCTO(
      P_CAT_CATEGORIA,
      P_PRO_NOMBRE,
      P_PRO_PRECIO_UNITARIO,
      P_PRO_CANT_EXISTENTE,
      P_PRO_PESO_G,
      O_COD_RET,
      O_MSG
    );

    IF O_COD_RET <> C_OK THEN
      RETURN;
    END IF;

    IF P_PRO_REFERENCIA IS NOT NULL THEN
      SELECT COUNT(*)
        INTO V_EXISTE
        FROM MUE_PRODUCTO
       WHERE PRO_Referencia = P_PRO_REFERENCIA
         AND PRO_Producto  <> P_PRO_PRODUCTO;

      IF V_EXISTE > 0 THEN
        O_COD_RET := C_ERR;
        O_MSG     := 'Ya existe otro producto con esa referencia.';
        RETURN;
      END IF;
    END IF;

    UPDATE MUE_PRODUCTO
       SET CAT_Categoria       = P_CAT_CATEGORIA,
           PRO_Nombre          = P_PRO_NOMBRE,
           PRO_Descripcion     = P_PRO_DESCRIPCION,
           PRO_Precio_Unitario = P_PRO_PRECIO_UNITARIO,
           PRO_Cant_Existente  = P_PRO_CANT_EXISTENTE,
           PRO_Alto_Cm         = P_PRO_ALTO_CM,
           PRO_Ancho_Cm        = P_PRO_ANCHO_CM,
           PRO_Prof_Cm         = P_PRO_PROF_CM,
           PRO_Color           = P_PRO_COLOR,
           PRO_Peso_G          = P_PRO_PESO_G,
           PRO_Referencia      = P_PRO_REFERENCIA
     WHERE PRO_Producto = P_PRO_PRODUCTO;

    O_COD_RET := C_OK;
    O_MSG     := 'Producto actualizado correctamente.';

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Ya existe otro producto con esa referencia.';
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al actualizar producto: ' || SQLERRM;
  END PR_PRODUCTO_ACTUALIZAR;


  PROCEDURE PR_PRODUCTO_ELIMINAR (
    P_PRO_PRODUCTO IN NUMBER,
    O_COD_RET      OUT NUMBER,
    O_MSG          OUT VARCHAR2
  ) IS
    V_DETALLES NUMBER;
    V_PRECIOS  NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO V_DETALLES
      FROM MUE_ORDEN_DETALLE
     WHERE PRO_Producto = P_PRO_PRODUCTO;

    IF V_DETALLES > 0 THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'No se puede eliminar: el producto tiene '
                   || V_DETALLES || ' detalle(s) de orden asociado(s).';
      RETURN;
    END IF;

    SELECT COUNT(*)
      INTO V_PRECIOS
      FROM MUE_PRECIO
     WHERE PRO_Producto = P_PRO_PRODUCTO;

    IF V_PRECIOS > 0 THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'No se puede eliminar: el producto tiene '
                   || V_PRECIOS || ' precio(s) asociado(s).';
      RETURN;
    END IF;

    DELETE FROM MUE_PRODUCTO
     WHERE PRO_Producto = P_PRO_PRODUCTO;

    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'Producto no encontrado.';
      RETURN;
    END IF;

    O_COD_RET := C_OK;
    O_MSG     := 'Producto eliminado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al eliminar producto: ' || SQLERRM;
  END PR_PRODUCTO_ELIMINAR;


  PROCEDURE PR_PRODUCTO_OBTENER (
    P_PRO_PRODUCTO IN NUMBER,
    O_CURSOR       OUT SYS_REFCURSOR,
    O_COD_RET      OUT NUMBER,
    O_MSG          OUT VARCHAR2
  ) IS
  BEGIN
    -- [FIX #15] Columnas explícitas en lugar d