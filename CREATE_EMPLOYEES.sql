USE [Stage1]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***************************Drop Data Objects****************************************/
DROP TABLE IF EXISTS [dbo].[S1_PW_Customers]
GO
DROP TABLE IF EXISTS [dbo].[S1_PW_Employees]
GO
DROP TABLE IF EXISTS [dbo].[S1_PW_Employee_Timesheet]
GO
DROP VIEW IF EXISTS [dbo].[S1_V_MM_Stock_Take]
GO
DROP VIEW IF EXISTS [dbo].[S1_V_MM_Material]
GO
DROP TABLE IF EXISTS [dbo].[S1_MM_Stock_Take]
GO

/***************************Drop Metadata Objects****************************************/

DROP PROCEDURE IF EXISTS [dbo].[Create_Import_Batch_Process_Task]
GO
DROP PROCEDURE IF EXISTS [dbo].[Create_Import_Batch_Process]
GO
DROP PROCEDURE IF EXISTS [dbo].[Create_Import_Batch]
GO
DROP VIEW IF EXISTS [dbo].[V_IB_Latest]
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

CREATE VIEW [dbo].[V_IB_Latest]
AS
SELECT        IB_Year, IB_Month, MAX(IB_ID) AS Latest_IB_ID, EOMONTH(DATEFROMPARTS(IB_Year, IB_Month, 1)) AS Last_Day_Of_Month
FROM            dbo.Import_Batch
GROUP BY IB_Year, IB_Month, EOMONTH(DATEFROMPARTS(IB_Year, IB_Month, 1))
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


/***************************Create Data Objects****************************************/
CREATE TABLE [dbo].[S1_MM_Stock_Take](
	[ST_Year] [smallint] NOT NULL,
	[ST_Item_ID] [nvarchar](10) NOT NULL,
	[ST_Material] [nvarchar](20) NOT NULL,
	[ST_Item_Category] [nvarchar](20) NOT NULL,
	[ST_Item_Detail_1] [nvarchar](20) NOT NULL,
	[ST_Item_Detail_2] [nvarchar](20) NOT NULL,
	[ST_Item_Size] [nvarchar](20) NOT NULL,
	[ST_Item_Size_Unit_of_Measure] [nvarchar](5) NOT NULL,
	[ST_Item_Size_Note] [nvarchar](20) NOT NULL,
	[ST_Item_Comment] [nvarchar](50) NOT NULL,
	[ST_Item_Standard_Length_mm] [numeric](10, 2) NOT NULL,
	[ST_Item_Standard_Width_or_Diameter_mm] [numeric](10, 2) NOT NULL,
	[ST_Item_Standard_Height_mm] [numeric](10, 2) NOT NULL,
	[ST_Item_Standard_Interior_Diameter_mm] [numeric](10, 2) NOT NULL,
	[ST_Item_Standard_Thinkness_or_Wall_mm] [numeric](10, 2) NOT NULL,
	[ST_Item_Length_Measured_m] [numeric](10, 3) NULL,
	[ST_Item_Width_Measured_m] [numeric](10, 3) NULL,
	[ST_Item_Full_Units_Counted] [smallint] NULL,
	[ST_Item_Quantity_Unit_of_Measure] [nvarchar](10) NOT NULL,
	[ST_Item_Quantity_Scrapped] [float] NULL,
	[ST_Item_Unit_Price_incl_VAT] [numeric](10, 2) NULL,
	[ST_VAT] [numeric](10, 2) NOT NULL,
	[ST_Item_Source_Quantity_on_Hand_Value_excl_VAT] [float] NOT NULL,
	[ST_Transaction_ID] [nvarchar](20) NOT NULL,
	[IBPT_ID] [int] NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[S1_MM_Stock_Take]  WITH CHECK ADD  CONSTRAINT [FK_S1_MM_Stock_Take_Import_Batch_Process_Task] FOREIGN KEY([IBPT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO

CREATE VIEW [dbo].[S1_V_MM_Material]
AS
SELECT        dbo.S1_MM_Stock_Take.ST_Year AS M_Year, dbo.S1_MM_Stock_Take.ST_Item_ID AS M_Material_Item_ID, dbo.S1_MM_Stock_Take.ST_Material AS M_Material_Type, 
                         dbo.S1_MM_Stock_Take.ST_Item_Category AS M_Material_Item_Category, dbo.S1_MM_Stock_Take.ST_Item_Detail_1 AS M_Material_Item_Detail_1, dbo.S1_MM_Stock_Take.ST_Item_Detail_2 AS M_Material_Item_Detail_2, 
                         dbo.S1_MM_Stock_Take.ST_Item_Size AS M_Material_Item_Size, dbo.S1_MM_Stock_Take.ST_Item_Size_Unit_of_Measure AS M_Material_Item_Size_Unit_Of_Measure, 
                         dbo.S1_MM_Stock_Take.ST_Item_Size_Note AS M_Material_Item_Size_Note, dbo.S1_MM_Stock_Take.ST_Item_Standard_Length_mm AS M_Material_Item_Standard_Length_mm, 
                         dbo.S1_MM_Stock_Take.ST_Item_Standard_Width_or_Diameter_mm AS M_Material_Item_Standard_Width_or_Diameter_mm, dbo.S1_MM_Stock_Take.ST_Item_Standard_Height_mm AS M_Material_Item_Standard_Height_mm,
                          dbo.S1_MM_Stock_Take.ST_Item_Standard_Interior_Diameter_mm AS M_Material_Item_Standard_Interior_Diameter_mm, 
                         dbo.S1_MM_Stock_Take.ST_Item_Standard_Thinkness_or_Wall_mm AS M_Material_Item_Standard_Thinkness_or_Wall_mm, 
                         dbo.S1_MM_Stock_Take.ST_Item_Quantity_Unit_of_Measure AS M_Material_Item_Quantity_Unit_of_Measure
FROM            dbo.S1_MM_Stock_Take INNER JOIN
                         dbo.V_IB_Latest ON dbo.S1_MM_Stock_Take.ST_Year = dbo.V_IB_Latest.IB_Year INNER JOIN
                         dbo.Import_Batch_Process_Task ON dbo.S1_MM_Stock_Take.IBPT_ID = dbo.Import_Batch_Process_Task.IBPT_ID INNER JOIN
                         dbo.Import_Batch_Process ON dbo.Import_Batch_Process_Task.IBP_ID = dbo.Import_Batch_Process.IBP_ID AND dbo.V_IB_Latest.Latest_IB_ID = dbo.Import_Batch_Process.IB_ID
GROUP BY dbo.S1_MM_Stock_Take.ST_Year, dbo.S1_MM_Stock_Take.ST_Item_ID, dbo.S1_MM_Stock_Take.ST_Material, dbo.S1_MM_Stock_Take.ST_Item_Category, dbo.S1_MM_Stock_Take.ST_Item_Detail_1, 
                         dbo.S1_MM_Stock_Take.ST_Item_Detail_2, dbo.S1_MM_Stock_Take.ST_Item_Size, dbo.S1_MM_Stock_Take.ST_Item_Size_Unit_of_Measure, dbo.S1_MM_Stock_Take.ST_Item_Size_Note, 
                         dbo.S1_MM_Stock_Take.ST_Item_Standard_Length_mm, dbo.S1_MM_Stock_Take.ST_Item_Standard_Width_or_Diameter_mm, dbo.S1_MM_Stock_Take.ST_Item_Standard_Height_mm, 
                         dbo.S1_MM_Stock_Take.ST_Item_Standard_Interior_Diameter_mm, dbo.S1_MM_Stock_Take.ST_Item_Standard_Thinkness_or_Wall_mm, dbo.S1_MM_Stock_Take.ST_Item_Quantity_Unit_of_Measure
GO

CREATE VIEW [dbo].[S1_V_MM_Stock_Take]
AS
SELECT        dbo.S1_MM_Stock_Take.ST_Transaction_ID, dbo.S1_MM_Stock_Take.ST_Year, dbo.S1_MM_Stock_Take.ST_Item_ID AS ST_Material_Item_ID, dbo.S1_MM_Stock_Take.ST_Item_Comment AS ST_Stock_Take_Comment, 
                         dbo.S1_MM_Stock_Take.ST_Item_Length_Measured_m AS ST_Length_Measured_m, dbo.S1_MM_Stock_Take.ST_Item_Width_Measured_m AS ST_Width_Measured_m, 
                         dbo.S1_MM_Stock_Take.ST_Item_Full_Units_Counted AS ST_Full_Units_Counted, dbo.S1_MM_Stock_Take.ST_Item_Quantity_Scrapped AS ST_Quantity_Scrapped, 
                         dbo.S1_MM_Stock_Take.ST_Item_Unit_Price_incl_VAT AS ST_Unit_Price_incl_VAT, dbo.S1_MM_Stock_Take.ST_VAT AS ST_VAT_Decimal, 
                         dbo.S1_MM_Stock_Take.ST_Item_Source_Quantity_on_Hand_Value_excl_VAT AS ST_Source_Quantity_on_Hand_Value_excl_VAT
FROM            dbo.S1_MM_Stock_Take INNER JOIN
                         dbo.Import_Batch_Process_Task ON dbo.S1_MM_Stock_Take.IBPT_ID = dbo.Import_Batch_Process_Task.IBPT_ID INNER JOIN
                         dbo.Import_Batch_Process ON dbo.Import_Batch_Process_Task.IBP_ID = dbo.Import_Batch_Process.IBP_ID INNER JOIN
                         dbo.V_IB_Latest ON dbo.Import_Batch_Process.IB_ID = dbo.V_IB_Latest.Latest_IB_ID AND dbo.S1_MM_Stock_Take.ST_Year = dbo.V_IB_Latest.IB_Year
GO

CREATE TABLE [dbo].[S1_PW_Customers](
	[C_Customer_ID] [nvarchar](20) NOT NULL,
	[C_Department_ID] [nvarchar](20) NOT NULL,
	[C_Customer_Name] [nvarchar](100) NOT NULL,
	[C_Contact_Person] [nvarchar](50) NOT NULL,
	[C_Address_Line_1] [nvarchar](100) NOT NULL,
	[C_Address_Line_2] [nvarchar](100) NOT NULL,
	[C_City_Town] [nvarchar](50) NOT NULL,
	[C_Postal_Code] [nvarchar](4) NOT NULL,
	[IBPT_ID] [int] NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[S1_PW_Customers]  WITH CHECK ADD  CONSTRAINT [FK_S1_PW_Customers_Import_Batch_Process_Task] FOREIGN KEY([IBPT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO

CREATE TABLE [dbo].[S1_PW_Employees](
	[E_Employee_ID] [nvarchar](20) NOT NULL,
	[E_Employee_Name] [nvarchar](50) NOT NULL,
	[E_Employee_Surname] [nvarchar](50) NOT NULL,
	[IPBT_ID] [int] NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[S1_PW_Employees]  WITH CHECK ADD  CONSTRAINT [FK_S1_PW_Employees_Import_Batch_Process_Task] FOREIGN KEY([IPBT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO

CREATE TABLE [dbo].[S1_PW_Employee_Timesheet](
	[E_Year] [int] NOT NULL,
	[E_Week_of_Year] [int] NOT NULL,
	[E_Week_End_Date] [date] NOT NULL,
	[E_Project_ID] [nvarchar](7) NOT NULL,
	[E_Employee] [nvarchar](20) NOT NULL,
	[E_Hours] [decimal](38, 4) NOT NULL,
	[IPBT_ID] [int] NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[S1_PW_Employee_Timesheet]  WITH CHECK ADD  CONSTRAINT [FK_S1_PW_Employee_Timesheet_Import_Batch_Process_Task] FOREIGN KEY([IPBT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO
