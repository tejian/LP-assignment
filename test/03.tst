l = [1,2,3,4,5]
print l
while(not empty(l)) do
    l3 = [[1,2]]
    l4 = head(l3)
    flatten l3
    if(l3 == l4) then
        print [11111]
        print lreduce + l
        print [22222]
        print lreduce - l
        print [33333]
        print lreduce * l
        print [44444]
        print lreduce / l
    endif
    pop(l)
endwhile
list = [[1,4],[3,6,4],3,[-3,-3],[[0,-1],-2]]
print list
l1 = head(list)
print l1
pop (list)
print head(list)
print l1#list
print lfilter <= 0 list
print lfilter > 0 list
l7= lmap * 2 list
print l7
print lmap / 2 l7



