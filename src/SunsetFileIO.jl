"""
IPART
---
1   x
2   y
3   node type
4   n.x
5   n.y
6   s

nodes
---
1   x
2   y
3   s
4   h
5   node type

fields
---
1   rho
2   u
3   v
4   vort
5   T
6   p
7   hrr
8   Y1
9   Y2
10  etc.

flame
---
1   x
2   y
3   u
4   v
5   vort
6   rho
7   rhoE
8   T
9   p
10  hrr
11  Y1
12  Y2 
13  etc

init_flame.in
---
1   x
2   y
3   u
4   v
5   vort
6   rho
7   rhoE
8   T
9   p
11  Y1
12  Y2 
13  etc
"""
module SunsetFileIO

export
    ### fields.jl
    FieldValueScalar,
    FieldValue,
    Field,

    axes_strings,
    u_strings,
    n_strings,
    Y_string,
    ω_string,
    i_strings,

    position_fields,
    s_field,
    h_field,
    type_field,
    n_fields,
    proc_field,

    rho_field,
    u_fields,
    vort_field,
    T_field,
    p_field,
    hrr_field,
    Y_fields,
    ω_fields,
    rhoE_field,

    i_fields,
    s_interp_field,

    node_linkage_field,
    vol_field,

    nodes_fields,
    fields_fields,
    IPART_fields,
    flame_fields,
    init_flame_fields,

    ### node_sets.jl
    NodeSet,
    stitch_node_sets,
    join_node_sets,
    check_field,
    check_position,
    get_field_index,
    get_field_by_name,
    zip_array,
    get_positions,
    set_field_by_name!,
    set_positions!,
    add_field!,
    remove_field!,
    copy_node_set,

    ### iteration_indexing.jl
    getindex,
    setindex!,
    firstindex,
    lastindex,
    iterate,
    IteratorSize,
    IteratorEltype,
    eltype,
    length,
    size,
    isdone,
    filter,
    filter!,

    ### transform.jl
    reflect_origin!,
    reflect!,
    scale!,
    translate!,

    ### keep.jl
    keep_check_stride,
    keep_check_box,
    keep_check_max,
    keep_indices,
    keep_indices!,
    get_shuffle_keep_indices,

    ### read_files.jl
    nodes_file_path,
    fields_file_path,
    flame_file_path,
    read_nodes_file,
    read_nodes_files,
    read_fields_files,
    read_IPART_file,
    read_flames_file,
    read_init_flame_file,
    read_vtu_file,
    read_nodes_and_fields_files,

    ### ask.jl
    ask_file_type,
    ask_skip,
    ask_scale,
    ask_reflect,

    ### cartesian_interpolate.jl
    cartesian_interpolate,

    ### vtu_writer.jl
    open_and_write_vtu,

    ### sph.jl
    calculate_node_linkage,
    add_volumes!



using Random, Dates, WriteVTK, ReadVTK, DelimitedFiles, PyCall, ProgressMeter

include("fields.jl")
include("node_sets.jl")
include("iteration_indexing.jl")
include("transform.jl")
include("keep.jl")
include("read_files.jl")
include("ask.jl")
include("vtu_writer.jl")
include("cartesian_interpolate.jl")
include("sph.jl")


end