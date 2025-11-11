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
    IdRol     INT NOT NULL,
    PRIMARY KEY (IdUsuario, IdRol),
    CONSTRAINT FK_UsuarioRol_Usuario
        FOREIGN KEY (IdUsuario) REFERENCES Usuario(IdUsuario),
    CONSTRAINT FK_UsuarioRol_Rol
        FOREIGN KEY (IdRol) REFERENCES Rol(IdRol)
);

CREATE TABLE SocioMembresia (
    Id              INT IDENTITY(1,1) PRIMARY KEY,
    IdSocio         INT  NOT NULL,
    IdPlanMembresia INT  NOT NULL,
    FechaInicio     DATE NOT NULL,
    FechaFin        DATE NULL,
    Activo          BIT  NOT NULL DEFAULT 1,
    CONSTRAINT FK_SocioMembresia_Socio
        FOREIGN KEY (IdSocio) REFERENCES Socio(IdSocio),
    CONSTRAINT FK_SocioMembresia_Plan
        FOREIGN KEY (IdPlanMembresia) REFERENCES PlanMembresia(Id)
);

CREATE TABLE Factura (
    Id               INT IDENTITY(1,1) PRIMARY KEY,
    IdSocio          INT        NOT NULL,
    Importe          MONEY      NOT NULL,
    FechaFacturacion DATE       NOT NULL,
    TipoFactu        VARCHAR(30) NOT NULL,
    Descrip          VARCHAR(255) NULL,
    Pagado           BIT        NOT NULL DEFAULT 0,
    CONSTRAINT FK_Factura_Socio
        FOREIGN KEY (IdSocio) REFERENCES Socio(IdSocio)
);

CREATE TABLE PlanMembresia (
    Id       INT IDENTITY(1,1) PRIMARY KEY,
    Nombre   VARCHAR(50) NOT NULL,
    Duracion INT         NOT NULL   -- meses
);