-- CONSULTAS ESPECIFICADAS PARA GREENTEC.



--******
--View solicitado.
--******
CREATE VIEW EspeciesCRPAN AS 
SELECT NombreComun,NombreCientifico,TipoEspecie.Nombre AS Tipo, Descripcion.Detalle AS Detalle, Parque.Nombre AS Parque, Area.Nombre AS Area
FROM Especie
INNER JOIN Descripcion ON Especie.idDescripcion = Descripcion.idDescripcion
INNER JOIN TipoEspecie ON Descripcion.idTipoEspecie = TipoEspecie.idTipoEspecie
INNER JOIN Area ON Especie.idArea = Area.idArea
INNER JOIN Parque ON Area.idParque = Parque.idParque



--******
--CONSULTA QUE MUESTRA EL NUMERO DE PARQUES QUE HAY EN CADA COMUNIDAD
--******
SELECT Comunidad.Nombre, COUNT(Parque.Nombre) AS NumeroParques
FROM Parque
INNER JOIN Comunidad ON Parque.idComunidad = Comunidad.idComunidad
GROUP BY Comunidad.Nombre



--******
--CONSULTA QUE MUESTRA LA EXTENSION TOTAL DE PARQUES EN CADA COMUNIDAD
--******
SELECT Comunidad.Nombre AS Comunidad, SUM(EXTENSION) AS HectareasTotalenParques
FROM (	SELECT Area.idParque AS idP,CONVERT(INT,SUBSTRING(Extension,1,2)) AS EXTENSION
		FROM Area) AS Extension
INNER JOIN Parque ON idP = Parque.idParque
INNER JOIN Comunidad ON Parque.idComunidad = Comunidad.idComunidad
GROUP BY Comunidad.Nombre



-- ********
-- CONSULTA DE DATOS DE LOS VISITANTES CON SU RESPECTIVO ALOJAMIENTO
-- La consulta contiene tres sub consultas, 4 JOINS, CASE, ORDER BY y CONVERT
-- ********
PRINT('CONSULTA PARA OBTENER LOS DATOS DE LOS VISITANTES Y SUS ALOJACIONES CON LA CATEGORÍA CORRESPONDIENTE.')
PRINT('La consulta utiliza 3 sub-consultas, 4 JOINS, CASE, ORDER BY, TOP y CONVERT.')
PRINT('CONSULTA INICIADA')
SELECT TOP (300) Persona.Nombre AS NOMBRE, Persona.PrimerApellido AS PAPELLIDO, Persona.SegundoApellido AS SAPELLIDO, PROFESION, ALOJAMIENTO, CONVERT(nvarchar,CATEGORIA) AS CATEGORIA
FROM (	SELECT Visitante.idPersona AS idPer, Visitante.Profesion AS PROFESION, ALOJAMIENTO, CATEGORIA
		FROM (	SELECT Alojamiento.idAlojamiento AS idAloj, Alojamiento.Nombre AS ALOJAMIENTO  ,CATEGORIA
				FROM (	SELECT idCategoria AS idCat, Nombre AS CATEGORIA
						FROM Categoria) AS Categorias
				INNER JOIN Alojamiento ON Alojamiento.idCategoria = idCat
				INNER JOIN Parque ON Parque.idParque = Alojamiento.idParque) AS Alojamientos
		INNER JOIN Visitante ON Visitante.idAlojamiento = idAloj) AS Visitantes
INNER JOIN Persona ON Persona.idPersona = idPer
WHERE idPersona IS NOT NULL 
ORDER BY CASE Persona.Nombre WHEN Persona.Nombre THEN Persona.Nombre
ELSE Persona.Nombre END
PRINT('CONSULTA FINALIZADA CON ÉXITO')


--********
--CONSULTA QUE MUESTRA LA INFORMACION DEL PERSONAL CON EL SUELDO MAS BAJO Y MAS ALTO
--La consulta utiliza dos funciones agregadas, y CONVERT
--********
PRINT('CONSULTA QUE MUESTRA LA INFORMACION DEL PERSONAL CON EL SUELDO MAS BAJO Y MAS ALTO')
PRINT('La consulta utiliza MAX, MIN y CONVERT como funciones agregadas')
PRINT('CONSULTA INICIADA')
SELECT Personal.idPersonal, Persona.Nombre, Persona.PrimerApellido, Persona.SegundoApellido, Personal.Tipo AS Empleo, Personal.Especialidad, CONVERT(int,Personal.Sueldo) AS Sueldo
FROM (	SELECT MAX(Sueldo) AS SueldoMaximo, MIN(Sueldo) AS SueldoMinimo
		FROM Personal) AS Sueldos
INNER JOIN Personal ON Personal.Sueldo = SueldoMaximo OR Personal.Sueldo = SueldoMinimo
INNER JOIN Persona ON Persona.idPersona = Personal.idPersona
PRINT('CONSULTA FINALIZADA CON ÉXITO')



-- *******
-- Consulta que muestra en nombre comun y especifico de las primeras 50 especies registradas
-- Utilizando LTRIM, COALESCE, SUBSTRING Y TOP.
-- *******
SELECT DISTINCT TOP (50)  LTRIM(NombreComun) AS Especie, COALESCE(NULL,NULL,NombreCientifico) AS NombreCientifico, SUBSTRING(TipoEspecie.Nombre,1,1) AS InicialReino
FROM Especie 
INNER JOIN Descripcion ON Especie.idDescripcion = Descripcion.idDescripcion
INNER JOIN TipoEspecie ON Descripcion.idTipoEspecie = TipoEspecie.idTipoEspecie 



-- *******
-- Consulta para obtener el promedio de plantas y animales en las areas de los parques registrados
-- Utilizando AVERAGE, DISTINCT y UNION.
-- ********
SELECT DISTINCT TipoEspecie.Nombre,
(	SELECT AVG(PoblacionXArea) 
	FROM Especie
	INNER JOIN Descripcion ON Especie.idDescripcion = Descripcion.idDescripcion 
	INNER JOIN TipoEspecie ON Descripcion.idTipoEspecie = TipoEspecie.idTipoEspecie 
	WHERE TipoEspecie.idTipoEspecie = 1) AS PromedioEspecies
FROM Especie 
INNER JOIN Descripcion ON Especie.idDescripcion = Descripcion.idDescripcion 
INNER JOIN TipoEspecie ON Descripcion.idTipoEspecie = TipoEspecie.idTipoEspecie 
WHERE TipoEspecie.idTipoEspecie = 1 
UNION
SELECT DISTINCT TipoEspecie.Nombre,
(	SELECT AVG(PoblacionXArea) 
	FROM Especie
	INNER JOIN Descripcion ON Especie.idDescripcion = Descripcion.idDescripcion 
	INNER JOIN TipoEspecie ON Descripcion.idTipoEspecie = TipoEspecie.idTipoEspecie 
	WHERE TipoEspecie.idTipoEspecie = 2) AS PromedioEspecies
FROM Especie 
INNER JOIN Descripcion ON Especie.idDescripcion = Descripcion.idDescripcion 
INNER JOIN TipoEspecie ON Descripcion.idTipoEspecie = TipoEspecie.idTipoEspecie 
WHERE TipoEspecie.idTipoEspecie = 2 



--*******
-- Consultas realizadas para hacer el ETL.
--*******
PRINT('CONSULTA PARA OBTENER EL NOMBRE DE LAS ESPECIES CON SU RESPECTIVO TIPO.')
PRINT('CONSULTA INICIADA')
SELECT DISTINCT NombreComun , NombreCientifico, TipoEspecie.Nombre AS Tipo
FROM Especie
INNER JOIN Descripcion ON Especie.idDescripcion = Descripcion.idDescripcion
INNER JOIN TipoEspecie ON Descripcion.idTipoEspecie = TipoEspecie.idTipoEspecie
PRINT('CONSULTA FINALIZADA CON ÉXITO')


PRINT('CONSULTA PARA OBTENER LA CADENA ALIMENTICIA CON SUS RESPECTIVOS NOMBRES DE ESPECIES.')
PRINT('CONSULTA INICIADA')
SELECT Depredador, Especie.NombreComun AS presa
FROM (	SELECT Especie.NombreComun AS Depredador , idPresa AS codPresa
		FROM CadenaAlimenticia
		INNER JOIN Especie ON CadenaAlimenticia.idDepredador = Especie.idEspecie) AS DEP
INNER JOIN Especie ON codPresa = Especie.idEspecie
PRINT('CONSULTA FINALIZADA CON ÉXITO')