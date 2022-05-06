USE [Stage2]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***************************Drop Data Objects****************************************/
DROP TABLE IF EXISTS [dbo].[S2_MM_Material_Group_Lookup]
GO
DROP VIEW IF EXISTS [dbo].[S2_V_MM_Stock_Take_Indicators]
GO
DROP TABLE IF EXISTS [dbo].[S2_MM_Stock_Take]
GO
DROP TABLE IF EXISTS [dbo].[S2_MM_Material]
GO
/***************************Drop Metadata Objects****************************************/

DROP VIEW IF EXISTS [dbo].[V_IB_Latest]
GO
DROP PROCEDURE IF EXISTS [dbo].[Create_Import_Batch_Process_Task]
GO
DROP PROCEDURE IF EXISTS [dbo].[Create_Import_Batch_Process]
GO
DROP PROCEDURE IF EXISTS [dbo].[Create_Import_Batch]
GO
DROP TABLE IF EXISTS [dbo].[Import_Batch_Process_Task]
GO
DROP TABLE IF EXISTS [dbo].[Import_Batch_Process]
GO
DROP TABLE IF EXISTS [dbo].[Import_Batch]
GO

/***************************Create metadata Objects******************************/
CREATE TABLE [dbo].[Import_Batch](
	[IB_ID] [int] IDENTITY(1,1) NOT NULL,
	[IB_Description] [nvarchar](50) NOT NULL,
	[IB_Year] [smallint] NOT NULL,
	[IB_Month] [smallint] NULL,
	[IB_Start] [datetime] NOT NULL,
	[IB_End] [datetime] NULL,
	[IB_Status] [nvarchar](10) NOT NULL,
 CONSTRAINT [PK_Import_Batch] PRIMARY KEY CLUSTERED 
(
	[IB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Import_Batch_Process](
	[IBP_ID] [int] IDENTITY(1,1) NOT NULL,
	[IB_ID] [int] NOT NULL,
	[IBP_Description] [nvarchar](50) NOT NULL,
	[IBP_Start] [datetime] NOT NULL,
	[IBP_End] [datetime] NULL,
	[IBP_Status] [nvarchar](10) NOT NULL,
 CONSTRAINT [PK_Import_Batch_Process] PRIMARY KEY CLUSTERED 
(
	[IBP_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Import_Batch_Process]  WITH CHECK ADD  CONSTRAINT [FK_IBP_IB_ID] FOREIGN KEY([IB_ID])
REFERENCES [dbo].[Import_Batch] ([IB_ID])
GO

CREATE TABLE [dbo].[Import_Batch_Process_Task](
	[IBPT_ID] [int] IDENTITY(1,1) NOT NULL,
	[IBP_ID] [int] NOT NULL,
	[IBPT_Description] [nvarchar](50) NOT NULL,
	[IBPT_Start] [datetime] NOT NULL,
	[IBPT_End] [datetime] NULL,
	[IBPT_Status] [nvarchar](10) NOT NULL,
	[IBPT_Records_In] [int] NULL,
	[IBPT_Records_Failed] [int] NULL,
	[IBPT_Records_Out] [int] NULL,
 CONSTRAINT [PK_Import_Batch_Process_Task] PRIMARY KEY CLUSTERED 
(
	[IBPT_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Import_Batch_Process_Task]  WITH CHECK ADD  CONSTRAINT [FK_IBPT_IBP_ID] FOREIGN KEY([IBP_ID])
REFERENCES [dbo].[Import_Batch_Process] ([IBP_ID])
GO

CREATE PROCEDURE [dbo].[Create_Import_Batch]
	-- Add the parameters for the stored procedure here
	@IB_Description nvarchar(50),
	@IB_Year smallint,
	@IB_Month smallint = NULL,
	@IB_Start datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO [dbo].[Import_Batch] VALUES
           (@IB_Description,
            @IB_Year,
			@IB_Month,
			@IB_Start,
            NULL,
			'Running');
	RETURN SCOPE_IDENTITY()
END
GO
CREATE PROCEDURE [dbo].[Create_Import_Batch_Process]
	-- Add the parameters for the stored procedure here
	@IB_ID int,
	@IBP_Description nvarchar(50),
	@IBP_Start datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO [dbo].[Import_Batch_Process] VALUES
           (@IB_ID,
            @IBP_Description,
			@IBP_Start,
			NULL,
			'Running');
	RETURN SCOPE_IDENTITY()
END
GO
CREATE PROCEDURE [dbo].[Create_Import_Batch_Process_Task]
	-- Add the parameters for the stored procedure here
	@IBP_ID int,
	@IBPT_Description nvarchar(50),
	@IBPT_Start datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO [dbo].[Import_Batch_Process_Task] VALUES
           (@IBP_ID,
            @IBPT_Description,
			@IBPT_Start,
			NULL,
			'Running',
			NULL,
			NULL,
			NULL);
	RETURN SCOPE_IDENTITY()
END
GO

CREATE VIEW [dbo].[V_IB_Latest]
AS
SELECT        IB_Year, IB_Month, MAX(IB_ID) AS Latest_IB_ID, EOMONTH(DATEFROMPARTS(IB_Year, IB_Month, 1)) AS Last_Day_Of_Month
FROM            dbo.Import_Batch
GROUP BY IB_Year, IB_Month, EOMONTH(DATEFROMPARTS(IB_Year, IB_Month, 1))
GO


/***************************Create Data Objects*****************************/
CREATE TABLE [dbo].[S2_MM_Material_Group_Lookup](
	[MG_Material_Type] [nvarchar](20) NOT NULL,
	[MG_Material_Group] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_S2_MM_Material_Group_Lookup] PRIMARY KEY CLUSTERED 
(
	[MG_Material_Type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[S2_MM_Material](
	[M_Year] [int] NOT NULL,
	[M_Material_Item_ID] [nvarchar](10) NOT NULL,
	[M_Material_Group] [nvarchar](20) NOT NULL,
	[M_Material_Type] [nvarchar](20) NOT NULL,
	[M_Material_Item_Category] [nvarchar](20) NOT NULL,
	[M_Material_Item_Detail_1] [nvarchar](20) NOT NULL,
	[M_Material_Item_Detail_2] [nvarchar](20) NOT NULL,
	[M_Material_Item_Size] [nvarchar](20) NOT NULL,
	[M_Material_Item_Size_Unit_Of_Measure] [nvarchar](5) NOT NULL,
	[M_Material_Item_Size_Note] [nvarchar](20) NOT NULL,
	[M_Material_Item_Standard_Length_mm] [numeric](10, 2) NOT NULL,
	[M_Material_Item_Standard_Width_or_Diameter_mm] [numeric](10, 2) NOT NULL,
	[M_Material_Item_Standard_Height_mm] [numeric](10, 2) NOT NULL,
	[M_Material_Item_Standard_Interior_Diameter_mm] [numeric](10, 2) NOT NULL,
	[M_Material_Item_Standard_Thinkness_or_Wall_mm] [numeric](10, 2) NOT NULL,
	[M_Material_Item_Quantity_Unit_of_Measure] [nvarchar](10) NOT NULL,
	[IBPT_ID] [int] NOT NULL,
 CONSTRAINT [PK_S2_MM_Material] PRIMARY KEY CLUSTERED 
(
	[M_Year] ASC,
	[M_Material_Item_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[S2_MM_Material]  WITH CHECK ADD  CONSTRAINT [FK_S2_MM_Material_Import_Batch_Process_Task] FOREIGN KEY([IBPT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO

CREATE TABLE [dbo].[S2_MM_Stock_Take](
	[ST_Transaction_ID] [nvarchar](20) NOT NULL,
	[ST_Year] [int] NOT NULL,
	[ST_Material_Item_ID] [nvarchar](10) NOT NULL,
	[ST_Stock_Take_Comment] [nvarchar](50) NOT NULL,
	[ST_Length_Measured_m] [numeric](10, 3) NULL,
	[ST_Length_Measured_Indicator] [nvarchar](50) NOT NULL,
	[ST_Width_Measured_m] [numeric](10, 3) NULL,
	[ST_Width_Measured_Indicator] [nvarchar](50) NOT NULL,
	[ST_Full_Units_Counted] [smallint] NULL,
	[ST_Full_Units_Counted_Indicator] [nvarchar](50) NOT NULL,
	[ST_Quantity_Scrapped] [float] NULL,
	[ST_Material_Scrapped_Indicator] [nvarchar](50) NOT NULL,
	[ST_Unit_Price_incl_VAT] [numeric](10, 2) NULL,
	[ST_Unit_Price_Available_Indicator] [nvarchar](50) NOT NULL,
	[ST_VAT_Decimal] [numeric](10, 2) NOT NULL,
	[ST_VAT_Percentage] [nvarchar](20) NOT NULL,
	[ST_Source_Quantity_on_Hand_Value_excl_VAT] [float] NOT NULL,
	[IBPT_ID] [int] NOT NULL,
 CONSTRAINT [PK_S2_Stock_Take] PRIMARY KEY CLUSTERED 
(
	[ST_Transaction_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[S2_MM_Stock_Take]  WITH CHECK ADD  CONSTRAINT [FK_S2_MM_Stock_Take_Import_Batch_Process_Task] FOREIGN KEY([IBPT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO

ALTER TABLE [dbo].[S2_MM_Stock_Take]  WITH CHECK ADD  CONSTRAINT [FK_S2_MM_Stock_Take_S2_MM_Material] FOREIGN KEY([ST_Year], [ST_Material_Item_ID])
REFERENCES [dbo].[S2_MM_Material] ([M_Year], [M_Material_Item_ID])
GO

CREATE VIEW [dbo].[S2_V_MM_Stock_Take_Indicators]
AS
SELECT        ST_Year, ST_Stock_Take_Comment, ST_Length_Measured_Indicator, ST_Width_Measured_Indicator, ST_Full_Units_Counted_Indicator, ST_Material_Scrapped_Indicator, ST_Unit_Price_Available_Indicator, ST_VAT_Percentage
FROM            dbo.S2_MM_Stock_Take
GROUP BY ST_Year, ST_Stock_Take_Comment, ST_Length_Measured_Indicator, ST_Width_Measured_Indicator, ST_Full_Units_Counted_Indicator, ST_Material_Scrapped_Indicator, ST_Unit_Price_Available_Indicator, ST_VAT_Percentage
GO