clear
xm=200;
ym=200;
sink.x=0.5*xm;
sink.y=0.5*ym;
n=100
 
p=0.1;
 
Eo=0.5;
%Eelec=Etx=Erx %Eelec is the energy to transmit one bit of a message
ETX=50*0.000000001; %key 10^-9
ERX=50*0.000000001;
%Transmit Amplifier types
Efs=10*0.000000000001;% 10^-12 ---> amplification coefficient of free-space signal
Emp=0.0013*0.000000000001; % multi-path fading signal amplification coefficient
%Data Aggregation Energy
EDA=5*0.000000001;
%their values depend on the circuit amplifier model, we are using the first
%order radio model
rmax=2500
 
do=sqrt(Efs/Emp);
do
Et=50;
 
for i=1:1:n
    S2(i).xd=rand(1,1)*xm;
    S1(i).xd=S2(i).xd;
    XR2(i)=S1(i).xd;% array of x coordinates
    XR1(i)=XR2(i);
    S2(i).yd=rand(1,1)*ym;
    S1(i).yd=S2(i).yd;
    YR2(i)=S1(i).yd;%array of y coordinates
    YR1(i)=YR2(i);
    S1(i).G=0;
    S2(i).G=0;
    S1(i).E=Eo;
    S2(i).E=Eo;
    %initially there are no cluster heads only nodes
    S1(i).type='N';
    S2(i).type='N';
end
 
S1(n+1).xd=sink.x;
S2(n+1).xd=sink.x;
S1(n+1).yd=sink.y;
S2(n+1).yd=sink.y;

for i=1:1:n+1
    for j=1:1:n+1
        cost(i,j)=sqrt( (S1(i).xd-(S1(j).xd) )^2 + (S1(i).yd-(S1(j).yd) )^2 );
           
    end
end    
src=n+1;
for i=1:1:n+1
    dist(i)=cost(src,i);
end
    


for i=1:1:n+1
    min_hd=dist(i);
    f=1;
    l=1;%%
    shortpath(i,f)=i;
    i1=i; %temporary sorce
    while( i1~=(n+1))  
       for j=1:1:n+1
           len=sqrt( (S1(i1).xd-(S1(j).xd) )^2 + (S1(i1).yd-(S1(j).yd) )^2 );
           if((len<do)&&(j~=i))   %% hop distance limit = 20
             if(j==(n+1)) l=j;  break; 
             elseif((dist(j)<min_hd))
                    min_hd=dist(j); l=j;     
             end
           end 
       end
       f=f+1; shortpath(i,f)=l;
       i1=l;
    end 
end

shortpath

%1st algorithm

countCHs1=0;
cluster1=1;
flag_first_dead1=0;
flag_teenth_dead1=0;
flag_all_dead1=0;
 
dead1=0;
first_dead1=0;
teenth_dead1=0;
all_dead1=0;
 
allive1=n;
%counter for bit transmitted to Bases Station and to Cluster Heads
packets_TO_BS1=0;
packets_TO_CH1=0;
 
for r=0:1:rmax     
    r %no. of rounds
 
  if(mod(r, round(1/p) )==0)  %if 1/p, ie, the total number of rounds in                       which       all nodes have become cluster heads once, = r, the G=0, due to which number of       clusters will be 0 too.
    for i=1:1:n
        S1(i).G=0;
        S1(i).cl=0;
    end
  end
  El1(r+1)=0;
  for i=1:100
    El1(r+1)=S1(i).E+El1(r+1);%El = Energy left for the round
  end
Ec1(r+1)=Et-El1(r+1); %Et=total energy, Ec=Energy consumed till previous round
 
dead1=0;
for i=1:1:n
 
    if (S1(i).E<=0)
        dead1=dead1+1; 
 
        if (dead1==1)
           if(flag_first_dead1==0)
              first_dead1=r;%the number of round in which the first node dies.
              flag_first_dead1=1;
           end
        end
 
        if(dead1==0.1*n)
           if(flag_teenth_dead1==0)
              teenth_dead1=r;
              flag_teenth_dead1=1;
           end
        end
        if(dead1==n)
           if(flag_all_dead1==0)
              all_dead1=r;
              flag_all_dead1=1;
           end
        end
    end
    if S1(i).E>0
        S1(i).type='N';
    end
end
STATISTICS.DEAD1(r+1)=dead1;%number of nodes which dies in r-th round
STATISTICS.ALLIVE1(r+1)=allive1-dead1;
 
 
 
countCHs1=0;
cluster1=1;
for i=1:1:n
 if(S1(i).E>0)
   temp_rand=rand; 
   % rand is a keyword for an array of random numbers, which here generates
   % a scalar random number
   if ( (S1(i).G)<=0) 
 
        if(temp_rand<= (p/(1-p*mod(r,round(1/p)))))%key
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
 
           distance; %key
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
STATISTICS.COUNTCHS1(r+1)=countCHs1; %lower bound, minimum value
 
for c=1:1:cluster1-1
    x1(c)=0;
end
y1=0; %key
z1=0; %key
for i=1:1:n
   if ( S1(i).type=='N' && S1(i).E>0 )
     if(cluster1-1>=1)%checks for more than 1 cluster
       min_dis=Inf;%infinity signifies not reachable
       min_dis_cluster=0;
       for c=1:1:cluster1-1%finding minimum distances between clusters and heads..... fee
           temp=min(min_dis,sqrt( (S1(i).xd-C1(c).xd)^2 + (S1(i).yd-C1(c).yd)^2 ) );
           if ( temp<min_dis )%re-checking minimum distance and then assigning
               min_dis=temp;
               min_dis_cluster=c;
               x1(c)=x1(c)+1;
           end
       end
 
            min_dis;
            if (min_dis>do)
                S1(i).E=S1(i).E- ( ETX*(4000) + Emp*4000*( min_dis * min_dis * min_dis * min_dis)); 
            end
            if (min_dis<=do)
                S1(i).E=S1(i).E- ( ETX*(4000) + Efs*4000*( min_dis * min_dis)); 
            end
 
            S1(C1(min_dis_cluster).id).E =S1(C1(min_dis_cluster).id).E- 1.5*( (ERX)*4000 ); 
             
            packets_TO_CH1=packets_TO_CH1+1;
 
       S1(i).min_dis=min_dis;
       S1(i).min_dis_cluster=min_dis_cluster; 
   else
          y1=y1+1; %key
          min_dis=sqrt( (S1(i).xd-S1(n+1).xd)^2 + (S1(i).yd-S1(n+1).yd)^2 );
            if (min_dis>do)
                S1(i).E=S1(i).E- ( ETX*(4000) + Emp*4000*( min_dis * min_dis * min_dis * min_dis)); %packet size=4000
            end
            if (min_dis<=do)
                S1(i).E=S1(i).E- ( ETX*(4000) + Efs*4000*( min_dis * min_dis)); 
            end
            packets_TO_BS1=packets_TO_BS1+1;
    end
  end
end
if countCHs1~=0 % countCHs!=0
   u1=(n-y1)/countCHs1;
 for c=1:1:cluster1-1
    z1=(x1(c)-u1)*(x1(c)-u1)+z1;
 end
 LBF1(r+1)=z1/countCHs1;%key
else  LBF1(r+1)=0;%key
end
STATISTICS.PACKETS_TO_CH1(r+1)=packets_TO_CH1;
STATISTICS.PACKETS_TO_BS1(r+1)=packets_TO_BS1;
end
 
 
 
%2nd Algorithm
 
countCHs2=0;
cluster2=1;
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
 
for r=0:1:rmax     
    r
 
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
 
countCHs2=0;
cluster2=1;
for i=1:1:n
 if(S2(i).E>0)
   temp_rand=rand;     
   if ( (S2(i).G)<=0) 
 
        if(temp_rand<= (p/(1-p*mod(r,round(1/p)))))
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
 
           distance;
            if ((distance>do))
                d=1;
                S2(shortpath(i,d)).E=S2(shortpath(i,d)).E- 1.5*( (ETX)+((EDA)*(4000))  + Efs*4000*( distance * distance ));
               for d=2:1:3
                   if(shortpath(i,(d))==0) break; end
                   S2(shortpath(i,d)).E=S2(shortpath(i,d)).E- 3*( (ETX)*(4000)  + Efs*4000*( distance * distance )); 
               end

            end
            if ((distance<=do))
                S2(i).E=S2(i).E- 1.5*( (ETX)+((EDA)*(4000))  + Efs*4000*( distance * distance )); 
            end
        end     
 
   else
    S2(i).G=S2(i).G-1;  
   end
 end 
end
STATISTICS.COUNTCHS2(r+1)=countCHs2;
 
for c=1:1:cluster2-1
    x2(c)=0;
end
y2=0;
z2=0;
for i=1:1:n
   if ( S2(i).type=='N' && S2(i).E>0 )
     if(cluster2-1>=1)
       min_dis=Inf;%sqrt( (S2(i).xd-S2(n+1).xd)^2 + (S2(i).yd-S2(n+1).yd)^2 );%diff (instead of min_dis=inf;)
       min_dis_cluster=0;
       for c=1:1:cluster2-1
           temp=min(min_dis,sqrt( (S2(i).xd-C2(c).xd)^2 + (S2(i).yd-C2(c).yd)^2 ) );
           if ( temp<min_dis )
               min_dis=temp;
               min_dis_cluster=c;
               x2(c)=x2(c)+1;
           end
       end
 
       min_dis;
            if ((min_dis>do))
                S2(i).E=S2(i).E- ( ETX*(4000) + Emp*4000*( min_dis * min_dis * min_dis * min_dis));
            end
            if ((min_dis<=do))
                S2(i).E=S2(i).E- ( ETX*(4000) + Efs*4000*( min_dis * min_dis)); 
            end
          
            S2(C2(min_dis_cluster).id).E =S2(C2(min_dis_cluster).id).E- 1.5*( (ERX + EDA)*4000 ); 
            packets_TO_CH2=packets_TO_CH2+1;
            
        S2(i).min_dis=min_dis;
       S2(i).min_dis_cluster=min_dis_cluster;
   else
          y2=y2+1;
          min_dis=sqrt( (S2(i).xd-S2(n+1).xd)^2 + (S2(i).yd-S2(n+1).yd)^2 );
            if ((min_dis>do))
                d=1;
                S2(shortpath(i,d)).E=S2(shortpath(i,d)).E- 1.5*( (ETX+EDA)*(4000)  + Efs*4000*( distance * distance ));
                for d=2:1:3
                   if(shortpath(i,(d))==0) break; end
                   S2(shortpath(i,d)).E=S2(shortpath(i,d)).E- 3*( (ETX)*(4000)  + Efs*4000*( distance * distance )); 
               end
            end
            if ((min_dis<=do))
                S2(i).E=S2(i).E-( ETX*(4000) + Efs*4000*( min_dis * min_dis)); 
            end
            packets_TO_BS2=packets_TO_BS2+1;
    
         
     end
  end
end
if countCHs2~=0
   u2=(n-y2)/countCHs2;
 for c=1:1:cluster2-1
    z2=(x2(c)-u2)*(x2(c)-u2)+z2;
 end
 LBF2(r+1)=z2/countCHs2;
else  LBF2(r+1)=0;
end
STATISTICS.PACKETS_TO_CH2(r+1)=packets_TO_CH2;
STATISTICS.PACKETS_TO_BS2(r+1)=packets_TO_BS2;
end
 
r=0:2500;
figure
plot(r,STATISTICS.ALLIVE1,':b',r,STATISTICS.ALLIVE2,'-r');
legend('with attack','without attack');
xlabel('x(no. of rounds)');
ylabel('y(alive nodes)');
title('\bf ');
figure
plot(r,STATISTICS.PACKETS_TO_BS1,':b',r,STATISTICS.PACKETS_TO_BS2,'-r');
legend('with attack','without attack');
xlabel('x(no. of rounds)');
ylabel('y(data transmitted)');
title('\bf');
r=0:2500;
figure
plot(r,El1,':b',r,El2,'-r');
legend('with attack','without attack');
xlabel('x(no. of rounds)');
ylabel('y(energy consumption)');
title('\bf ');
r=0:60:2500;
figure
plot(r,STATISTICS.COUNTCHS1(r+1),':b',r,STATISTICS.COUNTCHS2(r+1),'-r');
legend('with attack','without attack');
xlabel('x(no. of rounds)');
ylabel('y(count of CH)');
title('');
r=0:60:2500;
figure
plot(r,LBF1(r+1),':b',r,LBF2(r+1),'-r');
legend('with attack','without attack');
xlabel('x(no. of rounds)');
ylabel('y(balance)');
title('\bf');
 



