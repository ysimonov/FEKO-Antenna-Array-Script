%this matlab routine generates uniform arrays spacing 

coord = zeros(16,3)

x = zeros(16,1)
y = zeros(16,1)

spacing = 0.1
while spacing < 0.8
    spacing = input("Enter spacing between two elements in a uniform planar array (>0.8 m): ");
end 

%spacing = 1.1; %variable 

y(1:4) = y(1);
y(5:8) = y(1) + spacing;
y(9:12) = y(1) + 2 * spacing;
y(13:16) = y(1) + 3 * spacing;

for i = 2:16
    if ( i <= 4 || ( i > 9 && i <= 12) )
        x(i) = x(i-1) + spacing;
    elseif ( (i > 5 && i <= 8) || i > 13 )
        x(i) = x(i-1) - spacing;
    else
        x(i) = x(i-1);
    end 
end 

% shift the entire array to the centre of coordinate system 
distance_to_centre = 0.5 * sqrt( ( max(x) - min(x) )^2 + ( max(y) - min(y) )^2 );
x_c =  distance_to_centre / sqrt(2);
y_c =  distance_to_centre / sqrt(2);

x = x - x_c;
y = y - y_c;
z = zeros(16,1);

% write data into a text file 
fileID = fopen('data.txt','w');
for i = 1:16
    fprintf(fileID,'%4.2f %4.2f %4.2f\n',x(i),y(i),z(i));
end
fclose(fileID);
