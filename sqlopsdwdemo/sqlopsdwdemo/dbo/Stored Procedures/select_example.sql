CREATE PROC [dbo].[select_example] @p1 [int] AS
BEGIN
	SELECT [c1], [c2]
	FROM [dbo].[simple_example]
	WHERE [c1] = @p1
END