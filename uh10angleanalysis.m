%---uh10---getting rid of redundant code like outlier
obj=mmreader('Trial1.avi');
a=read(obj);
frames=get(obj,'numberOfFrames');
d1=figure('PaperSize',[600 600],'visible','off');
scrsz = get(0,'ScreenSize');% retrieve screensize of computer
d3=figure('Position',[1 1 scrsz(3)/.82 scrsz(4)/1],'visible','off');%create the position and size of figure d3
winsize = get(d3,'Position');%initiate winsize, which will determine the position and size of the movie,
winsize(1:2) = [0 0]; %adjust size of window to include whole figure window
A=moviein(frames,d3,winsize);%create movie matrix A
values=0; %intiate the values variable

xx=zeros(1,frames-1);
countit=0;
for tony=1:frames-1
    xx(1,tony)=tony;
end
yy=zeros(1,frames-1);%velocity values stored here
zz=zeros(1,frames-1);%acceleration values stored here
zz(1,1)=0;

im1 = a(:,:,:,1);
Height=size(im1(:,1,1),1);
Length=size(im1(1,:,1),2);
Area=Height*Length;
x=zeros(1,Area);
y=zeros(1,Area);
for i = 1:Length
 for j= 1:Height
     x(1,(Height.*(i-1)+j ))=i;
y(1,(Height.*(i-1)+j ))= j;
end
end
anglebisector=-0.9435*pi;
InitialAngleRange=pi/4;
accelerationcounter=0;

if anglebisector<-pi+InitialAngleRange
    anglebisector=anglebisector+2*pi;
end
for k=44 %loop
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

set(d1,'Position',[scrsz(3)/3.5 scrsz(4)/3 scrsz(3)/1.75 scrsz(4)/1.75],'Menubar','none');

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
u=reshape(u,[1,Area]);
v=reshape(v,[1,Area]);

arrowlength=sqrt(u.^2+v.^2);
 %a matrice, size based on #of non-zero arrows, indices contains the indice number of non-zero indices 
arrowlengthsquareit=arrowlength(arrowlength~=0); %returns the vector's magnitude of non-zero indices
findthreshold=sort(arrowlengthsquareit,'descend');%sort from BIGGEST, vector magnitudes
threshold=findthreshold(1,floor(size(arrowlengthsquareit(1,:),2)/2));%take the value at the 50th percentile for all possible vectors, and sets it as THRESHOLD

validarrows=arrowlength>threshold;
AverageMagnitude=mean(arrowlength(validarrows));

s=std(validarrows);

johnny=atan2(-v,u);%contains the angle of the vectors from the interval [-pi, pi]
%johnny contains the angle of the vectors, but the interval can be changed.
  %initialize variable desiredangle with value of 1.05pi. Used to determine angle direction that will be measured

if  anglebisector<-pi+InitialAngleRange || anglebisector>pi-InitialAngleRange % if anglebisector>7pi/4, that means values greater than 2pi will be evaluated. These values are basically
    %the first quartile(NE). to make these values evaluated, add 2pi to those values, as seen in line 200. 
    %transporse interval if necessary
    
        if anglebisector>pi-InitialAngleRange
            anglebisector=anglebisector-2*pi;
        end
        joy=find(johnny<anglebisector+InitialAngleRange);
    for yikes = 1: size(joy(1,:),2)
            johnny(1,joy(1,yikes))=johnny(1,joy(1,yikes))+2*pi; %transposes interval
        
    end
end
if anglebisector<-pi+InitialAngleRange
    anglebisector=anglebisector+2*pi;%convert angle back to higher angle
end
UpperInitialRange=anglebisector+InitialAngleRange;
LowerInitialRange=anglebisector-InitialAngleRange;
joseph=(arrowlength>threshold & johnny>LowerInitialRange & johnny<UpperInitialRange);% find indice values containing all the car vectors
alltheangles=johnny(joseph);%gets the actual angles of the car vectors
RevisedAngleRange=std(alltheangles);%get the standard deviation
CarVectors=find(arrowlength>threshold & johnny>LowerInitialRange & johnny<UpperInitialRange); %stores indices values'
BackGroundVectors=find( johnny<LowerInitialRange &arrowlength>threshold | johnny>UpperInitialRange & arrowlength>threshold);%stores indices values'

thetally=2;
   while size(CarVectors(1,:),2)+size(BackGroundVectors(1,:),2)>5000%if there are more than 5000 arrows 
    
threshold=findthreshold(1,floor(size(arrowlengthsquareit(1,:),2)/(4*(thetally-1))));%take the 75%biggest and set it as the THRESHOLD so that less arrows appear
CarVectors=find(arrowlength>threshold & johnny>LowerInitialRange & johnny<UpperInitialRange); %stores indices values'
BackGroundVectors=find(johnny<LowerInitialRange &arrowlength>threshold | johnny>UpperInitialRange & arrowlength>threshold);%stores indices values'
 thetally=thetally+2  
   end
   UpperRevisedRange=anglebisector+RevisedAngleRange;
   LowerRevisedRange=anglebisector-RevisedAngleRange;
   UpperAgainRange=anglebisector+pi/4;
   LowerAgainRange=anglebisector-pi/4;
carvectorstwo=find(arrowlength>threshold & johnny> LowerRevisedRange & johnny< UpperRevisedRange);
    carvectorsthree=find(arrowlength>threshold & johnny> LowerAgainRange & johnny< LowerRevisedRange);

    carvectorsfour=find(arrowlength>threshold & johnny> UpperRevisedRange & johnny< UpperAgainRange);


quiver(x(carvectorsfour), y(carvectorsfour),u(carvectorsfour),v(carvectorsfour),0, 'color', 'm', 'linewidth', 2);
quiver(x(carvectorsthree), y(carvectorsthree),u(carvectorsthree),v(carvectorsthree),0, 'color', 'm', 'linewidth', 2);
quiver(x(carvectorstwo), y(carvectorstwo),u(carvectorstwo),v(carvectorstwo),0, 'color', 'g', 'linewidth', 2);

%quiver(x(CarVectors), y(CarVectors),u(CarVectors),v(CarVectors),0, 'color', 'g', 'linewidth', 2);
quiver(x(BackGroundVectors),y(BackGroundVectors),u(BackGroundVectors),v(BackGroundVectors),0, 'color', 'r', 'linewidth', 2);

% 0 = won't autoscale to biggest arrow




%--------------------end of video(withvectors)----------------------------------------%
%-------------start construction of rose plot-----------------------------------------%





backgroundfrequency=  johnny(johnny<LowerRevisedRange &arrowlength>threshold &  (arrowlength-AverageMagnitude)/s<2 ...
    | johnny>UpperRevisedRange & arrowlength>threshold &  (arrowlength-AverageMagnitude)/s<2);%background
backgroundfrequencysize=size(backgroundfrequency(1,:),2);
carfrequency= johnny(arrowlength>threshold &  johnny>LowerRevisedRange & johnny<UpperRevisedRange  &  (arrowlength-AverageMagnitude)/s<2);

carfrequencysize=size(carfrequency(1,:),2);

carfrequencytwo= johnny(arrowlength>threshold &  johnny>LowerAgainRange & johnny<LowerRevisedRange  &  (arrowlength-AverageMagnitude)/s<2);

carfrequencytwosize=size(carfrequencytwo(1,:),2);


carfrequencythree= johnny(arrowlength>threshold &  johnny>UpperRevisedRange & johnny<UpperAgainRange  &  (arrowlength-AverageMagnitude)/s<2);

carfrequencythreesize=size(carfrequencythree(1,:),2);


hax = axes('Position', [-0.073, 0, .75, .75]);



if   backgroundfrequencysize*3>carfrequencysize || backgroundfrequencysize*3==carfrequencysize
h=rose(backgroundfrequency, 60); 
xd = get(h, 'XData') ;
yd = get(h, 'YData') ;
p = patch(xd, yd, 'r','EdgeColor',[1 1 0]) ;
hold on;
hg=rose(carfrequency,60);
xy = get(hg, 'XData') ;
yz = get(hg, 'YData') ;
pt = patch(xy, yz, 'g','EdgeColor','b') ;
hg=rose(carfrequencytwo,60);
xyz = get(hg, 'XData') ;
yzz = get(hg, 'YData') ;
ptt = patch(xyz, yzz, 'm','EdgeColor','m') ;
hold on;
hg=rose(carfrequencythree,60);
xyz = get(hg, 'XData') ;
yzz = get(hg, 'YData') ;
tt = patch(xyz, yzz, 'm','EdgeColor','m') ;
hold on;

hold off;
elseif backgroundfrequencysize*3<carfrequencysize
hg=rose(hax,carfrequency,60);
xy = get(hg, 'XData') ;
yz = get(hg, 'YData') ;
pt = patch(xy, yz, 'g','EdgeColor','b') ;
hold on;
h=rose(hax,backgroundfrequency, 60);
xd = get(h, 'XData') ;
yd = get(h, 'YData') ;
p = patch(xd, yd, 'r','EdgeColor',[1 1 0]) ;
hold off;
end
%---end construction of rose plot===
   A(k-countit).cdata=imcapture(d1);
   




capturescreen
end%stop for loop
%plotvelocity=figure();
%plot(xx,yy)

%plotacceleration=figure();
%plot(xx,zz)

%moviefigure=figure();
%set(moviefigure,'Position',[scrsz(3)/16 scrsz(4)/18 scrsz(3)/0.82 scrsz(4)/1.1],'Menubar','none')
%movie(moviefigure,A,60,3,winsize)


