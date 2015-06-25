function lambda = gen_uniformweight(start_obj_index, max_value_left, coordinate, H, lambda,nobj)
%

if (1 == start_obj_index || 0 == max_value_left)
    
    coordinate(start_obj_index) = max_value_left;
    
    temp = [];
    for k = 1:1:nobj
        temp= [temp,coordinate(k,1)];
        lambda = [lambda,1.0*temp(k) / H]; %最后每个子问题中的namda就是所想要的权重了
    end
    return ;
end

for i = max_value_left:-1:1
    coordinate(start_obj_index) = i;
    lambda = gen_uniformweight(start_obj_index - 1, max_value_left - i, coordinate, H, lambda,nobj);
end

end

