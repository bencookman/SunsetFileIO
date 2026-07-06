### FIELDS

FieldValueScalar = Union{Float64, Int64, Bool}
FieldValue = Union{FieldValueScalar, Vector{Int64}}

struct Field
    name :: String
    type :: Type
end


axes_strings = ["x", "y", "z"]
u_strings = [string("u_", axes_strings[i_axis]) for i_axis in 1:3]
u_moving_strings = [string("u_moving_", axes_strings[i_axis]) for i_axis in 1:3]
n_strings = [string("n_", axes_strings[i_axis]) for i_axis in 1:3]
Y_string(i_Y) = string("Y", i_Y)
ω_string(i_Y) = string("ω", i_Y)
i_strings = [string("i_", axes_strings[i_axis]) for i_axis in 1:3]

index_field = Field("i", Int64)
position_fields = [Field(axes_strings[i_axis], Float64) for i_axis in 1:3]
s_field = Field("s", Float64)
h_field = Field("h", Float64)
h_small_field = Field("h_small", Float64)
type_field = Field("type", Int64)
n_fields = [Field(n_strings[i_axis], Float64) for i_axis in 1:3]
proc_field = Field("proc", Int64)

rho_field = Field("rho", Float64)
u_fields = [Field(u_strings[i_axis], Float64) for i_axis in 1:3]
u_moving_fields = [Field(u_moving_strings[i_axis], Float64) for i_axis in 1:3]
vort_field = Field("vort", Float64)
T_field = Field("T", Float64)
p_field = Field("p", Float64)
hrr_field = Field("hrr", Float64)
Y_fields(Y) = [Field(Y_string(i_Y), Float64) for i_Y in 1:Y]
ω_fields(Y) = [Field(ω_string(i_Y), Float64) for i_Y in 1:Y]
rhoE_field = Field("rhoE", Float64)

i_fields = [Field(i_strings[i_axis], Int64) for i_axis in 1:3]
s_interp_field = Field("s interp", Float64)

node_linkage_field = Field("node_linkage", Vector{Float64})
vol_field = Field("vol", Float64)

nodes_fields(D; has_index = true, has_h_small = true) = begin
    fields = Field[]
    if has_index
        push!(fields, index_field)
    end
    push!(fields, position_fields[1:D]...)
    push!(fields, s_field)
    push!(fields, h_field)
    if has_h_small
        push!(fields, h_small_field)
    end
    push!(fields, type_field)
    return fields
end
fields_fields(D, Y; has_ω = true, has_vol = true, has_moving_frame = true) = begin
    fields = Field[]
    push!(fields, rho_field)
    push!(fields, u_fields[1:D]...)
    if has_moving_frame
        push!(fields, u_moving_fields[1:D]...)
    end
    push!(fields, vort_field)
    push!(fields, T_field)
    push!(fields, p_field)
    push!(fields, hrr_field)
    push!(fields, Y_fields(Y)...)
    if has_ω
        push!(fields, ω_fields(Y)...)
    end
    if has_vol
        push!(fields, vol_field)
    end
    return fields
end
IPART_fields(D; has_index = true) = begin
    fields = Field[
        position_fields[1:D]...,
        type_field,
        n_fields[1:D]...,
        s_field,
    ]
    if has_index
        fields = [index_field, fields...]
    end
    return fields
end
flame_fields(D, Y; has_hrr = true) = begin
    fields = Field[
        position_fields[1:D]...,
        u_fields[1:D]...,
        vort_field,
        rho_field,
        rhoE_field,
        T_field,
        p_field,
    ]
    if has_hrr
        push!(fields, hrr_field)
    end
    push!(fields, Y_fields(Y)...)
    return fields
end
init_flame_fields(D, Y) = Field[
    position_fields[1:D]...,
    u_fields[1:D]...,
    vort_field,
    rho_field,
    rhoE_field,
    T_field,
    p_field,
    Y_fields(Y)...,
]

