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