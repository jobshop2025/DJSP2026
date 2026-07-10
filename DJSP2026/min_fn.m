function i_min = min_fn(OPEN,OPEN_COUNT,xTarget,yTarget)
 temp_array=[];
 k=1;
 flag=0;
 goal_index=0;
 for j=1:OPEN_COUNT%附近可行点的个数，是否存在终点
     if (OPEN(j,1)==1)
         temp_array(k,:)=[OPEN(j,:) j]; %#ok<*AGROW>
         if (OPEN(j,2)==xTarget && OPEN(j,3)==yTarget)%该点等于终点
             flag=1;
             goal_index=j;%Store the index of the goal node
         end
         k=k+1;
     end
 end%Get all nodes that are on the list open
 if flag == 1 % 
     i_min=goal_index;
 end
 %Send the index of the smallest node
 if size(temp_array ~= 0)
  [~,temp_min]=min(temp_array(:,8));%Index of the smallest node in temp array
  i_min=temp_array(temp_min,9);%Index of the smallest node in the OPEN array
 else
     i_min=-1;%没有更多的有效路径
 end
end