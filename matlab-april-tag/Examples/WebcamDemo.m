function WebcamDemo()
clear('cam')
cam  = webcam;
% cam.Resolution = '1920x1080';
% cam.Resolution = '160x120';
figure;
while(1)
    image = snapshot(cam);
    %profile on;
    StartTime = tic;
    [Pose,Detections] = AprilTag(image,1);
    fps = 1/toc(StartTime)
    Detections
    %profile viewer;
    imshow(image);
    hold on;
    for i = 1:size(Detections)
        plot(Detections(i).QuadPts(1:2,1),Detections(i).QuadPts(1:2,2),'g-','LineWidth',2);
        plot(Detections(i).QuadPts(2:3,1),Detections(i).QuadPts(2:3,2),'r-','LineWidth',2);
        plot(Detections(i).QuadPts(3:4,1),Detections(i).QuadPts(3:4,2),'m-','LineWidth',2);
        plot(Detections(i).QuadPts([4,1],1),Detections(i).QuadPts([4,1],2),'b-','LineWidth',2);
        scatter(Detections(i).cxy(1),Detections(i).cxy(2),100,'r','LineWidth',2);
        text(Detections(i).cxy(1)+10,Detections(i).cxy(2)+5,sprintf('#%i',Detections(i).id),'color','r');
    end
    hold off;
end
clear('cam')
end
