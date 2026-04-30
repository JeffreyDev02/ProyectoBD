# Guía de instalación y arranque local — Equipo (Muebles Online)

Documento **paso a paso** para quien **aún no tiene herramientas instaladas**: instalar entorno en Windows, **clonar** el repositorio, **restaurar** NuGet, **compilar**, **ejecutar** y **comprobar** que todo funciona.

---

## ¿Está todo correcto? (criterios de éxito)

Si en tu máquina ocurre lo siguiente, el entorno está bien configurado:


| Qué comprobar   | Cómo debe verse                                                                                                                                                                                             |
| --------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Compilación** | Menú **Compilar → Compilar solución** (`Ctrl+Mayús+B`). En **Ver → Salida**, origen **Compilación**: **0 erróneo** (puede decir **1 actualizado** si no hubo cambios desde la última compilación correcta). |
| **Ejecución**   | **F5** o botón verde **IIS Express**. Se abre el navegador en `**https://localhost:`** + un puerto (ej. **44355** según el proyecto).                                                                       |
| **Página**      | Ves la plantilla por defecto de ASP.NET MVC: barra “Inicio / Acerca de / Contacto”, título tipo **“Mi aplicación ASP.NET”** o similar.                                                                      |


Eso confirma que la solución carga, compila y el sitio **levanta** en local. La base de datos Oracle se prueba aparte cuando el equipo tenga esquema y conexión acordados.

---

## 0. Instalación desde cero (sin Visual Studio ni Git)

### 0.1 Windows

Usar **Windows 10 u 11** (64 bits). Con permisos de usuario normales suele bastar; instalar software puede requerir permisos de administrador.

### 0.2 Git

1. Descargar **Git for Windows**: [https://git-scm.com/download/win](https://git-scm.com/download/win)
2. Instalar con opciones por defecto (incluir **Git Bash** opcional pero útil).
3. Comprobar en **PowerShell** o **cmd**:
  ```text
   git --version
  ```
   Debe mostrar un número de versión.

### 0.3 Visual Studio 2022 (recomendado: Community)

1. Descargar el instalador: [https://visualstudio.microsoft.com/es/vs/community/](https://visualstudio.microsoft.com/es/vs/community/)
2. En el instalador, marcar la carga de trabajo **“Desarrollo de ASP.NET y web”** (ASP.NET and web development).
3. En la pestaña **“Componentes individuales”**, si no viene incluido, añadir:
  - **.NET Framework 4.8.1 SDK** o **paquete de compatibilidad / targeting pack para .NET Framework 4.8.1** (el proyecto usa **.NET Framework 4.8.1**).
4. Instalar y reiniciar si el instalador lo pide.
5. Opcional: **Cuenta Microsoft** para licencia Community (gratis para uso educativo/individual según términos de Microsoft).

**Nota:** Este proyecto es **.NET Framework** (no es un “proyecto .NET 8” tipo consola moderno). Hace falta el soporte **ASP.NET y web** en Visual Studio, no solo “Desarrollo de escritorio de .NET”.

---

## 1. Clonar el repositorio

Sustituye la URL por la que use tu equipo (GitHub, Azure DevOps, etc.):

```text
git clone <URL_DEL_REPOSITORIO>
cd <CARPETA_QUE_CREÓ_GIT>
```

En la **raíz del clon** deberías ver, entre otros:

- `MueblesOnline.sln` — **abrir este archivo en Visual Studio** (compatibilidad máxima).
- `MueblesOnline.slnx` — solo Visual Studio 2022 reciente; opcional.
- Carpeta `MueblesOnline\` con `MueblesOnline.vbproj`, `Web.config`, `Controllers`, `Views`, etc.

Si la raíz solo tiene una subcarpeta y no ves el `.sln`, quizá clonaron una rama o ruta incorrecta; la solución debe estar en la **misma carpeta** que contiene `MueblesOnline\` (carpeta del proyecto web).

---

## 2. Abrir la solución en Visual Studio

1. Abrir **Visual Studio 2022**.
2. **Archivo → Abrir → Proyecto o solución**.
3. Seleccionar `**MueblesOnline.sln`** (en la raíz del repositorio clonado).

**Importante:** usar **“Abrir proyecto o solución”**, no **“Abrir una carpeta”** (ese modo no muestra el proyecto MVC igual).

Si **Explorador de soluciones** no se ve: **Vista → Explorador de soluciones** o `**Ctrl+Alt+L`**. Debe aparecer el proyecto **MueblesOnline** con carpetas **Controllers**, **Views**, etc.

---

## 3. Restaurar paquetes NuGet

La carpeta **`packages\`** en la raíz del repo **no** se sube a Git (suele estar en `.gitignore`). Hay que restaurar.

**En Visual Studio**

1. Clic derecho en la **solución** (nodo superior en Explorador de soluciones).
2. **Restaurar paquetes NuGet** (Restore NuGet Packages).

**Comprobar:** tras unos segundos, debe existir la carpeta `packages\` junto a `MueblesOnline.sln`, con subcarpetas como `Oracle.ManagedDataAccess...`, `Microsoft.AspNet.Mvc...`, etc.

Si falla: revisar internet, proxy o firewall; la fuente debe poder llegar a `https://api.nuget.org/`.

---

## 4. Cadenas de conexión Oracle (por máquina)

El `Web.config` referencia un archivo externo:

- Copiar `**MueblesOnline\connectionStrings.config.example`** a `**MueblesOnline\connectionStrings.config**` (misma carpeta que `Web.config`).
- Editar `**connectionStrings.config**` con tu `Data Source`, usuario y contraseña de **desarrollo** (no subir contraseñas reales a Git).

Mientras no exista lógica que falle sin Oracle, el sitio puede arrancar igual; cuando implementen acceso a BD, sin una cadena válida verán errores en tiempo de ejecución al usar esas rutas.

---

## 5. Compilar

1. Configuración: **Debug**.
2. Plataforma: **Any CPU**.
3. Menú **Compilar → Compilar solución** o `**Ctrl+Mayús+B`**.
4. **Ver → Salida** → desplegable **“Mostrar salida de:”** → **Compilación**.

**Éxito:** línea final con **0 erróneo** (puede figurar **1 correcto** o **1 actualizado** según si recompiló o dejó binarios al día).

**Fallo:** abrir **Ver → Lista de errores** y corregir lo que indique (suele ser paquetes no restaurados o referencias rotas).

---

## 6. Ejecutar (levantar el sitio)

1. En la barra superior, el perfil de inicio suele ser **IIS Express (Chrome/Edge)**.
2. **Depurar → Iniciar depuración** o `**F5`**.

**Éxito:** se abre el navegador en `**https://localhost:<puerto>/`** (el puerto HTTPS aparece en las propiedades del proyecto → **Web**; a menudo **44355** si no se cambió).

Debe mostrarse la **página inicial** del template MVC (texto tipo ASP.NET, enlaces Inicio / Acerca de / Contacto).

---

## 7. Cómo verificar que “funciona” (checklist para el equipo)

Marca cada ítem:

- `git --version` funciona.
- Visual Studio abre `**MueblesOnline.sln`** sin errores de carga del proyecto.
- **Restaurar paquetes NuGet** completado; existe carpeta `**packages\`** en la raíz del clon.
- Existe `**MueblesOnline\connectionStrings.config**` (copiado del `.example`) para cuando haga falta Oracle.
- **Compilar solución** → **0 erróneos** en la salida de compilación.
- **F5** → navegador en **localhost** con la página por defecto del sitio.

---

## 8. Problemas frecuentes


| Síntoma                              | Qué revisar                                                                                                  |
| ------------------------------------ | ------------------------------------------------------------------------------------------------------------ |
| No aparece el árbol del proyecto     | No usar “Abrir carpeta”; abrir `**MueblesOnline.sln`**. **Vista → Explorador de soluciones** (`Ctrl+Alt+L`). |
| Errores de ensamblados al compilar   | **Restaurar paquetes NuGet**; cerrar VS, borrar `bin` y `obj` dentro de `MueblesOnline\`, volver a compilar. |
| El navegador no abre o puerto en uso | Cerrar otras instancias de IIS Express; en propiedades del proyecto → **Web**, probar otro puerto.           |
| Página de error amarilla de ASP.NET  | Leer el mensaje; muchas veces es configuración o Oracle cuando ya haya código que consulte la BD.            |


---

## 9. Documentación relacionada

- `**README.md`** — visión general del proyecto y convenciones.
- `**connectionStrings.config.example**` — plantilla de cadenas Oracle.

---

*Actualizar esta guía si cambia la URL del repositorio, la versión de .NET Framework o el flujo de secretos.*