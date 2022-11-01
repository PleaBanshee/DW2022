USE [Stage2]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***************************Drop Data Objects****************************************/
DROP TABLE IF EXISTS [dbo].[S2_PW_Employee_Timesheet]
GO
DROP TABLE IF EXISTS [dbo].[S2_PW_Internal_Projects]
GO
DROP TABLE IF EXISTS [dbo].[S2_PW_Customers]
GO
DROP TABLE IF EXISTS [dbo].[S2_PW_Customer_Department]
GO
DROP TABLE IF EXISTS [dbo].[S2_PW_Customer_Department_Group]
GO
DROP TABLE IF EXISTS [dbo].[S2_PW_Employees]
GO
DROP TABLE IF EXISTS [dbo].[S2_MM_Material_Group_Lookup]
GO
DROP VIEW IF EXISTS [dbo].[S2_V_MM_Stock_Take_Indicators]
GO
DROP TABLE IF EXISTS [dbo].[S2_MM_Stock_Take]
GO
DROP TABLE IF EXISTS [dbo].[S2_MM_Material]
GO
DROP TABLE IF EXISTS [dbo].[Employee_Lookup]
GO
DROP VIEW IF EXISTS [dbo].[S2_V_Employees]
GO
DROP VIEW IF EXISTS [dbo].[S2_V_Employee_TimeSheet_Fact]
GO
DROP VIEW IF EXISTS [dbo].[S2_V_PW_Project]
GO
DROP VIEW IF EXISTS [dbo].[S2_V_PW_Customer]
GO
DROP VIEW IF EXISTS [dbo].[S2_V_PW_Project]
GO
DROP VIEW IF EXISTS [dbo].[S2_V_PW_Project_Status]
GO
DROP VIEW IF EXISTS [dbo].[S2_V_Annual_Project_Costs_Analysis]
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
SELECT IB_Year, IB_Month, MAX(IB_ID) AS Latest_IB_ID, EOMONTH(DATEFROMPARTS(IB_Year, IB_Month, 1)) AS Last_Day_Of_Month
FROM dbo.Import_Batch
GROUP BY IB_Year, IB_Month, EOMONTH(DATEFROMPARTS(IB_Year, IB_Month, 1))
GO


/***************************Create Data Objects*****************************/
CREATE TABLE [dbo].[Employee_Lookup](
	[Employee_ID] [nvarchar](20) NOT NULL,
	[Employee_Fullname] [nvarchar](100) NULL
) ON [PRIMARY]
GO

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

-- Selects all the stock take indicator fields 
CREATE VIEW [dbo].[S2_V_MM_Stock_Take_Indicators]
AS
SELECT ST_Year, ST_Stock_Take_Comment, ST_Length_Measured_Indicator, ST_Width_Measured_Indicator, ST_Full_Units_Counted_Indicator, ST_Material_Scrapped_Indicator, ST_Unit_Price_Available_Indicator, ST_VAT_Percentage
FROM dbo.S2_MM_Stock_Take
GROUP BY ST_Year, ST_Stock_Take_Comment, ST_Length_Measured_Indicator, ST_Width_Measured_Indicator, ST_Full_Units_Counted_Indicator, ST_Material_Scrapped_Indicator, ST_Unit_Price_Available_Indicator, ST_VAT_Percentage
GO

CREATE TABLE [dbo].[S2_PW_Employees](
	[E_Employee_ID] [nvarchar](20) NOT NULL,
	[IB_Year] [smallint] NOT NULL,
	[E_Employee_Name] [nvarchar](50) NOT NULL,
	[E_Employee_Surname] [nvarchar](50) NOT NULL,
	[E_Employee_Fullname] [nvarchar](100) NOT NULL,
	[IPBT_ID] [int] NOT NULL,
 CONSTRAINT [PK_Employees] PRIMARY KEY CLUSTERED 
(
	[E_Employee_ID] ASC,
	[IB_Year] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[S2_PW_Employees]  WITH CHECK ADD  CONSTRAINT [FK_S2_PW_Employees_Import_Batch_Process_Task] FOREIGN KEY([IPBT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO

ALTER TABLE [dbo].[S2_PW_Employees] CHECK CONSTRAINT [FK_S2_PW_Employees_Import_Batch_Process_Task]
GO

CREATE TABLE [dbo].[S2_PW_Customer_Department_Group](
	[G_Customer_Group_ID] [nvarchar](10) NOT NULL,
	[IB_Year] [smallint] NOT NULL,
	[G_Customer_Group_Name] [nvarchar](50) NOT NULL,
	[G_Internal_Or_External] [nvarchar](10) NOT NULL,
	[IBPT_ID] [int] NOT NULL,
	CONSTRAINT PK_Customer_Department_Group PRIMARY KEY ([G_Customer_Group_ID], [IB_Year])
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[S2_PW_Customer_Department_Group]  WITH CHECK ADD  CONSTRAINT [FK_S2_PW_Customer_Department_Group_Import_Batch_Process_Task] FOREIGN KEY([IBPT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO

CREATE TABLE [dbo].[S2_PW_Customer_Department](
	[D_Department_ID] [nvarchar](20) NOT NULL,
	[IB_Year] [smallint] NOT NULL,
	[D_Department_Name] [nvarchar](60) NOT NULL,
	[D_Customer_Group_ID] [nvarchar](10) NOT NULL,
	[IBPT_ID] [int] NOT NULL,
	CONSTRAINT PK_Customer_Department PRIMARY KEY ([D_Department_ID], [IB_Year])
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[S2_PW_Customer_Department]  WITH CHECK ADD  CONSTRAINT [FK_S2_PW_Customer_Department_Group] FOREIGN KEY([D_Customer_Group_ID],[IB_Year])
REFERENCES [dbo].[S2_PW_Customer_Department_Group] ([G_Customer_Group_ID],[IB_Year])
GO

ALTER TABLE [dbo].[S2_PW_Customer_Department]  WITH CHECK ADD  CONSTRAINT [FK_S2_PW_Customer_Department_Import_Batch_Process_Task] FOREIGN KEY([IBPT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO

CREATE TABLE [dbo].[S2_PW_Customers](
	[C_Customer_ID] [nvarchar](20) NOT NULL,
	[IB_Year] [smallint] NOT NULL,
	[C_Department_ID] [nvarchar](20) NOT NULL,
	[C_Customer_Name] [nvarchar](100) NOT NULL,
	[C_Contact_Person] [nvarchar](50) NOT NULL,
	[C_Address_Line_1] [nvarchar](100) NOT NULL,
	[C_Address_Line_2] [nvarchar](100) NOT NULL,
	[C_City_Town] [nvarchar](50) NOT NULL,
	[C_Postal_Code] [nvarchar](4) NOT NULL,
	[IBPT_ID] [int] NOT NULL,
	CONSTRAINT PK_Customers PRIMARY KEY ([C_Customer_ID], [IB_Year])
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[S2_PW_Customers]  WITH CHECK ADD  CONSTRAINT [FK_S2_PW_Customers_Department] FOREIGN KEY([C_Department_ID],[IB_Year])
REFERENCES [dbo].[S2_PW_Customer_Department] ([D_Department_ID],[IB_Year])
GO

ALTER TABLE [dbo].[S2_PW_Customers]  WITH CHECK ADD  CONSTRAINT [FK_S2_PW_Customers_Import_Batch_Process_Task] FOREIGN KEY([IBPT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO

CREATE TABLE [dbo].[S2_PW_Internal_Projects](
	[IP_Project_ID] [nvarchar](7) NOT NULL,
	[IB_Year] [smallint] NOT NULL,
	[IP_Request_Date] [date] NOT NULL,
	[IP_Customer_ID] [nvarchar](20) NOT NULL,
	[IP_Project_Category] [nvarchar](50) NOT NULL,
	[IP_Project_Description] [nvarchar](200) NOT NULL,
	[IP_Status] [nvarchar](50) NOT NULL,
	[IP_Labour_Costs] [decimal](38,4) NULL,
	[IP_Material_Costs] [decimal](38,4)  NULL,
	[IP_Handling_Fee] [decimal](38,4) NULL,
	[IP_Service_Billing_Number] [nvarchar](50) NOT NULL,
	[IBPT_ID] [int] NOT NULL,
	CONSTRAINT PK_Projects PRIMARY KEY([IP_Project_ID], [IB_Year])
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[S2_PW_Internal_Projects]  WITH CHECK ADD  CONSTRAINT [FK_S2_PW_Internal_Projects_Customer] FOREIGN KEY([IP_Customer_ID],[IB_Year])
REFERENCES [dbo].[S2_PW_Customers] ([C_Customer_ID],[IB_Year])
GO

ALTER TABLE [dbo].[S2_PW_Internal_Projects]  WITH CHECK ADD  CONSTRAINT [FK_S2_PW_Internal_Projects_Import_Batch_Process_Task] FOREIGN KEY([IBPT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO

CREATE TABLE [dbo].[S2_PW_Employee_Timesheet](
	[E_Year] [int] NOT NULL,
	[IB_Year] [smallint] NOT NULL,
	[E_Week_of_Year] [int] NOT NULL,
	[E_Week_End_Date] [date] NOT NULL,
	[E_Project_ID] [nvarchar](7) NOT NULL,
	[E_Employee] [nvarchar](100) NOT NULL,
	[E_Hours] [decimal](38, 4) NULL,
	[IPBT_ID] [int] NOT NULL,
	[E_Employee_ID] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_S2_PW_Employee_Timesheet_1] PRIMARY KEY CLUSTERED 
(
	[IB_Year] ASC,
	[E_Week_End_Date] ASC,
	[E_Project_ID] ASC,
	[E_Employee_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[S2_PW_Employee_Timesheet]  WITH CHECK ADD  CONSTRAINT [FK_S2_PW_Employee_Timesheet_Employee] FOREIGN KEY([E_Employee_ID], [IB_Year])
REFERENCES [dbo].[S2_PW_Employees] ([E_Employee_ID], [IB_Year])
GO

ALTER TABLE [dbo].[S2_PW_Employee_Timesheet] CHECK CONSTRAINT [FK_S2_PW_Employee_Timesheet_Employee]
GO

ALTER TABLE [dbo].[S2_PW_Employee_Timesheet]  WITH CHECK ADD  CONSTRAINT [FK_S2_PW_Employee_Timesheet_Import_Batch_Process_Task] FOREIGN KEY([IPBT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO

ALTER TABLE [dbo].[S2_PW_Employee_Timesheet] CHECK CONSTRAINT [FK_S2_PW_Employee_Timesheet_Import_Batch_Process_Task]
GO

ALTER TABLE [dbo].[S2_PW_Employee_Timesheet]  WITH CHECK ADD  CONSTRAINT [FK_S2_PW_Employee_Timesheet_Project] FOREIGN KEY([E_Project_ID], [IB_Year])
REFERENCES [dbo].[S2_PW_Internal_Projects] ([IP_Project_ID], [IB_Year])
GO

ALTER TABLE [dbo].[S2_PW_Employee_Timesheet] CHECK CONSTRAINT [FK_S2_PW_Employee_Timesheet_Project]
GO

-- Selects all details of the employee: their ID, name, surname and fullname
CREATE VIEW [dbo].[S2_V_Employees]
AS
SELECT dbo.S2_PW_Employees.E_Employee_ID, dbo.S2_PW_Employees.E_Employee_Name, dbo.S2_PW_Employees.E_Employee_Surname, dbo.S2_PW_Employees.E_Employee_Fullname, dbo.S2_PW_Employees.IPBT_ID, 
                  dbo.Import_Batch.IB_Year
FROM     dbo.S2_PW_Employees INNER JOIN
                  dbo.Import_Batch_Process_Task ON dbo.S2_PW_Employees.IPBT_ID = dbo.Import_Batch_Process_Task.IBPT_ID INNER JOIN
                  dbo.Import_Batch_Process ON dbo.Import_Batch_Process_Task.IBP_ID = dbo.Import_Batch_Process.IBP_ID INNER JOIN
                  dbo.Import_Batch ON dbo.Import_Batch_Process.IB_ID = dbo.Import_Batch.IB_ID
GROUP BY dbo.S2_PW_Employees.E_Employee_ID, dbo.S2_PW_Employees.E_Employee_Name, dbo.S2_PW_Employees.E_Employee_Surname, dbo.S2_PW_Employees.E_Employee_Fullname, dbo.S2_PW_Employees.IPBT_ID, 
                  dbo.Import_Batch.IB_Year
GO

-- "Selects the employee working on a project, the project ID, weekend of the timesheet submission, and the hours an empoyee worked on the project during that week"
CREATE VIEW [dbo].[S2_V_Employee_TimeSheet_Fact]
AS
SELECT        dbo.S2_PW_Employee_Timesheet.E_Employee, dbo.S2_PW_Employee_Timesheet.E_Week_End_Date, dbo.S2_PW_Employee_Timesheet.E_Project_ID, dbo.S2_PW_Employee_Timesheet.E_Hours, 
                         dbo.S2_PW_Employee_Timesheet.IPBT_ID, dbo.Import_Batch.IB_Year, dbo.S2_PW_Employee_Timesheet.E_Employee_ID
FROM            dbo.S2_PW_Employee_Timesheet INNER JOIN
                         dbo.Import_Batch_Process_Task ON dbo.S2_PW_Employee_Timesheet.IPBT_ID = dbo.Import_Batch_Process_Task.IBPT_ID INNER JOIN
                         dbo.Import_Batch_Process ON dbo.Import_Batch_Process_Task.IBP_ID = dbo.Import_Batch_Process.IBP_ID INNER JOIN
                         dbo.Import_Batch ON dbo.Import_Batch_Process.IB_ID = dbo.Import_Batch.IB_ID
GROUP BY dbo.S2_PW_Employee_Timesheet.E_Employee, dbo.S2_PW_Employee_Timesheet.E_Week_End_Date, dbo.S2_PW_Employee_Timesheet.E_Project_ID, dbo.S2_PW_Employee_Timesheet.E_Hours, 
                         dbo.S2_PW_Employee_Timesheet.IPBT_ID, dbo.Import_Batch.IB_Year, dbo.S2_PW_Employee_Timesheet.E_Employee_ID
GO

-- Selects all details from the Customer, such as Customer name, their department and department group IDs and names, contact details and address lines.
CREATE VIEW [dbo].[S2_V_PW_Customer]
AS
SELECT        dbo.S2_PW_Customer_Department_Group.G_Customer_Group_ID, dbo.S2_PW_Customer_Department_Group.G_Customer_Group_Name, dbo.S2_PW_Customer_Department.D_Department_ID, 
                         dbo.S2_PW_Customer_Department.D_Department_Name, dbo.S2_PW_Customers.C_Customer_ID, dbo.S2_PW_Customers.C_Department_ID, dbo.S2_PW_Customers.C_Customer_Name, 
                         dbo.S2_PW_Customers.C_Contact_Person, dbo.S2_PW_Customers.C_Address_Line_1, dbo.S2_PW_Customers.C_Address_Line_2, dbo.S2_PW_Customers.C_City_Town, dbo.S2_PW_Customers.C_Postal_Code, 
                         dbo.Import_Batch.IB_Year, dbo.S2_PW_Customer_Department_Group.G_Internal_Or_External
FROM            dbo.Import_Batch_Process_Task INNER JOIN
                         dbo.S2_PW_Customer_Department_Group INNER JOIN
                         dbo.S2_PW_Customer_Department ON dbo.S2_PW_Customer_Department_Group.G_Customer_Group_ID = dbo.S2_PW_Customer_Department.D_Customer_Group_ID AND 
                         dbo.S2_PW_Customer_Department_Group.IB_Year = dbo.S2_PW_Customer_Department.IB_Year INNER JOIN
                         dbo.S2_PW_Customers ON dbo.S2_PW_Customer_Department.D_Department_ID = dbo.S2_PW_Customers.C_Department_ID AND dbo.S2_PW_Customer_Department.IB_Year = dbo.S2_PW_Customers.IB_Year ON 
                         dbo.Import_Batch_Process_Task.IBPT_ID = dbo.S2_PW_Customer_Department_Group.IBPT_ID INNER JOIN
                         dbo.Import_Batch_Process INNER JOIN
                         dbo.Import_Batch ON dbo.Import_Batch_Process.IB_ID = dbo.Import_Batch.IB_ID ON dbo.Import_Batch_Process_Task.IBP_ID = dbo.Import_Batch_Process.IBP_ID
GROUP BY dbo.S2_PW_Customer_Department_Group.G_Customer_Group_ID, dbo.S2_PW_Customer_Department_Group.G_Customer_Group_Name, dbo.S2_PW_Customer_Department.D_Department_ID, 
                         dbo.S2_PW_Customer_Department.D_Department_Name, dbo.S2_PW_Customers.C_Customer_ID, dbo.S2_PW_Customers.C_Department_ID, dbo.S2_PW_Customers.C_Customer_Name, 
                         dbo.S2_PW_Customers.C_Contact_Person, dbo.S2_PW_Customers.C_Address_Line_1, dbo.S2_PW_Customers.C_Address_Line_2, dbo.S2_PW_Customers.C_City_Town, dbo.S2_PW_Customers.C_Postal_Code, 
                         dbo.Import_Batch.IB_Year, dbo.S2_PW_Customer_Department_Group.G_Internal_Or_External
GO

/********** Stage 2 View Project *************/
--Selects the project category, request date, description, and status(dimension) and performs a group by. 
CREATE VIEW [dbo].[S2_V_PW_Project]
AS
SELECT        dbo.S2_PW_Internal_Projects.IP_Project_ID, dbo.S2_PW_Internal_Projects.IP_Project_Category, dbo.S2_PW_Internal_Projects.IP_Project_Description, dbo.S2_PW_Internal_Projects.IP_Request_Date, 
                         dbo.S2_PW_Internal_Projects.IP_Status, dbo.Import_Batch.IB_Year, dbo.S2_PW_Internal_Projects.IBPT_ID
FROM            dbo.Import_Batch INNER JOIN
                         dbo.Import_Batch_Process ON dbo.Import_Batch.IB_ID = dbo.Import_Batch_Process.IB_ID INNER JOIN
                         dbo.Import_Batch_Process_Task ON dbo.Import_Batch_Process.IBP_ID = dbo.Import_Batch_Process_Task.IBP_ID INNER JOIN
                         dbo.S2_PW_Internal_Projects ON dbo.Import_Batch_Process_Task.IBPT_ID = dbo.S2_PW_Internal_Projects.IBPT_ID
GO

/********* Stage 2 View Project Status *********/
--Selects  the project status
CREATE VIEW [dbo].[S2_V_PW_Project_Status]
AS
SELECT        dbo.S2_PW_Internal_Projects.IP_Status, dbo.Import_Batch.IB_Year, dbo.S2_PW_Internal_Projects.IBPT_ID
FROM            dbo.Import_Batch INNER JOIN
                         dbo.Import_Batch_Process ON dbo.Import_Batch.IB_ID = dbo.Import_Batch_Process.IB_ID INNER JOIN
                         dbo.Import_Batch_Process_Task ON dbo.Import_Batch_Process.IBP_ID = dbo.Import_Batch_Process_Task.IBP_ID INNER JOIN
                         dbo.S2_PW_Internal_Projects ON dbo.Import_Batch_Process_Task.IBPT_ID = dbo.S2_PW_Internal_Projects.IBPT_ID
GROUP BY dbo.S2_PW_Internal_Projects.IP_Status, dbo.Import_Batch.IB_Year, dbo.S2_PW_Internal_Projects.IBPT_ID
GO

-- Selects all the measurements and relevant keys involving the costs of a project
CREATE VIEW [dbo].[S2_V_Annual_Project_Costs_Analysis]
AS
SELECT dbo.S2_PW_Internal_Projects.IP_Request_Date, dbo.S2_PW_Internal_Projects.IP_Project_ID, dbo.S2_PW_Internal_Projects.IP_Customer_ID, dbo.S2_PW_Internal_Projects.IP_Status, 
                  dbo.S2_PW_Internal_Projects.IP_Service_Billing_Number, dbo.S2_PW_Internal_Projects.IP_Labour_Costs, dbo.S2_PW_Internal_Projects.IP_Material_Costs, dbo.S2_PW_Internal_Projects.IP_Handling_Fee, 
                   SUM(dbo.S2_PW_Internal_Projects.IP_Labour_Costs + dbo.S2_PW_Internal_Projects.IP_Material_Costs + dbo.S2_PW_Internal_Projects.IP_Handling_Fee) AS Total_Costs, dbo.S2_PW_Internal_Projects.IBPT_ID, dbo.Import_Batch.IB_Year
FROM     dbo.S2_PW_Internal_Projects INNER JOIN
                  dbo.Import_Batch_Process_Task ON dbo.S2_PW_Internal_Projects.IBPT_ID = dbo.Import_Batch_Process_Task.IBPT_ID INNER JOIN
                  dbo.Import_Batch_Process ON dbo.Import_Batch_Process_Task.IBP_ID = dbo.Import_Batch_Process.IBP_ID INNER JOIN
                  dbo.Import_Batch ON dbo.Import_Batch_Process.IB_ID = dbo.Import_Batch.IB_ID
GROUP BY dbo.S2_PW_Internal_Projects.IP_Request_Date, dbo.S2_PW_Internal_Projects.IP_Project_ID, dbo.S2_PW_Internal_Projects.IP_Customer_ID, dbo.S2_PW_Internal_Projects.IP_Status, 
                  dbo.S2_PW_Internal_Projects.IP_Service_Billing_Number, dbo.S2_PW_Internal_Projects.IP_Labour_Costs, dbo.S2_PW_Internal_Projects.IP_Material_Costs, dbo.S2_PW_Internal_Projects.IP_Handling_Fee, 
                  dbo.S2_PW_Internal_Projects.IBPT_ID, dbo.Import_Batch.IB_Year
GO