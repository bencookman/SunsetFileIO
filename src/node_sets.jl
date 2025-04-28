mutable struct NodeSet
    fields :: Vector{Field}
    set :: Matrix{FieldValue}
end


function stitch_node_sets(node_sets...)
    # Take copies of node_sets
    node_sets_copies = [copy_node_set(node_set) for node_set in node_sets]
    if !allequal([length(node_set) for node_set in node_sets_copies])
        throw(ArgumentError("These node sets contain different numbers of nodes"))
    end
    # Only pick out each unique field once, prioritising values from earlier node sets
    old_fields = [node_set.fields for node_set in node_sets_copies]
    old_sets = [node_set.set for node_set in node_sets_copies]
    new_fields = vcat(old_fields...)
    new_set = hcat(old_sets...)
    reduced_fields = Field[]
    reduced_fields_indices = Int64[]
    for (i_field, field) in enumerate(new_fields)
        if field ∉ reduced_fields
            push!(reduced_fields, field)
            push!(reduced_fields_indices, i_field)
        end
    end
    # Then stitch. Stitching is the hcat above
    reduced_set = new_set[:, reduced_fields_indices]
    return NodeSet(reduced_fields, reduced_set)
end

function join_node_sets(node_sets...)
    # Take copies
    node_sets_copies = [copy_node_set(node_set) for node_set in node_sets]
    old_fields = [node_set.fields for node_set in node_sets_copies]
    old_sets = [node_set.set for node_set in node_sets_copies]
    if !allequal(old_fields)
        throw(ArgumentError("These node sets contain different fields"))
    end
    # Then join. Joining is a vcat
    return NodeSet(old_fields[1], vcat(old_sets...))
end


vector_fields_scalars = Dict(
    "position" => axes_strings,
    "velocity" => u_strings,
    "normal" => n_strings
)

# true if has field false otherwise
function check_field(node_set :: NodeSet, field_name)
    names = [field.name for field in node_set.fields]
    return field_name ∈ names
end

# Returns D if position or 0 if no position
function check_position(node_set)
    axis_present = Bool[check_field(node_set, axis_string) for axis_string in axes_strings]
    return count(==(true), axis_present)
end

function check_vector_field(node_set, vector_field_name)
    scalars_preset = [check_field(node_set, field_name) for field_name in vector_fields_scalars[vector_field_name]]
    return count(==(true), scalars_preset)
end

"""
Can zip or unzip because both operations turn arrays of arrays into arrays of arrays.

Zipping helps make the transformations easier.
"""
function zip_array(a_a_f)
    a_f_a = [[a_a_f[i_field][i_node] for i_field in axes(a_a_f, 1)] for i_node in axes(a_a_f[1], 1)]
    return a_f_a
end

function get_field_index(node_set :: NodeSet, field_name)
    if !check_field(node_set, field_name)
        throw(ArgumentError("Field $(field_name) does not exist in this node set"))
    end
    first_node_names = [field.name for field in node_set.fields]
    i_field = findall(val -> val == field_name, first_node_names)[1]
    return i_field
end

function get_field_by_name(node_set :: NodeSet, field_name)
    i_name_field = get_field_index(node_set, field_name)
    field_type = node_set.fields[i_name_field].type
    return field_type.(node_set.set[:, i_name_field])
end

function get_vector_by_name(node_set, vector_field_name)
    D = check_vector_field(node_set, vector_field_name)
    if D == 0
        throw(ArgumentError(string("This node set contains no ", vector_field_name)))
    end
    scalar_field_names = vector_fields_scalars[vector_field_name][1:D]
    scalar_field_values = [get_field_by_name(node_set, name) for name in scalar_field_names]
    return zip_array(scalar_field_values)
end

function get_positions(node_set)
    return get_vector_by_name(node_set, "position")
end

function set_field_by_name!(node_set :: NodeSet, field_name, field_values)
    if length(node_set) != length(field_values)
        throw(ArgumentError("Mismatch in number of nodes"))
    end
    i_field = get_field_index(node_set, field_name)
    node_set.set[:, i_field] = field_values
    return nothing
end

function set_vector_field_by_name!(node_set, vector_field_name, vector_field_values_zipped)
    D = check_vector_field(node_set, vector_field_name)
    if D == 0
        throw(ArgumentError(string("This node set contains no ", vector_field_name)))
    end
    vector_field_values_unzipped = zip_array(vector_field_values_zipped)
    for i_scalar_field in 1:D
        set_field_by_name!(node_set, vector_fields_scalars[vector_field_name][i_scalar_field], vector_field_values_unzipped[i_scalar_field])
    end
end

function set_positions!(node_set, positions_zipped)
    set_vector_field_by_name!(node_set, "position", positions_zipped)
    return nothing
end

function add_field!(node_set, field, values)
    # Skip if this field is already there
    if check_field(node_set, field.name)
        printstyled("node set already contains this field\n", color = :red)
        return nothing
    end
    push!(node_set.fields, field)
    node_set.set = hcat(node_set.set, values)
    return nothing
end

dropcol(M::AbstractMatrix, j) = M[:, deleteat!(collect(axes(M, 2)), j)]

function remove_field!(node_set, field_name)
    if !check_field(node_set, field_name)
        printstyled("node set does not contain this field\n", color = :red)
        return nothing
    end

    i_field = get_field_index(node_set, field_name)
    popat!(node_set.fields, i_field)
    node_set.set = dropcol(node_set.set, i_field)
    return nothing
end

function copy_node_set(node_set)
    return NodeSet(copy(node_set.fields), copy(node_set.set))
end



