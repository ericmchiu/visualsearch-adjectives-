function create_display(rv,rh,gv,gh)

global width height im
global margin mindist long short  

darkgreen   = 160;                          % Darker green

% Put the list together
%disp([rv rh gv gh])
list = [ones(1,rv) ones(1,rh)*2 ones(1,gv)*3 ones(1,gh)*4];
% Type 1 = rv - red vertical
% Type 2 = rh - red horizontal
% Type 3 = gv - green vertical
% Type 4 = gh - green horizontal
% REMEMBER: x values are associated to width, but in the second dimension
% for im!!! Use im(y,x) to get to width x and height y!

list = list(randperm(length(list))); % Permute
for i=1:length(list)
    if list(i)==1 || list(i)==3 % translate long/short into actual x,y
        % verticals
        xe = short;
        ye = long;
    else
        % horizontals
        xe = long; % width is long
        ye = short;% height is short
    end;
    found = false;
    while found == false % Search for a non-overlapping point
        % Find a random point that respects margin and shape
        x = round(rand*(width-2*margin-xe)+margin+xe/2);
        y = round(rand*(height-2*margin-ye)+margin+ye/2);
        found = true; % Assume optimistically that we found it
        for j=round(x-xe/2-mindist)+1:round(x+xe/2+mindist)
            for k=round(y-ye/2-mindist)+1:round(y+ye/2+mindist)
                if im(k,j,3) == 100;
                    found = false; % Oh well, we didn't find it...
                end;
            end;
        end;
    end;
    % Paint yellow around the area
    im(round(y-ye/2-mindist)+1:round(y+ye/2+mindist),round(x-xe/2-mindist)+1:round(x+xe/2+mindist),3) = 100;
    % Paint the stimuli itself
    im(round(y-ye/2):round(y-ye/2)+ye,round(x-xe/2):round(x-xe/2)+xe,:) = 0;
    if list(i)==1 || list(i)==2
        im(round(y-ye/2):round(y-ye/2)+ye,round(x-xe/2):round(x-xe/2)+xe,1) = 255;
    else
        im(round(y-ye/2):round(y-ye/2)+ye,round(x-xe/2):round(x-xe/2)+xe,2) = darkgreen;
    end;
end;
im(find(im==100))=255; % Remove the yellow again