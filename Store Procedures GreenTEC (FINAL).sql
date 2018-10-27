--STORE PROCEDURES SOLICITADOS.

--******
--STORE PROCEDURE DE ESCRITURA EN CUATRO TABLAS.
--******
USE [GreenTEC]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE Insertar_Pais
	
	@idPais int,
	@Nombre_Pais nvarchar(50),
	@idProvincia int, 
	@Nombre_Provincia nvarchar(50),
	@idCanton int,
	@Nombre_Canton nvarchar(50),
	@idLocalizacion int,
	@Detalles nvarchar(50)

AS

SET NOCOUNT ON;

BEGIN TRAN

	    PRINT ('Empieza Stored Procedure')
        		
		INSERT INTO Pais(idPais,Nombre)
		VALUES (@idPais,@Nombre_Pais)	
	
		PRINT('Inserta País')
    
	
		INSERT INTO Provincia (idProvincia,Nombre,idPais) 
		VALUES ( @idProvincia,@Nombre_Provincia,@idPais)
		 	
		PRINT ('Inserta Provincia')
    
	
		INSERT INTO Canton(idCanton,Nombre,idProvincia) 
		VALUES ( @idCanton, @Nombre_Canton,@idProvincia)
	
		PRINT ('Inserta Cantón')   

	
		INSERT INTO Localizacion(idLocalizacion, idCanton, Detalles) 
		VALUES ( @idLocalizacion, @idCanton, @Detalles)		
		
		PRINT ('Termina Stored Procedure')
    
COMMIT TRAN	   

--*Ejemplo de prueba para el procedure.
--DECLARE	@return_value int
--EXEC	@return_value = [dbo].[Insertar_Pais]
--		@idPais = 3,
--		@Nombre_Pais = N'MEXICO',
--		@idProvincia = 17,
--		@Nombre_Provincia = N'YUCATAN',
--		@idCanton = 131,
--		@Nombre_Canton = N'JALISCO',
--		@idLocalizacion = 131,
--		@Detalles = N'Pase por un recuerdo'



--******
--STORE PROCEDURE DE DOS NIVELES.
--******
--*STORE PROCEDURE AUXILIAR.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Cambiar_Telefono_Nombre
	
	@idPersona int,
	@Nombre nvarchar(50),
	@TelefonoMovil int
	
AS
BEGIN TRAN 
	
	PRINT 'Empieza Store Procedure2'

	UPDATE Persona 
	SET Nombre= @Nombre WHERE idPersona= @idPersona

	If @@Error != 0 
	BEGIN
	PRINT 'Ha ecorrido un error. Abortamos la transacción1'
	--Se lo comunicamos al usuario y deshacemos la transacción
	--todo volverá a estar como si nada hubiera ocurrido
	ROLLBACK TRAN
	END

	UPDATE Personal
	SET TelefonoMovil= @TelefonoMovil WHERE idPersona= @idPersona

	If @@Error != 0 
	BEGIN
	PRINT 'Ha ecorrido un error. Abortamos la transacción2'
	--Se lo comunicamos al usuario y deshacemos la transacción
	--todo volverá a estar como si nada hubiera ocurrido
	ROLLBACK TRAN
	END
	PRINT 'Termina Store Procedure2'
COMMIT TRAN

--*STORE PROCEDURE PRINCIPAL.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Cambiar_Especie_Periodo_Persona
	
	@idTipoEspecie int,
	@idDescripcion int,
	@NombreEspecie varchar(10),
	@PeriodoReproduccion varchar (15),
	@idPersona int,
	@NombrePersona varchar(50),
	@TelefonoMovil int
		
AS
BEGIN TRAN

	PRINT 'Empieza el Stored Procedure'

	UPDATE TipoEspecie
	SET Nombre= @NombreEspecie WHERE idTipoEspecie= @idTipoEspecie

	If @@ERROR != 0 
	
	BEGIN
		PRINT 'Ha ecorrido un error. Abortamos la transacción1'
		--Deshace la transacción
		--Todo volverá a estar como si nada hubiera ocurrido
		ROLLBACK TRAN
	END

	UPDATE Descripcion
	SET PeriodoReproduccion= @PeriodoReproduccion WHERE idDescripcion= @idDescripcion AND idTipoEspecie= @idTipoEspecie

	If @@Error != 0 
	BEGIN
		PRINT 'Ha ecorrido un error. Abortamos la transacción2'
		--Deshace la transacción
		--Todo volverá a estar como si nada hubiera ocurrido
		ROLLBACK TRAN
	END
	EXEC Cambiar_Telefono_Nombre @idPersona,@NombrePersona,@TelefonoMovil

    PRINT 'Termina Stored Procedure'	
COMMIT TRAN

--*Ejemplo de prueba para los stores procedures.
--DECLARE	@return_value int
--EXEC	@return_value = [dbo].[Cambiar_Especie_Periodo_Persona]
--		@idTipoEspecie = 2,
--		@idDescripcion = 1,
--		@NombreEspecie = N'Vegetales',
--		@PeriodoReproduccion = N'Verano',
--		@idPersona = 190956,
--		@NombrePersona = N'Jose',
--		@TelefonoMovil = 99911156
--SELECT	'Return Value' = @return_value





--******
--PROCEDURE DE INSERCIÓN CON UN ARCHIVO XML.
--******
CREATE PROCEDURE InsertarXML
	@x varchar(max)
AS
declare @xmldoc xml
declare @docHandle int

BEGIN

SET NOCOUNT ON;
PRINT('Iniciando PROCEDURE de inserción de datos con un archivo XML.')
set @xmldoc = Convert(XML,@x);
EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmldoc;
insert TipoEspecie select * from openxml(@docHandle,'/Info/Data') with TipoEspecie;
EXEC sp_xml_removedocument @docHandle
PRINT('PROCEDURE de inserción de datos con archivo XML finalizado con éxito.')

END
--***Ejemplo de prueba del store procedure.
--EXEC  InsertarXML @x = '<Info>
--						<Data idTipoEspecie="4" Nombre="Hongos" ></Data>
--						</Info>';
--***	Para borrar la insercion de ejemplo
--DELETE FROM TipoEspecie WHERE TipoEspecie.Nombre IN ('Hongos'); 




--******
--STORED PROCEDURE DE INSERCIÓN MEDIANTE TABLE VALUED PARAMETERS.
--******
--Crear el tipo como tabla. 
CREATE TYPE LocationTableType AS TABLE   
( idTipoEspecie INT  
,Nombre VARCHAR(50) );  
GO

--Crear el procedure que recibe los datos por table valued parameter.  
ALTER PROCEDURE dbo.InsertarTVP  
    @TVP LocationTableType READONLY  
AS 
    SET NOCOUNT ON 
	PRINT('Iniciando PROCEDURE de insercion mediante table valued parameters.') 
    INSERT  TipoEspecie (idTipoEspecie, Nombre) 
    SELECT idTipoEspecie, Nombre  
        FROM  @TVP;  
    PRINT('PROCEDURE de inserción con TVP finalizado con éxito.')
	GO 

--***Ejemplo para probar el funcionamiento del procedure con TVP
--Declarar la variable que que referencia en tipo.   
--DECLARE @LocationTVP AS LocationTableType;  

--***Agregar los datos a la tabla variable.  
--INSERT INTO @LocationTVP (idTipoEspecie, Nombre)  VALUES (4,'Hongos')

--***Pasa los datos de la tabla variable  al stored procedure.  
--EXEC InsertarTVP @LocationTVP;  
--GO
  
--***Para borrar la insercion de ejemplo
--DELETE FROM TipoEspecie WHERE TipoEspecie.Nombre IN ('Hongos'); 




--******
--STORED PROCEDURE UTILIZANDO MERGE.
--******
-- Proceso para insertar y actualizar en una tabla utilizando MERGE y EXECUTE
-- MERGE realiza operaciones de inserción, actualización o eliminación en una tabla de destino en función 
-- de los resultados de una unión con una tabla de origen. 
-- EXECUTE establece el contexto de ejecución de una sesión.
 
CREATE PROCEDURE dbo.InsertarValores
    @idTipoEspecie int,  
    @Nombre nvarchar(50)  
AS   
BEGIN  
    SET NOCOUNT ON;  
	PRINT('Iniciando PROCEDURE de inserción usando MERGE.')
	MERGE TipoEspecie AS target  
    USING (SELECT @idTipoEspecie, @Nombre) AS source (idTipoEspecie, Nombre)
	ON (target.idTipoEspecie = source.idTipoEspecie)  
    WHEN MATCHED THEN   
        UPDATE SET Nombre = source.Nombre
	WHEN NOT MATCHED THEN  
		INSERT (idTipoEspecie, Nombre)  
    VALUES (source.idTipoEspecie, source.Nombre);   
	PRINT('PROCEDURE de inserción con MERGE finalizado con éxito.') 
END; 
--***Ejemplo de insercion basica usando el proceso 
--EXEC  sp_recompile TipoEspecie
--EXEC  InsertarValores @idTipoEspecie = 4, @Nombre = 'Hongos';   
GO
--***	Para borrar la insercion de ejemplo
--DELETE FROM TipoEspecie WHERE TipoEspecie.Nombre IN ('Hongos'); 