data = xlsread('data_check_101717.xlsx');
index = data(:,7);
voltage = data(:,6);
B = data(:,1);

V1 = voltage(index==1);
V2 = voltage(index==2);
B1 = B(index==1);
B2 = B(index==2);

figure
plot(B1, abs(V1),'bo', B2, abs(V2),'ro')