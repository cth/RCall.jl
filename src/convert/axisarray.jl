function rcopy(::Type{AxisArray}, r::Ptr{S}) where {S<:VectorSxp}
    dnames = getattrib(r, Const.DimNamesSymbol)
    isnull(dnames) && error("r has no dimnames")
    dsym = rcopy(Array{Symbol}, getnames(dnames))
    for i in 1:length(dsym)
        if dsym[i] == Symbol("")
            dsym[i] = i == 1 ? (:row) : i == 2 ? (:col) : i == 3 ? (:page) : Symbol(:dim_, i)
        end
    end
    AxisArray(rcopy(AbstractArray, r),
             [Axis{dsym[i]}(isnull(n) ? (1:(size(r)[i])) : rcopy(n)) for (i,n) in enumerate(dnames)]...)
end

function sexp(aa::AxisArray)
    rv = protect(sexp(aa.data))
    try
        d = OrderedDict(
            k => v.val for (k, v) in zip(axisnames(aa), axes(aa)))
        setattrib!(rv, Const.DimSymbol, collect(size(aa)))
        setattrib!(rv, Const.DimNamesSymbol, d)
    finally
        unprotect(1)
    end
    rv
end
