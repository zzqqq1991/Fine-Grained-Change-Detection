startTime = clock;

dir = 'demoData\';%数据目录
%读取数据
im1names = {'1-1'};
im2names = {'2-1'};

 
%设置参数
[h,w,dim] = size(imread([dir im1names{1} '.bmp']));
diagonal = (h^2+w^2)^0.5;
paramrate = ((772^2+515^2)^0.5)/diagonal;
separate = 1;%计算lrr时每对图像单独算
functionnum = 2;%计算lrr中线性方程组用的方法，1：反除。2：cgs。3：symmlq。4：lsqr。5：rref
lambda = 0.0015*paramrate;  %data项的系数 big:0.0015,middle:0.003,mini:0.006;
gama = 0.0025*paramrate; %WE项的系数 big:0.0025,middle:0.005,mini:0.01;
rou = 0.02*paramrate;%强制项系数
    
%parameter设置
parameter = [];
parameter.separate = separate;
parameter.functionnum = functionnum;
parameter.lambda = lambda;
parameter.gama = gama;
parameter.display = true;

%开始
X = [];
Y = [];
for i = 1:length(im1names)
    im1 = imread([dir im1names{i} '.bmp']);
    im1 = im2double(im1);
    X(:,:,:,1) = im1;
    im2 = imread([dir im2names{i} '.bmp']);
    im2 = im2double(im2);
    Y(:,:,:,1) = im2;
end
% lastXA(:,:,:,1) = lastA1;
% lastYA(:,:,:,1) = lastA2;
% lastXE(:,:,:,1) = lastE1;
% lastYE(:,:,:,1) = lastE2;
[XError,YError,XA,YA] = fineChangeDetection(X,Y,parameter);

EX = XError(:,:,:,1);
EY = YError(:,:,:,1);
AX = XA(:,:,:,1);
AY = YA(:,:,:,1);

%计时结束，统计时间
endTime = clock;
duringTime = etime(endTime,startTime);
disp(['Total Time is: ' num2str(duringTime) ' second']); 


imwrite(EX, 'result\EX.bmp');
imwrite(EY, 'result\EY.bmp');
imwrite(AX, 'result\AX.bmp');
imwrite(AY, 'result\AY.bmp');
% %输出
% newdirName = ['model' int2str(model) '_func' int2str(functionnum) '_lambda' num2str(lambda) ...
%     '_gama' num2str(gama) '_fai' num2str(fai) '_' num2str(duringTime)];
% mkdir([dir prepath], newdirName);
% resultDir = [dir prepath newdirName '\'];
% 
% imwrite(EX, [resultDir 'EX.bmp']);
% imwrite(EY, [resultDir 'EY.bmp']);
% imwrite(AX, [resultDir 'AX.bmp']);
% imwrite(AY, [resultDir 'AY.bmp']);
% imwrite(EX, [dir 'data\' type 'EX.bmp']);
% imwrite(EY, [dir 'data\' type 'EY.bmp']);
% imwrite(AX, [dir 'data\' type 'AX.bmp']);
% imwrite(AY, [dir 'data\' type 'AY.bmp']);
% 
% save([resultDir 'result.mat'], 'EX', 'EY', 'AX', 'AY', 'parameter', 'duringTime');
