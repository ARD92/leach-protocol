Close all;
Clear all;

%Field Dimensions - x and y maximum (in meters)
xm=200;
ym=200;

%x and y Coordinates of the Sink
sink.x=0.5*xm;
sink.y=0.5*ym;

%Number of Nodes in the field
n=100

%Optimal Election Probability of a node to become cluster head
p=0.1;

%Energy Model (all values in Joules)
%Initial Energy
Et=50;
Eo=0.5;
ETX=50*0.000000001;         %energy for transmitting single bit
ERX=50*0.000000001;         %energy for receiving single bit
%Transmit Amplifier types
Efs=10*0.000000000001;% amplification coefficient of free-space signal
Emp=0.0013*0.000000000001; % multi-path fading signal amplification coefficient
%Data Aggregation Energy
EDA=5*0.000000001;
%maximum number of rounds
rmax=2500;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Computation of do

do=sqrt(Efs/Emp);

%Creation of the random Sensor Network
for i=1:1:n
S2(i).xd=rand(1,1)*xm;
S1(i).xd=S2(i).xd;
S3(i).xd=S2(i).xd;
XR2(i)=S1(i).xd;% array of x coordinates
XR1(i)=XR2(i);
XR3(i)=XR2(i);
S2(i).yd=rand(1,1)*ym;
S1(i).yd=S2(i).yd;
S3(i).yd=S2(i).yd;
YR2(i)=S1(i).yd;%array of y coordinates
YR1(i)=YR2(i);
YR3(i)=YR2(i);
S1(i).G=0;
S2(i).G=0;
S3(i).G=0;
S1(i).E=Eo;
S2(i).E=Eo;
S3(i).E=Eo;
    %initially there are no cluster heads only nodes
S1(i).type='N';
S2(i).type='N';
S3(i).type='N';
end
S1(n+1).xd=sink.x;
S2(n+1).xd=sink.x;
S3(n+1).xd=sink.x;
S1(n+1).yd=sink.y;
S2(n+1).yd=sink.y;
S3(n+1).yd=sink.y;

% 1st algorithm ------------------ Basic LEACH

% Counters for cluster heads (CH) and clusters in the network
countCHs1=0;
cluster1=1;

% Counters to keep track of the dead nodes in the network
flag_first_dead1=0;
flag_teenth_dead1=0;
flag_all_dead1=0;
dead1=0;
first_dead1=0;
teenth_dead1=0;
all_dead1=0;
allive1=n;

% counter for bit transmitted to Bases Station and to Cluster Heads
packets_TO_BS1=0;
packets_TO_CH1=0;

% Calculation of residual energy in the network
for r=0:1:rmax     
if(mod(r, round(1/p) )==0)  %if 1/p, ie, the total number of rounds in                       which all nodes have become cluster heads once, = r, the G=0, due to which number of clusters will be 0 too.
for i=1:1:n
S1(i).G=0;
S1(i).cl=0;
end
end
  El1(r+1)=0;
for i=1:100
    El1(r+1)=S1(i).E+El1(r+1); %El = Energy left for the round
end
Ec1(r+1)=Et-El1(r+1); %Et=total energy, Ec=Energy consumed till previous round

% Calculation of number of dead nodes in the network
dead1=0;
for i=1:1:n

if (S1(i).E<=0)
        dead1=dead1+1; 

if (dead1==1)
if(flag_first_dead1==0)
              first_dead1=r; %number of round in which the 1st node dies.
              flag_first_dead1=1;
end
end

if(dead1==0.1*n)
if(flag_teenth_dead1==0)
              teenth_dead1=r; %number of rounds in which 10 nodes die.

              flag_teenth_dead1=1;
end
end
if(dead1==n)
if(flag_all_dead1==0)
              all_dead1=r; %number of rounds in which all nodes die.
              flag_all_dead1=1;
end
end
end
if S1(i).E>0
S1(i).type='N';
end
end
STATISTICS.DEAD1(r+1)=dead1; %number of nodes which dies in r-th round
STATISTICS.ALLIVE1(r+1)=allive1-dead1;

% Selection of cluster heads
countCHs1=0;
cluster1=1;
for i=1:1:n
if(S1(i).E>0)
temp_rand(i,(r+1))=rand; 
   % rand is a keyword for an array of random numbers, which here generates a scalar random number
if ( (S1(i).G)<=0) 
if(temp_rand(i,(r+1))<= (p/(1-p*mod(r,round(1/p)))))%key
            countCHs1=countCHs1+1;
            packets_TO_BS1=packets_TO_BS1+1;
            PACKETS_TO_BS1(r+1)=packets_TO_BS1; %key
S1(i).type='C';
S1(i).G=round(1/p)-1;%key
C1(cluster1).xd=S1(i).xd; %C1 is an array of clusters
C1(cluster1).yd=S1(i).yd;
           distance=sqrt( (S1(i).xd-(S1(n+1).xd) )^2 + (S1(i).yd-(S1(n+1).yd) )^2 );
C1(cluster1).distance=distance;
C1(cluster1).id=i;
           X1(cluster1)=S1(i).xd; %X1 is the array of all the x oordinates
Y1(cluster1)=S1(i).yd; %Y1 is the array of all the y oordinates
            cluster1=cluster1+1;
% Calculation of energy dissipated
if (distance>do)
S1(i).E=S1(i).E- 1.5*( (ETX)+((EDA)*(4000)) + Emp*4000*( distance*distance*distance*distance )); 
end
if (distance<=do)
S1(i).E=S1(i).E-1.5*( (ETX)+((EDA)*(4000))  + Efs*4000*( distance * distance )); 
end
end

else
S1(i).G=S1(i).G-1;  
end
end
end
STATISTICS.COUNTCHS1(r+1)=countCHs1; 

% Association of normal nodes with cluster heads (Formation of clusters)
for i=1:1:n
if ( S1(i).type=='N' && S1(i).E>0 )
if(cluster1-1>=1)
min_dis=Inf;
min_dis_cluster=0;
max_en_cluster=0;
max_en=0;
for c=1:1:cluster1-1
           temp=min(min_dis,sqrt( (S1(i).xd-C1(c).xd)^2 + (S1(i).yd-C1(c).yd)^2 ) );
           temp1=S1(C1(c).id).E;
if((temp<do/2)&&(temp1>max_en))
max_en=temp1;
max_en_cluster=c;
end
if ( temp<min_dis )
min_dis=temp;
min_dis_cluster=c;
end
end
if(max_en_cluster~=0)
min_dis=sqrt( (S1(i).xd-C1(c).xd)^2 + (S1(i).yd-C1(c).yd)^2 );
cluster_head=max_en_cluster;
else
cluster_head=min_dis_cluster;
end

% Calculation of energy dissipated 
if (min_dis>do)
S1(i).E=S1(i).E- ( ETX*(4000) + Emp*4000*( min_dis * min_dis * min_dis * min_dis)); 
end
if (min_dis<=do)
S1(i).E=S1(i).E- ( ETX*(4000) + Efs*4000*( min_dis * min_dis)); 
end

S1(C1(cluster_head).id).E =S1(C1(cluster_head).id).E- 1.5*( (ERX)*4000 ); 

       packets_TO_CH1=packets_TO_CH1+1;

S1(i).min_dis=min_dis;
S1(i).min_dis_cluster=min_dis_cluster; 
else
min_dis=sqrt( (S1(i).xd-S1(n+1).xd)^2 + (S1(i).yd-S1(n+1).yd)^2 );
if (min_dis>do)
S1(i).E=S1(i).E- ( ETX*(4000) + Emp*4000*( min_dis * min_dis * min_dis * min_dis)); 
end
if (min_dis<=do)
S1(i).E=S1(i).E- ( ETX*(4000) + Efs*4000*( min_dis * min_dis)); 
end
       packets_TO_BS1=packets_TO_BS1+1;
end
end
end

STATISTICS.PACKETS_TO_CH1(r+1)=packets_TO_CH1;
STATISTICS.PACKETS_TO_BS1(r+1)=packets_TO_BS1;
end

%2nd Algorithm ------------- LEACH with sinkhole attack

% sinkhole node generation

S2(80).xd=0.25*xm;% X co-ordinate of the malicious node
S2(80).yd=0.25*ym;% Y co-ordinate of the malicious node
XR2(80)=S2(80).xd;
YR2(80)=S2(80).yd;
S2(80).E=10*Eo;% Initializing the node with higher energy

% Counters for cluster heads (CH) and clusters in the network
countCHs2=0;
cluster2=1;

% Counters to keep track of the dead nodes in the network
flag_first_dead2=0;
flag_teenth_dead2=0;
flag_all_dead2=0;
dead2=0;
first_dead2=0;
teenth_dead2=0;
all_dead2=0;
allive2=n;

%counter for bit transmitted to Bases Station and to Cluster Heads
packets_TO_BS2=0;
packets_TO_CH2=0;

% Calculation of residual energy in the network
for r=0:1:rmax     
if(mod(r, round(1/p) )==0)
for i=1:1:n
S2(i).G=0;
S2(i).cl=0;
end
end
  El2(r+1)=0;
for i=1:100
   El2(r+1)=S2(i).E+El2(r+1);
end
Ec2(r+1)=Et-El2(r+1);
% Calculation of number of dead nodes in the network
dead2=0;
for i=1:1:n

if (S2(i).E<=0)
        dead2=dead2+1; 

if (dead2==1)
if(flag_first_dead2==0)
              first_dead2=r;
              flag_first_dead2=1;
end
end

if(dead2==0.1*n)
if(flag_teenth_dead2==0)
              teenth_dead2=r;
              flag_teenth_dead2=1;
end
end
if(dead2==n)
if(flag_all_dead2==0)
              all_dead2=r;
              flag_all_dead2=1;
end
end
end
if S2(i).E>0
S2(i).type='N';
end
end
STATISTICS.DEAD2(r+1)=dead2;
STATISTICS.ALLIVE2(r+1)=allive2-dead2;



% Selection of cluster heads
countCHs2=0;
cluster2=1;
for i=1:1:n
if(S2(i).E>0)
% sinkhole node broadcasting as cluster head in all rounds (does not participate in cluster head selection process)
if(i==80) 
       countCHs2=countCHs2+1;
S2(i).type='C';
S2(i).G=round(1/p)-1;
C2(cluster2).xd=S2(i).xd;
C2(cluster2).yd=S2(i).yd;
       distance=sqrt( (S2(i).xd-(S2(n+1).xd) )^2 + (S2(i).yd-(S2(n+1).yd) )^2 );
C2(cluster2).distance=distance;
C2(cluster2).id=i;
       X2(cluster2)=S2(i).xd;
Y2(cluster2)=S2(i).yd;
       cluster2=cluster2+1;


elseif(S2(i).G<=0)
if(temp_rand(i,(r+1))<= (p/(1-p*mod(r,round(1/p)))))
   countCHs2=countCHs2+1;
   packets_TO_BS2=packets_TO_BS2+1;
   PACKETS_TO_BS2(r+1)=packets_TO_BS2;
S2(i).type='C';
S2(i).G=round(1/p)-1;
C2(cluster2).xd=S2(i).xd;
C2(cluster2).yd=S2(i).yd;
           distance=sqrt( (S2(i).xd-(S2(n+1).xd) )^2 + (S2(i).yd-(S2(n+1).yd) )^2 );
C2(cluster2).distance=distance;
C2(cluster2).id=i;
    X2(cluster2)=S2(i).xd;
Y2(cluster2)=S2(i).yd;
    cluster2=cluster2+1;

% Calculation of energy dissipated 
if ((distance>do))
S2(i).E=S2(i).E- 1.5*( (ETX+EDA)*(4000) + Emp*4000*( distance*distance*distance*distance )); 
end
if ((distance<=do))
S2(i).E=S2(i).E- 1.5*( (ETX+EDA)*(4000)  + Efs*4000*( distance * distance )); 
end
end

else
S2(i).G=S2(i).G-1;  
end
end
end
STATISTICS.COUNTCHS2(r+1)=countCHs2;

for i=1:1:n
if ( S2(i).type=='N' && S2(i).E>0 )
if(cluster2-1>=1)
min_dis=Inf;
min_dis_cluster=0;
max_en_cluster=0;
max_en=0;
for c=1:1:cluster2-1
           temp=min(min_dis,sqrt( (S2(i).xd-C2(c).xd)^2 + (S2(i).yd-C2(c).yd)^2 ) );
           temp1=S2(C2(c).id).E;
if((temp<do/2)&&(temp1>max_en))
max_en=temp1;
max_en_cluster=c;
end
if ( temp<min_dis )
min_dis=temp;
min_dis_cluster=c;
end
end

if(max_en_cluster~=0)
min_dis=sqrt( (S2(i).xd-C2(c).xd)^2 + (S2(i).yd-C2(c).yd)^2 );
cluster_head=max_en_cluster;
else
cluster_head=min_dis_cluster;
end

% Calculation of energy dissipated
if ((min_dis>do))
S2(i).E=S2(i).E- ( ETX*(4000) + Emp*4000*( min_dis * min_dis * min_dis * min_dis));
end
if ((min_dis<=do))
S2(i).E=S2(i).E- ( ETX*(4000) + Efs*4000*( min_dis * min_dis)); 
end
S2(C2( cluster_head).id).E =S2(C2( cluster_head).id).E- 1.5*( (ERX + EDA)*4000 ); 
     packets_TO_CH2=packets_TO_CH2+1;

S2(i).min_dis=min_dis;
S2(i).min_dis_cluster=min_dis_cluster;
else
min_dis=sqrt( (S2(i).xd-S2(n+1).xd)^2 + (S2(i).yd-S2(n+1).yd)^2 );
if ((min_dis>do))
S2(i).E=S2(i).E-( ETX*(4000) + Emp*4000*( min_dis * min_dis * min_dis * min_dis)); 
end
if ((min_dis<=do))
S2(i).E=S2(i).E-( ETX*(4000) + Efs*4000*( min_dis * min_dis)); 
end
if(i~=80) packets_TO_BS2=packets_TO_BS2+1; end
end
end
end
STATISTICS.PACKETS_TO_CH2(r+1)=packets_TO_CH2;
STATISTICS.PACKETS_TO_BS2(r+1)=packets_TO_BS2;

end

% 3rd algorithm -------------- LEACH with blackhole attack

% MALICIOUS NODES – 3,5,6,7,8,10,16,27,38,50
% Counters for cluster heads (CH) and clusters in the network
countCHs3=0;
cluster3=1;

% Counters to keep track of the dead nodes in the network
flag_first_dead3=0;
flag_teenth_dead3=0;
flag_all_dead3=0;
dead3=0;
first_dead3=0;
teenth_dead3=0;
all_dead3=0;
allive3=n;

%counter for bit transmitted to Bases Station and to Cluster Heads
packets_TO_BS3=0;
packets_TO_CH3=0;

% Calculation of residual energy in the network
for r=0:1:rmax     
if(mod(r, round(1/p) )==0)
for i=1:1:n
S3(i).G=0;
S3(i).cl=0;
end
end
  El3(r+1)=0;
for i=1:100
   El3(r+1)=S3(i).E+El3(r+1);
end
Ec3(r+1)=Et-El3(r+1);


% Calculation of number of dead nodes in the network
dead3=0;
for i=1:1:n

if (S3(i).E<=0)
        dead3=dead3+1; 

if (dead3==1)
if(flag_first_dead3==0)
              first_dead3=r;
              flag_first_dead3=1;
end
end

if(dead3==0.1*n)
if(flag_teenth_dead3==0)
              teenth_dead3=r;
              flag_teenth_dead3=1;
end
end
if(dead3==n)
if(flag_all_dead3==0)
              all_dead3=r;
              flag_all_dead3=1;
end
end
end
if S3(i).E>0
S3(i).type='N';
end
end
STATISTICS.DEAD3(r+1)=dead3;
STATISTICS.ALLIVE3(r+1)=allive3-dead3;

% Selection of cluster heads
countCHs3=0;
cluster3=1;
for i=1:1:n
if(S3(i).E>0)
if ( (S3(i).G)<=0) 
if(temp_rand(i,(r+1))<= (p/(1-p*mod(r,round(1/p)))))
            countCHs3=countCHs3+1;
% Do not transmit (increment number of packets) if node is malicious 
if((i~=3)&&(i~=5)&&(i~=6)&&(i~=7) &&(i~=8)&&(i~=10)&&(i~=16)&&(i~=27) &&(i~=38)&&(i~=50))
            packets_TO_BS3=packets_TO_BS3+1;
            PACKETS_TO_BS3(r+1)=packets_TO_BS3;
end
S3(i).type='C';
S3(i).G=round(1/p)-1;
C3(cluster3).xd=S3(i).xd;
C3(cluster3).yd=S3(i).yd;
           distance=sqrt( (S3(i).xd-(S3(n+1).xd) )^2 + (S3(i).yd-(S3(n+1).yd) )^2 );
C3(cluster3).distance=distance;
C3(cluster3).id=i;
            X3(cluster3)=S3(i).xd;
Y3(cluster3)=S3(i).yd;
            cluster3=cluster3+1;
% Calculate the energy dissipated (only for non-malicious nodes)
if ((distance>do) &&(i~=3)&&(i~=5)&&(i~=6)&&(i~=7) &&(i~=8)&&(i~=10)&&(i~=3)&&(i~=65)&&(i~=16)&&(i~=37) &&(i~=38)&&(i~=50))
S3(i).E=S3(i).E- 1.5*( (ETX+EDA)*(4000) + Emp*4000*( distance*distance*distance*distance )); 
end
            if ((distance<=do) &&(i~=3)&&(i~=5)&&(i~=6)&&(i~=7) &&(i~=8)&&(i~=10)&&(i~=3)&&(i~=65)&&(i~=16)&&(i~=27) &&(i~=38)&&(i~=50))
S3(i).E=S3(i).E- 1.5*( (ETX+EDA)*(4000)  + Efs*4000*( distance * distance )); 
end
end

else
S3(i).G=S3(i).G-1;  
end
end
end
STATISTICS.COUNTCHS3(r+1)=countCHs3;

% Association of normal nodes with cluster heads (Formation of clusters)
for i=1:1:n
if ( S3(i).type=='N' && S3(i).E>0 )
if(cluster3-1>=1)
min_dis=Inf;
min_dis_cluster=0;
max_en_cluster=0;
max_en=0;
for c=1:1:cluster3-1
           temp=min(min_dis,sqrt( (S3(i).xd-C3(c).xd)^2 + (S3(i).yd-C3(c).yd)^2 ) );
           temp1=S3(C3(c).id).E;
if((temp<do/2)&&(temp1>max_en))
max_en=temp1;
max_en_cluster=c;
end
if ( temp<min_dis )
min_dis=temp;
min_dis_cluster=c;
x3(c)=x3(c)+1;
end
end

if(max_en_cluster~=0)
min_dis=sqrt( (S3(i).xd-C3(c).xd)^2 + (S3(i).yd-C3(c).yd)^2 );
cluster_head=max_en_cluster;
else
cluster_head=min_dis_cluster;
end

% Calculate the energy dissipated (only for non-malicious nodes)
       if((i~=3)&&(i~=5)&&(i~=6)&&(i~=7) &&(i~=8)&&(i~=10)&&(i~=3)&&(i~=65)&&(i~=16)&&(i~=27) &&(i~=38)&&(i~=50))
if ((min_dis>do))
S3(i).E=S3(i).E- ( ETX*(4000) + Emp*4000*( min_dis * min_dis * min_dis * min_dis));
end
if ((min_dis<=do))
S3(i).E=S3(i).E- ( ETX*(4000) + Efs*4000*( min_dis * min_dis)); 
end
end
S3(C3(cluster_head).id).E =S3(C3(cluster_head).id).E- 1.5*( (ERX + EDA)*4000 ); 
            packets_TO_CH3=packets_TO_CH3+1;

S3(i).min_dis=min_dis;
S3(i).min_dis_cluster=min_dis_cluster;
else
min_dis=sqrt( (S3(i).xd-S3(n+1).xd)^2 + (S3(i).yd-S3(n+1).yd)^2 );
% Calculate the energy dissipated (only for non-malicious nodes)
    if((i~=3)&&(i~=5)&&(i~=6)&&(i~=7) &&(i~=8)&&(i~=10)&&(i~=3)&&(i~=65)&&(i~=16)&&(i~=27) &&(i~=38)&&(i~=50)) 
if ((min_dis>do))
S3(i).E=S3(i).E-( ETX*(4000) + Emp*4000*( min_dis * min_dis * min_dis * min_dis)); 
end
if ((min_dis<=do))
S3(i).E=S3(i).E-( ETX*(4000) + Efs*4000*( min_dis * min_dis)); 
end
            packets_TO_BS3=packets_TO_BS3+1;

end
end
end
end

STATISTICS.PACKETS_TO_CH3(r+1)=packets_TO_CH3;
STATISTICS.PACKETS_TO_BS3(r+1)=packets_TO_BS3;
end




%%%%%%%%%%%%%%%%%%%%%%% PLOT %%%%%%%%%%%%%%%%%%%%%%%%

r=0:2500;

figure(1)
plot(r,STATISTICS.ALLIVE1,':b',r,STATISTICS.ALLIVE2,'-.r',r,STATISTICS.ALLIVE3,'-k');
legend('without attack','with sinkhole attack','withblackhole attack');
xlabel('x(no. of rounds)');
ylabel('y(alive nodes)');
title('Nodes alive during rounds');

figure(2)
plot(r,STATISTICS.PACKETS_TO_BS1,':b',r,STATISTICS.PACKETS_TO_BS2,'-.r',r,STATISTICS.PACKETS_TO_BS3,'-k');
legend('without attack','with sinkhole attack','withblackhole attack');
xlabel('x(no. of rounds)');
ylabel('y(data transmitted)');
title('Packets sent to base station');

figure(3)
plot(r,El1,':b',r,El2,'-.r',r,El3,'-k');
legend('without attack','with sinkhole attack','withblackhole attack');
xlabel('x(no. of rounds)');
ylabel('y(residual energy )');
title('Energy left in the network ');

