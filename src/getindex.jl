#######################
## Timedata getindex ##
#######################

## Based on following DataFrame getindex behaviour:
## isa(df[1:2], DataFrame)
## isa(df[1:2, 3:4], DataFrame)
## isa(df[1, 3:4], DataFrame)
## isa(df[1], Array{Float64,1})        # loses column name
## isa(df[2:4, 1], DataArray{Float64,1})   # loses column name
## isa(df[2, 2], Float64)                  # loses column name

typealias ColumnIndex Union(Real, Symbol)
import Base.getindex

for t = (:Timedata, :Timenum, :Timematr)
    @eval begin
        
        ############################################
        ## already type preserving for DataFrames ##
        ############################################
        
        ## select multiple columns
        function getindex{T <: ColumnIndex}(td::$(t), col_inds::AbstractVector{T})
            valsDf = getindex(td.vals, col_inds) # dataframe
            return $(t)(valsDf, idx(td))
        end
        
        ## multiple rows, multiple columns
        function getindex{R <: Real, T <: ColumnIndex}(td::$(t),
                                                       row_inds::AbstractVector{R},
                                                       col_inds::AbstractVector{T})
            valsDf = getindex(td.vals, row_inds, col_inds) # dataframe
            dats = idx(td)[row_inds]
            return $(t)(valsDf, dats)
        end
        
        ## single row, multiple columns
        function getindex{T <: ColumnIndex}(td::$(t), row_ind::Real,
                                            col_inds::AbstractVector{T})
            valsDf = getindex(td.vals, row_ind, col_inds) # dataframe
            
            dat = [idx(td)[row_ind]]
            return $(t)(valsDf, dat)
        end
        
        #####################################################
        ## only type preserving for AbstractTimedata types ##
        #####################################################
        
        ## select single column
        function getindex(td::$(t), col_ind::ColumnIndex)
            vals = getindex(td.vals, col_ind) # dataarray or array
            
            ## manually get column name
            selected_column = td.vals.colindex[col_ind]
            name = names(td)[selected_column] # ASCIIString
            
            ## create respective dataframe
            if isa(vals, DataArray)
                valsDf = DataFrame(a = vals)
            else
                valsDf = convert(DataFrame, vals)
            end
            names!(valsDf, [name])           # names must be given as
            # array 
            
            return $(t)(valsDf, idx(td))
        end
        
        ## multiple rows, single column
        function getindex{T <: Real}(td::$(t), row_inds::AbstractVector{T},
                                     col_ind::ColumnIndex)
            vals = getindex(td.vals, row_inds, col_ind) # dataarray or array
            
            ## manually get column name
            selected_column = td.vals.colindex[col_ind]
            name = names(td)[selected_column] # ASCIIString
            
            ## create respective dataframe
            if isa(vals, DataArray)
                valsDf = DataFrame(a = vals)
            else
                valsDf = convert(DataFrame, vals)
            end

            names!(valsDf, [name])           # names must be given as
            # array 
            
            ## get idx
            dats = [idx(td)[row_inds]]
            
            return $(t)(valsDf, dats)
        end
        
        ## select single row and single column index
        function getindex(td::$(t), row_ind::Real, col_ind::ColumnIndex)
            val = getindex(td.vals, row_ind, col_ind) # single value / NA
            
            ## manually get column name
            selected_column = td.vals.colindex[col_ind]
            name = names(td)[selected_column] # ASCIIString
            
            ## create respective dataframe
            valDf = DataFrame(a = val)
            names!(valDf, [name])           # names must be given as
            # array 
            
            ## single date needs to be transformed to DataArray
            dat = [idx(td)[row_ind]]
            
            return $(t)(valDf, dat)
        end
        
        #############################################################
        ## assumed as type preserving without further tests so far ##
        #############################################################
        
        ## getindex(td::$(t), ex::Expr) = getindex(td, with(td.vals, ex))
        ## getindex(td::$(t), ex::Expr, c::ColumnIndex) =
        ##     getindex(td, with(td.vals, ex), c)
        
        ## ## typealias ColumnIndex Union(Real, Symbol)
        ## getindex{T <: ColumnIndex}(td::$(t), ex::Expr, c::AbstractVector{T}) =
        ##     getindex(td, with(td.vals, ex), c)
        
        ## getindex(td::$(t), c::Real, ex::Expr) =
        ##     getindex(td, c, with(td.vals, ex))
        ## getindex{T <: Real}(td::$(t), c::AbstractVector{T}, ex::Expr) =
        ##     getindex(td, c, with(td.vals, ex))
        ## getindex(td::$(t), ex1::Expr, ex2::Expr) =
        ##     getindex(td, with(td.vals, ex1), with(td.vals, ex2))

        #########################
        ## indexing with dates ##
        #########################

        function getindex(td::$(t), date::Date)
            row_ind = idx(td) .== date
            return td[row_ind, :]
        end

        function getindex(td::$(t), date::Date, x::Any)
            row_ind = idx(td) .== date
            return getindex(td, row_ind, x)
        end
        
        function getindex(td::$(t), idxs::Array{Date,1})
            row_inds = findin(TimeData.idx(td), idxs)
            return td[row_inds, :]
        end
        
        function getindex(td::$(t), idxs::Array{Date,1}, x::Any)
            row_inds = findin(TimeData.idx(td), idxs)
            return td[row_inds, x]
        end
        
        function getindex(td::$(t), idx::StepRange{Date,Dates.Day})
            return getindex(td, [idx])
        end
        
        function getindex(td::$(t), idx::StepRange{Date,Dates.Day},
                          x::Any)
            return getindex(td, [idx], x)
        end
        
    end
end
