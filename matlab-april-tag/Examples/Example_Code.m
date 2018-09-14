clc;
clear;
close all;

addpath(genpath('../src'))

user_input_prompt = 'Which example do you want to run?\n1.Webcam\n2.Test Image\n3.Single Image\n';
usr_input = input(user_input_prompt);

if(usr_input == 1)
    WebcamDemo;
end

if(usr_input == 3)
    [file, path] = uigetfile('../pics/test_tag.png');
    if isequal(file,0)
        disp('User selected cancel')
    else
        profile on;
        [Pose,Detection] = AprilTag(imread([path,file]),1,1);
        profile viewer;
    end
else
    profile on;
    [Pose,Detection] = AprilTag(imread('../pics/test_tag.png'),1,1);
    profile viewer;
end
    