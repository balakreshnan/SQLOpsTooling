CREATE TABLE [dbo].[simple_example] (
    [c1] INT       NOT NULL,
    [c2] INT       NOT NULL,
    [c3] INT       NOT NULL,
    [c5] INT       NOT NULL,
    [c6] INT       NULL,
    [c7] CHAR (10) NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

