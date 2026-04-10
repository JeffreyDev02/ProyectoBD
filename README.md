# Portal web — Mueblería UMG (ASP.NET MVC, Visual Basic .NET)

Proyecto **MueblesOnline**: portal para el caso *Muebles de los Alpes* (Bases de Datos II). El acceso a datos contra Oracle 21c debe hacerse mediante **procedimientos, funciones, paquetes u objetos PL/SQL** definidos en el DBMS; no incluir SQL arbitrario embebido en el código de aplicación.

## Requisitos

- Visual Studio 2022 (o 2019) con carga de trabajo **ASP.NET y desarrollo web**
- Por fines didacticos se nos permite usar IA, por lo que el IDE a utilizar será **Antigravity**
- **.NET Framework 4.8.1**
- Oracle Database accesible desde tu red (desarrollo local o servidor del equipo)
- Paquetes NuGet: Visual Studio suele restaurarlos al abrir el proyecto; la carpeta `packages` puede estar en el directorio **padre** del proyecto (`..\packages`), según cómo esté configurado el equipo

## Primer arranque

1. Copiar `connectionStrings.config.example` a `connectionStrings.config` en la **misma carpeta** que `Web.config`.
2. Editar `connectionStrings.config` con tu cadena Oracle real (`OraclePrimary` y, si aplica, `OracleReporting` para consultas de reportes contra réplica).
3. Abrir la carpeta `ProyectoBD` en Visual Studio (**File → Open → Project/Solution**) y seleccionar `MueblesOnline.vbproj` (o la solución `.sln` si el repo la incluye).
4. Restaurar paquetes NuGet (**clic derecho en la solución → Restore NuGet Packages**) si hace falta.
5. Ejecutar con **IIS Express** (F5). El puerto HTTPS puede variar según el `.vbproj` (por ejemplo 44355).

## Configuración destacada

| Elemento | Descripción |
|----------|-------------|
| `connectionStrings.config` | **No se sube a Git** (está en `.gitignore`). Solo existe en cada máquina o en el servidor de despliegue, copiado de forma segura. |
| `connectionStrings.config.example` | Plantilla con nombres de cadena; sí va en el repositorio. |
| `UseReportingDatabaseForReports` (`Web.config` → `appSettings`) | En desarrollo suele ser `false` (misma BD). En producción, `true` cuando los reportes lean la base réplica. |

## API Web (Android y otros clientes)

El proyecto incluye **ASP.NET Web API** (registro en `Global.asax` / `App_Start\WebApiConfig.vb`). Los endpoints REST deben delegar en capas que ejecuten los procedimientos Oracle; la app Android consume esta API por HTTP, no Oracle directamente.

## Despliegue

- No incluir `connectionStrings.config` con contraseñas en el repositorio.
- En el servidor, desplegar credenciales y cadenas por un canal seguro, aparte del control de versiones.

## Documentación del curso

- Enunciado: portal, clientes, productos, carrito, compras, reportes, perfiles, Oracle 21c, DataGuard/réplica para reportes cuando aplique.

## Asistencia con IA

Según el enunciado, el desarrollo debe realizarse con apoyo de IA; el equipo define como herramienta a utilizar **Antigravity** (registro didáctico y de cumplimiento frente al curso).
