clc;
clear;
close all;
if(exist('../pics/R','dir') == 0)
    unzip('../pics/TestData.zip','../pics');
end

PdataC = csvread('../data/pitchTest.dat');
RdataC = csvread('../data/rollTest.dat');
YdataC = csvread('../data/yawTest.dat');
CData = csvread('../data/TestOutput.csv');

NumOfPics = 61;

TimeValues = zeros(3*NumOfPics,1);
TimeAddr = 1;

Path = [-30:30]';
TruePitch = [zeros(NumOfPics,1),zeros(NumOfPics,1), Path];

PitchPics = [];
for i = 1:NumOfPics
    PitchPics = [PitchPics;sprintf('../pics/P/%05d.jpg',i)];
end

PitchObs = [];
Detections = [];

for j = 1:size(PitchPics,1)
   CurrentPic = imread(PitchPics(j,:));
   StartTime = tic;
   [Pose,Detection] = AprilTag(CurrentPic,0);
   ElapsedTime = toc(StartTime);
   TimeValues(TimeAddr) = ElapsedTime;
   TimeAddr = TimeAddr + 1;
   PitchObs = [PitchObs, Pose];
   Detections = [Detections, Detection];
end


RollPics = [];
for i = 1:NumOfPics
    RollPics = [RollPics;sprintf('../pics/R/%05d.jpg',i)];
end

RollObs = [];
RollDet = [];

for j = 1:size(RollPics,1)
   CurrentPic = imread(RollPics(j,:));
   StartTime = tic;
   [Pose,Detection] = AprilTag(CurrentPic,0);
   ElapsedTime = toc(StartTime);
   TimeValues(TimeAddr) = ElapsedTime;
   TimeAddr = TimeAddr + 1;
   RollObs = [RollObs, Pose];
   Detections = [Detections, Detection];
end

YawPics = [];
for i = 1:NumOfPics
    YawPics = [YawPics;sprintf('../pics/Y/%05d.jpg',i)];
end

YawObs = [];
YawDet = [];
for j = 1:size(YawPics,1)
   CurrentPic = imread(YawPics(j,:));
   StartTime = tic;
   [Pose,Detection] = AprilTag(CurrentPic,0);
   ElapsedTime = toc(StartTime);
   TimeValues(TimeAddr) = ElapsedTime;
   TimeAddr = TimeAddr + 1;
   YawObs = [YawObs, Pose];
   Detections = [Detections, Detection];
end

MatDatacxy = [Detections(1).cxy(1),Detections(1).cxy(2)];
for i = 2:length(Detections)
    MatDatacxy = [MatDatacxy;[Detections(i).cxy(1),Detections(i).cxy(2)]];
end

MatDataQuad = [Detections(1).QuadPts(1,:),Detections(1).QuadPts(2,:),Detections(1).QuadPts(3,:),Detections(1).QuadPts(4,:)];
for i = 2:length(Detections)
    MatDataQuad = [MatDataQuad;Detections(i).QuadPts(1,:),Detections(i).QuadPts(2,:),Detections(i).QuadPts(3,:),Detections(i).QuadPts(4,:)];
end

test = CData(:,1:2) - MatDatacxy;
test1 = CData(:,3:10) - MatDataQuad;
 
% 
% figure;
% %Pitch Output
% plotYPR(0,PdataC,PitchObs, 0)
% 
% %Roll Output
% plotYPR(1,RdataC,RollObs, 0)
% 
% %Yaw Disp
% plotYPR(2,YdataC,YawObs, 0)
% 
% figure;
% %Pitch Diff
% plotYPR(0,PdataC,PitchObs, 1)
% 
% %Roll Diff
% plotYPR(1,RdataC,RollObs, 1)
% 
% %Yaw Diff
% plotYPR(2,YdataC,YawObs, 1)

function plotYPR(RowNum,CData,MatData,diff)
switch RowNum
case 0
    PlotTitle = 'Pitch Test:';
case 1
    PlotTitle = 'Roll Test:';
case 2
    PlotTitle = 'Yaw Test:';
end
    
if(diff ~= 1)
    subplot(3,3,1+RowNum);
    axis([-30 30 -40 40]);
    if(RowNum == 1)
        line([-30,30],[-30,30],'Color','green')
    else
        line([-30,30],[0,0],'Color','green')
    end
    hold on;
    plot([-30:30],CData(:,6)*(180/pi),'-r');
    plot([-30:30],[MatData(:).pitch]','-b');
    
    title([PlotTitle,'Pitch']);
    legend('Unity','C++','Matlab','location','southeast');
    xlabel('True Rotation (Degrees)') % x-axis label
    ylabel('degrees') % y-axis label
    hold off;
    
    subplot(3,3,4+RowNum);
    axis([-30 30 -40 40]);
    if(RowNum == 0)
        line([-30,30],[-30,30],'Color','green')
    else
        line([-30,30],[0,0],'Color','green')
    end
    hold on;
    plot([-30:30],CData(:,7)*(180/pi),'-r');
    plot([-30:30],[MatData(:).roll]','-b');
    
    title([PlotTitle,'Roll']);
    legend('Unity','C++','Matlab','location','southeast');
    xlabel('True Rotation (Degrees)') % x-axis label
    ylabel('degrees') % y-axis label
    hold off;

    subplot(3,3,7+RowNum);
    axis([-30 30 -40 40]);
    if(RowNum == 2)
        line([-30,30],[-30,30],'Color','green')
    else
        line([-30,30],[0,0],'Color','green')
    end
    hold on;
    plot([-30:30],CData(:,5)*(180/pi),'-r');
    plot([-30:30],[MatData(:).yaw]','-b');
    title([PlotTitle,'Yaw']);
    legend('Unity','C++','Matlab','location','southeast');
    xlabel('True Rotation (Degrees)') % x-axis label
    ylabel('degrees') % y-axis label
    hold off;
else
    Path = [-30:30];
    
    subplot(3,3,1+RowNum);
    if(RowNum == 1)
        plot([-30:30],((CData(:,6)*(180/pi)) - Path(:)),'-r');
        hold on;
        plot([-30:30],([MatData(:).pitch]' - Path(:)),'-b');
    else
        plot([-30:30],(CData(:,6)*(180/pi)),'-r');
        hold on;
        plot([-30:30],([MatData(:).pitch]'),'-b');
    end

    %axis([-30 30 -10 10]);
    title([PlotTitle,'Pitch Diff']);
    legend('C++','Matlab');
    xlabel('True Rotation (Degrees)') % x-axis label
    ylabel('degrees') % y-axis label
    hold off;
    
    subplot(3,3,4+RowNum);
    if(RowNum == 0)
        plot([-30:30],(CData(:,7)*(180/pi) - Path(:)),'-r');
        hold on;
        plot([-30:30],([MatData(:).roll]' - Path(:)),'-b');
    else
        plot([-30:30],(CData(:,7)*(180/pi)),'-r');
        hold on;
        plot([-30:30],([MatData(:).roll]'),'-b');
    end
    %axis([-30 30 -10 10]);
    title([PlotTitle,'Roll Diff']);
    legend('C++','Matlab');
    xlabel('True Rotation (Degrees)') % x-axis label
    ylabel('degrees') % y-axis label
    hold off;

    subplot(3,3,7+RowNum);
    if(RowNum == 2)
        plot([-30:30],(CData(:,5)*(180/pi) - Path(:)),'-r');
        hold on;
        plot([-30:30],([MatData(:).yaw]' - Path(:)),'-b');
    else
        plot([-30:30],(CData(:,5)*(180/pi)),'-r');
        hold on;
        plot([-30:30],([MatData(:).yaw]'),'-b');
    end
    %axis([-30 30 -10 10]);
    title([PlotTitle,'Yaw Diff']);
    legend('C++','Matlab');
    xlabel('True Rotation (Degrees)') % x-axis label
    ylabel('degrees') % y-axis label
    hold off;
end
end
