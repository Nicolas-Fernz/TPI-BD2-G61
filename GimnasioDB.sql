CREATE DATABASE GimnasioDB;
GO
USE GimnasioDB;
GO

CREATE TABLE DatosPersonales(
    IdDatosPersonales INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    Apellido VARCHAR(50) NOT NULL,
    Dni CHAR(8) NOT NULL,
    Telefono VARCHAR(20) NULL,
    Email VARCHAR(100) NULL,
    Direccion VARCHAR(100) NULL,
    FechaNacimiento DATE NULL,
);

CREATE TABLE Socio(
    IdSocio INT IDENTITY(1,1) PRIMARY KEY,
    IdDatosPersonales INT NOT NULL,
    FechaAlta DATE NOT NULL,
    Estado VARCHAR(20) NOT NULL,
    CONSTRAINT FK_Socio_DatosPersonales
	FOREIGN KEY (IdDatosPersonales)
	REFERENCES DatosPersonales(IdDatosPersonales)
);

CREATE TABLE SocioHorario (
    IdHorario        INT IDENTITY(1,1) PRIMARY KEY,
    IdSocio          INT  NOT NULL,
    FechaInscripcion DATE NOT NULL,
    CONSTRAINT FK_SocioHorario_Socio
    FOREIGN KEY (IdSocio) REFERENCES Socio(IdSocio)

);

CREATE TABLE Instructor (
    IdInstructor      INT IDENTITY(1,1) PRIMARY KEY,
    IdDatosPersonales INT NOT NULL, 
    Especialidad      VARCHAR(100) NULL,
    CONSTRAINT FK_Instructor_DatosPersonales
        FOREIGN KEY (IdDatosPersonales)
        REFERENCES DatosPersonales(IdDatosPersonales)
);


CREATE TABLE DatosMedicos (
    IdDatosMedicos INT IDENTITY(1,1) PRIMARY KEY,
    IdSocio        INT NOT NULL,
    GrupoSanguineo VARCHAR(5)   NULL,
    Alergias       VARCHAR(200) NULL,
    Lesiones       VARCHAR(200) NULL,
    AptoFisicoVto  DATE         NULL,
    Observaciones  VARCHAR(255) NULL,
    CONSTRAINT FK_DatosMedicos_Socio
        FOREIGN KEY (IdSocio) REFERENCES Socio(IdSocio)
);


CREATE TABLE Usuario(
    IdUsuario INT IDENTITY(1,1) PRIMARY KEY,
    IdDatosPersonales INT NULL,
    NombreUsuario VARCHAR(30) NOT NULL,
    Clave VARCHAR(100) NOT NULL,
    Activo BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Usuario_DatosPersonales
	FOREIGN KEY (IdDatosPersonales)
	REFERENCES DatosPersonales(IdDatosPersonales)
);

CREATE TABLE Rol(
    IdRol INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    Descripcion VARCHAR(50) NULL
);

CREATE TABLE UsuarioRol (
    IdUsuario INT NOT NULL,
    IdRol INT NOT NULL,
    PRIMARY KEY (IdUsuario, IdRol),
    CONSTRAINT FK_UsuarioRol_Usuario
    FOREIGN KEY (IdUsuario) REFERENCES Usuario(IdUsuario),
    CONSTRAINT FK_UsuarioRol_Rol
    FOREIGN KEY (IdRol) REFERENCES Rol(IdRol)
);
CREATE TABLE PlanMembresia (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    Duracion INT NOT NULL 
);

CREATE TABLE SocioMembresia (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    IdSocio INT  NOT NULL,
    IdPlanMembresia INT  NOT NULL,
    FechaInicio DATE NOT NULL,
    FechaFin DATE NULL,
    Activo BIT  NOT NULL DEFAULT 1,
    CONSTRAINT FK_SocioMembresia_Socio
    FOREIGN KEY (IdSocio) REFERENCES Socio(IdSocio),
    CONSTRAINT FK_SocioMembresia_Plan
    FOREIGN KEY (IdPlanMembresia) REFERENCES PlanMembresia(Id)
);

CREATE TABLE Factura (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    IdSocio INT NOT NULL,
    Importe MONEY NOT NULL,
    FechaFacturacion DATE NOT NULL,
    TipoFactu VARCHAR(30) NOT NULL,
    Descrip VARCHAR(255) NULL,
    Pagado BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_Factura_Socio
    FOREIGN KEY (IdSocio) REFERENCES Socio(IdSocio)
);

CREATE TABLE RutinaPersonalizada (
    IdRutina INT IDENTITY(1,1) PRIMARY KEY,
    IdSocio INT NOT NULL,
    IdInstructor INT NOT NULL,
    Descrip VARCHAR(255) NOT NULL,
    CONSTRAINT FK_Rutina_Socio
        FOREIGN KEY (IdSocio) REFERENCES Socio(IdSocio),
    CONSTRAINT FK_Rutina_Instructor
        FOREIGN KEY (IdInstructor) REFERENCES Instructor(IdInstructor)
);


GO
CREATE FUNCTION dbo.fn_EstadoMembresia(@IdSocio INT)
RETURNS VARCHAR(20)
AS
BEGIN
DECLARE @Estado VARCHAR(20);
IF EXISTS (
	SELECT 1
    FROM SocioMembresia
    WHERE IdSocio = @IdSocio
    AND Activo = 1
	AND (FechaFin IS NULL OR FechaFin >= CAST(GETDATE() AS DATE))
    )
SET @Estado = 'Activa';
    ELSE IF EXISTS (
        SELECT 1
        FROM SocioMembresia
        WHERE IdSocio = @IdSocio
    )
        SET @Estado = 'Vencida';
    ELSE
        SET @Estado = 'Sin membresia';
    RETURN @Estado;
END;
GO

-- Esta vista v_FacturasPendientes muestra todas las facturas que todavia no fueron pagadas. Junta los datos del socio, sus datos personales
-- y la factura, tambien calcula el estado de la membrecia con la funcion fn_EstadoMembresia.
-- No guarda datos, solo muesta una consulta lista para usar.

CREATE VIEW v_FacturasPendientes
AS
SELECT
    f.Id,
    f.IdSocio,
    dp.Nombre,
    dp.Apellido,
    f.Importe,
    f.FechaFacturacion,
    f.TipoFactu,
    f.Descrip,
    f.Pagado,
    dbo.fn_EstadoMembresia(f.IdSocio) AS EstadoMembresia
FROM Factura f
JOIN Socio s ON f.IdSocio = s.IdSocio
JOIN DatosPersonales dp ON s.IdDatosPersonales = dp.IdDatosPersonales
WHERE f.Pagado = 0;

GO

CREATE VIEW v_RutinasPorInstructor
AS
(SELECT  RP.IdRutina, 
        S.IdSocio,
        (DPS.Nombre + ' '+ DPS.Apellido) NombreSocio, 
        I.IdInstructor,
        (DPI.Nombre + ' '+ DPI.Apellido) NombreInstructor, 
        I.Especialidad, 
        RP.Descrip Rutina
FROM RutinaPersonalizada RP  
JOIN Socio S ON S.IdSocio = RP.IdSocio
JOIN Instructor I ON I.IdInstructor = RP.IdInstructor
JOIN DatosPersonales DPS ON DPS.IdDatosPersonales = S.IdDatosPersonales
JOIN DatosPersonales DPI ON DPI.IdDatosPersonales = I.IdDatosPersonales)

GO
CREATE VIEW v_SociosDetalle
AS
SELECT
    s.IdSocio,

    -- Datos Personales
    dp.Nombre,
    dp.Apellido,
    dp.Dni,
    dp.Telefono,
    dp.Email,
    dp.Direccion,
    dp.FechaNacimiento,

    -- Datos del socio
    s.FechaAlta,
    s.Estado AS EstadoSocio,

    -- Membresía actual (si la tiene)
    pm.Id AS IdPlan,
    pm.Nombre AS PlanNombre,
    pm.Duracion AS PlanDuracionMeses,

    sm.FechaInicio AS MembresiaFechaInicio,
    sm.FechaFin AS MembresiaFechaFin,
    sm.Activo AS MembresiaActiva,

    -- Estado calculado con tu función
    dbo.fn_EstadoMembresia(s.IdSocio) AS EstadoMembresia,

    -- Datos Médicos
    dm.GrupoSanguineo,
    dm.Alergias,
    dm.Lesiones,
    dm.AptoFisicoVto,
    dm.Observaciones AS ObservacionesMedicas,

    -- Horarios (si se usa la tabla de inscripción)
    sh.FechaInscripcion AS FechaInscripcionHorario,

    -- Última factura (opcional)
    fUltima.Importe AS UltimaFacturaImporte,
    fUltima.FechaFacturacion AS UltimaFacturaFecha,
    fUltima.Pagado AS UltimaFacturaPagado

FROM Socio s
JOIN DatosPersonales dp 
    ON s.IdDatosPersonales = dp.IdDatosPersonales

-- Membresía (puede ser NULL si no tiene)
LEFT JOIN SocioMembresia sm 
    ON sm.IdSocio = s.IdSocio 
    AND sm.Activo = 1

LEFT JOIN PlanMembresia pm
    ON sm.IdPlanMembresia = pm.Id

-- Datos Médicos
LEFT JOIN DatosMedicos dm
    ON dm.IdSocio = s.IdSocio

-- Horarios
LEFT JOIN SocioHorario sh
    ON sh.IdSocio = s.IdSocio

-- Última factura emitida
LEFT JOIN (
    SELECT f1.*
    FROM Factura f1
    JOIN (
        SELECT IdSocio, MAX(FechaFacturacion) FechaMax
        FROM Factura
        GROUP BY IdSocio
    ) fx
        ON f1.IdSocio = fx.IdSocio
       AND f1.FechaFacturacion = fx.FechaMax
) fUltima
    ON fUltima.IdSocio = s.IdSocio;
GO

-- Trigger
CREATE TRIGGER TRG_SocioMembresia_AI
ON SocioMembresia
AFTER INSERT
AS
BEGIN
SET NOCOUNT ON;
    -- cuando se da de alta una nueva membresia, desactiva otras activas del mismo socio
    UPDATE sm
    SET Activo = 0,
	FechaFin = CAST(GETDATE() AS DATE)
    FROM SocioMembresia sm
    JOIN inserted i ON sm.IdSocio = i.IdSocio
    WHERE sm.Id <> i.Id AND sm.Activo = 1;
END;
GO

--   Este procedimiento almancenado inserta una nueva factura a un socio, cargando el importe, tipo , descripcion y la fecha. 
-- La factura por defecto se registra Pagado =0. Al finaliza devuelde el ID de la factura generada mediante SCOPE_IDENTITY ()
-- COn distintas validaciones probadas.
CREATE OR ALTER PROCEDURE sp_RegistrarFactura
    @IdSocio INT,
    @Importe MONEY,
    @TipoFactu VARCHAR(30),
    @Descrip VARCHAR(255) = NULL
AS
BEGIN

    IF Trim(@TipoFactu) = ''
    BEGIN
    RAISERROR('El tipo de factura no puede estar vaico', 16, 1);
    RETURN;
    END;

    -- VALidando que el socio exita 
    IF NOT EXISTS (SELECT 1 FROM Socio WHERE IdSocio = @IdSocio)
    BEGIN
    RAISERROR('El socio indicado no existe.', 16, 1);
    RETURN;
    END;

    -- Validacion de importe 
    IF @Importe IS NULL OR @Importe <= 0
    BEGIN
    RAISERROR('El importe debe ser mayor a cero.', 16, 1);
    RETURN;
    END;

-- insert con validaciones Trim
    INSERT INTO Factura (IdSocio, Importe, FechaFacturacion, TipoFactu, Descrip, Pagado)
    VALUES (
    @IdSocio,
    @Importe,
    CAST(GETDATE() AS DATE),
    Trim(@TipoFactu),
    Trim(@Descrip),
    0);

    SELECT SCOPE_IDENTITY() AS IdFacturaCreada;
END;

GO
--   Este procedimiento almancenado inserta una nueva factura a un socio, cargando el importe, tipo , descripcion y la fecha. 
-- La factura por defecto se registra Pagado =0. Al finaliza devuelde el ID de la factura generada mediante SCOPE_IDENTITY ()
CREATE PROCEDURE sp_ReporteSociosPorPlan
    @IdPlanMembresia INT = NULL,
    @BuscarSoloActivos BIT = 1
AS
BEGIN
    SELECT
        S.IdSocio,
        SM.IdPlanMembresia,
        (DP.Nombre + ' ' + DP.Apellido) NombreCompleto,
        SM.FechaInicio,
        SM.FechaFin,
        SM.Activo MembresiaActiva,
        dbo.fn_EstadoMembresia( s.IdSocio ) AS EstadoMembresia
    FROM Socio S
    JOIN SocioMembresia SM ON SM.IdSocio = S.IdSocio
    JOIN DatosPersonales DP ON DP.IdDatosPersonales = S.IdDatosPersonales
    --Si @BuscarSoloActivos es 0 busca tambien los inactivos, sino pregunta si SM esta activo
    WHERE ( @BuscarSoloActivos = 0 OR SM.Activo = 1)  
    --Si @IdPlanMembresia es diferente a NULL entonces pregunta si SM coincide con la variable
    AND   ( @IdPlanMembresia IS NULL OR @IdPlanMembresia = SM.IdPlanMembresia)
END;
GO

EXEC sp_ReporteSociosPorPlan null, 1;
CREATE OR ALTER TRIGGER TRG_Socio_AU
ON Socio
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- No permitir cambiar la persona asociada al socio
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN deleted d ON i.IdSocio = d.IdSocio
        WHERE i.IdDatosPersonales <> d.IdDatosPersonales
    )
    BEGIN
        RAISERROR('No se puede modificar IdDatosPersonales de un socio.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    -- Validar que FechaAlta no sea futura
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE FechaAlta > CAST(GETDATE() AS DATE)
    )
    BEGIN
        RAISERROR('La FechaAlta no puede ser futura.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    -- Validar Estado no vacío
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE LTRIM(RTRIM(Estado)) = ''
    )
    BEGIN
        RAISERROR('El Estado del socio no puede estar vacío.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

END;
GO
CREATE TRIGGER TRG_SocioMembresia_AD
ON SocioMembresia
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO LogSocioMembresia (
        IdSocio,
        IdPlanMembresia,
        FechaInicio,
        FechaFin,
        FechaEliminacion,
        Usuario
    )
    SELECT
        d.IdSocio,
        d.IdPlanMembresia,
        d.FechaInicio,
        d.FechaFin,
        GETDATE(),
        SYSTEM_USER
    FROM deleted d;
END;
GO
