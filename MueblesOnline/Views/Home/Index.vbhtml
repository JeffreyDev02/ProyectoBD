@Code
    ViewData("Title") = "Home Page"
End Code

<main>
    <section class="row" aria-labelledby="aspnetTitle">
        <h1 id="title">Muebles Online - Grupo 3</h1>
        <p class="lead">Sistema de gestión de inventarios, compras y recursos humanos.</p>
        <p><a href="~/GestionTurnos.aspx" class="btn btn-primary btn-md">Ir a Gestión de Turnos &raquo;</a></p>
        <p><a href="~/GestionConceptos.aspx" class="btn btn-primary btn-md">Ir a Gestión Pagos &raquo;</a></p>
    </section>

    <div class="row">
        <section class="col-md-4" aria-labelledby="gettingStartedTitle">
            <h2 id="gettingStartedTitle">Recursos Humanos</h2>
            <p>
                Acceda al módulo de gestión de turnos para registrar horarios de entrada,
                salida y descripciones del personal del Grupo 3.
            </p>
            <p><a class="btn btn-outline-dark" href="~/GestionTurnos.aspx">Registrar Turnos &raquo;</a></p>
            
        </section>

        <section class="col-md-4" aria-labelledby="librariesTitle">
            <h2 id="librariesTitle">Inventarios</h2>
            <p>NuGet is a free Visual Studio extension that makes it easy to add, remove, and update libraries and tools in Visual Studio projects.</p>
            <p><a class="btn btn-outline-dark" href="https://go.microsoft.com/fwlink/?LinkId=301866">Learn more &raquo;</a></p>
        </section>

        <section class="col-md-4" aria-labelledby="hostingTitle">
            <h2 id="hostingTitle">Compras</h2>
            <p>You can easily find a web hosting company that offers the right mix of features and price for your applications.</p>
            <p><a class="btn btn-outline-dark" href="https://go.microsoft.com/fwlink/?LinkId=301867">Learn more &raquo;</a></p>
        </section>
    </div>
</main>