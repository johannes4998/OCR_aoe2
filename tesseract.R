library(magrittr)
library(magick)
library(tesseract)

numbers <- tesseract(options = list(tessedit_char_whitelist ="1234567890"))
numbers1 <- tesseract(options = list(tessedit_char_whitelist ="1234567890: "))
numbers2 <- tesseract(options = list(tessedit_char_whitelist ="1234567890/"))
numbers3 <- tesseract(options = list(tessedit_char_whitelist ="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ "))



screen_shots <- list.files(pattern = "pic")

number_of_shots <- length(screen_shots)

aoe2_data <- data.frame(wood=1:number_of_shots, lumberjack=1:number_of_shots,
                        food=1:number_of_shots, farmer=1:number_of_shots,
                        gold=1:number_of_shots, gold_miner=1:number_of_shots,
                        stone=1:number_of_shots, stone_miner=1:number_of_shots,
                        villager=1:number_of_shots, pop_to_houses=1:number_of_shots,
                        idle_villager=1:number_of_shots,
                        age=1:number_of_shots,
                        time_stamp=1:number_of_shots)

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
