library(dplyr)
library(ggplot2)

library(ggnewscale)

aoe2_data <- readRDS("aoe2_data.rds")


aoe2_data2 <- aoe2_data%>%
  separate(pop_to_houses, c("pop", "houses"), sep="/")%>%
  mutate(pop=as.numeric(pop),
         houses=as.numeric(houses),
         military=pop-villager)

# If you want to account for fishing ships and trad carts/cog. Then the sum ressource_vills is bigger than villager. 
# You can than assume that in early game its fish and late game trade carts.

aoe2_data2$time_stamp2 <- as.POSIXct(strptime(aoe2_data2$time_stamp, "%H:%M:%OS"), tz="UTC")
#Ressources in Bank
ggplot(aoe2_data2)+
  geom_line(aes(time_stamp2,wood), color="brown", size=1)+
  geom_line(aes(time_stamp2,food), color="red", size=1)+
  geom_line(aes(time_stamp2,gold), color="gold", size=1)+
  geom_line(aes(time_stamp2,stone), color="black", size=1)

# Worker distribution
# Here you can see that it still not 100% accurate
ggplot(aoe2_data2)+
  geom_line(aes(time_stamp2,lumberjack), color="brown", size=1)+
  geom_line(aes(time_stamp2,farmer), color="red", size=1)+
  geom_line(aes(time_stamp2,gold_miner), color="gold", size=1)+
  geom_line(aes(time_stamp2,stone_miner), color="black", size=1)

#Villager and Military production by age----
ggplot(aoe2_data2)+
  geom_line(aes(time_stamp2,villager, color=age), size=2,show.legend = F)+
  geom_line(aes(time_stamp2,military, color=age), size=1)

#Build order comparison-----
time_stamp <- as.POSIXct(as_date(hms(c("00:08:00","00:08:10","00:08:20","00:08:35","00:09:00","00:09:30",
                                       "00:13:30","00:13:45","00:14:00","00:14:20","00:14:50","00:15:30",
                                       "00:16:30","00:17:00","00:17:30","00:18:00","00:18:40","00:19:30")),origin=substr(as.character(aoe2_data2$time_stamp2[100]),1,10)), tz="CEST")
bo_benchmarks <- data.frame(build_order=c(rep("pop_22+feudal",6),rep("scouts_6",6),rep("castle",6)),
                            time_stamp= time_stamp,
                            grade=rep(c("A+", "A", "B", "C", "D", "E"),3),
                            grade2=rep(1:6),3)

n_vill <- c(4:21,21,21,22:33,33)
time_stamps <- cumsum(c(rep(25,18),25,130,rep(25,12),75))
bo <- data.frame(villager=n_vill, 
                 #military=n_mil,
                 time = as.POSIXct(as_date(seconds_to_period(time_stamps),origin=substr(as.character(aoe2_data2$time_stamp2[100]),1,10)), tz="CEST"))

n_mil <- c(1,1,1,1,1,seq(2,5,1),5)
time_stamps2 <- cumsum(c(0,0,0,605,50,rep(30,5)))
bo2 <-data.frame(#villager=n_vill, 
  military=n_mil,
  time = as.POSIXct(as_date(seconds_to_period(time_stamps2),origin=substr(as.character(aoe2_data2$time_stamp2[100]),1,10)), tz="CEST"))


ggplot(aoe2_data2)+
  geom_line(aes(time_stamp2,villager, color=age), size=2,show.legend = F)+
  geom_line(aes(time_stamp2,military, color=age), size=1,show.legend = F)+
  geom_step(data=bo, aes(time, villager))+
  new_scale_color() +
  geom_step(data=bo2, aes(time, military))+
  geom_vline(data = bo_benchmarks, aes(xintercept=time_stamp, color=grade2),show.legend = F)+
  geom_text(data = bo_benchmarks, aes(x = time_stamp, y=0,label=grade, color=grade2),show.legend = F)+
  scale_colour_gradient(low="green",high = "red")

#tc idle time----
aoe2_data2%>%
  group_by(villager)%>%
  slice(1)%>%
  left_join(bo%>%
              group_by(villager)%>%
              slice(1), by="villager")%>%
  mutate(diff_time_sec=time_stamp2-time)%>%
  ggplot()+
  geom_line(aes(time_stamp2,diff_time_sec))
  
  
#idle villager----
ggplot(aoe2_data2)+
  geom_line(aes(time_stamp2,idle_villager), color="#D8D800", size=1)

#food gather rate----
aoe2_data2%>%
  select(food, time_stamp2)%>%
  mutate(gather=ifelse(food-lag(food, default = 0)>0,food-lag(food, default = 0),0))%>%
  ggplot()+
  geom_line(aes(time_stamp2, gather))
