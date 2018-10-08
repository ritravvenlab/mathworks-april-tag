function Detections = RemoveDuplicates(Detections)
if(isempty(Detections))
    Detections = [];
    return;
end

for i = 1:size(Detections,1)
   for j = 1:size(Detections,1)
      if(abs(Detections(i).cxy(1) - Detections(j).cxy(1)) <= 10)
          if(abs(Detections(i).cxy(2) - Detections(j).cxy(2)) <= 10)
              if(i == j || ~Detections(i).good)
                  continue;
              else
                  if(Detections(i).obsPerimeter >= Detections(j).obsPerimeter)
                      Detections(j).good = 0;
                  else
                      Detections(i).good = 0;
                  end
              end
          end
      end
       
   end
end
i = 1;
DetectCnt = size(Detections,1);
DetectTmp = 0;
good = 1;
while(good)
if(~Detections(i).good)
    Detections(i) = [];
    DetectTmp = DetectTmp + 1;
else
    i = i + 1;
    DetectTmp = DetectTmp + 1;
end
if(DetectTmp == DetectCnt)
    good = 0;
end
end

end