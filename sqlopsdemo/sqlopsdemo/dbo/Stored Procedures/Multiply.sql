CREATE PROC [dbo].[Multiply] @colname [varchar](8000),@multiplier [int] AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
	CASE WHEN @colname = 'c1' THEN [c1] ELSE Null END as selectedColumn,
	@colname as columnname,
	@multiplier as multiplier,
	CASE WHEN @colname = 'c1' THEN [c1]* @multiplier ELSE Null END as multiplied
	FROM [dbo].[simple_example]
END