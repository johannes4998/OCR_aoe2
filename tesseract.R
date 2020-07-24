library(magrittr)
library(magick)
library(tesseract)


library(dplyr)
library(tidyr)
library(lubridate)
library(ggplot2)


numbers <- tesseract(options = list(tessedit_char_whitelist ="1234567890"))
numbers1 <- tesseract(options = list(tessedit_char_whitelist ="1234567890: "))
numbers2 <- tesseract(options = list(tessedit_char_whitelist ="1234567890/"))
numbers3 <- tesseract(options = list(tessedit_char_whitelist ="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ "))



screen_shots <- list.files(pattern = "pic")

number_of_shots <- length(screen_shots)

screen_shots[208]
  

aoe2_data <- data.frame(wood=1:number_of_shots, lumberjack=1:number_of_shots,
                        food=1:number_of_shots, farmer=1:number_of_shots,
                        gold=1:number_of_shots, gold_miner=1:number_of_shots,
                        stone=1:number_of_shots, stone_miner=1:number_of_shots,
                        villager=1:number_of_shots, pop_to_houses=1:number_of_shots,
                        idle_villager=1:number_of_shots,
                        age=1:number_of_shots,
                        time_stamp=1:number_of_shots)
#i=10
microbenchmark::microbenchmark(
for (i in 1:number_of_shots) {
  
  test <- image_read(screen_shots[i])
  aoe2_data$wood[i] <-  as.numeric(image_crop(test,  "110x45+101+40")%>%image_threshold(type="black", threshold = "80%")%>%ocr(engine = numbers))
  aoe2_data$food[i] <-  as.numeric(image_crop(test,  "110x44+331+40")%>%image_threshold(type="black", threshold = "80%")%>%ocr(engine = numbers))
  aoe2_data$gold[i] <-  as.numeric(image_crop(test,  "110x45+561+40")%>%image_threshold(type="black", threshold = "80%")%>%ocr(engine = numbers))
  aoe2_data$stone[i] <- as.numeric(image_crop(test,  "110x43+791+40")%>%image_threshold(type="black", threshold = "80%")%>%ocr(engine = numbers))
  
  aoe2_data$lumberjack[i]   <-as.numeric(image_crop(test, "60x45+45+ 65")%>%image_threshold(type="black", threshold = "80%")%>%ocr(engine = numbers))
  aoe2_data$farmer[i]       <-as.numeric(image_crop(test, "60x45+268+65")%>%image_threshold(type="black", threshold = "80%")%>%ocr(engine = numbers))
  aoe2_data$gold_miner[i]   <-as.numeric(image_crop(test, "60x45+490+65")%>%image_threshold(type="black", threshold = "80%")%>%ocr(engine = numbers))
  aoe2_data$stone_miner[i]  <-as.numeric(image_crop(test, "60x45+720+65")%>%image_threshold(type="black", threshold = "80%")%>%ocr(engine = numbers))
  aoe2_data$villager[i] <-    as.numeric(image_crop(test, "65x45+940+65")%>%image_threshold(type="black", threshold = "80%")%>%ocr(engine = numbers))
  
  aoe2_data$pop_to_houses[i] <-image_crop(test,  "145x60+1003+33")%>%image_threshold(type="black", threshold = "80%")%>%ocr(engine = numbers2)
  
  
  aoe2_data$idle_villager[i] <- as.numeric(image_crop(test, "70x45+1210+56")%>%image_threshold(type="black", threshold = "80%")%>%ocr(engine = numbers))
  
  aoe2_data$age[i] <-        image_crop(test, "340x50+1450+35")%>%ocr(engine = numbers3)
  aoe2_data$time_stamp[i] <- image_crop(test, "160x40+1900+10")%>%image_threshold(type="black", threshold = "80%")%>%ocr(engine = numbers1)
}
, times=1)


aoe2_data2 <- aoe2_data%>%
  separate(pop_to_houses, c("pop", "houses"), sep="/")%>%
  mutate(pop=as.numeric(pop),
         houses=as.numeric(houses),
         military=pop-villager)

aoe2_data2$time_stamp2 <- as.POSIXct(strptime(aoe2_data2$time_stamp, "%H:%M:%OS"), tz="UTC")

            
ggplot(aoe2_data2)+
  geom_line(aes(time_stamp2,wood), color="brown", size=1)+
  geom_line(aes(time_stamp2,food), color="red", size=1)+
  geom_line(aes(time_stamp2,gold), color="gold", size=1)+
  geom_line(aes(time_stamp2,stone), color="black", size=1)

ggplot(aoe2_data2)+
  geom_line(aes(time_stamp2,lumberjack), color="brown", size=1)+
  geom_line(aes(time_stamp2,farmer), color="red", size=1)+
  geom_line(aes(time_stamp2,gold_miner), color="gold", size=1)+
  geom_line(aes(time_stamp2,stone_miner), color="black", size=1)

library(ggnewscale)
ggplot(aoe2_data2)+
  geom_line(aes(time_stamp2,villager, color=age), size=2,show.legend = F)+
  geom_line(aes(time_stamp2,military), color="brown", size=1)+
  geom_step(data=bo, aes(time, villager))+
  new_scale_color() +
  geom_step(data=bo2, aes(time, military))+
  geom_vline(data = bo_benchmarks, aes(xintercept=time_stamp, color=grade2),show.legend = F)+
  geom_text(data = bo_benchmarks, aes(x = time_stamp, y=0,label=grade, color=grade2),show.legend = F)+
  scale_colour_gradient(low="green",high = "red")

ggplot(aoe2_data2)+
  geom_line(aes(time_stamp2,idle_villager), color="brown", size=1)


aoe2_data2%>%
  group_by(villager)%>%
  slice(1)%>%
  left_join(bo, by="villager")%>%
  mutate(diff_time=time_stamp2-time)%>%
  ggplot()+
  geom_line(aes(time_stamp2,diff_time))

aoe2_data%>%
  select(food)%>%
  mutate(gather=ifelse(food-lag(food, default = 0)>0,food-lag(food, default = 0),0))%>%
  View

aoe2_data%>%
    select(wood)%>%
    mutate(gather=ifelse(wood-lag(wood, default = 0)>0,wood-lag(wood, default = 0),0))%>%
    summarise(gather=sum(gather))
  View

  aoe2_data2%>%
    select(gold)%>%
    mutate(gather=ifelse(gold-lag(gold, default = 0)>0,gold-lag(gold, default = 0),0))%>%
    summarise(gather=sum(gather))
  View
  
max(aoe2_data$villager, na.rm = T)