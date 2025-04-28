function ask_D()
    printstyled("Dimension\n", color = :blue)
    temp_str = readline()
    return parse(Int64, temp_str)
end
function ask_Y()
    printstyled("Number of species\n", color = :blue)
    temp_str = readline()
    return parse(Int64, temp_str)
end
function ask_n_cores()
    printstyled("Number of cores used\n", color = :blue)
    temp_str = readline()
    return parse(Int64, temp_str)
end
function ask_i_frame()
    printstyled("Output frame number\n", color = :blue)
    temp_str = readline()
    return parse(Int64, temp_str)
end
function ask_frames()
    printstyled("First frame #\n", color = :blue)
    temp_str = readline()
    arg_frame_start = parse(Int64, temp_str)

    printstyled("Final frame #\n", color = :blue)
    temp_str = readline()
    arg_frame_end = parse(Int64, temp_str)

    return (arg_frame_start, arg_frame_end)
end
function ask_n_line_skip()
    printstyled("Number of lines to skip at the start of the file\n", color = :blue)
    temp_str = readline()
    return parse(Int64, temp_str)
end

function ask_file_type(file_type)
    ft_args = Any[]

    if !isinteractive()
        throw(ErrorException("Must be run in interactive mode"))
    end

    if file_type == "nodes"
        arg_D = ask_D()
        arg_n_cores = ask_n_cores()
        ft_args = [arg_D, arg_n_cores]
    elseif file_type == "fields"
        arg_D = ask_D()
        arg_Y = ask_Y()
        arg_n_cores = ask_n_cores()
        arg_i_frame = ask_i_frame()
        ft_args = [arg_D, arg_Y, arg_n_cores, arg_i_frame]
    elseif file_type == "many fields"
        arg_D = ask_D()
        arg_Y = ask_Y()
        arg_n_cores = ask_n_cores()
        arg_frames = ask_frames()
        ft_args = [arg_D, arg_Y, arg_n_cores, arg_frames]
    elseif file_type == "flame"
        arg_D = ask_D()
        arg_Y = ask_Y()
        arg_n_cores = ask_n_cores()
        arg_i_frame = ask_i_frame()
        ft_args = [arg_D, arg_Y, arg_n_cores, arg_i_frame]
    elseif file_type == "many flames"
        arg_D = ask_D()
        arg_Y = ask_Y()
        arg_n_cores = ask_n_cores()
        arg_frames = ask_frames()
        ft_args = [arg_D, arg_Y, arg_n_cores, arg_frames]
    elseif file_type == "IPART"
        arg_D = ask_D()
        arg_n_line_skip = ask_n_line_skip()
        ft_args = [arg_D, arg_n_line_skip]
    else
        throw(ArgumentError("File type not accepted"))
    end

    return ft_args
end

function ask_file_type()
    printstyled("What sort of file type do you want to input\n", color = :blue)
    arg_file_type = readline()

    return ask_file_type(arg_file_type)
end

function ask_skip()
    keep_check_f_and_args = Vector{Any}[]

    if !isinteractive()
        throw(ErrorException("Must be run in interactive mode"))
    end

    printstyled("Skip nodes?\n", color = :blue)
    temp_str = readline()
    arg_do_skip = parse(Bool, temp_str)
    
    if !arg_do_skip
        return keep_check_f_and_args
    end

    printstyled("Constant node spacing?\n", color = :blue)
    temp_str = readline()
    arg_do_boxing = parse(Bool, temp_str)
    
    if arg_do_boxing
        printstyled("New spacing\n", color = :blue)
        temp_str = readline()
        arg_box_size = parse(Float64, temp_str)
        push!(keep_check_f_and_args, [keep_check_box, (arg_box_size, )])
    end
    
    printstyled("Stride?\n", color = :blue)
    temp_str = readline()
    arg_do_stride = parse(Bool, temp_str)
    
    if arg_do_stride
        printstyled("Use 1/# of the nodes\n", color = :blue)
        temp_str = readline()
        arg_stride_n = parse(Int64, temp_str)
        push!(keep_check_f_and_args, [keep_check_stride, (arg_stride_n, )])
    end
    
    printstyled("Enforce a maximum number of nodes?\n", color = :blue)
    temp_str = readline()
    arg_do_max_nodes = parse(Bool, temp_str)

    if arg_do_max_nodes
        printstyled("Maximum # of nodes\n", color = :blue)
        temp_str = readline()
        arg_max_nodes = parse(Int64, temp_str)
        push!(keep_check_f_and_args, [keep_check_max, (arg_max_nodes, )])
    end

    return keep_check_f_and_args
end

function ask_scale()
    if !isinteractive()
        throw(ErrorException("Must be run in interactive mode"))
    end

    printstyled("Scale down x, y, s and h by this # (L_char, 1 for no scaling)\n", color = :blue)
    temp_str = readline()
    arg_scale = parse(Float64, temp_str)

    return arg_scale
end

function ask_reflect()
    if !isinteractive()
        throw(ErrorException("Must be run in interactive mode"))
    end

    # args_reflect = Any[false, [0.0, 0.0], [0.0, 1.0]]
    args_reflect = Any[false]

    printstyled("Do we want to do a reflection\n", color = :blue)
    temp_str = readline()
    arg_do_reflect = parse(Bool, temp_str)
    args_reflect[1] = arg_do_reflect
    
    # if !arg_do_reflect
    #     return args_reflect
    # end

    # printstyled("Give the x coordinate of the first point in the line of reflection\n", color = :blue)
    # temp_str = readline()
    # arg_reflect_p1_x = parse(Float64, temp_str)

    # printstyled("Give the y coordinate of the first point in the line of reflection\n", color = :blue)
    # temp_str = readline()
    # arg_reflect_p1_y = parse(Float64, temp_str)

    # printstyled("Give the x coordinate of the second point in the line of reflection\n", color = :blue)
    # temp_str = readline()
    # arg_reflect_p2_x = parse(Float64, temp_str)

    # printstyled("Give the y coordinate of the second point in the line of reflection\n", color = :blue)
    # temp_str = readline()
    # arg_reflect_p2_y = parse(Float64, temp_str)

    # args_reflect[2] = [arg_reflect_p1_x, arg_reflect_p1_y]
    # args_reflect[3] = [arg_reflect_p2_x, arg_reflect_p2_y]

    return args_reflect
end
