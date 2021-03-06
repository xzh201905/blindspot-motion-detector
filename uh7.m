obj=mmreader('Trial1.avi');
a=read(obj);
frames=get(obj,'numberOfFrames');
d1=figure('PaperSize',[600 600],'visible','off');
d2=figure('visible','off');
scrsz = get(0,'ScreenSize');% retrieve screensize of computer
d3=figure('Position',[1 1 scrsz(3)/.82 scrsz(4)/1],'visible','off');%create the position and size of figure d3
winsize = get(d3,'Position');%initiate winsize, which will determine the position and size of the movie,
winsize(1:2) = [0 0]; %adjust size of window to include whole figure window
A=moviein(frames,d3,winsize);%create movie matrix A
values=0; %intiate the values variable
close all
xx=zeros(1,frames-1);
countit=0;
for tony=1:frames-1
    xx(1,tony)=tony;
end
yy=zeros(1,frames-1);%velocity values stored here
zz=zeros(1,frames-1);%acceleration values stored here
zz(1,1)=0;

im1 = a(:,:,:,1);
VerticalLength=size(im1(:,1,1),1);
HorizontalLength=size(im1(1,:,1),2);
Area=VerticalLength*HorizontalLength;
x=zeros(1,Area);
y=zeros(1,Area);
for i = 1:HorizontalLength
 for j= 1:VerticalLength
     x(1,(VerticalLength.*(i-1)+j ))=i;
y(1,(VerticalLength.*(i-1)+j ))= j;
end
end
NoOutliers=zeros(1,Area);
anglebisector=-pi;
accelerationcounter=0;
for k= 23%loop
    if rem(k+3,5)==0
        countit=countit+1
        continue;
    end
%     
im1 = a(:,:,:,k);
im2=a(:,:,:,k+1);
[u,v]=HS(im1,im2);
displayImg=im1;
%--------------create first image (video with vectors)--------------------------------------------


d1=figure('visible','off','PaperSize',[600 600]); 

set(d1,'Position',[scrsz(3)/3.5 scrsz(4)/3 scrsz(3)/1.75 scrsz(4)/1.75])
set(d1,'Menubar','none');

subplot('position',[0.58,0.05,0.39,.68]);
if sum(sum(displayImg))~=0
        imshow(displayImg,[0 255]);
        hold on;% holds image onto figure d1, so that the next image(in this case, the vector arrows) does
        %not replace the image
    end


    rSize=5;


  


% Enhance the quiver plot visually by showing one vector per region
for i=1:size(u,1)
    for j=1:size(u,2)
        if floor(i/rSize)~=i/rSize || floor(j/rSize)~=j/rSize
            u(i,j)=0;
            v(i,j)=0;
        end
    end
end
Length=floor(size(u(1,:),2)); %horizontal
Height=floor(size(u(:,1),1));% vertical
u=reshape(u,[1,Area]);
v=reshape(v,[1,Area]);
timesaver=find(u~=0 & v~=0); %a matrice, size based on #of non-zero arrows, indices contains the indice number of non-zero indices 
arrowlengthsquareit=sqrt(u(1,timesaver).^2+v(1,timesaver).^2); %returns the vector's magnitude of non-zero indices
findthreshold=sort(arrowlengthsquareit,'descend');%sort from BIGGEST, vector magnitudes
threshold=findthreshold(1,floor(size(timesaver(1,:),2)/2));%take the value at the 50th percentile for all possible vectors, and sets it as THRESHOLD

%calculate means
arrowlength=sqrt(u(find(sqrt(u.^2+v.^2)>threshold)).^2+v(find(sqrt(u.^2+v.^2)>threshold)).^2);
AverageMagnitude=mean(arrowlength);

s=std(arrowlength);

Just=zeros(1,Area);
for trikk =1:Area
    if (sqrt(u(1,trikk).^2+v(1,trikk).^2)-AverageMagnitude)/s<2%if z-score is less than two(if its not greater than two standard deviation units)
        Just(1,trikk)=2;
    end
end
tobes=zeros(1,Area);%initiates tobes with matrix size of 1 x Area.
%tobes is used as a threshold factor to determine which vectors are greater
%than threshold
for trikk=1:Area
    if sqrt(u(1,trikk).^2+v(1,trikk).^2)>threshold 
        tobes(1,trikk)= 1; % find greater than threshold
    end
end
joes=atan2(-v,u);%contains the angle of the vectors from the interval [-pi, pi]
johnny=joes;%johnny contains the angle of the vectors, but the interval can be changed.
  %initialize variable desiredangle with value of 1.05pi. Used to determine angle direction that will be measured

if anglebisector>7/4*pi || anglebisector<-3/4*pi  % if anglebisector>7pi/4, that means values greater than 2pi will be evaluated. These values are basically
    %the first quartile(NE). to make these values evaluated, add 2pi to those values, as seen in line 200. 
    for yikes = 1: size(johnny(1,:),2)
        if johnny(1,yikes)<anglebisector+pi/4
            johnny(1,yikes)=johnny(1,yikes)+2*pi; %transposes interval
        end
    end
end

CarVectors=find(tobes~=0 & johnny>3*pi/4); %stores indices values'
BackGroundVectors=find(tobes~=0 & johnny<3*pi/4);%stores indices values'

thetally=2;
   while size(CarVectors(1,:),2)+size(BackGroundVectors(1,:),2)>100000%if there are more than 5000 arrows 
    
threshold=findthreshold(1,floor(size(timesaver(1,:),2)/(4*(thetally-1))));%take the 75%biggest and set it as the THRESHOLD so that less arrows appear
 
tobes=zeros(1,Area);
for trikk=1:Area
    if sqrt(u(1,trikk).^2+v(1,trikk).^2)>threshold 
        tobes(1,trikk)= 1; % find arrows greater than threshold
    end
end


CarVectors=find(tobes~=0 & johnny>3*pi/4); %stores indices values'
BackGroundVectors=find(tobes~=0 & johnny<3*pi/4);%stores indices values'
 thetally=thetally+2  

   end

%--------------------start-determine SIZE of box-----------------
HorizontalParameter=floor(Length*size(CarVectors(1,:),2)/size(BackGroundVectors(1,:),2)/2);
if size(CarVectors(1,:),2)/size(BackGroundVectors(1,:),2)>0.4
    HorizontalParameter=floor(Length*0.4);
end

VerticalParameter=floor(Height*size(CarVectors(1,:),2)/size(BackGroundVectors(1,:),2)/2);
 
if size(CarVectors(1,:),2)/size(BackGroundVectors(1,:),2)>0.4
    VerticalParameter=floor(Height*0.4);
end
%-----------------------end-determine SIZE of box-----------------------

%-----start of determining box location code------------------------------------------
presence=0;

horizontalcenter=0;
verticalcenter=0;
itsthecounter=0;

if size(CarVectors(1,:),2)/size(BackGroundVectors(1,:),2)>0.1
    presence=1;
res1=reshape(u,[VerticalLength,HorizontalLength]);
res2=reshape(v,[VerticalLength,HorizontalLength]);
thewhy=reshape(johnny,[VerticalLength,HorizontalLength]);
for sigma=1:VerticalLength
    for gamma=1:HorizontalLength
        if sqrt(res1(sigma,gamma)^2+res2(sigma,gamma)^2)>threshold && thewhy(sigma,gamma)>3*pi/4
            horizontalcenter=horizontalcenter+gamma;
            verticalcenter=verticalcenter+sigma;
            itsthecounter=itsthecounter+1;
        end
    end
end
HorizontalCenter=floor(horizontalcenter/itsthecounter);
VerticalCenter=floor(verticalcenter/itsthecounter);

       
%-----end of determining box location
%code--------------------------------------------

%---start--make box location more accurate 1---
for standarddeviationunit=1:0.2:9
NoOutliers=zeros(1,Area);
LeftBorder=floor(HorizontalCenter-HorizontalParameter*(10-standarddeviationunit));%4 standard deviations from box
RightBorder=floor(HorizontalCenter+HorizontalParameter*(10-standarddeviationunit));
TopBorder=floor(VerticalCenter-VerticalParameter*(10-standarddeviationunit));
BottomBorder=floor(VerticalCenter+VerticalParameter*(10-standarddeviationunit));
if LeftBorder<1
    LeftBorder=1;
end
if RightBorder>Length
    RightBorder=Length;
end
if TopBorder<1
    TopBorder=1;
end
if BottomBorder>Height
    BottomBorder=Height;
end
%--start--find points three radius units away from box
    for kimchi=LeftBorder:RightBorder%horizontal 
   for kimmy=TopBorder:BottomBorder%vertical
       NoOutliers(1,VerticalLength*(kimchi-1)+ kimmy)=1;
   end
    end
     %--end--find points two three units away from box
%--remake box center--first time
horizontalcenter=0;
verticalcenter=0;
itsthecounter=0;

NoOutliers=reshape(NoOutliers,[VerticalLength,HorizontalLength]);
for sigma=1:VerticalLength
    for gamma=1:HorizontalLength
        if sqrt(res1(sigma,gamma)^2+res2(sigma,gamma)^2)>threshold && thewhy(sigma,gamma)>3*pi/4 &&NoOutliers(sigma,gamma)==1
            horizontalcenter=horizontalcenter+gamma;
            verticalcenter=verticalcenter+sigma;
            itsthecounter=itsthecounter+1;
        end
    end
end
if itsthecounter~=0
HorizontalCenter=floor(horizontalcenter/itsthecounter);
VerticalCenter=floor(verticalcenter/itsthecounter);
else%we dont change center
    
end
end
%--end--remake box center first time---

%---end---make box location more accurate 1---


if(presence==1 )
%--------------beginning of box code---------
Box=zeros(1,Area);



    %---start-check if box fits in picture---
   if HorizontalCenter-HorizontalParameter<1 
       HorizontalCenter=HorizontalParameter+1; end%what if parameters of box are out of range? default to a box hugging
    %the side of the frame
    if HorizontalCenter+HorizontalParameter>HorizontalLength
        HorizontalCenter=HorizontalLength-HorizontalParameter; end
        if VerticalCenter-VerticalParameter<1
            VerticalCenter=VerticalParameter+1;end
        if VerticalCenter+VerticalParameter>VerticalLength
            VerticalCenter=VerticalLength-VerticalParameter;end
    %---end-check if box fits in picture
    
    %---start--check if box is valid...and if car is actually present
    presenceTestTwo=0;
    for kimchi=HorizontalCenter-HorizontalParameter:HorizontalCenter+HorizontalParameter%horizontal 
   for kimmy=VerticalCenter-VerticalParameter:VerticalCenter+VerticalParameter%vertical
if (johnny(1,VerticalLength*(kimchi-1)+ kimmy)>3*pi/4 & tobes(1,VerticalLength*(kimchi-1)+ kimmy)~=0)
presenceTestTwo=presenceTestTwo+1;

   end
   end
    end
     %---end--check if box is valid...and if car is actually present
    Isthereabox=0;
    if presenceTestTwo>size(CarVectors(1,:),2)/2%if # car vectors in box is not even 1/5 of total car vectors, we can assume that a car isn't in the picture
        Isthereabox=1;
    end
    %make vertical sides of box
for kimchi=HorizontalCenter-HorizontalParameter:HorizontalParameter*2:HorizontalCenter+HorizontalParameter%horizontal 
   for kimmy=VerticalCenter-VerticalParameter:VerticalCenter+VerticalParameter%vertical
Box(1,VerticalLength*(kimchi-1)+ kimmy)=2;
u(1,VerticalLength*(kimchi-1)+ kimmy)=2;
v(1,VerticalLength*(kimchi-1)+ kimmy)=2;

   end
end
for kimchi=HorizontalCenter-HorizontalParameter:HorizontalCenter+HorizontalParameter%horizontal 
   for kimmy=VerticalCenter-VerticalParameter:VerticalParameter*2:VerticalCenter+VerticalParameter%vertical
Box(1,VerticalLength*(kimchi-1)+ kimmy)=2;
u(1,VerticalLength*(kimchi-1)+ kimmy)=2;
v(1,VerticalLength*(kimchi-1)+ kimmy)=2;

   end
end

%----------------end of box code--------------
testvectors=find(   Box~=0  );
end%end of statement if a box radius was found
end

quiver(x(CarVectors), y(CarVectors),u(CarVectors),v(CarVectors),0, 'color', 'g', 'linewidth', 2);
quiver(x(BackGroundVectors),y(BackGroundVectors),u(BackGroundVectors),v(BackGroundVectors),0, 'color', 'r', 'linewidth', 2);
if(presence==1 && Isthereabox==1)
quiver(x(testvectors),y(testvectors),u(testvectors),v(testvectors),0,'color','c','linewidth',2);
end
% 0 = won't autoscale to biggest arrow




%--------------------end of video(withvectors)----------------------------------------%
%-------------start construction of rose plot-----------------------------------------%





backgroundfrequency=  (johnny(find(tobes~=0 &  johnny<3*pi/4  & Just==2)));%background
carfrequency= (johnny(find(tobes~=0 & johnny>3*pi/4  & Just==2)));
backgroundfrequencysize=size(backgroundfrequency(1,:),2);
carfrequencysize=size(carfrequency(1,:),2);




hax = axes('Position', [-0.073, 0, .75, .75]);



if   backgroundfrequencysize*3>carfrequencysize || backgroundfrequencysize*3==carfrequencysize
h=rose(backgroundfrequency, 30); 
xd = get(h, 'XData') ;
yd = get(h, 'YData') ;
p = patch(xd, yd, 'r','EdgeColor',[1 1 0]) ;
hold on;
hg=rose(carfrequency,30);
xy = get(hg, 'XData') ;
yz = get(hg, 'YData') ;
pt = patch(xy, yz, 'g','EdgeColor','b') ;


hold off;
elseif backgroundfrequencysize*3<carfrequencysize
hg=rose(hax,carfrequency,30);
xy = get(hg, 'XData') ;
yz = get(hg, 'YData') ;
pt = patch(xy, yz, 'g','EdgeColor','b') ;
hold on;
h=rose(hax,backgroundfrequency, 30);
xd = get(h, 'XData') ;
yd = get(h, 'YData') ;
p = patch(xd, yd, 'r','EdgeColor',[1 1 0]) ;
hold off;
end
%---end construction of rose plot===
   A(k-countit).cdata=imcapture(d1);
  tally=0;
total=0; % 

NoOutliers=reshape(NoOutliers,[1,Area]);

joey=find(johnny>3*pi/4 & NoOutliers==1);%matrice containing index of car vectors in johnny
tally=size(joey(1,:),2);%# of car vectors

grrr=sqrt(u(1,joey).^2+v(1,joey).^2);
total=sum(grrr);

vectoraverage=total/tally; %average vector in certain direction
if size(joey(1,:),2)==0
    vectoraverage=0;
end
pixels=vectoraverage*9/10; %convert vectorlength to pixels
%window length (bottom portion of closest left car window) has 75 pixels, it is 81.3 cm.
actuallength=pixels*81.3/75; %converts from pixels to centimeters
actuallength=actuallength/2.54;%convert from centimeters to inches
actuallength=actuallength/12;%convert from inches to feet
actuallength=actuallength/5280;%convert from feet to mile
if rem(k+2-countit,2)==0
velocitytwo=actuallength*get(obj,'FrameRate')*3600;%convert from framerate units to hours;
   yy(1,k-countit)=velocitytwo;
acceleration=(velocitytwo-velocityone)*get(obj,'FrameRate')*3600;

zz(1,k-1-countit)=acceleration;

elseif rem(k+2-countit,2)==1
     velocityone=actuallength*get(obj,'FrameRate')*3600;
        yy(1,k-countit)=velocityone;
     if k==1
continue;
     end
acceleration=(velocityone-velocitytwo)*get(obj,'FrameRate')*3600;
zz(1,k-1-countit)=acceleration;


end
capturescreen
end%stop for loop
%plotvelocity=figure();
%plot(xx,yy)

%plotacceleration=figure();
%plot(xx,zz)

%moviefigure=figure();
%set(moviefigure,'Position',[scrsz(3)/16 scrsz(4)/18 scrsz(3)/0.82 scrsz(4)/1.1],'Menubar','none')
%movie(moviefigure,A,30,3,winsize)

if k>9000

triforce=figure();
scrsz = get(0,'ScreenSize');% retrieve screensize of computer
set(triforce,'Position',[scrsz(3)/18 scrsz(4)/17 scrsz(3)/0.88 scrsz(4)/1.15],'Menubar','none')
d3=figure('Position',[scrsz(3)/7 scrsz(4)/7 scrsz(3)/2 scrsz(4)/2]);%create the position and size of figure d3
winsize = get(d3,'Position');%initiate winsize, which will determine the position and size of the movie,
winsize(1:2) = [0 0]; %adjust size of window to include whole figure window
movie(triforce,A,30,3,winsize)

end




