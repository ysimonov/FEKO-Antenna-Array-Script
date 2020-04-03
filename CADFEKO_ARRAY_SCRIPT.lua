-- Author: Yevgeniy Simonov, 2020
app = cf.GetApplication()
app:NewProject()
project = app:OpenFile([[D:\FEKO_proj_new\Yevgeniy\4x4 Array Wire Model\TEST IMPEDANCE\191103_WM_Array.cfx]]) --add your own path

-- Specify the main object 
Union1 = project.Geometry["Union1"]
Union1_2 = Union1.Children["Union1"]

Line1_1 = Union1.Children["Polyline1"]
Line2_1 = Union1.Children["Polyline2"]

-- Read coordinates from data.txt
fileName = "data.txt"

local file = io.open(fileName,"r")

lines_data = {{}}
coordinate = {}

-- read the data file and assign coordinate[i][j] to i-th row j-th column element of the table 
for line in file:lines() do
    local x, y, z = string.match(line, '(%S+) (%S+) (%S+)')
    lines_data = {tonumber(x),tonumber(y),tonumber(z)}
    coordinate[#coordinate+1]=lines_data
end 

-- get the number of array elements (rows)
size = 0
for k,v in pairs(coordinate) do
     size = size + 1
end

file:close()

-- Add translate transform for the first object 
properties = cf.Translate.GetDefaultProperties()
properties.From.N = "0"
properties.From.U = "0"
properties.From.V = "0"
properties.To.N = tostring(coordinate[1][3])
properties.To.U = tostring(coordinate[1][1])
properties.To.V = tostring(coordinate[1][2])
Translate1 = Union1.Transforms:AddTranslate(properties)

-- Create wire ports
properties = cf.WirePort.GetDefaultProperties()
Union2 = project.Geometry["Union1"] 

-- Created port "Port with index 1"
properties.Label = "Port1" 
properties.Location = cf.Enums.WirePortLocationEnum.End
properties.DefinitionMethod = cf.Enums.WirePortDefinitionMethodEnum.UsingVertex
Wire10397 =  Union2.Wires["Wire10397"] -- Line1.Wires["Wire10397"]
properties.Wire = Wire10397
Port1 = project.Ports:AddWirePort(properties)
    
-- Created port "Port with index2"
properties.Label = "Port2" 
properties.Location = cf.Enums.WirePortLocationEnum.End
properties.DefinitionMethod = cf.Enums.WirePortDefinitionMethodEnum.UsingVertex
Wire10395 = Union2.Wires["Wire10395"] --Line2.Wires["Wire10395"]
properties.Wire = Wire10395
Port2 = project.Ports:AddWirePort(properties)
    
-- Create loads
properties = cf.Load.GetDefaultProperties()
properties.Filename = [[Z_LNA.s1p]]
properties.Label = "Load1" 
properties.LoadType = cf.Enums.LoadTypeEnum.SinglePortTouchstone
properties.Terminal = project.Ports["Port1"].Terminal
Load1 = project.SolutionConfigurations["StandardConfiguration1"].Loads:AddLoad(properties)

properties = cf.Load.GetDefaultProperties()
properties.Filename = [[Z_LNA.s1p]]
properties.Label = "Load2" 
properties.LoadType = cf.Enums.LoadTypeEnum.SinglePortTouchstone
properties.Terminal = project.Ports["Port2"].Terminal
Load2 = project.SolutionConfigurations["StandardConfiguration1"].Loads:AddLoad(properties)	

-- Create voltage source 
properties = cf.VoltageSource.GetDefaultProperties()
properties.Impedance = "100"
properties.Label = "VoltageSource1" 
properties.Terminal = project.Ports["Port1"].Terminal
VoltageSource2 = project.SolutionConfigurations["StandardConfiguration1"].Sources:AddVoltageSource(properties)
    
j = 2
k = 3

for i = 2, size do

    -- duplicate objects
    Union1_1 = Union1_2:Duplicate()
    Line1 = Line1_1:Duplicate()
    Line2 = Line2_1:Duplicate()
    
    -- translate objects 
    translate_1 = Union1_1.Transforms:AddTranslate(cf.Point(),cf.Point(coordinate[i][1],coordinate[i][2],coordinate[i][3]))
    translate_2 = Line1.Transforms:AddTranslate(cf.Point(),cf.Point(coordinate[i][1],coordinate[i][2],coordinate[i][3]))
    translate_3 = Line2.Transforms:AddTranslate(cf.Point(),cf.Point(coordinate[i][1],coordinate[i][2],coordinate[i][3]))

    targets = { Line1, Line2, Union1_1 }
    project.Geometry:Union(targets)
    
    index1 = tostring(j+1)
    j = j + 1
    
    properties = cf.WirePort.GetDefaultProperties()
    Union2 = project.Geometry["Union" .. tostring(i)] 
    
    -- Created port "Port with index 1"
    properties.Label = "Port" .. index1
    properties.Location = cf.Enums.WirePortLocationEnum.End
    properties.DefinitionMethod = cf.Enums.WirePortDefinitionMethodEnum.UsingVertex
    Wire10397 =  Union2.Wires["Wire10397"] -- Line1.Wires["Wire10397"]
    properties.Wire = Wire10397
    Port1 = project.Ports:AddWirePort(properties)

    index2 = tostring(j+1)
    j = j + 1
    
    -- Created port "Port with index2"
    properties.Label = "Port" .. index2
    properties.Location = cf.Enums.WirePortLocationEnum.End
    properties.DefinitionMethod = cf.Enums.WirePortDefinitionMethodEnum.UsingVertex
    Wire10395 = Union2.Wires["Wire10395"] --Line2.Wires["Wire10395"]
    properties.Wire = Wire10395
    Port2 = project.Ports:AddWirePort(properties)
    
    load_index = tostring(k)
    k = k + 1
  
    -- Create loads
    properties = cf.Load.GetDefaultProperties()
    properties.Filename = [[Z_LNA.s1p]]
    properties.Label = "Load" .. load_index
    properties.LoadType = cf.Enums.LoadTypeEnum.SinglePortTouchstone
    properties.Terminal = project.Ports["Port" .. index1].Terminal
    Load1 = project.SolutionConfigurations["StandardConfiguration1"].Loads:AddLoad(properties)

    -- Increment the load index 
    load_index = tostring(k)
    k = k + 1

    properties = cf.Load.GetDefaultProperties()
    properties.Filename = [[Z_LNA.s1p]]
    properties.Label = "Load" .. load_index
    properties.LoadType = cf.Enums.LoadTypeEnum.SinglePortTouchstone
    properties.Terminal = project.Ports["Port" .. index2].Terminal
    Load2 = project.SolutionConfigurations["StandardConfiguration1"].Loads:AddLoad(properties)	

    source_index = i
    
    -- Create voltage source 
    properties = cf.VoltageSource.GetDefaultProperties()
    properties.Impedance = "100"
    properties.Label = "VoltageSource" .. source_index
    properties.Terminal = project.Ports["Port" .. index1].Terminal
    VoltageSource2 = project.SolutionConfigurations["StandardConfiguration1"].Sources:AddVoltageSource(properties)

end 

-- Create a 5m x 5m finite ground plane for 4x4 array with the reference position at 0,0
properties = cf.Rectangle.GetDefaultProperties()
properties.DefinitionMethod = cf.Enums.RectangleDefinitionMethodEnum.BaseAtCentre
properties.Depth = "5"
properties.Label = "Rectangle1"
properties.Width = "5"
Rectangle1 = project.Geometry:AddRectangle(properties)

-- CREATE MESH
project.Mesher.Settings.WireRadius = "0.75e-3"

advancedMeshSettings = project.Mesher.Settings.Advanced
advancedMeshSettings.CurvilinearSegments = cf.Enums.MeshCurvilinearOptionsEnum.Disabled

frequencyRange = project.SolutionConfigurations["StandardConfiguration1"].Frequency
properties = frequencyRange:GetProperties()
properties.RangeType = cf.Enums.FrequencyRangeTypeEnum.LinearSpacedDiscrete
properties.Start = "50e6"
properties.End = "350.8e6"
properties.NumberOfDiscreteValues = "236"  
frequencyRange:SetProperties(properties)

-- Obtain the 'MeshAdvancedSettings'
advancedMeshSettings = project.Mesher.Settings.Advanced

-- Set the 'GrowthRate' (from 0.0 to 100.0)
advancedMeshSettings.GrowthRate = 0.0 --0.0 is slow rate, then 20.0, 100.0 - fast

-- Allow elongated triangles?
advancedMeshSettings.ElongatedTrianglesAllowed = true

-- Set a Refinement Factor (0 - fine, 100 - Course)
advancedMeshSettings.RefinementFactor = 0

-- Set the 'MinElementSize' (0 (Small) 100 (Medium))
advancedMeshSettings.MinElementSize = 0

-- Create mesh
project.Mesher.VoxelSettings.MeshSizeOption = cf.Enums.MeshSizeOptionEnum.Fine
project.Mesher:Mesh()

-- Access the 'FEKOParallelExecutionOptions' and check if parallel execution is enabled
parallelEnabled = project.Launcher.Settings.FEKO.Parallel.Enabled

-- CREATE FAR FIELD
properties = cf.FarField.GetDefaultProperties()
properties.Label = "FarField2"
properties.Phi.End = "360.0"
properties.Phi.Increment = "5.0"
properties.Theta.End = "90.0"
properties.Theta.Increment = "5.0"
FarField2 = project.SolutionConfigurations["StandardConfiguration1"].FarFields:Add(properties)

-- Request S-Parameters for automatic export
SParameterConfiguration1 = project.SolutionConfigurations:AddMultiportSParameter({
	project.Ports["Port1"].Terminal, 
	project.Ports["Port3"].Terminal, 
	project.Ports["Port5"].Terminal,
	project.Ports["Port7"].Terminal, 
	project.Ports["Port9"].Terminal, 
	project.Ports["Port11"].Terminal,
        project.Ports["Port13"].Terminal, 
	project.Ports["Port15"].Terminal, 
	project.Ports["Port17"].Terminal,
        project.Ports["Port19"].Terminal, 
	project.Ports["Port21"].Terminal, 
	project.Ports["Port23"].Terminal,
        project.Ports["Port25"].Terminal,
        project.Ports["Port27"].Terminal, 
	project.Ports["Port29"].Terminal, 
	project.Ports["Port31"].Terminal})
        
properties = cf.SParameter.GetDefaultProperties()
properties.Label = "SParameter1"

properties.PortProperties[1].Impedance = "100"
properties.PortProperties[1].Terminal = project.Ports["Port1"].Terminal

-- specify impedances 
j = 2
for i = 3, size * 2 - 1, 2 do
    properties.PortProperties[j] = {}
    properties.PortProperties[j].Active = true
    properties.PortProperties[j].Impedance = "100"
    properties.PortProperties[j].Terminal = project.Ports["Port"..tostring(i)].Terminal
	j = j + 1 
end 

properties.TouchstoneExportEnabled = true
SParameter1 = SParameterConfiguration1.SParameter
SParameter1:SetProperties(properties)

-- Per configuration settings for loads changed.
project.SolutionConfigurations:SetLoadsPerConfiguration() -- make sure the loads are specified per configuration 

-- Remove loads other than 100 Ohm
SParameterConfiguration1 = project.SolutionConfigurations["SParameterConfiguration1"]

for i = 1, size * 2 do
	Loadx = SParameterConfiguration1.Loads["Load" .. tostring(i)]
	Loadx:Delete()
end 

-- Assign new loads on all even port numbers 
properties = cf.Load.GetDefaultProperties()
properties.ImpedanceReal = "100"
j = 1 
for i = 2, size * 2, 2 do 
	properties.Label = "Load" .. tostring(j)
	properties.Terminal = project.Ports["Port" .. tostring(i)].Terminal
	project.SolutionConfigurations["SParameterConfiguration1"].Loads:AddLoad(properties)
	j = j + 1
end 

-- this part is used to store and reuse matrix elements from run to run
SolverSettings_1 = project.SolutionSettings.SolverSettings
properties = SolverSettings_1:GetProperties()
properties.GeneralSettings.OutputFileSettings.LUDecomposedMatrix = cf.Enums.OutputFileSettingsEnum.ReadFromFileIfAvailable
properties.GeneralSettings.OutputFileSettings.MatrixElements = cf.Enums.OutputFileSettingsEnum.ReadFromFileIfAvailable
SolverSettings_1:SetProperties(properties)

-- Save and Launch 
app:SaveAs("MWA_ARRAY.cfx")

-- Launch FEKO
-- project.Launcher:RunFEKO()

-- Save project
-- app:Save()

-- RunPOSTFEKO
-- project.Launcher:RunPOSTFEKO()
