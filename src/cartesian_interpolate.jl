
"""
Implementation would be better if we could hold metadata about a node set.

For this function it would be easiest if the node set had attached e.g. a
dictionary saying what the minimum and maximum x and y values are, what the
thermochem.in / control.in values were etc..

This would most likely require writing a wrapper structure which adds this
metadata onto a NodeSet.
"""
function cartesian_interpolate(
    node_set,
    dx,
    xlims,
    ylims;
    interp_method = "nearest"
)
    D = check_position(node_set)
    if D == 0
        throw(ArgumentError("Node set must have at least one position field"))
    elseif D != 2
        throw(ArgumentError("Function requires a dimension of two"))
    end

    si = pyimport("scipy.interpolate")
    
    # Get x and y meshes for interpolation
    x = node_set["x"]
    y = node_set["y"]
    xy = [x y]
    x_grid = collect((xlims[1] + 5dx):dx:(xlims[2] - 5dx))
    y_grid = collect((ylims[1] + 5dx):dx:(ylims[2] - 5dx))
    x_mesh = [x_g for x_g in x_grid, _ in y_grid]
    y_mesh = [y_g for _ in x_grid, y_g in y_grid]

    i_x_mesh = [i_x for i_x in axes(x_mesh, 1), _ in axes(x_mesh, 2)]
    i_y_mesh = [i_y for _ in axes(x_mesh, 1), i_y in axes(x_mesh, 2)]

    cart_node_set = NodeSet(
        [i_fields[1], i_fields[2], position_fields[1], position_fields[2], s_interp_field],
        [vec(i_x_mesh) vec(i_y_mesh) vec(x_mesh) vec(y_mesh) [dx for _ in 1:length(vec(x_mesh))]]
    )
    
    # Loop through each remaining field and interpolate those field values
    for field in node_set.fields
        if field.name in ["x", "y", "s", "h", "type", "proc", n_strings...]
            continue
        end
        field_values = get_field_by_name(node_set, field.name)
        values_mesh = si.griddata(xy, field_values, (x_mesh, y_mesh), method = interp_method, rescale = true)
        cart_values = vec(values_mesh)

        # Remove NaNs
        cart_values = [isnan(val) ? 0.0 : val for val in cart_values]
        # for (i_node, z) in enumerate(cart_values)
        #     if isnan(z)
        #         new_val = NaN
        #         i_offset = 1
        #         while isnan(new_val)
        #             new_val = cart_values[((i_node + i_offset - 1) % length(cart_values)) + 1]
        #             i_offset += 1
        #         end
        #         cart_values[i_node] = new_val
        #     end
        # end
        # print(2, field.name)

        add_field!(cart_node_set, field, cart_values)
    end

    return (x_grid, y_grid, cart_node_set)
end