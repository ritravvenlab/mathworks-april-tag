clc;
clear;
close all;

addpath(genpath('../src'))
addpath(genpath('../Examples'))

user_input_prompt = 'Which example do you want to run?\n1.Webcam\n2.Test Image\n3.Single Image\n4.Analyze Video\n';
usr_input = input(user_input_prompt);

switch usr_input
    case 1
        WebcamDemo;
    case 2
        profile on;
        [Pose,Detection] = AprilTag(imread('../pics/test_tag.png'),1);
        Detection
        profile viewer;
    case 3
        [file, path] = uigetfile('../pics/test_tag.png');
        if isequal(file,0)
            disp('User selected cancel')
        else
            profile on;
            [Pose,Detection] = AprilTag(imread([path,file]),1);
            Detection
            profile viewer;
        end
    case 4
        [file, path] = uigetfile('../pics/test480p.mp4');
        if isequal(file,0)
            disp('User selected cancel');
        else
            video  = VideoReader([path,file]);
            videoWidth = video.Width;
            videoHeight = video.Height;
            
            output = struct('cdata',zeros(videoHeight,videoWidth,3,'uint8'),'colormap',[]);
            mkdir vidframes;
            vidDisp = figure;
            FpsBuffer = zeros(1,10);
            k = 1;
            while hasFrame(video)
                CurrFrame = readFrame(video);
                
                tic;
                [~,det] = AprilTag(CurrFrame,1);
                FrameTime = toc;
                
                FpsBuffer(2:10) = FpsBuffer(1:9);
                FpsBuffer(1) = FrameTime;
                AvgFps = (sum(FpsBuffer)/10)^-1;
                
                
                figure(vidDisp); %Get Figure for displaying video
                imshow(CurrFrame);   %Display Current Frame
                hold on;          %Wait to draw AprilTag detections
                for i = 1:size(det)
                    plot(det(i).QuadPts(1:2,1),det(i).QuadPts(1:2,2),'g-','LineWidth',2);
                    plot(det(i).QuadPts(2:3,1),det(i).QuadPts(2:3,2),'r-','LineWidth',2);
                    plot(det(i).QuadPts(3:4,1),det(i).QuadPts(3:4,2),'m-','LineWidth',2);
                    plot(det(i).QuadPts([4,1],1),det(i).QuadPts([4,1],2),'b-','LineWidth',2);
                    scatter(det(i).cxy(1),det(i).cxy(2),100,'r','LineWidth',2);
                    text(det(i).cxy(1)+10,det(i).cxy(2)+5,sprintf('#%i',det(i).id),'color','r');
                end
                text(videoWidth-(0.15*videoWidth),videoHeight-(0.03*videoHeight),sprintf('%0.1f fps',AvgFps),'color','r');
                hold off;       %Release figure
                
%                 saveas(vidDisp,'test.png');
                annotatedFrame = getframe;
                output(k).cdata = annotatedFrame.cdata;
                imwrite(CurrFrame,sprintf('vidframes/%05i.png',k));
                k = k + 1;
            end
            
            vout = VideoWriter('test','MPEG-4');
            open(vout);
            writeVideo(vout,output);
            close(vout);
        end
    otherwise
        disp('Please select a valid option');
end
    