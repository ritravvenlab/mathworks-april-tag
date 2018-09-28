function Clusters = MergeEdges(Edges,Magnitude,Direction)

	%%DataTypes
	%Magnitude = 1*N list of Magnitudes for the entire image
	
	%Direction = 1*N list of Thetas for the entire image
	
	%Edges = 5*N list of correlated edges that have:
    % 1. Cost
	% 2. Ida (addr of current point) 
	% 3. Idb (addr of next connected point) 
	% 4. Point (x,y)
	
	%Clusters = 4*N list of Grouped Edge points
	% 1. & 2. Point X,Y
	% 3. Edge Magnitude
	% 4. Edge Cluster ID
	
	%SimpleUF = width*height*2 list of groups and size of groups
	% 1. Group ID (Starts the same as the addr)
	% 2. Group size (Starts as 1)


    %Constants to export sometime
    thetaThr = 100;
    magThr = 1200;
    
    %Get the width and height of the iamge
    width = size(Magnitude,2);
    height = size(Magnitude,1);
    
    %Reshape the Magnitude and Directions of the arrays
    tmin = ArraytoList(Direction);
    tmax = tmin;
    mmin = ArraytoList(Magnitude);
    mmax = mmin;
    
    ValidIds = [Edges(:,2) ; Edges(:,3)];
    
    %Create the unionfind vector which is pre allocated for speed
    SimpleUF = [(1:width*height)', ones(1,width*height)'];
    
    test = ismember(SimpleUF(:,1),ValidIds);
    SimpleUF(~test) = 0;
    
    for i = 1:size(Edges,1)
        ida = Edges(i,2);
        idb = Edges(i,3);
        
        ida = IgetRepresentative(SimpleUF,ida); %gets rep
        idb = IgetRepresentative(SimpleUF,idb); %gets rep
        
        if(ida == idb) %It's already connected!
            continue;
        end
        
        sza = SimpleUF(ida,2); %Get the size of tree a
        szb = SimpleUF(idb,2); %Get the size of tree b
        
        tmina = tmin(ida); tmaxa = tmax(ida); %finds the max and mins of a
        tminb = tmin(idb); tmaxb = tmax(idb); %finds the max and mins of b
        
        costa = tmaxa-tmina; %Intermediate cost value
        costb = tmaxb-tminb; %Intermediate cost value
        
        %Makes sure that the angles aren't more than +/- PI
        bshift = mod2pi((tminb+tmaxb)/2,(tmina+tmaxa)/2)-(tminb+tmaxb)/2;
        
        tminab = min(tmina, tminb+bshift); %Theta min
        tmaxab = max(tmaxa, tmaxb+bshift); %Theta max
        
        if(tmaxab-tminab > 2*pi)
            tmaxab = tminab + 2*pi;
        end
        
        mminab = min(mmin(ida), mmin(idb)); %Mag min
        mmaxab = max(mmax(ida), mmax(idb)); %Mag max
        
        costab = (tmaxab - tminab); %Intermediate cost value for a and b
        
        %Magic Values that I need to understand more :)
        Value1 = (costab <= min(costa,costb) + (thetaThr/(sza+szb)));
        Value2 = (mmaxab-mminab) <= min(mmax(ida)-mmin(ida),...
            mmax(idb)-mmin(idb)) + (magThr/(sza+szb));
        
        if(Value1 && Value2)
            [SimpleUF, idab] = IconnectNodes(SimpleUF, ida, idb,test);
            
            tmin(idab) = tminab; %Sets the minimum theta
            tmax(idab) = tmaxab; %Sets the maximum theta
            
            mmin(idab) = mminab; %Sets the minimum mag
            mmin(idab) = mmaxab; %Sets the maximum mag
        end
    end
    %Export the clusters
    Clusters = ExportClusters(SimpleUF,Magnitude, Edges);
end


% Gets the representative of the node
function root = IgetRepresentative(UFArray,NodeId)
    if(UFArray(NodeId,1) == NodeId) %If it is it's own rep return
        root = NodeId;              %No changes
    else
        root = UFArray(NodeId,1);
    end
end

%connects and merges the two trees together
function [UFArray,root] = IconnectNodes(UFArray, aId,bId,ValidIds)

    aRoot = IgetRepresentative(UFArray,aId); %Get rep of a
    bRoot = IgetRepresentative(UFArray,bId); %Get rep of b

    if(aRoot==bRoot) %It's already connected!
        root=aRoot;  %Return the root
        return;
    end
    
    if(UFArray(aRoot,2) > UFArray(bRoot,2)) %Larger tree wins!
        %Add the sizes together
        UFArray(aRoot,2) = UFArray(aRoot,2) + UFArray(bRoot,2);
        
        UFArray(UFArray == bRoot) = aRoot;
        
        root=aRoot; %Return the new root
        return;
    else
        %Add the sizes together
        UFArray(bRoot,2) = UFArray(aRoot,2) + UFArray(bRoot,2);
        
        UFArray(UFArray == aRoot) = bRoot;
        
        root=bRoot; %Return the new root
        return;
    end
end

function longArray = ArraytoList(Array)
Width = size(Array,2);
Height  = size(Array,1);

longArray = zeros(1,Width*Height);
for i = 1:Height
    StartIdx = ((i-1) * Width)+1;
    EndIdx   = (StartIdx + Width)-1;
    longArray(1,StartIdx:EndIdx) = Array(i,:);
end
end

%Formatting the clusters as a list with points to make it easier later
function ClusterList = ExportClusters(UF_Array,Magnitude,Edges)
    %Need to export these constants
    MinCluster = 4;

    %find clusters that have more than the MinSeg
    Valid_Clusters = UF_Array((UF_Array(:,2) >= MinCluster),1);
    
    %Create a logical array for faster indexing / display
    logical_arr = ismember(Edges(:,2),Valid_Clusters);
    
    ClusterList = zeros(size(Edges,1),4);  %Empty matrix for clusters
    
    for i = 1:size(Edges,1)-1 %loops through all the edges
        if(~logical_arr(i))
            EdgeCluster = UF_Array(Edges(i,3)); %Gets cluster #
            EdgeMag = Magnitude(Edges(i,3));      %Gets magnitude
            EdgeX = Edges(i,4);                   %Gets X coord
            EdgeY = Edges(i,5);                   %Gets Y coord
            ClusterList(i,:) = [EdgeX,EdgeY,EdgeMag,EdgeCluster];
        end
    end

    ClusterList = sortrows(ClusterList,4);
end