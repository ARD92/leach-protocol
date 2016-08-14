# leach-protocol

LEACH is one of the protocols in the clustering technique hierarchical routing protocols that can be used for minimizing the
energy consumed in collecting and disseminating data packets. LEACH was proposed for the reduction of the power consumption. 
Leach involves the data aggregation process which combines the original data into a smaller sized data. This aggregation 
takes place at the cluster head of each cluster which is elected randomly for each round. The aggregated data is then sent to
the base station. 

LEACH has many descendent protocols of which B-LEACH called as balanced leach where the steady phase remains the same
and the setup phase is modified and multihop LEACH where Transmission of data from cluster head to base 
station takes place in multiple hops have been considered.

LEACH is susceptible to many attacks of which Blackhole attack 
where the compromised nodes result in dropping of packets and Sinkhole attack where the attacker attracts all the traffic in 
the area and corrupts the data. In this report, LEACH protocol and its variations namely B-LEACH and multihop LEACH, the 
effect of Blackhole and Sinkhole attack on the Basic LEACH has been compared, analyzed and simulated.
