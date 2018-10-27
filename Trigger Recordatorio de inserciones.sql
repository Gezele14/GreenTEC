CREATE TRIGGER RecordatorioTipoEspecie 
ON TipoEspecie 
AFTER INSERT, UPDATE   
AS PRINT ('Se van a efectuar cambios en la tabla');  