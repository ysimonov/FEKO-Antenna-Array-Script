clear all;

N = 3; %square root of the number of array elements in one quadrant

fprintf('\n')

x = []; % Initialize array/vector
for i=1:N
  x_in =  input('Enter x-value: ');
  x(end+1)=x_in;
end

%x = [ 0.3 1.3 2.3 ];
Nx = size(x); %number of points (overall N^2 points)
N = Nx(1,2);

y = x;

% write data into a text file 
fileID = fopen('data_nonuniform.txt','w');
for xi = 1:N
    for yi = 1:N
        fprintf(fileID,'%4.2f %4.2f %4.2f\n',x(xi),y(yi),0.00);
        fprintf(fileID,'%4.2f %4.2f %4.2f\n',x(xi),-y(yi),0.00);
        fprintf(fileID,'%4.2f %4.2f %4.2f\n',-x(xi),y(yi),0.00);
        fprintf(fileID,'%4.2f %4.2f %4.2f\n',-x(xi),-y(yi),0.00);
    end
end
fclose(fileID);

%plot the results if you want (only main diagonal elements are plotted)
load('data_nonuniform.txt')
plot(data_nonuniform(:,1),data_nonuniform(:,2),"o")
xlabel("x-coordinate")
ylabel("y-coordinate")