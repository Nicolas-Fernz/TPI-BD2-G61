USE GimnasioDB;
GO

/* ============================
   1) DatosPersonales
   ============================ */
INSERT INTO DatosPersonales (Nombre, Apellido, Dni, Telefono, Email, Direccion, FechaNacimiento)
VALUES
('Juan',  'Pérez',     '30111222', '1155550001', 'juan.perez@example.com',  'Av. Siempre Viva 123', '1990-05-10'),
('María', 'Gómez',     '32123456', '1155550002', 'maria.gomez@example.com', 'Calle Falsa 456',      '1988-09-22'),
('Carlos','López',     '28999888', '1155550003', 'carlos.lopez@example.com','San Martín 789',       '1995-01-15'),
('Ana',   'Martínez',  '27888777', '1155550004', 'ana.martinez@example.com','Belgrano 1500',        '1985-03-02'),
('Luis',  'Rodríguez', '26777666', '1155550005', 'luis.rodriguez@example.com','Mitre 2345',        '1982-12-11'),
('Laura', 'Fernández', '35000111', '1155550006', 'laura.fernandez@example.com','Rivadavia 3200',   '1992-07-30'),
('Pedro', 'Sosa',      '34000999', '1155550007', 'pedro.sosa@example.com',   'Alvear 900',          '1998-11-05');
GO
-- IdDatosPersonales:
-- 1 Juan, 2 María, 3 Carlos  -> SOCIOS
-- 4 Ana, 5 Luis              -> INSTRUCTORES
-- 6 Laura, 7 Pedro           -> USUARIOS (admin / recepción)


/* ============================
   2) Socio
   ============================ */
INSERT INTO Socio (IdDatosPersonales, FechaAlta, Estado)
VALUES
(1, '2024-01-10', 'Activo'),   -- Juan
(2, '2024-02-05', 'Activo'),   -- María
(3, '2024-03-01', 'Activo');   -- Carlos
GO
-- IdSocio: 1 Juan, 2 María, 3 Carlos


/* ============================
   3) SocioHorario
   ============================ */
INSERT INTO SocioHorario (IdSocio, FechaInscripcion)
VALUES
(1, '2024-01-10'),
(1, '2024-03-10'),
(2, '2024-02-05'),
(3, '2024-03-01');
GO


/* ============================
   4) Instructor
   ============================ */
INSERT INTO Instructor (IdDatosPersonales, Especialidad)
VALUES
(4, 'Musculación y fuerza'),   -- Ana
(5, 'CrossFit y funcional');   -- Luis
GO
-- IdInstructor: 1 Ana, 2 Luis
-- Ojo: ninguno de estos IdDatosPersonales está en Socio, así que no se “entrenan a sí mismos”


/* ============================
   5) DatosMedicos
   ============================ */
INSERT INTO DatosMedicos (IdSocio, GrupoSanguineo, Alergias, Lesiones, AptoFisicoVto, Observaciones)
VALUES
(1, '0+',  'Ninguna',          'Dolor lumbar leve', '2025-01-31', 'Recomendado evitar peso máximo'),
(2, 'A+',  'Penicilina',       'Sin lesiones',      '2024-12-31', 'Apto para actividad moderada'),
(3, 'B-',  'Nueces',           'Rodilla derecha',   '2025-03-31', 'Evitar impacto alto en rodillas');
GO


/* ============================
   6) Usuario
   ============================ */
INSERT INTO Usuario (IdDatosPersonales, NombreUsuario, Clave, Activo)
VALUES
(6, 'admin',       'admin123',       1),  -- Laura - Admin
(7, 'recepcion1',  'recep123',       1),  -- Pedro - Recepción
(4, 'ana.inst',    'instAna123',     1),  -- Ana   - Instructor
(1, 'juan.socio',  'juanSocio123',   1);  -- Juan  - Socio portal
GO
-- IdUsuario: 1 admin, 2 recepcion1, 3 ana.inst, 4 juan.socio


/* ============================
   7) Rol
   ============================ */
INSERT INTO Rol (Nombre, Descripcion)
VALUES
('Administrador', 'Acceso total al sistema'),
('Recepcion',     'Gestión de socios, cobros y turnos'),
('Instructor',    'Gestión de rutinas y asistencia'),
('Socio',         'Acceso limitado al portal de socio');
GO
-- IdRol: 1 Admin, 2 Recepcion, 3 Instructor, 4 Socio


/* ============================
   8) UsuarioRol
   ============================ */
INSERT INTO UsuarioRol (IdUsuario, IdRol)
VALUES
(1, 1),  -- admin -> Administrador
(2, 2),  -- recepcion1 -> Recepcion
(3, 3),  -- ana.inst -> Instructor
(4, 4);  -- juan.socio -> Socio
GO


/* ============================
   9) PlanMembresia
   ============================ */
INSERT INTO PlanMembresia (Nombre, Duracion)
VALUES
('Mensual',   1),
('Trimestral',3),
('Anual',    12);
GO
-- Id PlanMembresia: 1 Mensual, 2 Trimestral, 3 Anual


/* ============================
   10) SocioMembresia
   ============================ */
INSERT INTO SocioMembresia (IdSocio, IdPlanMembresia, FechaInicio, FechaFin, Activo)
VALUES
(1, 1, '2024-01-10', '2024-02-09', 0),  -- Juan tuvo mensual, ya vencido
(1, 2, '2024-02-10', '2024-05-09', 0),  -- Juan trimestral anterior, vencido
(1, 3, '2024-05-10', NULL,        1),  -- Juan ahora Anual activo

(2, 1, '2024-02-05', '2024-03-05', 0),  -- María mensual anterior
(2, 1, '2024-03-06', NULL,        1),   -- María mensual actual activa

(3, 2, '2024-03-01', NULL,        1);   -- Carlos plan trimestral activo
GO


/* ============================
   11) Factura
   ============================ */
INSERT INTO Factura (IdSocio, Importe, FechaFacturacion, TipoFactu, Descrip, Pagado)
VALUES
(1, 45000.00, '2024-01-10', 'Factura B', 'Alta de membresía Mensual',   1),
(1, 120000.00,'2024-05-10', 'Factura B', 'Alta de membresía Anual',     1),
(2, 45000.00, '2024-03-06', 'Factura B', 'Renovación membresía Mensual',1),
(3, 90000.00, '2024-03-01', 'Factura B', 'Alta de membresía Trimestral',1),
(3, 90000.00, '2024-06-01', 'Factura B', 'Renovación membresía Trimestral',0);
GO


/* ============================
   12) RutinaPersonalizada
   ============================ */
INSERT INTO RutinaPersonalizada (IdSocio, IdInstructor, Descrip)
VALUES
(1, 1, 'Rutina de fuerza 4x semana, énfasis en tren superior y core'),
(2, 2, 'Rutina funcional 3x semana, circuito de alta intensidad'),
(3, 1, 'Rutina de hipertrofia 5x semana, división por grupos musculares');
GO
-- Nota: 
--   IdSocio 1/2/3 (Juan, María, Carlos) son alumnos
--   IdInstructor 1/2 (Ana, Luis) son instructores distintos, 
--   no hay nadie que se entrene a sí mismo ni se mezclan roles raros.
