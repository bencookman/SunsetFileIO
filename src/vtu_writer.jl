vtu_start = """
<?xml version="1.0"?>
<VTKFile type= "UnstructuredGrid"  version= "0.1"  byte_order= "BigEndian">
  <UnstructuredGrid>
"""
vtu_end = """
  </UnstructuredGrid>
</VTKFile>
"""
vtu_start_piece(n_nodes) = """
    <Piece NumberOfPoints="$n_nodes" NumberOfCells="$n_nodes">
"""
vtu_end_piece = """
    </Piece>
"""
vtu_start_points = """
      <Points>
"""
vtu_end_points = """
      </Points>
"""
vtu_start_point_data = """
      <PointData>
"""
vtu_end_point_data = """
      </PointData>
"""
vtu_start_data_array(type, name; n_components = 1) = """
        <DataArray type="$type" $(name == "" ? "" : "Name=\"$name\" ")$(n_components == 1 ? "" : string("NumberOfComponents=\"", n_components, "\" "))format="ascii">
"""

vtu_end_data_array = """
        </DataArray>
"""
vtu_start_cells = """
      <Cells>
"""
vtu_end_cells = """
      </Cells>
      <CellData>
      </CellData>
"""




function reduce_types(old_type :: Type)
    if old_type == Float64
        return Float32
    elseif old_type == Int64
        return Int32
    end
    return old_type
end

function group_names(node_set, names)
    grouped_names = Any[]
    for field_name_group in [axes_strings, u_strings, n_strings]
        if !all([!check_field(node_set, field_name) for field_name in field_name_group])      # If we have any of this data, add those fields
            push!(grouped_names, filter(name -> name in field_name_group, names))
            filter!(name -> !(name in field_name_group), names)
        end
    end
    push!(grouped_names, [[name] for name in names]...)
end

nice_field_titles = Dict(
    [axis_string => axis_string for axis_string in axes_strings]...,
    [u_string => u_string for u_string in u_strings]...,
    [n_string => n_string for n_string in n_strings]...,
    "s" => "Node Spacing (m)",
    "h" => "Stencil Size (m)",
    "type" => "Node Type",
    "rho" => "Density (kg / m³)",
    "vort" => "Vorticity Scalar (1 / m)",
    "T" => "Temperature (K)",
    "p" => "Pressure (Pa)",
    "hrr" => "Heat Release Rate (W / m³)",
    "proc" => "Processor",
    "vol" => "Point Volume (m³)",
)

function get_nice_field_title(field_name :: String)
    if field_name ∉ keys(nice_field_titles)
        return field_name
    end
    return nice_field_titles[field_name]
end

function get_nice_field_title(names)
    names_title = get_nice_field_title(names[1])
    if length(names) > 1
        if names[1] in axes_strings
            names_title = "Position (m)"
        elseif names[1] in u_strings
            names_title = "Velocity (m / s)"
        elseif names[1] in n_strings
            names_title = "Boundary Normal"
        else
            names_title = string("(", join(get_nice_field_title.(names), ", "), ")")
        end
    end
    return names_title
end

function write_vtu_data_array(out_file, type :: T, name, data_vector :: S) where { T <: Union{AbstractString, Type}, S <: AbstractVector }
    write(out_file, vtu_start_data_array(type, name; n_components = length(data_vector[1])))
    for datum in data_vector
        write(out_file, typeof(data_vector).parameters[1] <: AbstractVector ? join(datum, " ") : string(datum))  # Having no whitespace saves up to ~60% on storage space
        write(out_file, "\n")
    end
    write(out_file, vtu_end_data_array)
end

function write_vtu_data_array(out_file, node_set, use_name :: Bool, field_names...)
    field_indices = [get_field_index(node_set, field_name) for field_name in field_names]
    old_type = node_set.fields[field_indices[1]].type
    new_type = reduce_types(old_type)
    
    write(out_file, vtu_start_data_array(new_type, use_name ? get_nice_field_title([field_names...]) : ""; n_components = length(field_names)))
    
    zipped_values = zip_array([get_field_by_name(node_set, field_name) for field_name in field_names])
    for node_values in zipped_values
        write(out_file, join(new_type.(node_values), " "))    # Having no whitespace saves up to ~60% on storage space
        write(out_file, "\n")
    end
    write(out_file, vtu_end_data_array)
end

function write_vtu_point(out_file, node_set)
    write(out_file, vtu_start_points)

    positions = zip_array(get_positions(node_set))
    # push!(positions, zeros(Float32, length(positions[1])))
    positions = zip_array([Float32.(axis_array) for axis_array in positions])
    write_vtu_data_array(out_file, "Float32", "Points", positions)

    write(out_file, vtu_end_points)
end

function write_vtu_point_data(out_file, node_set)
    write(out_file, vtu_start_point_data)

    field_names = [field.name for field in node_set.fields]
    grouped_names = group_names(node_set, field_names)
    for names in grouped_names
        write_vtu_data_array(out_file, node_set, true, names...)
    end

    write(out_file, vtu_end_point_data)
end

function write_vtu_cells(out_file, node_set)
    write(out_file, vtu_start_cells)

    write_vtu_data_array(out_file, "Int32", "connectivity", [i_node - 1 for i_node in axes(node_set.set, 1)])
    write_vtu_data_array(out_file, "Int32", "offsets", [i_node for i_node in axes(node_set.set, 1)])
    write_vtu_data_array(out_file, "Int32", "types", [1 for i_node in axes(node_set.set, 1)])

    write(out_file, vtu_end_cells)    
end

"""
Writes the node_set data to path at `out_file_path`, adding a third dimension to vector data if needed
"""
function open_and_write_vtu(out_file_path, node_set)
    # Add a third dimension if two-dimensional
    D = check_position(node_set)
    if D == 2
        check_field(node_set, axes_strings[1]) && add_field!(node_set, position_fields[3], zeros(length(node_set)))
        check_field(node_set, u_strings[1]) && add_field!(node_set, u_fields[3], zeros(length(node_set)))
        check_field(node_set, n_strings[1]) && add_field!(node_set, n_fields[3], zeros(length(node_set)))
    end

    open(out_file_path, "w") do out_file
        ## Beginning stuff
        write(out_file, vtu_start)
        write(out_file, vtu_start_piece(length(node_set)))
        
        ## Main stuff
        # Points
        write_vtu_point(out_file, node_set)
        # Point data
        write_vtu_point_data(out_file, node_set)
        # Cells
        write_vtu_cells(out_file, node_set)
        
        ## End stuff
        write(out_file, vtu_end_piece)
        write(out_file, vtu_end)
    end


    return nothing
end