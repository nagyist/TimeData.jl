#####################
## TESTING TIMENUM ##
#####################

## using Base.Test

############################################
## test exception throwing in constructor ##
############################################

## dates initialized with wrong type
vals = DataFrame([2, 3, 4])
dates = DataArray([1, 2, 3])
@test_throws TimeData.TimeNum(vals, dates)

## dates and vals sizes not matching
dates = [date(2013, 7, 1),
         date(2013, 7, 2),
         date(2013, 7, 3)]
dates = DataArray(dates)
valsArr = ones(8, 4)
@test_throws TimeData.TimeNum(valsArr, dates)

#############################
## test outer constructors ##
#############################

dates = [date(2013, 7, 1),
         date(2013, 7, 2),
         date(2013, 7, 3)]
dates = DataArray(dates)         
TimeData.TimeNum(vals, dates)

TimeData.TimeNum(vals)

valsArr = ones(8, 4)
TimeData.TimeNum(valsArr)

dates = [date(2013, 7, 1),
         date(2013, 7, 2),
         date(2013, 7, 3)]
dates = DataArray(dates)
valsArr = ones(3, 4)
TimeData.TimeNum(valsArr, dates)

tmp = TimeData.TimeNum(3.0, "Z4", date(2013, 7, 1))

tmp = TimeData.TimeNum([1.0, 4, 3], "Z4", dates)
tmp = TimeData.TimeNum([1.0 4 3], ["Z1", "Z2", "W3"], dates[1])

dates = [date(2013, 7, 1),
         date(2013, 7, 2),
         date(2013, 7, 3)]
valsArr = ones(3, 4)
tmp = TimeData.TimeNum(valsArr, dates)

## test str
TimeData.str(tmp)

## test mean
TimeData.mean(tmp)
TimeData.mean(tmp, 1)

@test_throws TimeData.mean(tmp, 2)

TimeData.rowmeans(tmp)

vals = TimeData.core(tmp)
nams = TimeData.vars(tmp)
dats = TimeData.dates(tmp)
tmp2 = TimeData.TimeNum(vals, nams, dats)
tmp3 = TimeData.TimeNum(vals, dats, nams)
@test isequal(tmp, tmp2)
@test isequal(tmp3, tmp2)
@test isequal(tmp, tmp3)

##################
## test isequal ##
##################

dates = [date(2013, 7, 1),
         date(2013, 7, 2),
         date(2013, 7, 3)]
valsArr = repmat([1. 2 3], 3, 1)

tmp = TimeData.TimeNum(valsArr, dates)
tmp2 = TimeData.TimeNum(valsArr, dates)

@test TimeData.isequal(tmp, tmp2)

##################################
## getindex DataFrame behaviour ##
##################################

## test for changes in DataFrame behaviour
df = DataFrame(rand(8, 4))
@test isa(df[1:2], DataFrame)
@test isa(df[1:2, 3:4], DataFrame)
@test isa(df[1, 3:4], DataFrame)
@test isa(df[1], DataArray{Float64,1})        
@test isa(df[2:4, 1], DataArray{Float64,1})   
@test isa(df[2, 2], Float64)                  

## create TimeNum test instance 
df = DataFrame(reshape([1:20], (5, 4)))
df[1, 1] = NA
df[2, 2] = NA
df[3, 4] = NA
df[4, 4] = NA

dates = [date(2013, 7, 1),
         date(2013, 7, 2),
         date(2013, 7, 3),
         date(2013, 7, 4),
         date(2013, 7, 5)]
         
tn = TimeData.TimeNum(df, DataArray(dates))

## multiple columns
tn[1:2]
tn[[4, 1]]

## multiple rows, multiple columns
tn[1:3, 2:4]

## single row, multiple columns
tn[3, 3:4]

## single column
tn[1]
tn[:x4]
tn["x4"]

## multiple rows, single column
tn[2:4, 4]
tn[2:4, :x4]
tn[2:4, "x4"]

## single row and single column index
tn[1, 3]
tn[1, 1]

######################
## logical indexing ##
######################

## create TimeNum test instance 
tn = setupTestInstance()

@test isequal(TimeData.ndims(tn), 2)
@test isequal(TimeData.size(tn), (5, 4))
@test isequal(TimeData.size(tn, 1), 5)
@test isequal(TimeData.size(tn, 2), 4)

## create bolean vector
bol = tn.vals[1] .> 3
tn[bol, :]
tn[bol, 1:2]
tn[:, [true, true, false, false]]
tn[1:2, [true, true, false, false]]
tn[bol, [true, true, false, false]]

#################
## expressions ##
#################

## create TimeNum test instance 
tn = setupTestInstance()

ex = :(x1 .> 2)
tn[ex, 1]
tn[ex, :]
tn[ex, [2, 3]]


###############
## operators ##
###############

function setupTestInstance()
    df = DataFrame(reshape([1:20], (5, 4)))
    df[1, 1] = NA
    df[2, 2] = NA
    df[3, 4] = NA
    df[4, 4] = NA

    dates = [date(2013, 7, 1),
             date(2013, 7, 2),
             date(2013, 7, 3),
             date(2013, 7, 4),
             date(2013, 7, 5)]
         
    tn = TimeData.TimeNum(df, DataArray(dates))
    return tn
end    


## create TimeNum test instance
tn = setupTestInstance()

macro assert(ex)
    :($ex ? nothing : error("Assertion failed: ", $(string(ex))))
end
@assert 1==1.0


