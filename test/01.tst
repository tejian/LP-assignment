L = []
L2 = [1,2,3]

L3 = L#L2

L4 = [[[1,2],3],4]

L5 = lreduce + L4
L6 = lmap - 1 L4

print L5
print L6

L7 = lfilter != 1 L4

print L7

L8 = lfilter > 2 L7

flatten L4

if (L2 > L4) then
    print L2
endif

while (not empty(L2)) do
    print head(L2)
    pop(L2)
endwhile
