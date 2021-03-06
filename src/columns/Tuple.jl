is_ch_type(::Val{:Tuple})  = true
can_be_nullable(::Val{Tuple}) = false

remove_vector_type(::Type{Vector{T}}) where {T} = T
remove_vector_type(::Type{CategoricalVector{T}}) where {T} = CategoricalValue{T}
result_type(::Val{:Tuple}, args::TypeAst...) =
    Vector{Tuple{remove_vector_type.(result_type.(args))...}}

function read_col_data(sock::ClickHouseSock, num_rows::VarUInt,
                         ::Val{:Tuple}, args::TypeAst...)
    tuple_columns = read_col_data.(Ref(sock), num_rows, args)
    return tuple.(tuple_columns...)
end

function write_col_data(sock::ClickHouseSock, data::AbstractVector{<:Tuple},
                        ::Val{:Tuple}, args::TypeAst...)
    isempty(data) && return
    length(data[1]) != length(args) &&
            error("Elements count mistmach between input and clickhouse tuples")

    for i in 1:length(args)
        write_col_data(sock, getindex.(data, i), args[i])
    end
end
