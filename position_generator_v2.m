clear all

d = 0.9; %spacing between array elements

N = 10; %number of elements in a row / column

xvec = zeros(N,1);
yvec = zeros(N,1);

xvec(1) = 0;
yvec(1) = 0;

dx = d;
dy = d;

for xi = 1:N
   xvec(xi) = xvec(1) + dx * (xi - 1);
end

% calculate increment required to shift the square to the centre of
% coordinate system
shift = - xvec(N) / 2;

xvec(:) = xvec(:) + shift;
yvec = xvec;

% write data into a text file 
fileID = fopen('data_v2.txt','w');
for xi = 1:N
    for yi = 1:N
        fprintf(fileID,'%4.2f %4.2f %4.2f\n',xvec(xi),yvec(yi),0.00);
    end
end
fclose(fileID);

%plot the results if you want (only main diagonal elements are plotted)
load('data_v2.txt')
plot(data_v2(:,1),data_v2(:,2),"o")
xlabel("x-coordinate")
ylabel("y-coordinate")


